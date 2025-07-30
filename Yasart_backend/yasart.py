from fastapi import FastAPI, HTTPException, Path
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime
from decimal import Decimal
import psycopg2
from pymodbus.client import ModbusSerialClient
from pymodbus.exceptions import ModbusIOException

app = FastAPI()

# ---------- CORS for Flutter frontend ----------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------- PostgreSQL Database Connection ----------
conn = psycopg2.connect(
    dbname="yasart_scada",
    user="postgres",
    password="123456789",
    host="127.0.0.1",
    port="5432"
)

# ---------- Data Models ----------
class LoginData(BaseModel):
    username: str
    password: str

class UserCreate(BaseModel):
    username: str
    password: str
    role: str
    pressure_transducer_id: str | None = None

class PumpUpdate(BaseModel):
    pump_id: int
    is_on: bool

class ModbusRequest(BaseModel):
    method: str = "rtu"
    com_port: str = "COM4"
    baudrate: int = 9600
    unit: int
    address: int
    value: int | None = None
    write: bool = False

# ---------- User Logic ----------
def check_user_exists(username: str):
    with conn.cursor() as cur:
        cur.execute("SELECT 1 FROM users WHERE username = %s", (username,))
        return cur.fetchone() is not None

@app.post("/login")
def login(data: LoginData):
    with conn.cursor() as cur:
        cur.execute("SELECT password, role FROM users WHERE username = %s", (data.username,))
        result = cur.fetchone()
    if result and data.password == result[0]:
        return {"role": result[1], "username": data.username}
    raise HTTPException(status_code=401, detail="Invalid username or password")

@app.post("/users/create")
def create_user(user: UserCreate):
    if user.role.lower() not in ["admin", "operator", "viewer"]:
        raise HTTPException(status_code=400, detail="Invalid role")
    if check_user_exists(user.username):
        raise HTTPException(status_code=400, detail="User already exists")

    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO users (username, password, role, pressure_transducer_id) VALUES (%s, %s, %s, %s)",
            (user.username, user.password, user.role.lower(), user.pressure_transducer_id)
        )
    conn.commit()
    return {"status": "User created successfully"}

# ---------- Billing Logic ----------
PRESSURE_TO_FLOW_FACTOR = 10.0
SAMPLING_INTERVAL_MIN = 5
BILLING_RATE = Decimal("10.00")

@app.get("/billing/{user_id}")
def generate_bill(user_id: int = Path(..., gt=0)):
    now = datetime.now()
    start_of_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    with conn.cursor() as cur:
        cur.execute("""
            SELECT pressure, timestamp FROM pressure_logs
            WHERE user_id = %s AND timestamp >= %s
            ORDER BY timestamp ASC
        """, (user_id, start_of_month))
        logs = cur.fetchall()

    if not logs:
        raise HTTPException(status_code=404, detail="No pressure logs found for this user in current month.")

    total_liters = 0.0
    for pressure, ts in logs:
        flow_rate = pressure * PRESSURE_TO_FLOW_FACTOR
        volume = flow_rate * SAMPLING_INTERVAL_MIN
        total_liters += volume

    total_m3 = total_liters / 1000.0
    total_birr = Decimal(total_m3) * BILLING_RATE

    return {
        "user_id": user_id,
        "month": now.strftime("%B %Y"),
        "total_volume_m3": round(total_m3, 2),
        "rate_birr_per_m3": float(BILLING_RATE),
        "total_birr": round(total_birr, 2)
    }

# ---------- Modbus via Serial (COM) ----------
@app.post("/modbus")
def modbus_interface(req: ModbusRequest):
    print("Modbus request received:", req)

    if req.method.lower() != "rtu":
        raise HTTPException(status_code=400, detail="Only RTU over serial COM port is supported.")

    try:
        print(f"Connecting to {req.com_port} at {req.baudrate} baud...")

        client = ModbusSerialClient(
            port=req.com_port,
            baudrate=req.baudrate,
            timeout=1,
            stopbits=1,
            bytesize=8,
            parity='N'
        )

        if not client.connect():
            print("Connection failed.")
            raise HTTPException(status_code=500, detail=f"Failed to connect to {req.com_port}")

        print("Connected to Modbus device.")

        if req.write:
            print(f"Writing value {req.value} to address {req.address}")
            result = client.write_register(req.address, req.value, unit=req.unit)
            print("Write result:", result)
            if isinstance(result, ModbusIOException):
                raise HTTPException(status_code=500, detail="Modbus write failed.")
            return {"status": "Write successful", "address": req.address, "value": req.value}
        else:
            print(f"Reading from address {req.address}")
            result = client.read_holding_registers(req.address, 1, unit=req.unit)
            print("Read result:", result)
            if not result or not result.registers:
                raise HTTPException(status_code=404, detail="Failed to read from Modbus register.")
            return {"address": req.address, "value": result.registers[0]}
    except Exception as e:
        print("Unexpected error:", e)
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        client.close()
        print("Connection closed.")

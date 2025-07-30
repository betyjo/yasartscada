from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from pymodbus.client import ModbusSerialClient
from pymodbus.exceptions import ModbusException
import threading
import time

app = FastAPI()

# Allow Flutter to talk to FastAPI
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, limit this
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize pymodbus v3.x client
client = ModbusSerialClient(
    port='COM9',          # Make sure COM8 is the Modbus master side
    baudrate=19200,
    stopbits=1,
    bytesize=8,
    parity='N',
    timeout=1
)

# Shared Modbus data store
modbus_data = {
    "SPump1Flow": 0,
    "SPump1Pres": 0
}

def poll_modbus():
    while True:
        try:
            if not client.connected:
                client.connect()

            response = client.read_holding_registers(address=14, count=2)
            if response and not response.isError():
                modbus_data["SPump1Flow"] = response.registers[0]
                modbus_data["SPump1Pres"] = response.registers[1]
                print(f"Flow: {response.registers[0]} | Pressure: {response.registers[1]}")
            else:
                print("Modbus read error")
        except ModbusException as e:
            print("Modbus Exception:", e)
        except Exception as e:
            print("General Exception:", e)
        time.sleep(1)  # poll every 1s

# Start the polling thread
threading.Thread(target=poll_modbus, daemon=True).start()

# Read-only endpoint for Flutter
@app.get("/status")
def get_status():
    return modbus_data

# Optional: write endpoint to control coils/registers
@app.post("/write")
def write_register(
    address: int = Query(..., description="Modbus register address"),
    value: int = Query(..., description="Value to write"),
    unit: int = Query(1, description="Modbus unit ID")
):
    try:
        if not client.connected:
            client.connect()
        response = client.write_register(address=address, value=value)
        if response.isError():
            return {"status": "error", "detail": str(response)}
        return {"status": "ok", "written": value}
    except Exception as e:
        return {"status": "error", "detail": str(e)}

from pymodbus.client import ModbusSerialClient

client = ModbusSerialClient(
    port='COM4',
    baudrate=9600,
    timeout=1,
    stopbits=1,
    bytesize=8,
    parity='N'
)

connected = client.connect()
print("Connected:", connected)

if connected:
    result = client.read_holding_registers(1, 1, unit=1)
    if result and result.registers:
        print("Register 1:", result.registers[0])
    else:
        print("Failed to read register.")
    client.close()
else:
    print("Could not connect to COM4.")
from pymodbus.client import ModbusSerialClient

client = ModbusSerialClient(
    method='rtu',    # specify RTU mode
    port='COM4',
    baudrate=9600,
    timeout=1,
    stopbits=1,
    bytesize=8,
    parity='N'
)

connected = client.connect()
print("Connected:", connected)

if connected:
    result = client.read_holding_registers(1, 1, unit=1)
    if result and hasattr(result, 'registers'):
        print("Register 1:", result.registers[0])
    else:
        print("Failed to read register.")
    client.close()
else:
    print("Could not connect to COM4.")
4
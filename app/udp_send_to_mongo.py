import socket
import struct
from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017")
col = client["frequency_db"]["time_vs_frequency"]

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("0.0.0.0", 25000))

print("Listening on UDP port 25000…")
while True:
    data, _ = sock.recvfrom(16)  # Waits for exactly 16 bytes (2 doubles)
    t, f = struct.unpack('dd', data)
    col.insert_one({"time": t, "frequency": f})
    print(f"Inserted → time: {t:.3f}, freq: {f:.3f}")
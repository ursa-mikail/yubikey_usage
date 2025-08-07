import os
import base64
import secrets
import json
import random

# === CONFIG ===
N = 5       # Number of keys to generate (key1 to keyN)
M = 12      # Number of characters in each key

# === FUNCTIONS ===

def generate_key_chars(length=M):
    raw = base64.b64encode(os.urandom(48)).decode('utf-8')
    filtered = ''.join(c for c in raw if c.isalnum())
    return filtered[:length]

def generate_hex_bytes(num_bytes):
    return secrets.token_hex(num_bytes)

def generate_puk():
    return f"{random.randint(0, 99999999):08d}"

# === OUTPUT STRUCTURE ===

key_pins = {
    f"key{i+1}": generate_key_chars() for i in range(N)
}
key_pins.update({
    "lock_code": generate_hex_bytes(16),
    "piv_mgmt_key": generate_hex_bytes(32),
    "piv_puk": generate_puk()
})

# === OUTPUT ===

print(json.dumps(key_pins, indent=2))

"""
{
  "key1": "yCUeAoaJBhyZ",
  "key2": "g33IoCd1SRDK",
  "key3": "iI8XaKEZWZ8d",
  "key4": "9WyPTupsGMNM",
  "key5": "roaEF4K10Vdg",
  "lock_code": "3143db65bba22cda37b43086c71572b4",
  "piv_mgmt_key": "dc58d4d63318a4acc4e1858f0af8242fc2a07f64469dacf5580724ddc78cd0d4",
  "piv_puk": "48013034"
}
"""

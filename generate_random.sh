#!/bin/bash

# === CONFIG ===
N=5        # Number of keys to generate (key1 to keyN)
M=12       # Number of characters in each key

# === FUNCTIONS ===

generate_key_chars() {
  openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | head -c "$M"
}

generate_hex_bytes() {
  local num_bytes=$1
  head -c "$num_bytes" /dev/urandom | od -An -tx1 | tr -d ' \n'
}

generate_puk() {
  printf "%08d" $(( (RANDOM * 10000 + RANDOM) % 100000000 ))
}

# === OUTPUT ===

echo "🔑 Generated Keys:"
for i in $(seq 1 "$N"); do
  key=$(generate_key_chars)
  echo "key$i: $key"
done

echo ""
echo "🔒 lock_code (16 bytes):"
generate_hex_bytes 16
echo ""

echo "🔐 piv_mgmt_key (32 bytes):"
generate_hex_bytes 32
echo ""

echo "🔢 piv_puk (8-digit number):"
generate_puk
echo ""

#🔑 Generated Keys:
#key1: IiKw77H7Tnkd
#key2: t0U2PgEOr7jV
#key3: fgFphAWeaDDa
#key4: 8MEuk1z3lOlW
#key5: bjbW1JgsDxzX

#🔒 lock_code (16 bytes):
#ec4e4608f676fec6ed59f8a5a3e9506f
#🔐 piv_mgmt_key (32 bytes):
#850d8221b7cd873d79a329d41db1531e14bd41199cdfe15363c9e575f2acf281
#🔢 piv_puk (8-digit number):
#18072954

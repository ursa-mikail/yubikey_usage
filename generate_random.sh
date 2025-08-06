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
#key1: wTN/<8B7deqr
#key2: h0P+YO*#WGP)
#key3: TfDBuM0G-5Fm
#key4: F1nizk,Q,/#7
#key5: u*0G&Vdv-xPg

#🔒 lock_code (16 bytes):
#2c8f124639d1aa42af86a060636322be
#🔐 piv_mgmt_key (32 bytes):
#230405f710032ad1fe4ecb530aad9d92eaab435d00e037423e6646f1d3fc9a82
#🔢 piv_puk (8-digit number):
#00023508

#!/bin/bash
# chmod +x generate_keyshares_and_domaincerts.sh
# ./generate_keyshares_and_domaincerts.sh

set -euo pipefail

NUM=${1:-3}       # Default: generate 3 sets
KEYSIZE=32        # Bytes per keyshare
KEYDIR="./gen_output"
mkdir -p "$KEYDIR"

PIN_FILE="$KEYDIR/pass.txt"
: > "$PIN_FILE"   # Clear old pins

generate_pin() {
  head -c 8 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 8
}

generate_keyshare() {
  local id="$1"
  local fname="$KEYDIR/keyshare_$(printf '%02d' "$id").json"
  head -c "$KEYSIZE" /dev/urandom | base64 | jq -R '{ key: . }' > "$fname"
  echo "$fname"
}

generate_self_signed_cert() {
  local id="$1"
  local cert="$KEYDIR/domain_cert_$(printf '%02d' "$id").pem"
  local key="$KEYDIR/domain_key_$(printf '%02d' "$id").key"
  openssl req -x509 -newkey rsa:2048 -nodes -keyout "$key" -out "$cert" -subj "/CN=Domain$(printf '%02d' "$id")/" -days 365
  echo "$cert"
}

main() {
  echo "🔐 Generating $NUM keyshares and domain certs..."
  for i in $(seq 0 $((NUM - 1))); do
    PIN=$(generate_pin)
    keyshare_file=$(generate_keyshare "$i")
    cert_file=$(generate_self_signed_cert "$i")
    printf "keyshare_%02d.json : %s\n" "$i" "$PIN" >> "$PIN_FILE"
    printf "domain_cert_%02d.pem : %s\n" "$i" "$PIN" >> "$PIN_FILE"
    echo "✅ Set $i complete."
  done

  echo "📄 All PINs stored in: $PIN_FILE"
  echo "📁 Files in: $KEYDIR/"
}

main


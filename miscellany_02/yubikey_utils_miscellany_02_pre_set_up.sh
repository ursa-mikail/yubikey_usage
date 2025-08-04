#!/bin/bash
# chmod +x yubikey_utils_miscellany_02_pre_set_up.sh
# ./yubikey_utils_miscellany_02_pre_set_up.sh [NUM]

set -euo pipefail

NUM=${1:-3}
BASE_DIR="../keys"
DOMAIN_DIR="$BASE_DIR/domain_keys"
SHARE_DIR="$BASE_DIR/key_shares"
PIN_FILE="$BASE_DIR/pass.txt"

mkdir -p "$DOMAIN_DIR" "$SHARE_DIR"
> "$PIN_FILE"

DOMAIN_KEY_SIZE=32
KEYSHARE_SIZE=32

gen_random_bytes() {
  local size="$1"
  head -c "$size" /dev/urandom
}

gen_random_pin() {
  head -c 8 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 8
}

for i in $(seq 0 $((NUM - 1))); do
  ID=$(printf "%02d" "$i")

  DOMAIN_PATH="$DOMAIN_DIR/domain_key_${ID}"
  KEYSHARE_PATH="$SHARE_DIR/key_share_${ID}.json"

  # domain key
  gen_random_bytes "$DOMAIN_KEY_SIZE" > "$DOMAIN_PATH"

  # key share (as json structure)
  keyshare_hex=$(gen_random_bytes "$KEYSHARE_SIZE" | xxd -p | tr -d '\n')
  echo "{\"keyshare\":\"$keyshare_hex\"}" > "$KEYSHARE_PATH"

  # PIN
  PIN=$(gen_random_pin)
  echo "keyshare_${ID} : $PIN" >> "$PIN_FILE"

  echo "✅ Prepared domain_key_${ID} and key_share_${ID}.json"
done

echo "🔐 PINs written to: $PIN_FILE"


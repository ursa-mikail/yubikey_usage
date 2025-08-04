#!/bin/bash
# chmod +x yubikey_utils_miscellany_01_pre_set_up.sh
# ./yubikey_utils_miscellany_01_pre_set_up.sh [NUM]

set -euo pipefail

# === Config ===
NUM=${1:-3}  # Default to 3 keyshares if not specified
OUTDIR="./yk_piv_objects"
mkdir -p "$OUTDIR"
PIN_FILE="$OUTDIR/pass.txt"
> "$PIN_FILE"

DOMAIN_KEY_SIZE=32  # bytes
KEYSHARE_SIZE=32    # bytes

# === Helpers ===

gen_random_bytes() {
  local size="$1"
  head -c "$size" /dev/urandom
}

gen_random_pin() {
  head -c 8 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 8
}

# === Generation Loop ===

for i in $(seq 0 $((NUM - 1))); do
  ID=$(printf "%02d" "$i")

  KEY_NAME="keyshare_${ID}"

  # Key name
  echo "$KEY_NAME" > "$OUTDIR/key_name_${ID}.txt"

  # Domain key (base64 + bin)
  DOMAIN_KEY=$(gen_random_bytes "$DOMAIN_KEY_SIZE" | base64)
  echo "$DOMAIN_KEY" > "$OUTDIR/domain_key_${ID}.b64"
  echo -n "$DOMAIN_KEY" | base64 -d > "$OUTDIR/domain_key_${ID}.bin"

  # Keyshare (base64 + bin)
  KEYSHARE=$(gen_random_bytes "$KEYSHARE_SIZE" | base64)
  echo "$KEYSHARE" > "$OUTDIR/keyshare_${ID}.b64"
  echo -n "$KEYSHARE" | base64 -d > "$OUTDIR/keyshare_${ID}.bin"

  # Hashes (raw binary SHA256 digests)
  sha256sum "$OUTDIR/domain_key_${ID}.bin" | cut -d ' ' -f1 | xxd -r -p > "$OUTDIR/domain_key_${ID}.hash"
  sha256sum "$OUTDIR/keyshare_${ID}.bin"   | cut -d ' ' -f1 | xxd -r -p > "$OUTDIR/keyshare_${ID}.hash"

  # PIN for this entry
  PIN=$(gen_random_pin)
  echo "$KEY_NAME : $PIN" >> "$PIN_FILE"

  echo "✅ Generated: $KEY_NAME"
done

# === Summary ===

echo
echo "📁 All sets stored in: $OUTDIR"
echo "🔑 PINs for each keyshare in: $PIN_FILE"
ls -lh "$OUTDIR"


# After running the script, yk_piv_objects/ will contain:
# | File              | Description                        |
# | ----------------- | ---------------------------------- |
# | `key_name.txt`    | UTF-8 label string (`keyshare_00`) |
# | `domain_key.b64`  | Base64-encoded random domain key   |
# | `domain_key.bin`  | Raw binary domain key (for import) |
# | `keyshare.b64`    | Base64-encoded keyshare            |
# | `keyshare.bin`    | Raw binary keyshare (for import)   |
# | `domain_key.hash` | SHA-256 digest of `domain_key.bin` |
# | `keyshare.hash`   | SHA-256 digest of `keyshare.bin`   |
# | `pass.txt`        | Contains randomly generated PIN    |

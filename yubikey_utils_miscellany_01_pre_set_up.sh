#!/bin/bash
# chmod +x yubikey_utils_miscellany_01_pre_set_up.sh
# ./yubikey_utils_miscellany_01_pre_set_up.sh

set -euo pipefail

# === Config ===
OUTDIR="./yk_piv_objects"
mkdir -p "$OUTDIR"

KEY_NAME="keyshare_00"
DOMAIN_KEY_SIZE=32  # bytes
KEYSHARE_SIZE=32    # bytes
PIN_FILE="$OUTDIR/pass.txt"

# === Helper ===

gen_random_bytes() {
  local size="$1"
  head -c "$size" /dev/urandom
}

write_base64() {
  echo -n "$2" | base64 > "$1"
}

hex_sha256() {
  echo -n "$1" | xxd -p -r | sha256sum | cut -d ' ' -f1
}

# === Generation ===

# 1. Key name
echo "$KEY_NAME" > "$OUTDIR/key_name.txt"

# 2. Domain key
DOMAIN_KEY=$(gen_random_bytes "$DOMAIN_KEY_SIZE" | base64)
echo "$DOMAIN_KEY" > "$OUTDIR/domain_key.b64"
echo -n "$DOMAIN_KEY" | base64 -d > "$OUTDIR/domain_key.bin"

# 3. Keyshare
KEYSHARE=$(gen_random_bytes "$KEYSHARE_SIZE" | base64)
echo "$KEYSHARE" > "$OUTDIR/keyshare.b64"
echo -n "$KEYSHARE" | base64 -d > "$OUTDIR/keyshare.bin"

# 4. Domain key hash
sha256sum "$OUTDIR/domain_key.bin" | cut -d ' ' -f1 | xxd -r -p > "$OUTDIR/domain_key.hash"

# 5. Keyshare hash
sha256sum "$OUTDIR/keyshare.bin" | cut -d ' ' -f1 | xxd -r -p > "$OUTDIR/keyshare.hash"

# 6. Save a random PIN (or default)
PIN=$(head -c 8 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 8)
echo "PIN: $PIN" > "$PIN_FILE"

# 7. Summary
echo "✅ Pre-setup complete. Files generated in: $OUTDIR"
ls -lh "$OUTDIR"

echo "📄 Contents:"
cat "$PIN_FILE"

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

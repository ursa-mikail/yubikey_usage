#!/bin/bash
# chmod +x yubikey_utils_miscellany_02.sh
# ./yubikey_utils_miscellany_02.sh 00

set -euo pipefail

INDEX="${1:-00}"

# === Paths and Constants ===
PIN_FILE="../keys/pass.txt"
DOMAIN_KEY_PATH="../keys/domain_keys/domain_key_${INDEX}"
KEYSHARE_JSON_PATH="../keys/key_shares/key_share_${INDEX}.json"
EXPORT_DIR="./exported_yubikey_objects/${INDEX}"
TMPDIR=$(mktemp -d)

# === Validate Inputs ===
if [ ! -f "$PIN_FILE" ]; then
  echo "❌ PIN file not found: $PIN_FILE"
  exit 1
fi

PIN=$(grep "keyshare_${INDEX}" "$PIN_FILE" | awk -F' : ' '{print $2}')
if [ -z "$PIN" ]; then
  echo "❌ PIN not found for keyshare_${INDEX} in $PIN_FILE"
  exit 1
fi

if [ ! -s "$DOMAIN_KEY_PATH" ]; then
  echo "❌ Domain key missing or empty: $DOMAIN_KEY_PATH"
  exit 1
fi

if [ ! -s "$KEYSHARE_JSON_PATH" ]; then
  echo "❌ Key share JSON missing or empty: $KEYSHARE_JSON_PATH"
  exit 1
fi

mkdir -p "$EXPORT_DIR"

# === Prepare Values ===
KEY_NAME="keyshare_${INDEX}"
DOMAIN_KEY=$(cat "$DOMAIN_KEY_PATH")
KEYSHARE_HEX=$(grep -o '"keyshare":"[^"]*"' "$KEYSHARE_JSON_PATH" | cut -d '"' -f4)
KEYSHARE_BIN=$(echo "$KEYSHARE_HEX" | xxd -r -p)

DOMAIN_HASH=$(echo -n "$DOMAIN_KEY" | sha256sum | cut -d ' ' -f1)
KEYSHARE_HASH=$(echo -n "$KEYSHARE_BIN" | sha256sum | cut -d ' ' -f1)

# === Write Temporary Binary Files ===
echo -n "$KEY_NAME" > "$TMPDIR/keyname.bin"
echo -n "$DOMAIN_KEY" > "$TMPDIR/domain_key.bin"
echo -n "$KEYSHARE_BIN" > "$TMPDIR/keyshare.bin"
echo -n "$DOMAIN_HASH" | xxd -r -p > "$TMPDIR/domain_key.hash"
echo -n "$KEYSHARE_HASH" | xxd -r -p > "$TMPDIR/keyshare.hash"

# === Import to YubiKey ===
echo "🔐 Importing keyshare_${INDEX} into YubiKey..."

ykman piv objects import 0x5fc000 "$TMPDIR/keyname.bin" -P "$PIN"
ykman piv objects import 0x5fc103 "$TMPDIR/domain_key.bin" -P "$PIN"
ykman piv objects import 0x5fc108 "$TMPDIR/keyshare.bin" -P "$PIN"
ykman piv objects import 0x5fc113 "$TMPDIR/domain_key.hash" -P "$PIN"
ykman piv objects import 0x5fc118 "$TMPDIR/keyshare.hash" -P "$PIN"

echo "✅ YubiKey PIV objects imported."

# === Export for Verification ===
echo "📤 Exporting objects for keyshare_${INDEX} to $EXPORT_DIR..."

# Fallback to default PIN if PIN is empty or missing
if [ -z "${PIN:-}" ]; then
  echo "⚠️  PIN empty or not found, using default PIN: 123456"
  PIN="123456"
else
  echo "🔑 Using PIN from pass.txt"
fi

for oid in 0x5fc000 0x5fc103 0x5fc108 0x5fc113 0x5fc118; do
  out_file="$EXPORT_DIR/${oid}.bin"
  echo "Exporting object $oid to $out_file with PIN: $PIN"
  
  if ! ykman piv objects export "$oid" "$out_file" -P "$PIN"; then
    echo "❌ Export failed for object $oid using PIN: $PIN"
    # Prompt interactively for correct PIN and retry once
    read -rsp "Enter correct PIN for export: " PIN
    echo
    if ! ykman piv objects export "$oid" "$out_file" -P "$PIN"; then
      echo "❌ Export failed again for object $oid. Aborting."
      rm -rf "$TMPDIR"
      exit 1
    fi
  fi
done

echo "✅ Export complete. Contents:"
ls -lh "$EXPORT_DIR"

# === Cleanup ===
rm -rf "$TMPDIR"



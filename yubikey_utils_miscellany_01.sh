#!/bin/bash
# chmod +x yubikey_utils_miscellany_01.sh
# ./yubikey_utils_miscellany_01.sh

set -euo pipefail

PIN_DEFAULT="123456"
MGMT_KEY_HEX="010203040506070801020304050607080102030405060708"  # 32-byte AES256

# Hex object IDs
KEY_NAME_OBJ="0x5F000"
DOMAIN_KEY_OBJ="0x5F103"
KEYSHARE_OBJ="0x5F108"
DOMAIN_HASH_OBJ="0x5F113"
KEYSHARE_HASH_OBJ="0x5F118"

# TEMP files
TMP_DIR="./yk_misc_temp"
mkdir -p "$TMP_DIR"

read_hex_object() {
  local object_id="$1"
  echo "📥 Reading object from $object_id..."
  ykman piv objects export "$object_id" "$TMP_DIR/obj_$(basename $object_id).bin" -P "$PIN_DEFAULT" 2>/dev/null
  hexdump -C "$TMP_DIR/obj_$(basename $object_id).bin" || echo "❌ Failed to read $object_id"
}

compute_sha256() {
  local file="$1"
  sha256sum "$file" | cut -d ' ' -f1
}

verify_hash_object() {
  local object="$1"
  local object_hash="$2"

  ykman piv objects export "$object" "$TMP_DIR/current.bin" -P "$PIN_DEFAULT" || { echo "❌ Failed to read object."; return 1; }
  ykman piv objects export "$object_hash" "$TMP_DIR/hashref.bin" -P "$PIN_DEFAULT" || { echo "❌ Failed to read hash object."; return 1; }

  computed=$(sha256sum "$TMP_DIR/current.bin" | cut -d ' ' -f1)
  reference=$(xxd -p "$TMP_DIR/hashref.bin" | tr -d '\n')

  if [ "$computed" == "$reference" ]; then
    echo "✅ Hash matches for $object"
  else
    echo "❌ Hash mismatch for $object"
    echo "Computed : $computed"
    echo "Expected : $reference"
  fi
}

list_objects() {
  echo "📋 Checking known object IDs..."
  for oid in $KEY_NAME_OBJ $DOMAIN_KEY_OBJ $KEYSHARE_OBJ $DOMAIN_HASH_OBJ $KEYSHARE_HASH_OBJ; do
    echo -n "$oid : "
    if ykman piv objects export "$oid" /dev/null -P "$PIN_DEFAULT" 2>/dev/null; then
      echo "✔ Present"
    else
      echo "❌ Not found"
    fi
  done
}

main() {
  echo "=== 🔧 YubiKey PIV Miscellaneous Utils ==="
  echo "1) List known object IDs"
  echo "2) Read and hexdump domain key"
  echo "3) Read and hexdump keyshare"
  echo "4) Verify domain key SHA256"
  echo "5) Verify keyshare SHA256"
  echo "q) Quit"
  read -rp "Enter choice: " choice

  case "$choice" in
    1) list_objects ;;
    2) read_hex_object "$DOMAIN_KEY_OBJ" ;;
    3) read_hex_object "$KEYSHARE_OBJ" ;;
    4) verify_hash_object "$DOMAIN_KEY_OBJ" "$DOMAIN_HASH_OBJ" ;;
    5) verify_hash_object "$KEYSHARE_OBJ" "$KEYSHARE_HASH_OBJ" ;;
    q|Q)
      echo "👋 Bye"
      exit 0
      ;;
    *) echo "❌ Invalid choice" ;;
  esac
}

main

#| Object ID | Content                  | Purpose                                     |
#| --------- | ------------------------ | ------------------------------------------- |
#| `0x5F000` | Key name / label (UTF-8) | Human-readable reference                    |
#| `0x5F103` | Domain key (binary)      | Shared domain-wide symmetric or signing key |
#| `0x5F108` | Key share (binary)       | Participant-specific partial key            |
#| `0x5F113` | SHA-256(domain key)      | Integrity check                             |
#| `0x5F118` | SHA-256(keyshare)        | Integrity check                             |

#!/bin/bash
# chmod +x yubikey_utils_miscellany_00.sh
# ./yubikey_utils_miscellany_00.sh

set -euo pipefail

RANDOM_PIN=$(head -c 6 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 8)
PIN_DEFAULT="123456"

list_yubikeys() {
  echo "📦 Available YubiKeys (serials):"
  ykman list --serials
}

get_serial_info() {
  local serial="$1"
  echo "🔍 Device info for serial $serial:"
  ykman --device "$serial" info
}

import_piv_object() {
  local serial="$1"
  local object_id="$2"  # 5fc103 or 5fc108
  local path="$3"
  echo "🔐 Importing $path to PIV object ID $object_id..."
  ykman --device "$serial" piv objects import "$object_id" "$path" -P "$PIN_DEFAULT"
  echo "✅ Import complete."
}

export_piv_object() {
  local serial="$1"
  local object_id="$2"
  local output_path="$3"
  echo "📤 Exporting PIV object $object_id to $output_path..."
  ykman --device "$serial" piv objects export "$object_id" "$output_path" -P "$PIN_DEFAULT"
  echo "✅ Export complete."
}

generate_random_keyshare() {
  local output_path="$1"
  local size_bytes="$2"
  echo "🔧 Generating $size_bytes-byte random keyshare to $output_path"
  head -c "$size_bytes" /dev/urandom > "$output_path"
  echo "✅ Keyshare generated."
}

main() {
  echo "=== 🔐 YubiKey PIV Object Test Utility ==="
  list_yubikeys
  read -rp "Enter YubiKey serial number: " serial

  get_serial_info "$serial"

  echo "Choose an action:"
  echo "1) Import keyshare to 5fc108"
  echo "2) Import domain cert to 5fc103"
  echo "3) Export keyshare from 5fc108"
  echo "4) Export domain cert from 5fc103"
  echo "5) Generate random keyshare (binary)"
  echo "q) Quit"
  read -rp "Choice: " choice

  case "$choice" in
    1)
      read -rp "Path to keyshare file (.json or .bin): " keyshare
      import_piv_object "$serial" 5fc108 "$keyshare"
      ;;
    2)
      read -rp "Path to domain cert (PEM or DER): " cert
      import_piv_object "$serial" 5fc103 "$cert"
      ;;
    3)
      read -rp "Output path (e.g. keyshare_00.json): " out
      export_piv_object "$serial" 5fc108 "$out"
      ;;
    4)
      read -rp "Output path (e.g. domain_cert.pem): " out
      export_piv_object "$serial" 5fc103 "$out"
      ;;
    5)
      read -rp "Output path for keyshare (e.g. keyshare_00.json): " out
      read -rp "Size of keyshare in bytes (e.g. 32): " size
      generate_random_keyshare "$out" "$size"
      ;;
    q|Q)
      echo "👋 Goodbye"
      exit 0
      ;;
    *)
      echo "❌ Invalid choice"
      ;;
  esac
}

main


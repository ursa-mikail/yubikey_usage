#!/bin/bash
# chmod +x yubikey_utils.sh
# ./yubikey_utils.sh

set -euo pipefail
trap 'rm -f /tmp/tmp_cert.pem' EXIT

# Wait for YubiKey connection
wait_for_yubikey() {
  echo "Waiting for YubiKey..."
  while true; do
    if ykman list > /dev/null 2>&1; then
      echo "✅ YubiKey detected."
      break
    else
      echo "❌ No YubiKey detected. Press Ctrl+C to quit."
      sleep 2
    fi
  done
}

format_yubikey() {
  echo "⚠️  Resetting PIV application on YubiKey (this will wipe keys and certs)..."
  read -rp "Type 'yes' to continue: " confirm
  if [ "$confirm" == "yes" ]; then
    ykman piv reset -f
    echo "🔄 YubiKey PIV reset complete."
  else
    echo "❌ Reset cancelled."
  fi
}

import_key_and_cert() {
  local cert_path="$1"
  local key_path="$2"
  local slot="${3:-9a}"

  echo "🔑 Importing key and certificate into slot $slot..."
  ykman piv keys import "$slot" "$key_path"
  ykman piv certificates import "$slot" "$cert_path"
  echo "✅ Import complete."
}

export_cert() {
  local slot="${1:-9a}"
  local output_path="${2:-exported_cert.pem}"

  echo "📤 Exporting certificate from slot $slot to $output_path..."
  ykman piv certificates export "$slot" "$output_path"
  echo "✅ Export complete."
}

export_pubkey() {
  local slot="${1:-9c}"
  local output_path="${2:-pubkey_${slot}.pem}"

  echo "📤 Exporting public key from slot $slot to $output_path..."
  ykman piv keys export-public "$slot" "$output_path"
  echo "✅ Public key saved to $output_path"
}

generate_key_on_device() {
  local slot="${1:-9c}"
  local algorithm="${2:-RSA2048}"

  echo "🛠️  Generating key on YubiKey slot $slot with algorithm $algorithm..."
  ykman piv keys generate "$slot" --algorithm "$algorithm" public_key.pem
  echo "✅ Key generated. Public key saved to public_key.pem"
}

generate_self_signed_cert() {
  local subject="${1:-/CN=YubiKey Test/}"
  local key_path="${2:-test.key}"
  local cert_path="${3:-selfsigned_cert.pem}"

  if [ ! -f "$key_path" ]; then
    echo "🔐 Private key not found. Generating a new 2048-bit RSA key..."
    openssl genpkey -algorithm RSA -out "$key_path" -pkeyopt rsa_keygen_bits:2048
  fi

  echo "📜 Generating self-signed certificate..."
  openssl req -new -x509 -key "$key_path" -out "$cert_path" -subj "$subject" -days 365
  echo "✅ Self-signed certificate created at: $cert_path"
}

export_key() {
  local key_path="$1"
  local output_path="$2"

  if [ ! -f "$key_path" ]; then
    echo "❌ Key file not found: $key_path"
    return 1
  fi

  cp "$key_path" "$output_path"
  echo "📤 Exported private key to: $output_path"
}

verify_cert() {
  local slot="${1:-9a}"
  echo "🔍 Verifying certificate in slot $slot..."
  ykman piv certificates export "$slot" /tmp/tmp_cert.pem
  openssl x509 -in /tmp/tmp_cert.pem -text -noout
}

change_pin_puk() {
  echo "🔧 Changing PIN..."
  ykman piv change-pin
  echo "🔧 Changing PUK..."
  ykman piv change-puk
}

change_mgmt_key() {
  echo "🛡️  Changing Management Key..."
  ykman piv change-management-key
}

audit_slots() {
  echo "📋 Auditing standard slots (9a, 9c, 9d, 9e)..."
  for slot in 9a 9c 9d 9e; do
    echo -n "Slot $slot: "
    if ykman piv certificates export "$slot" /dev/null 2>/dev/null; then
      echo "✔ Occupied"
    else
      echo "❌ Empty"
    fi
  done
}

backup_all() {
  mkdir -p yubikey_backup
  echo "💾 Backing up certificates from slots 9a, 9c, 9d, 9e..."
  for slot in 9a 9c 9d 9e; do
    if ykman piv certificates export "$slot" "yubikey_backup/cert_${slot}.pem" 2>/dev/null; then
      echo "✅ Slot $slot backed up."
    else
      echo "⚠️  Slot $slot empty or failed to export."
    fi
  done
  echo "🗂️  Backup complete. Stored in ./yubikey_backup/"
}

main() {
  wait_for_yubikey

  echo "========= YubiKey Utility ========="
  echo "1) Format/reset PIV"
  echo "2) Import key and certificate"
  echo "3) Export private key (from local file)"
  echo "4) Export certificate from YubiKey"
  echo "5) Generate new key on YubiKey"
  echo "6) Generate self-signed certificate"
  echo "7) Verify certificate on YubiKey"
  echo "8) Change PIN/PUK"
  echo "9) Change Management Key"
  echo "10) Export public key from slot"
  echo "11) Audit standard slots"
  echo "12) Backup certificates"
  echo "q) Quit"
  echo "===================================="
  read -rp "Enter choice: " choice

  case "$choice" in
    1) format_yubikey ;;
    2)
      read -rp "Path to certificate (.pem): " cert_path
      read -rp "Path to private key (.pem): " key_path
      read -rp "Slot (default 9a): " slot
      import_key_and_cert "$cert_path" "$key_path" "$slot"
      ;;
    3)
      read -rp "Path to existing private key: " key_path
      read -rp "Output path for exported key: " output_path
      export_key "$key_path" "$output_path"
      ;;
    4)
      read -rp "Slot to export cert from (default 9a): " slot
      read -rp "Output path for certificate: " output_path
      export_cert "$slot" "$output_path"
      ;;
    5)
      read -rp "Slot for key generation (default 9c): " slot
      read -rp "Algorithm (RSA2048, RSA3072, ECCP256, ECCP384) default RSA2048: " algorithm
      generate_key_on_device "$slot" "$algorithm"
      ;;
    6)
      read -rp "Subject (default /CN=YubiKey Test/): " subject
      read -rp "Path to private key (default test.key): " key_path
      read -rp "Output path for cert (default selfsigned_cert.pem): " cert_path
      generate_self_signed_cert "$subject" "$key_path" "$cert_path"
      ;;
    7)
      read -rp "Slot to verify cert from (default 9a): " slot
      verify_cert "$slot"
      ;;
    8) change_pin_puk ;;
    9) change_mgmt_key ;;
    10)
      read -rp "Slot to export public key from (default 9c): " slot
      read -rp "Output path (default pubkey_<slot>.pem): " output_path
      export_pubkey "$slot" "$output_path"
      ;;
    11) audit_slots ;;
    12) backup_all ;;
    q|Q)
      echo "👋 Exiting..."
      exit 0
      ;;
    *)
      echo "❌ Invalid choice."
      ;;
  esac
}

main

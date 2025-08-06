#!/bin/bash
# chmod +x yubikey_utils_set_defaults.sh
# ./yubikey_utils_set_defaults.sh [--factory-default]

set -euo pipefail

# === Factory-default config ===
FACTORY_PIN="123456"
FACTORY_PUK="12345678"
FACTORY_MGMT_KEY="010203040506070801020304050607080102030405060708"
FACTORY_LOCK_CODE="000000000000000000000000000000000000000000000000"

# === "All ones" config ===
ALLONES_PIN="111111"
ALLONES_PUK="11111111"
ALLONES_MGMT_KEY="FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
ALLONES_LOCK_CODE="FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"

# === Choose profile ===
if [[ "${1:-}" == "--factory-default" ]]; then
  PROFILE_NAME="Factory Default"
  PIN="$FACTORY_PIN"
  PUK="$FACTORY_PUK"
  MGMT_KEY="$FACTORY_MGMT_KEY"
  LOCK_CODE="$FACTORY_LOCK_CODE"
else
  PROFILE_NAME="All Ones"
  PIN="$ALLONES_PIN"
  PUK="$ALLONES_PUK"
  MGMT_KEY="$ALLONES_MGMT_KEY"
  LOCK_CODE="$ALLONES_LOCK_CODE"
fi

# === Start setup ===
echo "🧪 Applying YubiKey PIV Profile: $PROFILE_NAME"
echo "🔁 Resetting PIV to factory defaults..."
ykman piv reset -f

echo "🔐 Setting PIN and PUK..."
#ykman piv access change-pin --pin "$PIN" --new-pin "$PIN"
#ykman piv access change-puk --puk "$PUK" --new-puk "$PUK"

if [ "$PIN" != "123456" ]; then
  echo "🔐 Setting PIN..."
  ykman piv access change-pin --pin "123456" --new-pin "$PIN"
else
  echo "ℹ️  Skipping PIN change (already default)"
fi

if [ "$PUK" != "12345678" ]; then
  echo "🔐 Setting PUK..."
  ykman piv access change-puk --puk "12345678" --new-puk "$PUK"
else
  echo "ℹ️  Skipping PUK change (already default)"
fi


echo "🔧 Setting Management Key..."
ykman piv access change-management-key --new-management-key "$MGMT_KEY"

#echo "🛡️  Setting Lock Code for protected object access..."
#ykman piv access set-lock-code --lock-code "$LOCK_CODE"

# === Summary ===
echo ""
echo "✅ YubiKey configured with profile: $PROFILE_NAME"
echo "---------------------------------------------"
echo -e "PIN:            $PIN"
echo -e "PUK:            $PUK"
echo -e "Management Key: $MGMT_KEY"
echo -e "Lock Code:      $LOCK_CODE"
echo "---------------------------------------------"

# ./yubikey_utils_set_defaults.sh         # sets ALL ONES config (default)
# ./yubikey_utils_set_defaults.sh --factory-default   # sets factory config

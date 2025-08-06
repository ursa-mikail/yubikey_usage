 % ./yubikey_utils_set_defaults.sh
🧪 Applying YubiKey PIV Profile: All Ones
🔁 Resetting PIV to factory defaults...
Resetting PIV data...
Reset complete. All PIV data has been cleared from the YubiKey.
Your YubiKey now has the default PIN, PUK and Management Key:
	PIN:	123456
	PUK:	12345678
	Management Key:	010203040506070801020304050607080102030405060708
🔐 Setting PIN and PUK...
🔐 Setting PIN...
New PIN set.
🔐 Setting PUK...
New PUK set.
🔧 Setting Management Key...
Enter the current management key [blank to use default key]: 
New management key set.

✅ YubiKey configured with profile: All Ones
---------------------------------------------
PIN:            111111
PUK:            11111111
Management Key: FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
Lock Code:      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
---------------------------------------------

% ./yubikey_utils_set_defaults.sh --factory-default
🧪 Applying YubiKey PIV Profile: Factory Default
🔁 Resetting PIV to factory defaults...
Resetting PIV data...
Reset complete. All PIV data has been cleared from the YubiKey.
Your YubiKey now has the default PIN, PUK and Management Key:
	PIN:	123456
	PUK:	12345678
	Management Key:	010203040506070801020304050607080102030405060708
🔐 Setting PIN and PUK...
ℹ️  Skipping PIN change (already default)
ℹ️  Skipping PUK change (already default)
🔧 Setting Management Key...
Enter the current management key [blank to use default key]: 
New management key set.

✅ YubiKey configured with profile: Factory Default
---------------------------------------------
PIN:            123456
PUK:            12345678
Management Key: 010203040506070801020304050607080102030405060708
Lock Code:      000000000000000000000000000000000000000000000000
---------------------------------------------


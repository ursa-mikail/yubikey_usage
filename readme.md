"""
# 🔐 YubiKey Utilities Script

This is a shell utility script to manage your YubiKey's PIV (Personal Identity Verification) features.

## ✅ Prerequisites

- Install [YubiKey Manager CLI (`ykman`)](https://developers.yubico.com/yubikey-manager/)
  ```bash
  pip install yubikey-manager
```

Features:
```
✅ YubiKey detection

✅ PIV reset and default keys

✅ Certificate and private key import

✅ Export and hash verification

✅ On-device key generation

✅ Self-signed certificate creation
```

| Option                                  | Description                                                                             |
| --------------------------------------- | --------------------------------------------------------------------------------------- |
| **1)** Format/reset PIV                 | Wipes the PIV applet. Use with caution.                                                 |
| **2)** Import key and certificate       | Uploads a `.pem` key and cert into a slot (default: 9a).                                |
| **3)** Export private key (from file)   | Copies an existing `.pem` key file to another location (not from YubiKey).              |
| **4)** Export certificate               | Extracts a cert from a YubiKey slot (default: 9a).                                      |
| **5)** Generate key on YubiKey          | Creates a key on the device (slot 9c by default). Saves public key to `public_key.pem`. |
| **6)** Generate self-signed certificate | Creates a self-signed cert for testing, using a provided or new private key.            |
| **7)** Verify certificate               | Displays parsed content of the cert from a YubiKey slot.                                |
| **8)** Change PIN/PUK                   | Allows you to rotate your PIN and PUK codes for security.                               |
| **9)** Change Management Key            | Rotates the YubiKey's management key.                                                   |
| **10)** Export public key               | Retrieves public key from slot (e.g. 9c) into `pubkey_<slot>.pem`.                      |
| **11)** Audit slots                     | Lists which of the common PIV slots (9a, 9c, 9d, 9e) are occupied.                      |
| **12)** Backup certificates             | Exports certificates from all major slots to `./yubikey_backup/`.                       |
| **q)** Quit                             | Exits the program.                                                                      |


brew install ykman  # Mac


python3 -m venv venv          # optional: create virtual environment
#source venv/bin/activate      # Linux/macOS
#venv\Scripts\activate         # Windows

pip install -r requirements.txt # pip install yubikey-manager yubikit

python3 yubikey_utils.py

 % ./yubikey_utils.sh
Waiting for YubiKey...
✅ YubiKey detected.
Choose an action:
1) Format/reset PIV
2) Import key and certificate
3) Export private key (from local file)
4) Export certificate from YubiKey
5) Generate new key on YubiKey
6) Generate self-signed cert
q) Quit
Enter choice: 1
Resetting PIV application on YubiKey...
Resetting PIV data...
Reset complete. All PIV data has been cleared from the YubiKey.
Your YubiKey now has the default PIN, PUK and Management Key:
	PIN:	123456
	PUK:	12345678
	Management Key:	010203040506070801020304050607080102030405060708
YubiKey PIV reset complete.

% ./yubikey_utils.sh
Enter choice: 2
Path to certificate (.pem): ./test.pem
Path to private key (.pem): ./test.key
Slot (default 9a): 9a
Importing key and certificate into slot 9a...
Enter a management key [blank to use default key]: 
Private key imported into slot AUTHENTICATION.
Enter a management key [blank to use default key]: 
Certificate imported into slot AUTHENTICATION
Import complete.

Enter choice: 3
Path to existing private key: ./test.key
Output path for exported key: ./exported_key.key
Exported private key (from local file) to: ./exported_key.key


% hash_file ./exported_key.key
 ./exported_key.key exists
[ ./exported_key.key exists. ]
a8896ce9d080f0cb5fdaf05c78d187c62d34c6d9b046f6c3f61505ce291a9ccc
(venv) (base) chanfamily@Chans-Air yubikey_python_usage % hash_file ./test.key
 ./test.key exists
[ ./test.key exists. ]
a8896ce9d080f0cb5fdaf05c78d187c62d34c6d9b046f6c3f61505ce291a9ccc


Enter choice: 4
Slot to export cert from (default 9a): 9a
Output path for certificate: ./out.pem
Exporting certificate from slot 9a to ./out.pem...
Certificate from slot 9A (AUTHENTICATION) exported to ./out.pem.
Export complete.

% hash_file ./out.pem 
 ./out.pem exists
[ ./out.pem exists. ]
e55c5db4432875c6cc2a626bf1336909b9e9ce664c02f4e0f5e5e2ea12c5bec0
(venv) (base) chanfamily@Chans-Air yubikey_python_usage % hash_file ./test.pem
 ./test.pem exists
[ ./test.pem exists. ]
e55c5db4432875c6cc2a626bf1336909b9e9ce664c02f4e0f5e5e2ea12c5bec0

% ./yubikey_utils.sh
Enter choice: 5
Slot for key generation (default 9c): 9c
Algorithm (RSA2048, RSA3072, ECCP256, ECCP384) default RSA2048: RSA2048
Generating key on YubiKey slot 9c with algorithm RSA2048...
Enter a management key [blank to use default key]: 
Private key generated in slot 9C (SIGNATURE), public key written to public_key.pem.
Key generated. Public key saved to public_key.pem

Enter choice: 6
Subject for self-signed cert (default /CN=YubiKey Test/): 
Path to private key file (default test.key): 
Output path for cert (default selfsigned_cert.pem): 
Generating self-signed certificate...
Self-signed certificate created: selfsigned_cert.pem

| Slot name | Hex ID | Usage                            |
| --------- | ------ | -------------------------------- |
| **9a**    | 0x9a   | PIV Authentication (often login) |
| **9c**    | 0x9c   | Digital Signature                |
| **9d**    | 0x9d   | Key Management                   |
| **9e**    | 0x9e   | Card Authentication              |


# ykman piv info

% ykman piv certificates export 9a cert_9a.pem || echo "No cert in slot 9a"
ykman piv certificates export 9c cert_9c.pem || echo "No cert in slot 9c"
ykman piv certificates export 9d cert_9d.pem || echo "No cert in slot 9d"

Certificate from slot 9A (AUTHENTICATION) exported to cert_9a.pem.
ERROR: No certificate found.
No cert in slot 9c
ERROR: No certificate found.
No cert in slot 9d






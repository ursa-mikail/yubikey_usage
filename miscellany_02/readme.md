# 1. Prepare keys (e.g., 3 sets)
./yubikey_utils_miscellany_02_pre_set_up.sh 3

# 2. Import keyshare_00
./yubikey_utils_miscellany_02.sh 00

# 3. Check output
ls ./exported_yubikey_objects/00/

```
% ./yubikey_utils_miscellany_02.sh
🔐 Importing keyshare_00 into YubiKey...
Enter a management key [blank to use default key]: 
Object imported.
Enter a management key [blank to use default key]: 
Object imported.
Enter a management key [blank to use default key]: 
Object imported.
Enter a management key [blank to use default key]: 
Object imported.
Enter a management key [blank to use default key]: 
Object imported.
✅ YubiKey PIV objects imported.
📤 Exporting objects for keyshare_00 to ./exported_yubikey_objects/00...
🔑 Using PIN from pass.txt
Exporting object 0x5fc000 to ./exported_yubikey_objects/00/0x5fc000.bin with PIN: JLdFEmI7
Exported object 6275072 to ./exported_yubikey_objects/00/0x5fc000.bin.
Exporting object 0x5fc103 to ./exported_yubikey_objects/00/0x5fc103.bin with PIN: JLdFEmI7
ERROR: PIN verification failed, 2 tries left.
❌ Export failed for object 0x5fc103 using PIN: JLdFEmI7
Enter correct PIN for export: 
Exported object 6275331 to ./exported_yubikey_objects/00/0x5fc103.bin.
Exporting object 0x5fc108 to ./exported_yubikey_objects/00/0x5fc108.bin with PIN: 123456
Exported object 6275336 to ./exported_yubikey_objects/00/0x5fc108.bin.
Exporting object 0x5fc113 to ./exported_yubikey_objects/00/0x5fc113.bin with PIN: 123456
Exported object 6275347 to ./exported_yubikey_objects/00/0x5fc113.bin.
Exporting object 0x5fc118 to ./exported_yubikey_objects/00/0x5fc118.bin with PIN: 123456
Exported object 6275352 to ./exported_yubikey_objects/00/0x5fc118.bin.
✅ Export complete. Contents:
total 40
-rw-r--r--  1 chanfamily  staff    11B Aug  4 12:59 0x5fc000.bin
-rw-r--r--  1 chanfamily  staff    32B Aug  4 13:00 0x5fc103.bin
-rw-r--r--  1 chanfamily  staff    32B Aug  4 13:00 0x5fc108.bin
-rw-r--r--  1 chanfamily  staff    32B Aug  4 13:00 0x5fc113.bin
-rw-r--r--  1 chanfamily  staff    32B Aug  4 13:00 0x5fc118.bin
```
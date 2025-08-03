from ykman.device import list_all_devices
from yubikit.core.smartcard import SmartCardConnection
from yubikit.management import ManagementSession, CAPABILITY
from yubikit.piv import PivSession, KEY_TYPE, SLOT, Algorithm, PivPinPolicy, PivTouchPolicy
import os

# -------------------------------
def get_devices():
    devices = list_all_devices()
    for info, conn in devices:
        print(f"Device: {info}")
    return devices

# -------------------------------
def format_yubikey():
    devices = get_devices()
    if not devices:
        raise Exception("No YubiKey connected.")
    info, conn = devices[0]
    mgmt = ManagementSession(conn)
    print("Resetting PIV application...")
    mgmt.reset_piv()
    print("YubiKey PIV reset complete.")

# -------------------------------
def import_key(cert_path, key_path, slot=SLOT.AUTHENTICATION):
    from cryptography.hazmat.primitives.serialization import load_pem_private_key
    from cryptography.hazmat.backends import default_backend

    devices = get_devices()
    info, conn = devices[0]
    piv_session = PivSession(conn)
    
    # Load private key
    with open(key_path, "rb") as f:
        key_data = f.read()
        private_key = load_pem_private_key(key_data, password=None, backend=default_backend())
    
    # Load certificate
    with open(cert_path, "rb") as f:
        cert_data = f.read()

    print(f"Importing key and certificate into slot {slot.name}")
    piv_session.put_key_and_cert(slot, private_key, cert_data)
    print("Key and certificate import complete.")

# -------------------------------
def export_cert(slot=SLOT.AUTHENTICATION, output_path="exported_cert.pem"):
    devices = get_devices()
    info, conn = devices[0]
    piv_session = PivSession(conn)
    cert = piv_session.get_certificate(slot)
    
    with open(output_path, "wb") as f:
        f.write(cert.public_bytes())
    print(f"Certificate exported to {output_path}")

# -------------------------------
def generate_key_on_device(slot=SLOT.AUTHENTICATION, algorithm=Algorithm.RSA2048):
    devices = get_devices()
    info, conn = devices[0]
    piv_session = PivSession(conn)

    print(f"Generating key in slot {slot.name} using {algorithm.name}")
    public_key = piv_session.generate_key(
        slot,
        algorithm,
        pin_policy=PivPinPolicy.DEFAULT,
        touch_policy=PivTouchPolicy.DEFAULT
    )
    print(f"Public key:\n{public_key.public_bytes().decode()}")
    return public_key

# -------------------------------
def generate_self_signed_cert(public_key, subject="/CN=YubiKey Test/", cert_path="selfsigned_cert.pem", key_path="test.key"):
    """Helper to generate a test self-signed cert using openssl and save it."""

    # Write the public key to a file (for openssl usage if needed)
    os.system(f"openssl req -new -x509 -key {key_path} -out {cert_path} -subj \"{subject}\" -days 365")
    print(f"Self-signed certificate created: {cert_path}")

def export_key(key_path="test.key", output_path="exported_key.pem"):
    """
    Export the private key that was previously imported (from local file).
    NOTE: This does NOT extract from YubiKey — that's impossible.

    Params:
        key_path (str): Path to the existing PEM key that was imported.
        output_path (str): Destination to copy/export the key.

    Raises:
        FileNotFoundError: If the source key file doesn't exist.
    """
    if not os.path.exists(key_path):
        raise FileNotFoundError(f"No such key file: {key_path}")

    with open(key_path, "rb") as src, open(output_path, "wb") as dst:
        dst.write(src.read())

    print(f"Exported private key (from local import file) to: {output_path}")



from yubikey_utils import *


def wait_for_device():
    """Loop until a YubiKey is connected or user exits."""
    while True:
        devices = get_devices()
        if devices:
            print("✅ YubiKey detected.\n")
            return devices[0]  # (info, connection)

        print("❌ No YubiKey detected.")
        print("Options:")
        print("  [R] Retry")
        print("  [Q] Quit")
        choice = input("Choose an option: ").strip().lower()
        if choice == 'q':
            print("Exiting...")
            exit(0)
        print("Retrying...\n")
        time.sleep(1)

def main():
    print("🔐 YubiKey PIV Manager\n")

    # Wait until a device is connected
    info, conn = wait_for_device()

    # Uncomment the actions you want to perform:

    # 1. Format/reset PIV
    # format_yubikey()

    # 2. Import key + cert
    import_key(cert_path="test.pem", key_path="test.key")

    # 3. Export key (from file, not from YubiKey)
    export_key(key_path="test.key", output_path="my_exported_key.pem")

    # 4. Export cert from YubiKey slot 9a
    export_cert(slot=SLOT.AUTHENTICATION, output_path="yubikey_9a_cert.pem")

    # 5. Generate a new key inside YubiKey (Slot 9c or 9d recommended)
    generate_key_on_device(slot=SLOT.SIGNATURE)

if __name__ == "__main__":
    main()



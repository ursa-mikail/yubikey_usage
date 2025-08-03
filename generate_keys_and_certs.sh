# chmod +x generate_keys_and_certs.sh
# ./generate_keys_and_certs.sh

#🧪 Generate Keys and Certs for Testing
#1. Generate RSA 2048 Private Key
openssl genrsa -out test.key 2048

#2. Generate Self-Signed Certificate
openssl req -new -x509 -key test.key -out test.crt -subj "/CN=YubiKey Test/" -days 365

# Convert to PEM if needed:
openssl x509 -in test.crt -out test.pem -outform PEM

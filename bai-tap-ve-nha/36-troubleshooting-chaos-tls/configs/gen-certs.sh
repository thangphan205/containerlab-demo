#!/bin/sh
# gen-certs.sh — dựng PKI nội bộ NTC lúc deploy:
#   NTC Root CA  ->  NTC Issuing CA (intermediate)  ->  leaf cert portal.local
# Leaf cert được cấp HẾT HẠN (not_after trong quá khứ) để mô phỏng sự cố quên gia hạn.
# Yêu cầu OpenSSL >= 3.4 (cờ -not_before/-not_after). Alpine 3.22 có OpenSSL 3.5.
set -e

DIR=/etc/nginx/certs
OUT=/certs-out
mkdir -p "$DIR" "$OUT"
cd "$DIR"

# 1. Root CA (tự ký, 10 năm) — cert này được phát cho mọi máy client trust
openssl req -x509 -newkey rsa:2048 -nodes -keyout root-ca.key -out root-ca.crt \
  -days 3650 -subj "/O=NTC/CN=NTC Root CA" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign"

# 2. Issuing CA (intermediate, do Root ký, 5 năm)
printf 'basicConstraints=critical,CA:TRUE,pathlen:0\nkeyUsage=critical,keyCertSign,cRLSign\n' > ca-ext.cnf
openssl req -newkey rsa:2048 -nodes -keyout issuing-ca.key -out issuing-ca.csr \
  -subj "/O=NTC/CN=NTC Issuing CA"
openssl x509 -req -in issuing-ca.csr -CA root-ca.crt -CAkey root-ca.key -CAcreateserial \
  -out issuing-ca.crt -days 1825 -extfile ca-ext.cnf

# 3. Leaf cert portal.local — do Issuing CA ký, CỐ TÌNH đã hết hạn (01/2024 -> 01/2025)
printf 'basicConstraints=CA:FALSE\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth\nsubjectAltName=DNS:portal.local,IP:10.0.9.80\n' > leaf-ext.cnf
openssl req -newkey rsa:2048 -nodes -keyout server.key -out server.csr \
  -subj "/O=NTC/CN=portal.local"
openssl x509 -req -in server.csr -CA issuing-ca.crt -CAkey issuing-ca.key -CAcreateserial \
  -out server.crt -extfile leaf-ext.cnf \
  -not_before 20240101000000Z -not_after 20250101000000Z

# Phát root CA cho client (bind mount chung /certs-out)
cp root-ca.crt "$OUT/root-ca.crt"

echo "PKI ready:"
openssl x509 -in server.crt -noout -subject -dates

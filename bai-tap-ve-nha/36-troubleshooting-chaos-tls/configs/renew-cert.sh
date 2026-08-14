#!/bin/sh
# renew-cert.sh — quy trình gia hạn cert portal.local của team hạ tầng
# (ký leaf cert MỚI còn hạn 1 năm từ NTC Issuing CA, giữ nguyên key + SAN).
# Lưu ý: script chỉ gia hạn cert — KHÔNG tự reload nginx.
set -e

DIR=/etc/nginx/certs
cd "$DIR"

openssl req -newkey rsa:2048 -nodes -keyout server.key -out server.csr \
  -subj "/O=NTC/CN=portal.local"
openssl x509 -req -in server.csr -CA issuing-ca.crt -CAkey issuing-ca.key -CAcreateserial \
  -out server.crt -days 365 -extfile leaf-ext.cnf

echo "Cert moi da ky:"
openssl x509 -in server.crt -noout -subject -dates
echo "Nho ap dung: nginx -s reload"

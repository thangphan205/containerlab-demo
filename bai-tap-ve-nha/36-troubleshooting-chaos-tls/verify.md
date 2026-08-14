# Verify checklist — Bài 36 chaos-tls (chạy trên server lab)

## Deploy
```bash
cd 36-troubleshooting-chaos-tls/topology
sudo clab deploy -t chaos-tls.clab.yml
```
- [ ] Deploy sạch, không exec nào fail. **Soi kỹ output `sh /tmp/gen-certs.sh`**: phải in `PKI ready:` + dates của leaf (notAfter = Jan 1 2025).
  - ⚠️ Nếu openssl báo lỗi cờ `-not_before`/`-not_after` → OpenSSL trong image < 3.4. Fallback: sửa gen-certs.sh dùng `apk add libfaketime` + `faketime '2024-01-01' openssl req -x509 ...` cho leaf. Ghi gotcha vào README.
- [ ] `docker exec web ls /etc/nginx/certs/` có: root-ca, issuing-ca, server.crt/key.
- [ ] `docker exec client cat /certs-out/root-ca.crt` có nội dung (bind mount chung hoạt động).

## Triệu chứng lỗi 1 (ssl_protocols TLSv1/1.1)
- [ ] `docker exec client curl -m 5 --cacert /certs-out/root-ca.crt https://portal.local` fail — lỗi handshake (alert handshake failure / protocol version). **Ghi lại error string thực tế**, chỉnh guide nếu khác.
- [ ] `docker exec web nginx -s reload` sau khi cp config KHÔNG bị lỗi (nếu nginx từ chối TLSv1/1.1 ngay lúc reload thì triệu chứng đổi — chỉnh guide theo thực tế).

## Fix 1 → triệu chứng lỗi 2 (cert hết hạn)
```bash
docker exec web sed -i 's/ssl_protocols TLSv1 TLSv1.1;/ssl_protocols TLSv1.2 TLSv1.3;/' /etc/nginx/nginx.conf
docker exec web nginx -s reload
```
- [ ] curl lại → `SSL certificate problem: certificate has expired`.

## Fix 2 (renew) → triệu chứng lỗi 3 (thiếu chain)
```bash
docker exec web sh /usr/local/bin/renew-cert.sh
docker exec web nginx -s reload
```
- [ ] `docker exec web openssl x509 -in /etc/nginx/certs/server.crt -noout -dates` → notAfter tương lai.
- [ ] curl lại → `unable to get local issuer certificate`.
- [ ] `docker exec client sh -c 'openssl s_client -connect 10.0.9.80:443 -servername portal.local -showcerts </dev/null'` → server chỉ gửi 1 cert.

## Fix 3 → pass cuối
```bash
docker exec web sh -c 'cat /etc/nginx/certs/server.crt /etc/nginx/certs/issuing-ca.crt > /etc/nginx/certs/fullchain.pem'
docker exec web sed -i 's|ssl_certificate     /etc/nginx/certs/server.crt;|ssl_certificate     /etc/nginx/certs/fullchain.pem;|' /etc/nginx/nginx.conf
docker exec web nginx -s reload
```
- [ ] `docker exec client curl -sI --cacert /certs-out/root-ca.crt https://portal.local` → `HTTP/1.1 200 OK` (không dùng `-k`).
- [ ] `docker exec client curl -s --cacert /certs-out/root-ca.crt https://portal.local` → `<h1>NTC portal (HTTPS) OK</h1>`.

## Cleanup
```bash
sudo clab destroy -t chaos-tls.clab.yml
sudo rm -rf ../certs-out   # bind dir do docker tự tạo, chứa root CA
```
- [ ] Không còn container/certs-out sót lại.

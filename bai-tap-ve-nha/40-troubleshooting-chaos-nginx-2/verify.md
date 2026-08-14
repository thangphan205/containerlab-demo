# Verify checklist — Bài 40 chaos-nginx-2 (chạy trên server lab)

## Deploy
```bash
cd 40-troubleshooting-chaos-nginx-2/topology
sudo clab deploy -t chaos-nginx2.clab.yml
```
- [ ] Deploy sạch, cả 3 nginx reload OK (lb, web1, web2 — config đều có `pid /var/run/nginx.pid;`).
- [ ] `docker exec web1 ss -tlnp` → nginx :80; `docker exec web2 ss -tlnp` → nginx :80.
- [ ] Backend trực tiếp từ lb: `docker exec lb curl -s -o /dev/null -w "%{http_code}\n" http://10.0.14.11` → 200; `...http://10.0.14.12` → **404**.

## Triệu chứng
- [ ] Vòng 6 curl từ client:
  ```bash
  docker exec client sh -c 'for i in $(seq 1 6); do curl -s -o /dev/null -w "%{http_code}\n" -m 5 http://10.0.4.100; done'
  ```
  → trộn 502 + 404. **Ghi lại pattern thực tế** (⚠️ nginx passive health-check có thể tạm eject web1 sau vài lần 502 → pattern không đều, có thể ra chuỗi 404 liên tiếp; nếu lệch nhiều so với guide, chỉnh câu chữ guide "xen kẽ không đều").
- [ ] `docker exec lb tail /var/log/nginx/error.log` → `connect() failed (111: Connection refused) ... upstream: "http://10.0.14.11:8080/..."` (⚠️ nếu log không xuất hiện — check path log của image, chỉnh guide).

## Fix 1 (LB upstream port)
```bash
docker exec lb sed -i 's/server 10.0.14.11:8080;/server 10.0.14.11:80;/' /etc/nginx/nginx.conf
docker exec lb nginx -s reload
```
- [ ] Vòng 6 curl → chỉ còn 200/404 xen kẽ (hết 502).

## Fix 2 (web2 root sai)
```bash
docker exec web2 sed -i 's|root /usr/share/nginx/html-v2;|root /usr/share/nginx/html;|' /etc/nginx/nginx.conf
docker exec web2 nginx -s reload
```
- [ ] Vòng 6 curl body:
  ```bash
  docker exec client sh -c 'for i in $(seq 1 6); do curl -s -m 5 http://10.0.4.100; done'
  ```
  → 6/6 thành công, xen kẽ `backend web1 OK` / `backend web2 OK`.

## Cleanup
```bash
sudo clab destroy -t chaos-nginx2.clab.yml
```
- [ ] Không còn container sót.

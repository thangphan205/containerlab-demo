# Verify checklist — Bài 46 (1 container nginx + máy học viên làm client)

## Phần A — đã verify thật ✅

Môi trường chạy thử: **macOS + Docker Desktop, Docker Engine 29.4.3, image `nginx:1.27-alpine` (nginx 1.27.5)**. Toàn bộ output trong `lab-guide.md` chép từ lần chạy này.

- [x] `docker compose up -d` → `portal   Up   0.0.0.0:8080->80/tcp`.
- [x] `ping -c 3 127.0.0.1` → 0% loss.
- [x] `curl -4 -v -m 10 http://127.0.0.1:8080` → in `* Connected to ...`, `> GET /`, `* Request completely sent off`, rồi `curl: (56) Recv failure: Connection reset by peer` (exit code 56).
- [x] `docker exec portal nginx -T | grep listen` → `listen 127.0.0.1:80;`.
- [x] `docker exec portal sh -c 'cat /proc/net/tcp'` → `0100007F:0050` (= 127.0.0.1:80).
- [x] `docker exec portal wget -qO- -T 3 http://127.0.0.1/` → trả về trang HTML.
- [x] `docker exec portal sh -c 'wget -qO- -T 3 http://$(hostname -i)/'` → `can't connect to remote host (172.18.0.2): Connection refused`.
- [x] Sửa `listen 80;` trong `nginx/conf.d/default.conf` → `docker exec portal nginx -T | grep listen` thấy ngay config mới (mount thư mục, không mount file).
- [x] `docker exec portal nginx -s reload` → **không ăn**: `docker logs` in `[emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address in use)`, `curl` vẫn `(56)`.
- [x] `docker compose restart portal` → `/proc/net/tcp` đổi thành `00000000:0050` (0.0.0.0:80), `curl -4 -sI` → `HTTP/1.1 200 OK`.
- [x] `docker logs portal` sau khi thành công → access log ghi IP nguồn `192.168.65.1` (gateway VM của Docker Desktop), **không** phải `127.0.0.1`.
- [x] `ping 172.18.0.2` (IP container) từ macOS → 100% loss — đã ghi chú trong guide là hành vi bình thường của Docker Desktop, không phải triệu chứng.

## Phần B — cần tự xác nhận (chưa chạy được ở môi trường soạn bài)

### B1. Chữ ký pcap (cần quyền root/ChmodBPF)
Chạy trong lúc `curl -4 -m 10 http://127.0.0.1:8080` ở terminal khác:
```bash
# macOS
sudo tcpdump -nni lo0 -ttt 'tcp port 8080'
# Linux / WSL2
sudo tcpdump -nni lo  -ttt 'tcp port 8080'
```
- [ ] Thấy đủ `Flags [S]` → `[S.]` → `[.]` → `[P.]` (GET) → `[R.]`.
- [ ] `[R.]` xuất hiện **sau** gói chứa `GET`, không phải ngay sau `[S]`.
- [ ] Sau khi restart container (đã fix): thấy `[S]` → `[S.]` → `[.]` → `[P.]` GET → `[P.]` `200 OK` → `[F.]`.
- [ ] ⚠️ Nếu chuỗi thật khác (ví dụ `[F.]` thay vì `[R.]`, hoặc Docker Desktop trả `Empty reply` thay vì reset) → chép output thật vào bảng "chữ ký lỗi" và mục Bước 2 của lời giải.

### B2. Wireshark GUI
- [ ] **Windows**: Wireshark có interface *Adapter for loopback traffic capture* (Npcap tick loopback lúc cài) và bắt được traffic tới `127.0.0.1:8080`.
- [ ] **macOS**: interface `lo0` bắt được (Wireshark đã cài ChmodBPF).
- [ ] `Statistics → Flow Graph` vẽ đúng hình 5 mũi tên như trong lời giải.
- [ ] `Follow → TCP Stream` (trước khi fix) → chỉ thấy request, không có response.
- [ ] `tcp.flags.syn==1 && tcp.flags.ack==1` → **có gói** (điểm chốt của bài).

### B3. Khác biệt theo hệ điều hành
- [ ] **Windows Docker Desktop**: `curl` báo lỗi giống macOS? (`(56)` reset hay `(52) Empty reply`) — ghi lại để bổ sung vào guide nếu khác.
- [ ] **Linux Docker Engine**: `ping <IP container>` **thông** (khác macOS/Windows) — xác nhận để giữ nguyên ghi chú trong lời giải.
- [ ] **Linux**: access log ghi IP nguồn `172.x.0.1` thay vì `192.168.65.1`.
- [ ] **OrbStack** (macOS): hành vi có giống Docker Desktop không (OrbStack route được tới IP container → `ping 172.x` có thể **thông**) → nếu khác, thêm 1 dòng ghi chú vào lời giải.

## Dọn dẹp
```bash
docker compose down
```
- [ ] Không còn container `portal`, không còn network `46-wireshark-ping-ok-web-fail_default`.

## Trạng thái file trong repo
- [ ] `nginx/conf.d/default.conf` phải ở **trạng thái lỗi**: `listen 127.0.0.1:80;` (kiểm tra trước khi commit — rất dễ commit nhầm bản đã sửa).

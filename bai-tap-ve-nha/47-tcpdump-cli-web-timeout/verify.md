# Verify checklist — Bài 47 tcpdump-cli-web-timeout (chạy trên **server lab** qua SSH)

> Cùng loại lỗi với bài 46 nhưng khác số liệu (`192.168.20.0/26` thay vì `10.0.1.0/25`) và khác tên node (`sw-hq fw-hq web-hq pc-01 pc-02`) — hai lab chạy song song được, không đụng tên container.

## Deploy
```bash
cd 47-tcpdump-cli-web-timeout/topology
sudo clab deploy -t tcpdump-web.clab.yml
```
- [ ] Deploy sạch, 5 container (`sw-hq fw-hq web-hq pc-01 pc-02`).
- [ ] `docker exec fw-hq nft list ruleset` → `table inet filter`, chain `forward` `policy drop`, 3 rule, trong đó `ip saddr 192.168.20.0/26 tcp dport 80 accept` (⚠️ **risk**: xác nhận family `inet` nhận `ip saddr`; nếu lỗi → đổi `table ip filter` trong `nftables/ruleset.nft` **và** mọi chỗ nhắc `inet filter` trong lab-guide).
- [ ] `docker exec pc-02 which tcpdump` → có (⚠️ **risk**: `apk add` cần default route mgmt `eth0` — phải nằm **trước** `ip route replace default via 192.168.20.1`).
- [ ] `docker exec sw-hq ip link show master br0` → `eth1`, `eth2`, `eth3` enslaved.
- [ ] `docker exec pc-01 ping -c 2 192.168.20.150` → 0% loss.
- [ ] `docker exec web-hq curl -sI http://127.0.0.1` → `200 OK`.

## Triệu chứng
- [ ] `docker exec pc-02 ping -c 3 192.168.30.80` → **0% loss**.
- [ ] `docker exec pc-01 curl -m 10 -sI http://192.168.30.80` → `HTTP/1.1 200 OK`.
- [ ] `docker exec pc-02 curl -m 10 -sS http://192.168.30.80` → fail ~10s, `curl: (28) Connection timed out ...` (⚠️ nếu `Connection refused` → đang reject chứ không drop).

## Chữ ký DROP đọc bằng tcpdump (phần đặc thù bài 47)
```bash
# Terminal 1
docker exec pc-02 timeout 20 tcpdump -nni eth1 -ttt 'host 192.168.30.80'
# Terminal 2
docker exec pc-02 curl -m 15 -sS http://192.168.30.80
```
- [ ] Output chỉ có `Flags [S]` một chiều, không `[S.]`, không `[R]`.
- [ ] **`seq` giống hệt nhau** giữa các dòng (chứng minh retransmission, không phải kết nối mới) (⚠️ **risk**: xác nhận output tcpdump của image có in `seq` ở gói SYN; nếu định dạng khác → chép output thật vào lời giải thay khối mẫu).
- [ ] Delta `-ttt` ~1s → 2s → 4s (⚠️ nếu `-m 15` chưa đủ 4 dòng → tăng `-m 30` trong guide).
- [ ] `docker exec pc-02 timeout 15 tcpdump -nni eth1 'tcp[tcpflags] & tcp-rst != 0'` → **rỗng** (⚠️ **risk**: cú pháp `tcp[tcpflags] & tcp-rst != 0` cần quote đúng trong `docker exec`; nếu shell nuốt ký tự → bọc `sh -c '...'` và sửa guide).
- [ ] `docker exec pc-02 timeout 15 tcpdump -nni eth1 icmp` → rỗng trong lúc curl (nhưng có gói khi ping).
- [ ] `docker exec pc-02 ss -tn state syn-sent` trong lúc curl treo → thấy socket `SYN-SENT` tới `192.168.30.80:80` (⚠️ **risk**: xác nhận `ss` có trong image multitool; nếu thiếu → thay bằng `netstat -tn | grep SYN_SENT` hoặc bỏ mục này).

## Khoanh vùng hop chết
```bash
docker exec -d sw-hq  tcpdump -nni br0  -w /tmp/sw.pcap     'tcp port 80'
docker exec -d fw-hq  tcpdump -nni eth1 -w /tmp/fw-in.pcap  'tcp port 80'
docker exec -d fw-hq  tcpdump -nni eth2 -w /tmp/fw-out.pcap 'tcp port 80'
docker exec -d web-hq tcpdump -nni eth1 -w /tmp/web.pcap    'tcp port 80'
docker exec pc-02 curl -m 15 -sS http://192.168.30.80
docker exec fw-hq pkill tcpdump ; docker exec sw-hq pkill tcpdump ; docker exec web-hq pkill tcpdump
```
- [ ] `docker exec fw-hq sh -c 'tcpdump -nn -r /tmp/fw-in.pcap "src 192.168.20.150" 2>/dev/null | wc -l'` → **> 0**.
- [ ] `docker exec fw-hq sh -c 'tcpdump -nn -r /tmp/fw-out.pcap "src 192.168.20.150" 2>/dev/null | wc -l'` → **0**.
- [ ] `sw.pcap` có gói từ `.150` (⚠️ **risk**: bắt trên `br0` có thể trống tuỳ hành vi bridge → đổi guide sang `sw-hq eth2`).
- [ ] `web.pcap` không có gói nào từ `.150`.
- [ ] Lặp lại với `pc-01` → cả 4 file đều có gói từ `192.168.20.35`, `web.pcap` có `[S]` → `[S.]` → `[.]` → `[P.] HTTP: GET /` → `HTTP/1.1 200 OK`.

## Xác nhận bằng nftables
- [ ] `docker exec fw-hq nft list ruleset -a` → thấy rõ `192.168.20.0/26`.
- [ ] (Tuỳ chọn) `nft monitor trace`:
  ```bash
  docker exec fw-hq nft add rule inet filter forward meta nftrace set 1
  docker exec -d fw-hq sh -c 'nft monitor trace > /tmp/trace.log 2>&1'
  docker exec pc-02 curl -m 5 -sS http://192.168.30.80
  docker exec fw-hq sh -c 'pkill -f "nft monitor"; cat /tmp/trace.log'
  ```
  - [ ] Thấy verdict `drop` / `policy drop` cho gói từ `192.168.20.150` (⚠️ nếu container thiếu hỗ trợ trace → giữ nhãn "tuỳ chọn"; nhớ `nft -f /etc/nftables/ruleset.nft` dọn rule trace).

## Fix
```bash
docker exec fw-hq sed -i 's#ip saddr 192.168.20.0/26 tcp dport 80 accept#ip saddr 192.168.20.0/24 tcp dport 80 accept#' /etc/nftables/ruleset.nft
docker exec fw-hq nft -f /etc/nftables/ruleset.nft
```
- [ ] `nft list ruleset` → rule thành `192.168.20.0/24`, không chồng rule cũ.
- [ ] `docker exec pc-02 curl -sI http://192.168.30.80` → `HTTP/1.1 200 OK`.
- [ ] `docker exec pc-01 curl -sI http://192.168.30.80` → vẫn `HTTP/1.1 200 OK`.
- [ ] Đọc payload trên CLI:
  ```bash
  docker exec -d pc-02 timeout 15 tcpdump -nni eth1 -A -s0 'tcp port 80'
  docker exec pc-02 curl -s http://192.168.30.80 > /dev/null
  ```
  → thấy `GET / HTTP/1.1` và `HTTP/1.1 200 OK` + `order-system OK` (⚠️ nếu `-d` không in được output ra terminal → chuyển sang chạy 2 terminal như bước 3, sửa guide cho khớp).

## Kiểm chứng câu hỏi tự kiểm 1 (drop vs reject)
```bash
docker exec fw-hq nft insert rule inet filter forward ip saddr 192.168.20.150 tcp dport 80 reject with tcp reset
docker exec pc-02 curl -m 10 -sS http://192.168.30.80     # 'Connection refused' NGAY
docker exec fw-hq nft -f /etc/nftables/ruleset.nft         # dọn rule thử nghiệm
```
- [ ] `refused` tức thì; `tcpdump -nnv` thấy `[R.]` và TTL của nó khác TTL gói từ server thật (⚠️ nếu `reject with tcp reset` không hợp lệ trong chain `forward` của bản nft này → ghi lại lỗi, sửa/gỡ câu hỏi tự kiểm 1).

## Cleanup
```bash
sudo clab destroy -t tcpdump-web.clab.yml
```
- [ ] Không còn container sót.

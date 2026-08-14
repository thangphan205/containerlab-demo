# Verify checklist — Bài 46 wireshark-ping-ok-web-fail (chạy trên server lab)

## Deploy
```bash
cd 46-wireshark-ping-ok-web-fail/topology
sudo clab deploy -t wireshark-web.clab.yml
```
- [ ] Deploy sạch, 5 container (`sw fw web pc-a pc-b`).
- [ ] `docker exec fw nft list ruleset` → có `table inet filter` với đúng 3 rule: `ct state established,related accept`, `ip protocol icmp accept`, `ip saddr 10.0.1.0/25 tcp dport 80 accept`, chain `forward` `policy drop` (⚠️ **risk**: xác nhận family `inet` nhận cú pháp `ip saddr`; nếu nft báo lỗi → đổi table sang `table ip filter` trong `nftables/ruleset.nft` **và** sửa mọi chỗ nhắc `inet filter` trong lab-guide, gồm cả lệnh `nft add rule ... meta nftrace set 1`).
- [ ] `docker exec pc-b which tcpdump` → có (⚠️ **risk**: `apk add --no-cache tcpdump` trong `exec` cần default route mgmt `eth0`; nếu fail → kiểm tra `apk` chạy **trước** `ip route replace default via 10.0.1.1`. Nếu image đã có sẵn tcpdump thì bỏ dòng `apk` cho nhanh).
- [ ] `docker exec sw ip link show master br0` → thấy `eth1`, `eth2`, `eth3` enslaved.
- [ ] `docker exec pc-a ping -c 2 10.0.1.200` → 0% loss (bridge LAN hoạt động).
- [ ] `docker exec pc-b ip route` → `default via 10.0.1.1 dev eth1`.
- [ ] `docker exec web curl -sI http://127.0.0.1` → `200 OK` (nginx mặc định của multitool đang chạy, index.html đã ghi).

## Triệu chứng (trước khi sửa)
- [ ] `docker exec pc-b ping -c 3 10.0.2.80` → **0% loss** (mồi nhử ICMP hoạt động).
- [ ] `docker exec pc-a ping -c 3 10.0.2.80` → 0% loss.
- [ ] `docker exec pc-a curl -m 10 -sI http://10.0.2.80` → `HTTP/1.1 200 OK`.
- [ ] `docker exec pc-b curl -m 10 -sS http://10.0.2.80` → fail sau ~10s với `curl: (28) Connection timed out ...` (⚠️ **risk**: nếu ra `Connection refused` → gói đang bị reject chứ không drop, kiểm tra lại `policy drop` và ghi lại output thật để sửa guide; nếu ra `No route to host` → thiếu route/`ip_forward`).

## Bắt gói — chữ ký DROP
```bash
docker exec -d pc-b tcpdump -ni eth1 -w /tmp/pcb.pcap 'host 10.0.2.80'
docker exec pc-b curl -m 30 -sS http://10.0.2.80 ; docker exec pc-b pkill tcpdump
docker cp pc-b:/tmp/pcb.pcap .
```
- [ ] Mở `pcb.pcap` bằng Wireshark trên máy cá nhân (sau `scp`) → thấy SYN lặp lại, **không** có RST, **không** có ICMP.
- [ ] Khoảng cách retransmit ~1s → 2s → 4s → 8s (⚠️ nếu `-m 30` chưa đủ để thấy 4 lần gửi lại → tăng lên `-m 60` trong guide; nếu backoff khác quy luật → ghi lại số thật và sửa bảng trong lời giải).
- [ ] Wireshark **Analyze → Expert Information** gắn cờ retransmission.
- [ ] Test luôn cách 2: VS Code Containerlab extension → chuột phải `pc-b / eth1` → **Capture Traffic** → Wireshark mở realtime (⚠️ **risk**: xác nhận extension bắt được interface của node linux qua SSH remote; nếu không chạy → hạ mục này xuống "tuỳ chọn" trong guide).

## Khoanh vùng hop chết
Chạy 4 lệnh bắt nền, rồi `curl` từ `pc-b`:
```bash
docker exec -d sw  tcpdump -ni br0  -w /tmp/sw.pcap     'tcp port 80'
docker exec -d fw  tcpdump -ni eth1 -w /tmp/fw-in.pcap  'tcp port 80'
docker exec -d fw  tcpdump -ni eth2 -w /tmp/fw-out.pcap 'tcp port 80'
docker exec -d web tcpdump -ni eth1 -w /tmp/web.pcap    'tcp port 80'
docker exec pc-b curl -m 15 -sS http://10.0.2.80
```
- [ ] `sw.pcap`, `fw-in.pcap` → **có** SYN từ `10.0.1.200` (⚠️ **risk**: bắt trên `br0` có thể không thấy gói tuỳ hành vi bridge; nếu trống → đổi guide sang bắt trên `sw eth2`).
- [ ] `fw-out.pcap`, `web.pcap` → **không** có gói nào từ `10.0.1.200`.
- [ ] Lặp lại với `curl` từ `pc-a` → cả 4 pcap **đều có** gói từ `10.0.1.10`, có handshake đủ và `HTTP/1.1 200 OK`.

## Xác nhận bằng nftables
- [ ] `docker exec fw nft list ruleset -a` → thấy rõ `10.0.1.0/25`.
- [ ] (Tuỳ chọn, nâng cao) `nft monitor trace`:
  ```bash
  docker exec fw nft add rule inet filter forward meta nftrace set 1
  docker exec -d fw sh -c 'nft monitor trace > /tmp/trace.log 2>&1'
  docker exec pc-b curl -m 5 -sS http://10.0.2.80
  docker exec fw sh -c 'pkill -f "nft monitor"; cat /tmp/trace.log'
  ```
  - [ ] Thấy verdict `drop` / `policy drop` cho gói từ `10.0.1.200` (⚠️ **risk**: container có thể thiếu module `nf_tables trace` hoặc quyền; nếu fail → giữ nguyên nhãn "tuỳ chọn" trong guide, đừng để học viên kẹt ở bước này. Nhớ `nft -f /etc/nftables/ruleset.nft` để xoá rule trace trước khi sang bước sửa).

## Fix
```bash
docker exec fw sed -i 's#ip saddr 10.0.1.0/25 tcp dport 80 accept#ip saddr 10.0.1.0/24 tcp dport 80 accept#' /etc/nftables/ruleset.nft
docker exec fw nft -f /etc/nftables/ruleset.nft
```
- [ ] `docker exec fw nft list ruleset` → rule đã thành `10.0.1.0/24`, không chồng rule cũ (nhờ `flush ruleset` trong file).
- [ ] `docker exec pc-b curl -sI http://10.0.2.80` → `HTTP/1.1 200 OK`.
- [ ] `docker exec pc-a curl -sI http://10.0.2.80` → vẫn `HTTP/1.1 200 OK`.
- [ ] Bắt gói lại tại `pc-b` → handshake 3 bước đủ, Follow TCP Stream đọc được `internal-portal OK`, không còn `[TCP Retransmission]`.

## Kiểm chứng câu hỏi tự kiểm 1 (drop vs reject)
```bash
docker exec fw nft insert rule inet filter forward ip saddr 10.0.1.200 tcp dport 80 reject with tcp reset
docker exec pc-b curl -m 10 -sS http://10.0.2.80     # phải ra 'Connection refused' NGAY, không treo
docker exec fw nft -f /etc/nftables/ruleset.nft       # nạp lại file để dọn rule thử nghiệm
```
- [ ] `refused` tức thì, và pcap có RST (⚠️ nếu `reject with tcp reset` không hợp lệ trong chain `forward` của bản nft này → ghi lại lỗi và sửa/gỡ câu hỏi tự kiểm 1 trong guide).

## Cleanup
```bash
sudo clab destroy -t wireshark-web.clab.yml
```
- [ ] Không còn container sót.

## Sau khi verify xong
- [ ] Sửa guide theo output thật (nhất là các mục ⚠️).
- [ ] Chuyển thư mục ra khỏi `_draft/`, thêm dòng bài 46 vào bảng **Arc 5** trong `bai-tap-ve-nha/README.md` (và `README_en.md` nếu làm bản EN).

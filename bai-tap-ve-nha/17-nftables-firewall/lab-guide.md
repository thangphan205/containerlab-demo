**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Bài 17: nftables — Firewall Cơ Bản Giữa 2 Subnet

**Arc 4 — Security & Observability**

## Mục tiêu
- Viết rule `nftables` trên router trung gian để lọc traffic đi qua (chain `forward`, không phải `input`).
- Hiểu default-deny: policy `drop` mặc định, chỉ mở đúng traffic cần thiết (icmp + 1 cổng TCP cụ thể).
- Verify bằng cách thử kết nối thật (`nc`) thay vì chỉ đọc rule.

## Yêu cầu tiên quyết
Hoàn thành [02-ip-subnetting-thuc-chien](../02-ip-subnetting-thuc-chien/lab-guide.md) — quen mô hình router trung gian giữa 2 subnet.

## Sơ đồ topology
```
host-a (10.20.1.0/24) --- gw (nftables, ip_forward=1) --- host-b (10.20.2.0/24)
```
`gw` đã cài sẵn `nftables` (qua `apk add nftables` trong `exec`). Xem [`topology/nft-lab.clab.yml`](./topology/nft-lab.clab.yml).

## Đề bài / Yêu cầu

1. Deploy topology, gán IP cho `host-a`/`host-b`/2 interface của `gw` (giống Bài 02), gán default route cho 2 host (nhớ dùng `ip route replace`).
2. Trên `host-b`, mở 2 listener TCP để test:
   ```bash
   nc -l -p 8080 &
   nc -l -p 2323 &
   ```
3. Hoàn thiện [`nftables/ruleset.nft`](./nftables/ruleset.nft) (đang thiếu rule cho phép TCP port 8080) rồi nạp vào `gw`:
   ```bash
   nft -f nftables/ruleset.nft
   ```
4. Từ `host-a`, verify:
   - `ping -c 2 <ip host-b>` → phải thông (icmp được allow).
   - `nc -zv -w 2 <ip host-b> 8080` → phải **thành công** (port được mở trong rule).
   - `nc -zv -w 2 <ip host-b> 2323` → phải **thất bại/timeout** (không có rule allow, bị policy `drop` mặc định chặn).
5. Trên `gw`, chạy `nft list ruleset` — quan sát counter của từng rule đã tăng theo đúng traffic vừa test.
6. Ghi lại: nội dung `ruleset.nft` đã hoàn thiện + output bước 4 (cả 3 lệnh) + output `nft list ruleset`.

## Gợi ý
- Rule đặt trong chain `forward` (traffic đi **qua** router), không phải `input` (traffic gửi **đến chính** router) — 2 chain khác nhau hoàn toàn.
- Thêm từ khoá `counter` vào mỗi rule để `nft list ruleset` hiện được số packet/byte đã khớp — dễ debug hơn.
- Nếu `nc -l` chỉ nhận 1 kết nối rồi thoát, mở lại listener trước mỗi lần test là được (không cần daemon phức tạp cho bài này).

## Thảo luận và hỏi đáp
Bài tập này tự làm và tự xác minh kết quả. Nếu có thắc mắc hoặc cần trao đổi thêm, các bạn hãy đăng bài thảo luận trên group Facebook [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991).
## Bài tiếp theo
→ 13-troubleshooting-chaos-lab

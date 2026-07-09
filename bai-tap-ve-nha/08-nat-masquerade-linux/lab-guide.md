# Bài 08: NAT/Masquerade Trên Linux

**Arc 1 — Networking nền tảng nâng cao**

## Mục tiêu
- Cấu hình Source NAT (masquerade) bằng `nftables` trên Linux — mô phỏng mạng LAN nội bộ ra internet qua 1 gateway.
- Hiểu sự khác biệt giữa SNAT cố định và masquerade (tự detect IP WAN).
- Verify bằng cách quan sát IP nguồn từ phía server — xác nhận server thấy IP WAN (đã NAT), không phải IP private.

## Yêu cầu tiên quyết
Hoàn thành [17-nftables-firewall](../17-nftables-firewall/lab-guide.md) — quen cú pháp `nftables` và table/chain/rule.

## Sơ đồ topology
```
host-lan1 (10.0.1.10) ───┐
                          gw-nat (nftables, ip_forward=1) ─── server-pub (172.16.0.10)
host-lan2 (10.0.2.10) ───┘
```

- `gw-nat`: 3 interface — 2 phía LAN (`eth1`: `10.0.1.1/24`, `eth2`: `10.0.2.1/24`), 1 phía WAN (`eth3`: `172.16.0.1/24`).
- `server-pub`: mô phỏng server trên "internet" (`172.16.0.10/24`).

Xem [`topology/nat-lab.clab.yml`](./topology/nat-lab.clab.yml).

## Đề bài / Yêu cầu

1. Deploy topology. IP các interface của `gw-nat` và `server-pub` đã gán sẵn.
2. Gán IP cho `host-lan1` (`10.0.1.10/24`, default gw `10.0.1.1`) và `host-lan2` (`10.0.2.10/24`, default gw `10.0.2.1`). Nhớ dùng `ip route replace default`.
3. Trên `server-pub`, mở 1 listener TCP: `nc -l -p 80 &`.
4. Thử ping và `nc -zv 172.16.0.10 80` từ `host-lan1` — **chưa thông** vì `server-pub` không có route ngược lại về `10.0.1.0/24` (đây chính là lý do cần NAT).
5. Hoàn thiện [`nftables/nat-rules.nft`](./nftables/nat-rules.nft) — thêm rule `masquerade` cho traffic đi ra interface WAN (`eth3`). Nạp vào `gw-nat`:
   ```bash
   nft -f nftables/nat-rules.nft
   ```
6. Verify:
   - `host-lan1` ping `server-pub` → **phải thông** (traffic đã NAT, server thấy src IP là `172.16.0.1`).
   - `host-lan2` cũng ping `server-pub` → thông.
   - Trên `server-pub`, chạy `tcpdump -i eth1 -n` khi `host-lan1` ping — xác nhận src IP là `172.16.0.1` (IP WAN), **không** phải `10.0.1.10`.
   - Trên `gw-nat`, chạy `nft list ruleset` — xem counter của rule masquerade đã tăng.
7. Ghi lại: nội dung `nat-rules.nft` đã hoàn thiện + output tcpdump trên server + output `nft list ruleset`.

## Gợi ý
- `masquerade` nằm trong chain `postrouting` (hook `postrouting`, type `nat`, priority `srcnat`). Đây là Source NAT — đổi IP nguồn của gói tin trước khi đi ra WAN.
- Khác biệt `snat to <ip>` vs `masquerade`: SNAT cần chỉ định IP cố định, masquerade tự lấy IP của interface đi ra — tiện cho DHCP/dynamic IP trên WAN.
- Nếu thiếu lệnh `nft`, cài: `apk add nftables`.

## Bonus — DNAT (Port Forwarding)
Trong production, ngoài SNAT (LAN ra internet), còn cần **DNAT** (port forwarding từ internet vào LAN). Thử thêm:
1. Rule DNAT: redirect traffic đến `gw-nat:eth3` port `8080` về `host-lan1:80` (chain `prerouting`, type `nat`, `dnat to 10.0.1.10:80`).
2. Trên `host-lan1`, mở `nc -l -p 80`.
3. Từ `server-pub`: `nc -zv 172.16.0.1 8080` → phải kết nối được đến `host-lan1`.

## Cách nộp bài
Đăng nội dung `nat-rules.nft` + output tcpdump + output `nft list ruleset` vào Facebook group/comment bài viết tuần này.
**Hạn nộp:** 1 tuần kể từ ngày đăng bài.

## Bài tiếp theo
→ [09-ospf-multi-area](../09-ospf-multi-area/lab-guide.md): OSPF multi-area.

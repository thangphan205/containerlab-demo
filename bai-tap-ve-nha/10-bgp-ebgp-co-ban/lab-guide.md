# Bài 10: BGP eBGP Cơ Bản

**Arc 2 — Routing protocol chuyên sâu**

## Mục tiêu
- Thiết lập phiên eBGP giữa 2 AS.
- Quảng bá subnet nội bộ ra bên ngoài qua BGP.
- Verify bằng `show ip bgp summary` và `show ip bgp`.

## Yêu cầu tiên quyết
Hoàn thành [09-ospf-multi-area](../09-ospf-multi-area/lab-guide.md) — đã quen thao tác sửa `frr.conf` và `vtysh`.

## Sơ đồ topology
```
srv1 (AS100 LAN) --- r-as100 ======= r-as200 --- srv2 (AS200 LAN)
                        eBGP AS100 <-> AS200
```
Chi tiết node/IP xem [`topology/bgp-lab.clab.yml`](./topology/bgp-lab.clab.yml). Interface đã có IP sẵn trong `configs/<router>/frr.conf`, phần `router bgp` để trống (`TODO`).

## Đề bài / Yêu cầu

1. Trên `r-as100`, hoàn thiện `router bgp 100`:
   - Khai báo neighbor là IP của `r-as200` trên link chung, `remote-as 200`.
   - Quảng bá subnet LAN của `srv1` (`192.168.10.0/24`) vào BGP.
2. Trên `r-as200`, hoàn thiện `router bgp 200` tương tự: neighbor về phía `r-as100` (`remote-as 100`), quảng bá `192.168.20.0/24`.
3. Verify neighbor lên **Established**: `show ip bgp summary` trên cả 2 router.
4. Verify route học được: `show ip bgp` trên `r-as100` phải thấy `192.168.20.0/24` học từ AS200 (và ngược lại).
5. Từ `srv1`, ping tới `srv2` — xác nhận đi được qua đường BGP vừa quảng bá.
6. Ghi lại: output `show ip bgp summary` + `show ip bgp` trên cả 2 router, và kết quả ping.

## Gợi ý
- Cách quảng bá subnet: dùng `network 192.168.x.0/24` trong `address-family ipv4 unicast` (cần có route connected khớp chính xác trên interface LAN — ở đây interface đã gán đúng `/24` nên khớp sẵn). **Không dùng `redistribute connected`** — nó sẽ quảng bá luôn subnet quản lý `172.20.20.0/24` của containerlab, gây nhiễu route không liên quan bài học.
- Nếu neighbor không lên Established, kiểm tra `remote-as` đúng chiều chưa và 2 IP neighbor có ping được nhau không.
- **Quan trọng:** FRR 10.x mặc định bật `bgp ebgp-requires-policy` (theo RFC 8212) — session eBGP vẫn lên **Established** bình thường nhưng sẽ **không trao đổi route nào** nếu thiếu route-map/policy. Thêm `no bgp ebgp-requires-policy` trong `router bgp` để tắt yêu cầu này (bài học tuần này chưa học route-map, để dành cho tuần 06).

## Cách nộp bài
Đăng output các lệnh verify ở trên vào Facebook group/comment bài viết tuần này.
**Hạn nộp:** 1 tuần kể từ ngày đăng bài.

## Bài tiếp theo
→ 06-bgp-route-map-policy

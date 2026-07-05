# Bài 11: BGP Route-Map & Policy

**Arc 2 — Routing protocol chuyên sâu**

## Mục tiêu
- Dùng route-map + AS-path prepend để ép BGP chọn đường theo ý muốn, thay vì để BGP tự chọn theo AS-PATH ngắn nhất.
- Hiểu thứ tự BGP best-path selection (ít nhất bước AS-PATH length) và cách chính sách outbound ảnh hưởng đến lựa chọn của AS lân cận.

## Yêu cầu tiên quyết
Hoàn thành [10-bgp-ebgp-co-ban](../10-bgp-ebgp-co-ban/lab-guide.md) — đã biết thiết lập eBGP session cơ bản.

## Sơ đồ topology
```
srv1 (AS100 LAN) --- r-as100 ======= r-as200 (transit) ======= r-as300 --- srv3 (AS300 LAN)
                         \_______________ link trực tiếp (backup) ________________/
```
AS100 và AS300 có **2 đường**: qua transit AS200 (2 AS-hop), và 1 link trực tiếp backup (1 AS-hop). Chi tiết IP xem [`topology/bgp-policy-lab.clab.yml`](./topology/bgp-policy-lab.clab.yml).

**Config đã hoàn chỉnh sẵn** (eBGP đã lên Established cả 2 đường) — bạn không cần cấu hình lại phần peering.

## Vấn đề cần giải quyết

Mặc định, BGP chọn đường theo AS-PATH ngắn nhất → traffic giữa AS100 và AS300 sẽ **đi thẳng qua link trực tiếp** (backup, băng thông thấp) thay vì qua transit AS200 (đường chính, băng thông cao). Đây là hành vi không mong muốn trong thực tế.

## Đề bài / Yêu cầu

1. Trên `r-as100`: thêm route-map áp dụng **outbound** cho neighbor trên link trực tiếp (không phải neighbor qua AS200), dùng `set as-path prepend` để làm AS-PATH của `192.168.10.0/24` dài hơn khi quảng bá qua link trực tiếp.
2. Trên `r-as300`: làm tương tự cho `192.168.30.0/24` — prepend outbound trên neighbor link trực tiếp.
3. Verify trên `r-as300`: `show ip bgp 192.168.10.0/24` phải thấy đường qua AS200 (AS-PATH ngắn hơn) được chọn là best path.
4. Verify trên `r-as100`: `show ip bgp 192.168.30.0/24` tương tự — best path phải qua AS200.
5. Từ `srv1`, `traceroute` tới `srv3` — xác nhận đi qua `r-as200` (transit), không đi thẳng qua link trực tiếp.
6. Ghi lại: route-map đã viết trên `r-as100` và `r-as300`, output `show ip bgp <prefix>` 2 chiều, và kết quả traceroute.

## Gợi ý
- `set as-path prepend <asn> <asn>` — prepend càng nhiều lần thì AS-PATH càng dài, càng kém ưu tiên.
- Route-map cần gắn vào neighbor bằng `neighbor <ip> route-map <tên> out`, áp cho đúng neighbor trên link trực tiếp (không phải neighbor qua AS200).
- Nếu traceroute vẫn đi thẳng, kiểm tra lại route-map đã bind đúng chiều `out` và đúng neighbor chưa — dùng `show route-map` để xem route-map có được áp dụng không.

## Bonus — Local Preference (inbound traffic engineering)
AS-path prepend chỉ ảnh hưởng **outbound** (cách AS lân cận thấy route của mình). Để điều khiển **inbound** (cách router nội bộ chọn đường đi ra ngoài), dùng **Local Preference**:
- Thử thêm route-map **inbound** trên `r-as100`: `set local-preference 200` cho route nhận từ AS200 (transit), giữ nguyên default `100` cho route nhận từ link trực tiếp.
- Verify bằng `show ip bgp` — route với LP cao hơn sẽ được chọn bất kể AS-PATH.
- **Mở rộng:** Trong production, route-map luôn đi kèm **prefix-list** để lọc chính xác prefix nào được apply policy — tránh áp nhầm cho toàn bộ route. Tìm hiểu thêm `ip prefix-list` trên FRR nếu muốn hiểu sâu.

## Cách nộp bài
Đăng route-map đã viết + output verify ở trên vào Facebook group/comment bài viết tuần này.
**Hạn nộp:** 1 tuần kể từ ngày đăng bài.

## Bài tiếp theo
→ 07-linux-bridge-vlan

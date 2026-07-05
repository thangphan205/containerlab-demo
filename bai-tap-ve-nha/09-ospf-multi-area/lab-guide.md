# Bài 09: OSPF Multi-Area

**Arc 2 — Routing protocol chuyên sâu**

## Mục tiêu
- Thiết kế OSPF nhiều area: area 1 — area 0 (backbone) — area 2.
- Hiểu vai trò ABR (Area Border Router) và luật vàng OSPF: mọi area phải nối trực tiếp hoặc gián tiếp với area 0.
- Verify hội tụ bằng `show ip ospf neighbor` và `show ip route ospf`.

## Yêu cầu tiên quyết
Hoàn thành [03-static-route-multi-hop](../03-static-route-multi-hop/lab-guide.md) — hiểu khái niệm định tuyến multi-hop trước khi chuyển sang dynamic routing.

## Sơ đồ topology
```
srv1 --- R1 ======= R2 ======= R3 ======= R4 --- srv2
       (area 1)  (area1|area0)(area0|area2) (area 2)
```
- R1: nội bộ area 1
- R2: ABR giữa area 1 và area 0
- R3: ABR giữa area 0 và area 2
- R4: nội bộ area 2

Chi tiết node/IP xem [`topology/ospf-lab.clab.yml`](./topology/ospf-lab.clab.yml). Interface đã có sẵn IP trong `configs/<router>/frr.conf`, phần OSPF để trống (`TODO`) — tự cấu hình.

## Đề bài / Yêu cầu

1. Trên mỗi router (r1–r4), hoàn thiện phần `router ospf` còn thiếu trong `configs/<router>/frr.conf`:
   - Gán `router-id` (dùng chính IP loopback nếu muốn, hoặc IP interface bất kỳ, miễn duy nhất).
   - Khai báo đúng area cho từng interface theo sơ đồ ở trên.
2. Deploy lại lab sau khi sửa config (`sudo clab destroy` rồi `deploy` lại để nạp config mới, hoặc `docker exec ... vtysh` sửa live rồi `write memory`).
3. Verify trên **R2 và R3** (2 router ABR): `show ip ospf neighbor` phải thấy đủ neighbor 2 phía; `show ip route ospf` phải thấy route học được từ area còn lại.
4. Kiểm tra LSDB (Link-State Database): chạy `show ip ospf database` trên R2 — phải thấy cả LSA Type 1 (Router-LSA) từ area 1 lẫn area 0. Hiểu LSDB là nền tảng để debug OSPF sâu hơn routing table.
5. Từ `srv1`, ping và `traceroute` tới `srv2` — phải đi qua đủ R1 → R2 → R3 → R4.
6. Ghi lại: output `show ip ospf neighbor` trên R2 + R3, output `show ip ospf database` trên R2, output `show ip route ospf` trên R1 + R4, và kết quả traceroute từ srv1 tới srv2.

## Gợi ý
- Nếu 2 router cùng area không lên neighbor, kiểm tra area ID khai báo trên interface có khớp 2 đầu không (`show ip ospf interface`).
- R2 và R3 là ABR — mỗi router này có 2 interface thuộc **2 area khác nhau**, không phải cùng area.
- **Mở rộng kiến thức:** Trong mạng production lớn, các area biên thường được cấu hình là **stub area** hoặc **totally stubby area** để giảm kích thước LSDB trên các router nội bộ — tìm hiểu thêm nếu muốn hiểu sâu OSPF scaling.

## Cách nộp bài
Đăng output các lệnh verify ở trên vào Facebook group/comment bài viết tuần này.
**Hạn nộp:** 1 tuần kể từ ngày đăng bài.

## Bài tiếp theo
→ 10-bgp-ebgp-co-ban

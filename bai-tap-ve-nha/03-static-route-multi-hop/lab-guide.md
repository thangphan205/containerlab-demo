**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Bài 03: Static Route Multi-Hop

**Arc 1 — Networking nền tảng nâng cao**

## Mục tiêu
- Cấu hình static route qua nhiều hop (không dùng default route ở router trung gian).
- Hiểu vì sao mỗi router trung gian cần biết đường đến **từng mạng đích cụ thể**, không thể chỉ dựa vào 1 route mặc định.
- Dùng `traceroute` để xác minh đường đi gói tin qua đúng các hop dự kiến.

## Yêu cầu tiên quyết
Hoàn thành [02-ip-subnetting-thuc-chien](../02-ip-subnetting-thuc-chien/lab-guide.md).

## Sơ đồ topology
Chuỗi 4 router nối tiếp, 2 đầu có LAN với host. Xem [`topology/static-route-lab.clab.yml`](./topology/static-route-lab.clab.yml). IP các link point-to-point **đã được gán sẵn**, IP LAN 2 đầu và toàn bộ static route thì **chưa có** — tự cấu hình.

```
host-1 (10.0.1.0/24) -- R1 -- R2 -- R3 -- R4 -- host-2 (10.0.2.0/24)
                       10.0.12.0/30  10.0.23.0/30  10.0.34.0/30  (đã gán sẵn trên link giữa router)
```

## Đề bài / Yêu cầu

1. Gán IP cho `host-1` (trong `10.0.1.0/24`), `host-2` (trong `10.0.2.0/24`), và interface LAN tương ứng trên `R1`, `R4`.
2. Trên **mỗi router** (R1, R2, R3, R4), thêm static route sao cho gói tin từ `host-1` đến `host-2` và ngược lại đi được trọn vẹn.
   - **Không được dùng route mặc định (`0.0.0.0/0`) trên R2 và R3** — 2 router này phải có static route rõ ràng tới từng subnet cụ thể (`10.0.1.0/24` và `10.0.2.0/24`). Đây là trọng tâm bài học: hiểu router trung gian cần biết đường đi cụ thể, không phải "đẩy hết cho gateway".
   - R1 và R4 được phép dùng default route hướng vào phía router láng giềng nếu muốn.
3. Gán default route cho `host-1` và `host-2` trỏ về router LAN tương ứng (R1, R4).

**Lưu ý:** mọi node đều đã có sẵn 1 default route qua `eth0` (mgmt network của containerlab) — dùng `ip route replace default via <ip> dev <iface>` thay vì `ip route add default ...` để tránh lỗi `File exists`. Static route tới subnet cụ thể (không phải default) thì dùng `ip route add <subnet> via <ip> dev <iface>` bình thường, không bị conflict.
4. Verify bằng `traceroute` từ `host-1` đến `host-2` — phải thấy đủ 4 hop trung gian đúng thứ tự R1 → R2 → R3 → R4.
5. Ghi lại: bảng static route đã thêm trên từng router (`ip route show`) + output `traceroute`.

## Gợi ý
- Nếu `ping` từ `host-1` đi được nhưng `traceroute`/reply không quay lại đúng đường, kiểm tra static route **chiều ngược lại** trên từng router.

## Bonus — Tại sao cần dynamic routing?
Sau khi hoàn thành bài chính, thử **tắt 1 interface trung gian** (ví dụ: `docker exec r2 ip link set eth2 down`). Quan sát:
- `host-1` ping `host-2` sẽ **mất vĩnh viễn** — static route không có cơ chế tự phát hiện link down và chuyển đường (convergence time = vô hạn).
- So sánh với OSPF ở Bài 04: khi link mất, OSPF sẽ tự tính lại đường đi trong vài giây.

Đây chính là lý do thực tế tại sao mạng production không bao giờ chỉ dùng static route.

## Thảo luận và hỏi đáp
Bài tập này tự làm và tự xác minh kết quả. Nếu có thắc mắc hoặc cần trao đổi thêm, các bạn hãy đăng bài thảo luận trên group Facebook [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991).
## Bài tiếp theo
→ 09-ospf-multi-area

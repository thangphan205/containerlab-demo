**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Bài 02: IP Subnetting Thực Chiến

**Arc 1 — Networking nền tảng nâng cao**

## Mục tiêu
- Chia subnet bằng VLSM cho 1 khối địa chỉ thật, đáp ứng đúng số host từng phòng ban.
- Gán địa chỉ vào interface thật trên containerlab, cấu hình default gateway cho host.
- Xác minh 3 phòng ban đi qua router trung tâm mà không lãng phí địa chỉ.

## Yêu cầu tiên quyết
Hoàn thành [01-cai-dat-containerlab](../01-cai-dat-containerlab/lab-guide.md): containerlab chạy được, biết `docker exec` vào container.

## Sơ đồ topology
1 router trung tâm `gw` nối 3 mạng LAN — mỗi LAN có 1 host đại diện cho 1 phòng ban. Xem [`topology/subnet-lab.clab.yml`](./topology/subnet-lab.clab.yml).

```
host-a (Kinh doanh, cần 50 host)  --- eth1 ---\
host-b (Kỹ thuật, cần 20 host)    --- eth2 --- gw (router, ip_forward=1)
host-c (Vận hành, cần 10 host)    --- eth3 ---/
```

Khối địa chỉ được cấp: **172.20.4.0/22**.

## Đề bài / Yêu cầu

1. Dùng VLSM chia `172.20.4.0/22` thành 3 subnet, mỗi subnet đủ chỗ cho số host yêu cầu **và không được lãng phí quá nhiều địa chỉ** (chọn prefix nhỏ nhất đáp ứng đủ +2 địa chỉ dự phòng):
   - Kinh doanh (host-a): 50 host
   - Kỹ thuật (host-b): 20 host
   - Vận hành (host-c): 10 host
2. Deploy topology, sau đó tự gán IP cho từng interface bằng `docker exec ... ip addr add <ip>/<prefix> dev eth1` theo bảng bạn vừa tính (gw có 3 interface, mỗi host có 1 interface).
3. Bật `ip_forward` trên `gw` (đã có sẵn trong topology qua `exec`, tự kiểm tra lại bằng `sysctl net.ipv4.ip_forward`).
4. Gán default route cho từng host trỏ về IP của `gw` trên cùng subnet. **Lưu ý:** container đã có sẵn 1 default route qua `eth0` (mgmt network của containerlab) nên `ip route add default ...` sẽ báo lỗi `File exists` — dùng `ip route replace default via <ip-gw> dev eth1` thay vì `add`.
5. Verify: từ `host-a` ping được `host-b` và `host-c` (đi qua `gw`).
6. Ghi lại: bảng subnet đã chia (network/mask/broadcast/usable range cho từng phòng ban) + output `ip addr` trên `gw` + output ping.

## Gợi ý
- VLSM: sắp xếp yêu cầu từ lớn đến nhỏ trước khi chia sẽ dễ tính hơn.
- `topology/subnet-lab.clab.yml` cố tình **không gán sẵn IP** — đây là phần bạn phải tự làm.

## Thảo luận và hỏi đáp
Bài tập này tự làm và tự xác minh kết quả. Nếu có thắc mắc hoặc cần trao đổi thêm, các bạn hãy đăng bài thảo luận trên group Facebook [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991).
## Bài tiếp theo
→ 03-static-route-multi-hop

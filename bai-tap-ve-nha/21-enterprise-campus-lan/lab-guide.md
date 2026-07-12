# Bài 21: Dựng campus LAN cho trụ sở NTC (VLAN access–distribution)

**Arc 7 — Triển khai mạng doanh nghiệp (dự án xuyên suốt)**

## Mục tiêu
- Thiết kế campus LAN 2 lớp **access–distribution** — mô hình chuẩn văn phòng doanh nghiệp.
- Cấu hình VLAN trải qua **nhiều switch** (access port, trunk port trên Linux bridge VLAN-aware).
- Inter-VLAN routing tập trung tại gateway FRR (sub-interface 802.1Q).
- Đọc yêu cầu nghiệp vụ → tự quyết định cấu hình (không có lệnh cho sẵn từng bước).

## Yêu cầu tiên quyết
- Hoàn thành [04-linux-bridge-vlan](../04-linux-bridge-vlan/lab-guide.md) — thao tác `bridge vlan` trên 1 switch.
- Hoàn thành [02-ip-subnetting-thuc-chien](../02-ip-subnetting-thuc-chien/lab-guide.md) — gán IP thủ công.

## Bối cảnh công ty
Bạn là network engineer mới vào **công ty NTC** (trụ sở TP.HCM). CTO giao dự án 4 tuần dựng lại toàn bộ hạ tầng mạng — mỗi tuần bàn giao 1 lớp. **Tuần 1: campus LAN trụ sở.**

Yêu cầu nghiệp vụ từ CTO:
1. Phòng **Kinh doanh** (~40 người, tầng 1 + tầng 2) và phòng **Kỹ thuật** (~15 người, tầng 1) phải **tách miền quảng bá** — broadcast/ARP của phòng này không được tràn sang phòng kia.
2. Nhân viên Kinh doanh ngồi ở **cả 2 tầng** (2 switch access khác nhau) vẫn phải chung một mạng lớp 2.
3. Hai phòng vẫn liên lạc được với nhau, nhưng **mọi traffic liên phòng phải đi qua gateway** (để tuần sau gắn kiểm soát/firewall).
4. Chuẩn đánh địa chỉ đã được duyệt: Kinh doanh `172.16.10.0/24` (VLAN 10), Kỹ thuật `172.16.20.0/24` (VLAN 20), gateway mỗi phòng luôn là `.1`.

## Sơ đồ topology
```
 pc-sales-1     pc-it-1              pc-sales-2
 (VLAN 10)     (VLAN 20)             (VLAN 10)
     |             |                     |
    eth1          eth2                  eth1
     +--- sw-acc1 ---+                sw-acc2        <- switch access (tầng 1, tầng 2)
           |eth3                        |eth2
         trunk                        trunk
           |eth1                        |eth2
           +--------- sw-dist ----------+            <- switch distribution
                        |eth3
                      trunk
                        |eth1
                      dist-1                          <- gateway FRR (router-on-a-stick)
                 eth1.10 = 172.16.10.1/24
                 eth1.20 = 172.16.20.1/24
```

Chi tiết xem [`topology/campus-lan-lab.clab.yml`](./topology/campus-lan-lab.clab.yml).

Đã chuẩn bị sẵn (mô phỏng thiết bị vừa bóc hộp, đã đi dây):
- 3 switch (`sw-acc1`, `sw-acc2`, `sw-dist`): bridge `br0` VLAN-aware đã tạo, port đã enslave — **chưa gán VLAN cho port nào**.
- `dist-1` (FRR): sub-interface `eth1.10`/`eth1.20` đã tạo, IP gateway đã gán trong `frr.conf`.
- 3 PC: chưa có IP.

## Đề bài / Yêu cầu

1. Lập **bảng kế hoạch VLAN** trước khi gõ lệnh: với mỗi switch, port nào là access (VLAN nào, PVID/untagged) — port nào là trunk (mang những VLAN nào, tagged). Đây là thói quen bắt buộc khi triển khai thật.
2. Cấu hình VLAN membership trên **cả 3 switch** bằng `bridge vlan add/del` theo bảng của bạn:
   - Port nối PC: access đúng VLAN của phòng.
   - Port giữa switch↔switch và switch↔gateway: trunk mang cả VLAN 10 + 20.
3. Gán IP cho 3 PC theo chuẩn công ty: `pc-sales-1` = `172.16.10.11`, `pc-sales-2` = `172.16.10.12`, `pc-it-1` = `172.16.20.11`, kèm default gateway `.1` tương ứng. Dùng `ip route replace default via <ip> dev eth1` (không dùng `add` — container đã có sẵn default route qua `eth0` mgmt).
4. Verify theo đúng 4 yêu cầu nghiệp vụ:
   - `pc-sales-1` ping `pc-sales-2` — **được** (cùng VLAN, xuyên 3 switch — yêu cầu 2).
   - `pc-sales-1` ping `pc-it-1` — **được**, nhưng `traceroute` phải cho thấy đi **2 hop** qua `172.16.10.1` (yêu cầu 3).
   - `bridge vlan show` trên cả 3 switch khớp bảng kế hoạch.
5. Bằng chứng tách miền quảng bá (yêu cầu 1): trên `dist-1` chạy `tcpdump -e -i eth1 -c 20` trong lúc ping liên phòng — chỉ ra frame nào mang tag VLAN 10, frame nào tag VLAN 20.
6. Ghi lại: bảng kế hoạch VLAN, output `bridge vlan show` cả 3 switch, kết quả ping/traceroute, vài dòng tcpdump có tag 802.1Q.

## Gợi ý
- Bridge VLAN-aware mặc định gán VID 1 cho mọi port khi enslave — xoá VID 1 trước khi thêm VID đúng, nếu không port dính 2 VLAN cùng lúc.
- Access port cần cả `pvid` lẫn `untagged`; trunk port chỉ cần thêm VID (tagged mặc định).
- Ping cùng VLAN khác switch không thông → soi từng trunk trên đường đi (`sw-acc1:eth3`, `sw-dist:eth1`...) đã mang đủ VID chưa.
- `traceroute` chỉ hiện 1 hop nghĩa là 2 PC đang chung miền L2 — kiểm tra lại VLAN membership.

## Bonus
- Thêm **VLAN 99 (management)**: gán IP `172.16.99.0/24` cho chính các switch (SVI = gán IP lên `br0` với VLAN 99, dùng `bridge vlan add dev br0 vid 99 self untagged pvid`), để từ `dist-1` ping được cả 3 switch — mô phỏng mạng quản trị thiết bị thật.

## Thảo luận và hỏi đáp
Bài tập này tự làm và tự xác minh kết quả. Nếu có thắc mắc hoặc cần trao đổi thêm, các bạn hãy đăng bài thảo luận trên group Facebook [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991).
## Bài tiếp theo
→ Bài 22 — Tuần 2 của dự án: gateway `dist-1` chết là cả trụ sở mất mạng. CTO yêu cầu **gateway dự phòng (VRRP) + routing core OSPF + server farm**. (sắp ra mắt)

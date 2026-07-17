# Bài 22: Routing core OSPF + gateway HA (VRRP) cho NTC

**Arc 7 — Triển khai mạng doanh nghiệp (dự án xuyên suốt)**

## Mục tiêu
- Dựng lớp **routing core** bằng OSPF area 0 (dist ↔ core, passive-interface phía người dùng).
- Gateway dự phòng **VRRP active/active theo VLAN** (chia tải: mỗi dist làm master 1 VLAN, backup VLAN kia).
- Nâng cấp HA **không đổi cấu hình client** — gateway `.1` tuần trước trở thành VRRP VIP.
- Đo thời gian failover thực tế khi gateway master chết.

## Yêu cầu tiên quyết
- [21-enterprise-campus-lan](../21-enterprise-campus-lan/lab-guide.md) — tuần 1 của dự án.
- [09-ospf-multi-area](../09-ospf-multi-area/lab-guide.md) — cấu hình OSPF trên FRR.
- [06-vrrp-ecmp-gateway-ha](../06-vrrp-ecmp-gateway-ha/lab-guide.md) — khái niệm VRRP.

## Bối cảnh công ty
**Tuần 2 của dự án NTC.** Tuần trước campus LAN chạy tốt được 3 ngày thì `dist-1` treo — cả trụ sở mất mạng 2 tiếng, CTO bị sếp gọi lên. Yêu cầu tuần này:
1. **Không còn điểm chết đơn (SPOF) ở gateway**: thêm `dist-2`, một con chết thì con kia tiếp quản trong vài giây, **người dùng không phải đổi bất kỳ cấu hình nào** (gateway của PC vẫn là `.1`).
2. Tận dụng cả 2 thiết bị thay vì để 1 con "ngồi chơi": VLAN 10 đi qua `dist-1`, VLAN 20 đi qua `dist-2` khi cả hai cùng sống.
3. Công ty triển khai ERP nội bộ — dựng **server farm** (`172.16.30.0/24`) sau router lõi `core`; toàn bộ định tuyến nội bộ dùng **OSPF** (hết thời gõ static route mỗi lần thêm mạng).

> Ghi chú topology: campus rút gọn còn 1 switch `sw-campus` (VLAN đã cấu hình sẵn — đúng nội dung bạn đã làm ở bài 21) để dành RAM cho lớp mới. Kỹ thuật không đổi.

## Sơ đồ topology
```mermaid
graph TD
    subgraph server_farm ["Server Farm (172.16.30.0/24)"]
        srv-app["srv-app<br>172.16.30.10/24 (ERP App, Nginx)"]
    end

    subgraph core_layer ["Core Layer"]
        core["core<br>Router ID: 10.255.0.3<br>eth1: 10.0.13.2/30 | eth2: 10.0.23.2/30<br>eth3: 172.16.30.1/24"]
    end

    subgraph dist_ha ["Distribution Gateway Pair (VRRP HA + OSPF Area 0)"]
        dist-1["dist-1 (Router ID 10.255.0.1)<br>eth2: 10.0.13.1/30<br>VIP10 (Master): 172.16.10.1<br>VIP20 (Backup): 172.16.20.1"]
        dist-2["dist-2 (Router ID 10.255.0.2)<br>eth2: 10.0.23.1/30<br>VIP10 (Backup): 172.16.10.1<br>VIP20 (Master): 172.16.20.1"]
    end

    subgraph campus ["Campus L2 Switch"]
        sw-campus["sw-campus<br>VLAN 10 & 20 Trunking"]
    end

    subgraph clients ["End User PCs"]
        pc-sales-1["pc-sales-1<br>VLAN 10 (172.16.10.11)<br>gw: 172.16.10.1"]
        pc-it-1["pc-it-1<br>VLAN 20 (172.16.20.11)<br>gw: 172.16.20.1"]
    end

    srv-app --- "eth1 <-> eth3" --- core
    core --- "eth1 <-> eth2<br>(10.0.13.0/30)" --- dist-1
    core --- "eth2 <-> eth2<br>(10.0.23.0/30)" --- dist-2
    dist-1 -- "eth1 (Trunk) <-> eth3" --- sw-campus
    dist-2 -- "eth1 (Trunk) <-> eth4" --- sw-campus
    sw-campus -- "eth1 <-> eth1" --- pc-sales-1
    sw-campus -- "eth2 <-> eth1" --- pc-it-1
```

Chi tiết xem [`topology/routing-core-lab.clab.yml`](./topology/routing-core-lab.clab.yml).

Đã chuẩn bị sẵn:
- Campus + PC + srv-app: cấu hình đầy đủ (lớp tuần trước).
- `dist-1`, `dist-2`, `core`: IP interface đã gán trong `frr.conf`; macvlan `vrrp4-10`/`vrrp4-20` + VIP đã tạo sẵn (FRR `vrrpd` yêu cầu device này — xem ghi chú trong topology).
- **Việc của bạn**: phần `TODO` trong `configs/*/frr.conf` — OSPF trên 3 router, VRRP trên 2 dist.

## Đề bài / Yêu cầu

1. Cấu hình **OSPF area 0** trên `dist-1`, `dist-2`, `core` theo TODO trong `frr.conf`:
   - Router-id: `10.255.0.1` / `.2` / `.3`.
   - Quảng bá đủ các mạng p2p + VLAN + server farm.
   - Bật passive (`ip ospf passive` dưới interface) trên mọi interface hướng người dùng/server (giải thích trong bài nộp: vì sao đây là chuẩn bắt buộc ở mạng thật).
2. Cấu hình **VRRP** trên 2 dist: vrid 10 (VIP `172.16.10.1`) và vrid 20 (VIP `172.16.20.1`), priority chéo — `dist-1` master VLAN 10, `dist-2` master VLAN 20.
3. Verify trạng thái:
   - `show ip ospf neighbor` trên `core` — đủ 2 neighbor `Full`.
   - `show ip route ospf` trên `dist-1` — thấy `172.16.30.0/24`.
   - `show vrrp` trên cả 2 dist — vrid 10/20 đúng Master/Backup như thiết kế.
4. Verify đường đi dữ liệu:
   - `pc-sales-1` → `srv-app`: `curl -s -o /dev/null -w "%{http_code}\n" http://172.16.30.10` trả `200`; `traceroute` đi qua `172.16.10.1` rồi tới core.
   - `pc-it-1` → `srv-app`: traceroute đi qua `172.16.20.1` — xác nhận VLAN 20 đang dùng `dist-2` (chia tải).
5. **Failover test** (yêu cầu 1 của CTO): từ `pc-sales-1` chạy `ping 172.16.30.10` liên tục; trên `dist-1` đánh `ip link set eth1 down` (giả lập chết trunk). Đếm số gói mất, xác nhận `show vrrp` trên `dist-2` đã lên Master cả 2 vrid, traceroute giờ đi `dist-2`. Bật lại link, quan sát preempt.
6. Ghi lại: output các lệnh show, kết quả traceroute trước/sau failover, số gói ping mất.

## Gợi ý
- FRR block VRRP nằm **dưới `interface eth1.10` / `eth1.20`** (`vrrp 10`, `vrrp 10 ip ...`, `vrrp 10 priority ...`). Sửa config bằng `vtysh`, hoặc sửa file rồi nạp bằng `docker exec <node> vtysh -f /etc/frr/frr.conf`. **KHÔNG dùng `docker restart`** — restart làm container mất toàn bộ interface do containerlab tạo (veth/macvlan chỉ được dựng lúc deploy); nếu lỡ restart, destroy + deploy lại lab.
- `show vrrp` không thấy gì → kiểm tra `vrrpd=yes` trong `/etc/frr/daemons` và macvlan `vrrp4-10`/`vrrp4-20` tồn tại (`ip -d link show`).
- OSPF neighbor không lên → soi network statement khớp đúng subnet /30 và interface không bị passive nhầm.
- Failover mất gói vô hạn → VIP chưa nằm trên macvlan của dist-2, hoặc priority 2 bên bằng nhau.

## Bonus
- Chỉnh **OSPF cost** trên uplink để traffic từ VLAN 10 về server farm ưu tiên đường `dist-1 → core` ngay cả khi cả 2 đường cùng sống; xác nhận bằng `show ip route` và traceroute.
- Giải thích trong bài nộp: vì sao lab này chỉ cần **1 area 0** trong khi bài 09 phải chia multi-area? Quy mô nào thì nên chia?

## Thảo luận và hỏi đáp
Bài tập này tự làm và tự xác minh kết quả. Nếu có thắc mắc hoặc cần trao đổi thêm, các bạn hãy đăng bài thảo luận trên group Facebook [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991).
## Bài tiếp theo
→ Bài 23 — Tuần 3: NTC khai trương **chi nhánh Hà Nội**, thuê kênh truyền riêng, chạy eBGP giữa 2 site. (sắp ra mắt)

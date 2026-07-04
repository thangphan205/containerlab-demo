# 📚 Bài Tập Về Nhà — Network Thực Chiến

Series bài tập về nhà dài hơi dành cho học viên đã có nền tảng CCNA, thực hành trực tiếp trên **containerlab**. Mỗi tuần ra 1 bài, không kèm lời giải sẵn — học viên tự làm, thảo luận trong Facebook group/comment, đáp án công bố sau ~1 tuần cùng video giải thích trên [Youtube - Network Thực Chiến](https://www.youtube.com/@NetworkThucChien).

Toàn bộ nội dung **mã nguồn mở** (xem [LICENSE](../LICENSE)) — mọi người tự do dùng, sửa, đóng góp bài mới. Xem [CONTRIBUTING.md](./CONTRIBUTING.md).

## Cách tham gia

1. Đọc `lab-guide.md` trong thư mục tuần hiện tại — đọc kỹ Mục tiêu + Yêu cầu.
2. Tự deploy topology bằng containerlab, làm theo checklist nhiệm vụ (không có bước giải sẵn).
3. Đăng kết quả (ảnh, output lệnh verify) vào Facebook group/comment bài viết tuần đó.
4. Sau 1 tuần: đáp án (`loi-giai.md`) + video giải thích được công bố.

## Danh sách bài tập

| Tuần | Chủ đề | Arc | Trạng thái | Video |
|:---:|:---|:---|:---|:---|
| [00](./00-chuan-bi-server/lab-guide.md) | Chuẩn bị server | Arc 0 — Nền tảng | 🟢 Đang mở | — |
| [01](./01-cai-dat-containerlab/lab-guide.md) | Cài đặt containerlab | Arc 0 — Nền tảng | 🟢 Đang mở | — |
| [02](./02-ip-subnetting-thuc-chien/lab-guide.md) | IP subnetting thực chiến | Arc 1 — Networking nền tảng | 🟢 Đang mở | — |
| [03](./03-static-route-multi-hop/lab-guide.md) | Static route multi-hop | Arc 1 — Networking nền tảng | 🟢 Đang mở | — |
| [04](./04-ospf-multi-area/lab-guide.md) | OSPF multi-area | Arc 2 — Routing chuyên sâu | 🟢 Đang mở | — |
| 05 | BGP eBGP cơ bản | Arc 2 — Routing chuyên sâu | ⏳ Sắp ra mắt | — |
| 06 | BGP route-map & policy | Arc 2 — Routing chuyên sâu | ⏳ Sắp ra mắt | — |
| 07 | VLAN trunking trên Linux bridge | Arc 1 — Networking nền tảng | ⏳ Sắp ra mắt | — |
| 08 | Ansible cơ bản (push config nhiều router) | Arc 3 — Automation/NetDevOps | ⏳ Sắp ra mắt | — |
| 09 | Python parsing (audit routing table) | Arc 3 — Automation/NetDevOps | ⏳ Sắp ra mắt | — |
| 10 | systemd + journald | Arc 4 — System Ops & Observability | ⏳ Sắp ra mắt | — |
| 11 | Prometheus + node_exporter | Arc 4 — System Ops & Observability | ⏳ Sắp ra mắt | — |
| 12 | nftables firewall cơ bản | Arc 4 — System Ops & Observability | ⏳ Sắp ra mắt | — |
| 13 | Troubleshooting chaos lab (OSPF) | Arc 5 — Troubleshooting chaos lab | ⏳ Sắp ra mắt | — |
| 14 | VRRP + ECMP (Gateway HA) | Arc 1 — Networking nền tảng | 📋 Dự kiến | — |
| 15 | Git workflow cho network config | Arc 3 — Automation/NetDevOps | 📋 Dự kiến | — |
| 16 | BGP Local Preference + prefix-list | Arc 2 — Routing chuyên sâu | 📋 Dự kiến | — |
| 17 | STP/RSTP/MST — chống loop Layer 2 | Arc 1 — Networking nền tảng | 📋 Dự kiến | — |
| 18 | HSRP/GLBP (Gateway Redundancy kiểu Cisco, so với VRRP) | Arc 1 — Networking nền tảng | 📋 Dự kiến | — |
| 19 | QoS & traffic shaping cơ bản (tc, DSCP marking) | Arc 1 — Networking nền tảng | 📋 Dự kiến | — |
| 20 | Multi-vendor automation (NAPALM: Cisco/Juniper/Arista) | Arc 3 — Automation/NetDevOps | 📋 Dự kiến | — |
| 21 | NetFlow/sFlow — giám sát lưu lượng mạng | Arc 4 — System Ops & Observability | 📋 Dự kiến | — |
| 22 | Centralized logging (ELK) + Alertmanager | Arc 4 — System Ops & Observability | 📋 Dự kiến | — |

Các bài tiếp theo sẽ được bổ sung dần theo tiến độ và phản hồi từ học viên. Xem thêm các Arc dự kiến bên dưới.

## Các Arc trong series

- **Arc 0 — Chuẩn bị nền tảng (System Ops):** Chuẩn bị server, cài Docker + containerlab.
- **Arc 1 — Networking nền tảng nâng cao:** Subnetting, static routing, VLAN/bridge trên Linux, STP/RSTP/MST chống loop L2, HSRP/GLBP bên cạnh VRRP/ECMP (gateway redundancy), QoS/traffic shaping cơ bản, cấu hình bền vững (persistent config).
- **Arc 2 — Routing protocol chuyên sâu:** OSPF, IS-IS, BGP (route-reflector, route-map, RPKI), ảo hóa định tuyến VRF.
- **Arc 3 — Automation/NetDevOps:** Ansible/Netmiko/NAPALM, parsing output, đa dạng vendor (Cisco/Juniper/Arista) qua NAPALM driver abstraction, GitOps & CI/CD tự động verify cấu hình (Auto-grading).
- **Arc 4 — System Operations & Observability:** systemd, logging tập trung (syslog/ELK), Prometheus + Alertmanager (alerting), NetFlow/sFlow (giám sát lưu lượng), nftables firewall & bảo mật Control Plane.
- **Arc 5 — Troubleshooting chaos lab:** Lab bị cấy lỗi sẵn, tự chẩn đoán và sửa lỗi theo phương pháp khoa học.
- **Arc 6 — Advanced Security & VPN (Dự kiến):** IPSec VPN, Wireguard, Control Plane Policing (CoPP), AAA (TACACS+/RADIUS) & 802.1X NAC, ACL/zone segmentation, DHCP snooping & Dynamic ARP Inspection.

## Lưu ý quan trọng khi học & thực hành

### 💡 Tối ưu hóa tài nguyên server
Khi chạy các bài lab lớn (từ Arc 2 trở đi với 10+ container chạy FRR), để tránh quá tải RAM/CPU cho các máy ảo cá nhân hoặc WSL2:
- Tắt các routing daemon không sử dụng trong file `/etc/frr/daemons` (ví dụ: chỉ bật `ospfd` hoặc `bgpd`, tắt `ripd`, `ripngd`, `pimd`...).
- Thiết lập giới hạn RAM (limit) cho từng container trong file topology nếu cần thiết.

### 🌐 Khoảng cách giữa Lab và thực tế (Production)
- **Cấu hình bền vững (Persistence):** Các lệnh `ip addr` hay `ip route` gõ trực tiếp trong container sẽ mất khi destroy lab. Ở môi trường Production, hãy luôn lưu cấu hình vào file hệ thống (như `/etc/network/interfaces`, `/etc/netplan/` hoặc `write memory` trên FRR).
- **Cách ly mạng quản trị (Out-of-Band):** Trong lab, containerlab tạo sẵn interface `eth0` để kết nối ra ngoài (internet/quản trị). Ngoài thực tế, mạng OOB này luôn được chạy trên một kênh vật lý riêng biệt hoặc VRF độc lập để đảm bảo an toàn thông tin.

### 🏢 Từ giáo trình này đến Enterprise-ready — cần bổ sung thêm gì?
Series tập trung vào core networking/automation trên nền FRR + Linux container — đủ để nắm khái niệm, nhưng khi đưa vào mạng doanh nghiệp thật, cần tự bổ sung thêm:
- **Đa dạng vendor (Multi-vendor):** Lab dùng FRR để mô phỏng khái niệm chung; mạng doanh nghiệp thật thường multi-vendor (Cisco/Juniper/Arista...) — cần kiểm chứng lại config/automation script trên thiết bị hoặc emulator thật (GNS3, EVE-NG) trước khi áp dụng.
- **Staging/CI gate trước khi go-live:** Không push cấu hình thẳng vào Production. Luôn có môi trường staging + pipeline CI (xem Arc 3) verify tự động, kèm rollback plan rõ ràng trước khi go-live.
- **Capacity planning & kiểm thử tải:** Lab chỉ chạy vài container nhỏ; mạng thật cần kiểm thử hiệu năng, tải cao điểm, và khả năng mở rộng (scale) trước khi đưa vào vận hành.
- **Tuân thủ & audit bảo mật (Compliance/Security Audit):** Pentest định kỳ, audit, và các chuẩn tuân thủ theo ngành (PCI-DSS, ISO 27001...) — nằm ngoài phạm vi lab nhưng bắt buộc với hệ thống doanh nghiệp thật.

## 💬 Đóng góp ý kiến & Hợp tác

Nếu bạn có bất kỳ đóng góp ý kiến nào về lộ trình, phát hiện lỗi cấu hình (bug) khi thực hành, hoặc muốn đề xuất thêm các bài lab thực chiến mới:
- Xem chi tiết hướng dẫn đóng góp tại [CONTRIBUTING.md](file:///Users/thangpa/projects/containerlab-demo/bai-tap-ve-nha/CONTRIBUTING.md).
- Mở **Issue** hoặc tạo **Pull Request** trực tiếp trên repository này.
- Tham gia thảo luận, chia sẻ quá trình làm bài và nhận phản hồi tại Facebook group / cộng đồng **Network Thực Chiến**.

# 📚 Bài Tập Về Nhà — Network Thực Chiến

Series bài tập về nhà dài hơi dành cho học viên đã có nền tảng CCNA — tổng hợp các bài lab dựng bằng **containerlab**, bám sát cách triển khai thực tế ở môi trường enterprise (không phải lab lý thuyết thuần túy).

**Không có lời giải nào là hoàn hảo.** Đáp án công bố sau mỗi tuần chỉ là một cách làm tham khảo — không phải chuẩn duy nhất. Giá trị thật nằm ở quá trình: tự deploy, tự bí, tự hỏi AI để gỡ, rồi đối chiếu lại với thực tế production. Kinh nghiệm triển khai thực sự đến từ chính quá trình đó, không phải từ việc chép đáp án.

Mỗi tuần ra 1 bài, không kèm lời giải sẵn — học viên tự làm, thảo luận trong Facebook group/comment, đáp án tham khảo công bố sau ~1 tuần cùng video giải thích trên [Youtube - Network Thực Chiến](https://www.youtube.com/@NetworkThucChien).

Toàn bộ nội dung **mã nguồn mở** (xem [LICENSE](../LICENSE)) — mọi người tự do dùng, sửa, đóng góp bài mới. Xem [CONTRIBUTING.md](./CONTRIBUTING.md).

## Cách tham gia

1. Chọn bất kỳ bài lab nào bạn muốn thực hành ở danh sách bên dưới và đọc `lab-guide.md` tương ứng.
2. Tự deploy topology bằng containerlab, làm theo checklist nhiệm vụ (không có bước giải sẵn). Bí chỗ nào cứ hỏi AI (ChatGPT/Claude...) để hiểu sâu hơn, đừng chỉ xin nguyên cục config — tự gõ, tự test, tự sai mới nhớ lâu.
3. Chia sẻ thành quả của mình hoặc thảo luận thêm ở group Facebook Network Thực Chiến: https://www.facebook.com/profile.php?id=61591373979991 .
4. Đáp án tham khảo mình sẽ chuẩn bị sau.
## Danh sách bài tập theo chủ đề

> Các bài lab được phân loại theo từng **Arc (Chủ đề)** độc lập. Bạn có thể tự do lựa chọn bất kỳ bài lab nào phù hợp với nhu cầu học tập hoặc dự án thực tế của mình mà không cần tuân theo thứ tự tuyến tính.

---

### Arc 0 — Khởi đầu

> Cài đặt containerlab và deploy lab đầu tiên. Yêu cầu trước: có 1 server Linux (Ubuntu 24.04, 4 vCPU/8GB RAM) đã cài Docker.

| Mã bài | Tên bài lab | Trạng thái | Video |
|:---:|:---|:---|:---|
| [01](./01-cai-dat-containerlab/lab-guide.md) | Cài đặt containerlab + deploy topology đầu tiên | 🟢 Đang mở | — |

---

### Arc 1 — Networking nền tảng nâng cao

> IP, định tuyến tĩnh, switching, gateway dự phòng (HA), NAT, DHCP — nền tảng mạng doanh nghiệp.

| Mã bài | Tên bài lab | Trạng thái | Video |
|:---:|:---|:---|:---|
| [02](./02-ip-subnetting-thuc-chien/lab-guide.md) | IP subnetting thực chiến (chia subnet cho data center) | 🟢 Đang mở | — |
| [03](./03-static-route-multi-hop/lab-guide.md) | Static route multi-hop (định tuyến tĩnh qua nhiều chặng) | 🟢 Đang mở | — |
| [04](./04-linux-bridge-vlan/lab-guide.md) | VLAN trunking trên Linux bridge | 🟢 Đang mở | — |
| [05](./05-stp-rstp-chong-loop/lab-guide.md) | STP/RSTP — chống loop Layer 2 (3 bridge tam giác) | 🟢 Đang mở (Mới) | — |
| [06](./06-vrrp-ecmp-gateway-ha/lab-guide.md) | VRRP + ECMP — Gateway HA (failover < 3 giây) | 🟢 Đang mở (Mới) | — |
| [07](./07-dhcp-server-relay/lab-guide.md) | DHCP Server trên Linux (dnsmasq, cấp IP multi-subnet) | 🟢 Đang mở (Mới) | — |
| [08](./08-nat-masquerade-linux/lab-guide.md) | NAT/Masquerade trên Linux (nftables SNAT cho LAN) | 🟢 Đang mở (Mới) | — |

---

### Arc 2 — Routing protocol chuyên sâu

> OSPF, BGP, policy routing — các giao thức định tuyến động dùng trong enterprise & ISP.

| Mã bài | Tên bài lab | Trạng thái | Video |
|:---:|:---|:---|:---|
| [09](./09-ospf-multi-area/lab-guide.md) | OSPF multi-area (chia vùng, ABR, route summarization) | 🟢 Đang mở | — |
| [10](./10-bgp-ebgp-co-ban/lab-guide.md) | BGP eBGP cơ bản (peering giữa 2 AS) | 🟢 Đang mở | — |
| [11](./11-bgp-route-map-policy/lab-guide.md) | BGP route-map & policy (lọc/ưu tiên route) | 🟢 Đang mở | — |
| 12 | BGP Local Preference + prefix-list (inbound traffic engineering) | ⏳ Sắp ra mắt | — |
| 13 | Policy-Based Routing — dual-WAN (route theo source IP) | ⏳ Sắp ra mắt | — |

---

### Arc 3 — Automation / NetDevOps

> Ansible, Python, Git — tự động hóa cấu hình & vận hành mạng.

| Mã bài | Tên bài lab | Trạng thái | Video |
|:---:|:---|:---|:---|
| [14](./14-ansible-co-ban/lab-guide.md) | Ansible cơ bản (push config nhiều router cùng lúc) | 🟢 Đang mở | — |
| [15](./15-python-parsing-show-command/lab-guide.md) | Python parsing (audit routing table từ show command) | 🟢 Đang mở | — |
| 16 | Git workflow cho network config (branch/merge/deploy) | ⏳ Sắp ra mắt | — |

---

### Arc 4 — Security & Observability

> Firewall và giám sát bảo mật hệ thống mạng qua containerlab.

| Mã bài | Tên bài lab | Trạng thái | Video |
|:---:|:---|:---|:---|
| [17](./17-nftables-firewall/lab-guide.md) | nftables firewall cơ bản (filter traffic giữa các subnet) | 🟢 Đang mở | — |

---

### Arc 5 — Troubleshooting chaos lab

> Lab bị cấy lỗi sẵn — tự chẩn đoán & sửa theo phương pháp khoa học.

| Mã bài | Tên bài lab | Trạng thái | Video |
|:---:|:---|:---|:---|
| [18](./18-troubleshooting-chaos-lab/lab-guide.md) | Troubleshooting chaos lab — OSPF (cấy lỗi area mismatch) | 🟢 Đang mở | — |
| 19 | Troubleshooting chaos lab — BGP (cấy lỗi prefix-list) | ⏳ Sắp ra mắt | — |

---

### Arc 6 — Advanced Security & VPN

> VPN kết nối site-to-site an toàn qua internet.

| Mã bài | Tên bài lab | Trạng thái | Video |
|:---:|:---|:---|:---|
| 20 | WireGuard VPN site-to-site (tunnel qua "internet" mô phỏng) | ⏳ Sắp ra mắt | — |

---

Các bài tiếp theo sẽ được bổ sung dần theo tiến độ và phản hồi từ học viên.

## Các Arc trong series

- **Arc 0 — Khởi đầu:** Cài containerlab, deploy topology đầu tiên.
- **Arc 1 — Networking nền tảng nâng cao:** Subnetting, static routing, VLAN/bridge, STP/RSTP chống loop L2, VRRP/ECMP (gateway HA), DHCP server (dnsmasq), NAT/Masquerade (nftables).
- **Arc 2 — Routing protocol chuyên sâu:** OSPF multi-area, BGP (eBGP, route-map, Local Preference, prefix-list), Policy-Based Routing (dual-WAN).
- **Arc 3 — Automation/NetDevOps:** Ansible push config, Python parsing, Git workflow (branch/merge/deploy).
- **Arc 4 — Security & Observability:** nftables firewall (filter traffic giữa subnet).
- **Arc 5 — Troubleshooting chaos lab:** Lab cấy lỗi sẵn — OSPF (area mismatch) và BGP (prefix-list typo).
- **Arc 6 — Advanced Security & VPN:** WireGuard VPN site-to-site.

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

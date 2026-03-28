# Containerlab Practice & Labs 🚀

Step-by-step demonstrations of network scenarios using Containerlab.

Chào mừng bạn đến với kho lưu trữ các bài thực hành mạng sử dụng **Containerlab (clab)**. Đây là nơi tôi lưu trữ và chia sẻ các mô hình mạng giả lập từ cơ bản đến nâng cao.

## 📌 Mục tiêu của Repo

- Chia sẻ các file topology (`.clab.yml`) đã được tối ưu hóa.
- Cung cấp cấu hình mẫu (startup-config) cho các Vendor: Cisco (IOS-XRv, NX-OS), Nokia (SRL), Arista (cEOS), FRR,...
- Hướng dẫn tích hợp Lab mạng với các công cụ NetDevOps như Ansible, Terraform, và Prometheus/Grafana.

## 🛠 Yêu cầu hệ thống

Trước khi bắt đầu, hãy đảm bảo bạn đã cài đặt:

- [Docker](https://docs.docker.com/get-docker/)
- [Containerlab](https://containerlab.dev/install/)

## 📂 Danh sách các bài Lab

| Lab Name | Vendor | Technologies | Status |
| :--- | :--- | :--- | :--- |
| [iproute2](./iproute2) | Linux | Linux Networking | ✅ Completed |
| [iproute2-tc](./iproute2-tc) | Linux | Linux Traffic Control TBF | ✅ Completed |
| apricot-2026-pcio | FRR | OSPF, ISIS, BGP | 🚧 In Progress |
| apricot-2026-pcio | FRR, Linux | RPKI | 📅 Planned |
| apricot-2026-pcio | FRR, Linux | RTBH | 📅 Planned |

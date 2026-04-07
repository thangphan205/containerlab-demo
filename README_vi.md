# Containerlab Practice & Labs 🚀

Bộ sưu tập các bài lab mạng và demo sử dụng **Containerlab**, bao gồm định nghĩa topology, cấu hình router, và các môi trường thực hành.

## 📌 Tổng quan Repository

Repository này chứa các bài lab mạng containerized với:

- **Network Topologies**: Các file `.clab.yml` định nghĩa kiến trúc mạng
- **Router Configurations**: Cấu hình FRR (Free Range Routing) và Linux routing hoàn chỉnh
- **Practice Environments**: Các bài lab sẵn sàng triển khai để học tập thực hành
- **Automation**: File inventory Ansible và hỗ trợ tích hợp

## 📂 Các Lab Có Sẵn

| Lab | Vendor | Công Nghệ | Mô Tả | Trạng Thái |
|:---|:---|:---|:---|:---|
| **apricot2026** | FRR | OSPF, IS-IS, BGP, Route-Maps | Bài lab mạng APRICOT 2026 PCIO với thiết kế multi-AS | ✅ Hoạt động |
| **iproute2** | Linux | iproute2, netlink | Cơ bản về networking Linux | ✅ Hoàn thành |
| **iproute2-tc** | Linux | Traffic Control (TBF, netem) | Shaping traffic nâng cao và QoS | ✅ Hoàn thành |

## 🚀 Bắt Đầu

### Yêu Cầu Hệ Thống

```bash
# Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

# Cài đặt Containerlab
bash -c "$(curl -sL https://get.containerlab.dev)"
```

### Triển Khai Một Bài Lab

```bash
cd <thư-mục-lab>
sudo clab deploy -t <tập-tin-topology>.clab.yml
```

### Truy Cập Router

```bash
docker exec -it clab-<tên-lab>-<tên-router> vtysh
```

### Hủy Bài Lab

```bash
sudo clab destroy -t <tập-tin-topology>.clab.yml
```

## 📖 Tài Liệu

- Mỗi thư mục lab chứa **requirements.md** riêng với các hướng dẫn chi tiết từng bước
- Các file cấu hình bao gồm comments chi tiết giải thích từng phần
- Biểu đồ lab (file `.jpg`) hiển thị topology và IP addressing

## 🛠 Quản Lý Repository

### Cấu Trúc File

File `.gitignore` được cấu hình để:
- **Bỏ qua**: Các thư mục `clab-*/` được tạo, `*.sav`, `frr.conf` (generated), chứng chỉ TLS, metadata files
- **Theo dõi**: Topology files, router configs, tài liệu, daemon configs, hình ảnh

Điều này đảm bảo version control sạch với chỉ source files được commit.

## 📝 Giấy Phép

Sử dụng giáo dục cho các workshop NSRC và thực hành networking.

## 🔗 Tài Nguyên

- [Tài liệu Containerlab](https://containerlab.dev/)
- [Dự án FRR](https://frrouting.org/)
- [Tài liệu Workshop NSRC](https://nsrc.org/workshops/)
- [Kênh YouTube - Network Thực Chiến](https://www.youtube.com/@NetworkThucChien)

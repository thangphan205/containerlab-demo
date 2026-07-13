**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Bài 00: Chuẩn Bị Server

**Arc 0 — Chuẩn bị nền tảng (System Ops)**

## Mục tiêu
- Có 1 server/máy ảo Linux sẵn sàng chạy containerlab cho cả series.
- Cài Docker Engine, chạy được không cần `sudo`.
- Xác nhận tài nguyên đủ chạy lab nhiều node (routing lab về sau có thể lên tới 10+ container).

## Yêu cầu tiên quyết
Không có — đây là bài đầu tiên trong series.

## Yêu cầu / Nhiệm vụ

1. Chuẩn bị 1 server chạy **Ubuntu 24.04 LTS** (VM cloud, VirtualBox/Proxmox, hoặc máy thật). Cấu hình đề xuất:
   * **Tối thiểu (Minimum)**: 2 vCPU / 4 GB RAM / 30 GB disk (cần cấu hình thêm 2 GB Swap như bước 6) — đủ chạy các bài lab FRR + Linux cơ bản.
   * **Khuyến nghị (Recommended)**: 4 vCPU / 8 GB RAM / 40 GB - 50 GB disk để chạy mượt mà tất cả bài lab và lưu trữ Docker images thoải mái.
   
   > [!NOTE]
   > **Lưu ý về dung lượng Disk & RAM:**
   > - Docker images của các hệ điều hành mạng doanh nghiệp lớn rất nặng (ví dụ: Arista cEOS nặng ~1.5GB - 2GB, Cisco Catalyst 8000v nặng ~1.5GB). Khi chạy, mỗi node cEOS cần ~1.5GB RAM, Cisco cần ~3GB - 4GB RAM.
   > - Nếu bạn muốn mở rộng chạy thử nghiệm thiết bị của các hãng lớn này bên cạnh FRR, hãy chuẩn bị server tối thiểu **8 GB - 16 GB RAM** và **50 GB+ Disk**.
2. Cài Docker Engine theo hướng dẫn chính thức (không dùng snap/docker-desktop trên Linux server).
3. Thêm user hiện tại vào group `docker`, xác nhận chạy `docker run hello-world` **không cần `sudo`**.
4. Bật IPv4 forwarding: đảm bảo `net.ipv4.ip_forward = 1` (containerlab cần để định tuyến giữa các container).
5. Thiết lập **SSH key-based authentication** (tắt password login nếu dùng cloud VM) — đây là bước bảo mật tối thiểu cho mọi server production.
6. Cấu hình **swap** (tối thiểu 2GB): các bài lab chạy nhiều container FRR cùng lúc, có swap giúp tránh tình trạng OOM (Out Of Memory) trên các máy cấu hình thấp.
   ```bash
   sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
   sudo mkswap /swapfile && sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```
7. Ghi lại output các lệnh sau để nộp bài:
   - `docker version`
   - `uname -a`
   - `free -h` (phải thấy dòng Swap khác 0)
   - `nproc`
   - `sysctl net.ipv4.ip_forward`
   - `ss -tlnp | grep 22` (xác nhận SSH đang chạy)

## Gợi ý
- Nếu dùng cloud VM, nhớ mở port cần thiết (SSH tối thiểu). Một số nhà cung cấp cloud (AWS, GCP) mặc định đã có SSH key — chỉ cần xác nhận password login đã tắt (`PasswordAuthentication no` trong `/etc/ssh/sshd_config`).
- Nếu server có ít RAM (2GB - 4GB), swap đặc biệt quan trọng — không có swap thì OOM killer sẽ tắt container ngẫu nhiên khi chạy lab.
- Không cần cài containerlab ở bài này — để dành cho Bài 01.

## Thảo luận và hỏi đáp
Bài tập này tự làm và tự xác minh kết quả. Nếu có thắc mắc hoặc cần trao đổi thêm, các bạn hãy đăng bài thảo luận trên group Facebook [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991).
## Bài tiếp theo
→ [01-cai-dat-containerlab](../01-cai-dat-containerlab/lab-guide.md): cài containerlab và deploy lab đầu tiên.

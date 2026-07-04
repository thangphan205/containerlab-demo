# Bài 00: Chuẩn Bị Server

**Arc 0 — Chuẩn bị nền tảng (System Ops)**

## Mục tiêu
- Có 1 server/máy ảo Linux sẵn sàng chạy containerlab cho cả series.
- Cài Docker Engine, chạy được không cần `sudo`.
- Xác nhận tài nguyên đủ chạy lab nhiều node (routing lab về sau có thể lên tới 10+ container).

## Yêu cầu tiên quyết
Không có — đây là bài đầu tiên trong series.

## Yêu cầu / Nhiệm vụ

1. Chuẩn bị 1 server chạy **Ubuntu 24.04 LTS** (VM cloud, VirtualBox/Proxmox, hoặc máy thật), tối thiểu **4 vCPU / 8GB RAM / 40GB disk**.
2. Cài Docker Engine theo hướng dẫn chính thức (không dùng snap/docker-desktop trên Linux server).
3. Thêm user hiện tại vào group `docker`, xác nhận chạy `docker run hello-world` **không cần `sudo`**.
4. Bật IPv4 forwarding: đảm bảo `net.ipv4.ip_forward = 1` (containerlab cần để định tuyến giữa các container).
5. Thiết lập **SSH key-based authentication** (tắt password login nếu dùng cloud VM) — đây là bước bảo mật tối thiểu cho mọi server production.
6. Cấu hình **swap** (tối thiểu 2GB): các bài lab từ Arc 2 trở đi chạy 10+ container FRR cùng lúc, thiếu swap dễ bị OOM killer tắt container giữa chừng.
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
- Nếu server có ít RAM (4GB), swap đặc biệt quan trọng — không có swap thì OOM killer sẽ tắt container ngẫu nhiên khi chạy nhiều lab node.
- Không cần cài containerlab ở bài này — để dành cho Bài 01.

## Cách nộp bài
Đăng ảnh chụp output 5 lệnh ở trên vào Facebook group/comment bài viết tuần này.
**Hạn nộp:** 1 tuần kể từ ngày đăng bài.

## Bài tiếp theo
→ [01-cai-dat-containerlab](../01-cai-dat-containerlab/lab-guide.md): cài containerlab và deploy lab đầu tiên.

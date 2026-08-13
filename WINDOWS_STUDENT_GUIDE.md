# 🖥️ HƯỚNG DẪN CÀI ĐẶT VÀ THỰC HÀNH CONTAINERLAB CHỦAN CHO HỌC VIÊN DÙNG WINDOWS

> **Dành cho Học viên sử dụng Windows 10 / Windows 11**  
> **Giải pháp tối ưu:** Sử dụng **WSL 2 (Windows Subsystem for Linux)** kết hợp với **Docker Engine & Containerlab**. Đây là phương pháp hiệu năng cao nhất, nhẹ nhất, không bị xung đột card mạng ảo và không cần cài các trình quản lý máy ảo nặng nề như VMware Workstation hay VirtualBox.

---

## 🏗️ TỔNG QUAN KIẾN TRÚC MÔI TRƯỜNG

```
┌────────────────────────────────────────────────────────────────────────┐
│ WINDOWS LAPTOP / PC (Windows 10 / 11 64-bit)                            │
│  │                                                                     │
│  ├─ Trình duyệt (Chrome / Edge / Firefox): http://localhost:<port>     │
│  ├─ VS Code (Tích hợp WSL Extension)                                   │
│  └─ Windows Terminal (PowerShell / Command Prompt)                    │
│       │                                                                │
│       ▼                                                                │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ WSL 2 (Ubuntu 22.04 LTS / 24.04 LTS)                             │  │
│  │  │                                                               │  │
│  │  ├─ Docker Engine (Quản lý các container ảo hóa)                 │  │
│  │  └─ Containerlab (Tạo Network Namespaces, veth pair kết nối)     │  │
│  │      ├─ Node 1: Router (FRR / Arista cEOS / Nokia SR Linux...)  │  │
│  │      └─ Node 2: Linux Host / Grafana / Prometheus / Wireshark    │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 ĐIỀU KIỆN CHUẨN BỊ (PREREQUISITES)

1. **Phiên bản Windows**:
   - Windows 10 (Phiên bản 2004 trở lên, Build 19041 trở lên) hoặc Windows 11.
2. **Ảo hóa cứng (Hardware Virtualization)**:
   - Cần bật **Intel VT-x** hoặc **AMD-V** trong BIOS/UEFI của máy tính (thường mặc định đã bật trên đa số laptop hiện đại).
3. **Dung lượng đĩa trống**: Tối thiểu **10 GB - 20 GB** (để chứa các Container Image như FRR, cEOS, SR Linux...).

---

## 🛠️ PHẦN 1: BƯỚC CÀI ĐẶT CHI TIẾT (CÀI 1 LẦN DUY NHẤT)

### 🔹 Bước 1: Cài đặt WSL 2 & Ubuntu từ Windows Terminal

1. Tìm **PowerShell** hoặc **Command Prompt** trên Windows ➔ Nhấp chuột phải chọn **Run as Administrator** (Chạy với quyền Quản trị viên).
2. Chạy câu lệnh sau để cài đặt WSL 2 cùng phân vùng **Ubuntu**:
   ```powershell
   wsl --install -d Ubuntu
   ```
3. Sau khi lệnh thực thi xong, hãy **Khởi động lại máy tính (Restart)** nếu Windows yêu cầu.
4. Sau khi khởi động lại, cửa sổ **Ubuntu** sẽ tự động mở ra.
   - Nhập **Username** mới (viết liền không dấu, ví dụ: `student` hoặc `devops`).
   - Nhập **Password** (lưu ý: khi gõ mật khẩu trên Linux sẽ **không hiển thị ký tự hay dấu ***, cứ gõ xong rồi bấm `Enter`).
5. Cập nhật danh sách gói phần mềm hệ thống Ubuntu:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

### 🔹 Bước 2: Cấu hình systemd cho WSL 2 (Giúp Docker tự chạy cùng hệ thống)

Mặc định WSL2 có thể không tự khởi động background service (như Docker). Thực hiện cấu hình `systemd` để Docker tự bật mỗi khi bạn mở Ubuntu:

1. Trong cửa sổ Ubuntu WSL2, chạy lệnh:
   ```bash
   sudo bash -c 'cat <<EOF > /etc/wsl.conf
   [boot]
   systemd=true
   EOF'
   ```
2. Mở cửa sổ **PowerShell** trên Windows và khởi động lại WSL2:
   ```powershell
   wsl --shutdown
   ```
3. Mở lại **Ubuntu** từ Start Menu hoặc Windows Terminal.

---

### 🔹 Bước 3: Cài đặt Docker & Containerlab (Tự động trọn gói)

Containerlab cung cấp script chính thức cài đặt nhanh toàn bộ môi trường bao gồm **Docker Engine**, **Docker Compose**, **Containerlab** và **GitHub CLI (`gh`)**:

Chạy duy nhất 1 câu lệnh sau trong terminal Ubuntu WSL2:

```bash
curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"
```

> **Ghi chú (Cách cài đặt thủ công/từng phần nếu không dùng script trọn gói):**
> 
> ```bash
> # 1. Cài đặt Docker Engine chính thức
> curl -fsSL https://get.docker.com -o get-docker.sh
> sudo sh get-docker.sh
> 
> # 2. Thêm user hiện tại vào group docker (để chạy lệnh docker không cần sudo)
> sudo usermod -aG docker $USER
> newgrp docker
> 
> # 3. Cài đặt Containerlab
> bash -c "$(curl -sL https://get.containerlab.dev)"
> ```

---

### 🔹 Bước 4: Kiểm tra và hoàn tất cài đặt

Chạy các lệnh kiểm tra trong Ubuntu WSL2:

```bash
# Kiểm tra Docker
docker version

# Kiểm tra Containerlab
clab version   # hoặc containerlab version
```

Nếu cả 2 lệnh trên đều hiển thị thông tin phiên bản (ví dụ: Containerlab version 0.x.x, Docker version 24+ hoặc 26+) là bạn đã sẵn sàng!

---

## 💻 PHẦN 2: THIẾT LẬP CÔNG CỤ LÀM VIỆC NÂNG CAO (RECOMMENDED)

Để thao tác code bài lab và gõ lệnh mượt mà nhất, học viên nên cài 2 công cụ sau trên Windows:

### 1. Windows Terminal
- Tải từ **Microsoft Store** (gõ tìm `Windows Terminal`).
- Cho phép mở nhiều tab (Ubuntu, PowerShell) trong cùng một cửa sổ với giao diện hiện đại.

### 2. Visual Studio Code (VS Code) + Extension WSL
1. Tải và cài đặt [VS Code trên Windows](https://code.visualstudio.com/).
2. Mở VS Code, nhấn `Ctrl + Shift + X` (mục Extensions), tìm và cài đặt extension tên **WSL** (do Microsoft phát triển).
3. Mỗi khi muốn mở một dự án lab trong WSL2:
   - Trong cửa sổ terminal Ubuntu WSL2, di chuyển vào thư mục lab (ví dụ: `cd ~/containerlab-demo`).
   - Gõ lệnh:
     ```bash
     code .
     ```
   - VS Code trên Windows sẽ tự động kết nối trực tiếp vào phân vùng Ubuntu WSL2, giúp bạn sửa file `.clab.yml` và cấu hình router vô cùng thuận tiện.

---

## 🚀 PHẦN 3: BẮT ĐẦU THỰC HÀNH VỚI CONTAINERLAB

### 1. Clone repository bài lab về WSL2
*(Lưu ý: Nên clone repo vào thư mục nhà `~` trong Linux WSL2 để đạt hiệu năng đĩa cao nhất)*

```bash
cd ~
git clone https://github.com/networkthucchien/kai-networks-demo.git
cd kai-networks-demo
```

### 2. Triển khai lab (Deploy)
```bash
sudo clab deploy -t <ten-file-lab>.clab.yml
```

### 3. Truy cập vào thiết bị (Router / Host)
- **Truy cập vào Router FRR (giao diện vtysh)**:
  ```bash
  docker exec -it clab-<ten-lab>-<ten-node> vtysh
  ```
- **Truy cập vào Linux Host / Container**:
  ```bash
  docker exec -it clab-<ten-lab>-<ten-node> bash
  ```

### 4. Kiểm tra trạng thái các node
```bash
sudo clab inspect -t <ten-file-lab>.clab.yml
```

### 5. Dọn dẹp / Hủy bỏ lab (Destroy)
```bash
sudo clab destroy -t <ten-file-lab>.clab.yml
```

---

## ❓ PHẦN 4: CÁC LỖI THƯỜNG GẶP & CÁCH XỬ LÝ (TROUBLESHOOTING)

### ❌ Lỗi 1: `Cannot connect to the Docker daemon at unix:///var/run/docker.sock`
- **Nguyên nhân**: Dịch vụ Docker chưa được khởi động trong WSL2.
- **Cách khắc phục**:
  Chạy lệnh bật Docker thủ công:
  ```bash
  sudo service docker start
  ```
  *(Hoặc xem lại Bước 2 Phần 1 để bật `systemd` tự động)*.

---

### ❌ Lỗi 2: `wsl --install` báo lỗi hoặc ảo hóa bị tắt (Virtualization disabled)
- **Nguyên nhân**: Tính năng ảo hóa cứng trong BIOS/UEFI của máy tính bị tắt.
- **Cách khắc phục**:
  1. Khởi động lại máy tính, bấm phím để vào BIOS (thường là `F2`, `F10`, `F12` hoặc `Del` tùy hãng laptop Dell, HP, Lenovo, Asus...).
  2. Tìm mục **Intel Virtualization Technology (VT-x)** hoặc **AMD-V / SVM Mode** và chuyển sang **Enabled**.
  3. Lưu cấu hình (F10) và khởi động lại vào Windows.

---

### ❌ Lỗi 3: Gõ `code .` nhưng không mở được VS Code
- **Nguyên nhân**: VS Code trên Windows chưa được tích hợp vào đường dẫn $PATH của WSL2.
- **Cách khắc phục**: Mở VS Code trên Windows, bấm `Ctrl + Shift + P`, gõ `Shell Command: Install 'code' command in PATH` hoặc cài extension **WSL** trong VS Code.

---

### ❌ Lỗi 4: Không kéo được ảnh Docker (Docker Pull Rate Limit / Network Timeout)
- **Nguyên nhân**: Mạng chập chờn hoặc hết lượt pull ẩn danh của Docker Hub.
- **Cách khắc phục**:
  Đăng nhập tài khoản Docker Hub miễn phí trong Ubuntu WSL2:
  ```bash
  docker login
  ```

---

## 📚 TÀI NGUYÊN THAM KHẢO

- 🌐 [Tài liệu chính thức Containerlab Installation](https://containerlab.dev/install/)
- 📖 [Containerlab trên Windows (Tài liệu gốc)](https://containerlab.dev/windows/)
- 🎥 [Kênh YouTube Network Thực Chiến](https://www.youtube.com/@NetworkThucChien)
- 🐙 [GitHub Repository Demo Network Thực Chiến](https://github.com/networkthucchien/kai-networks-demo)

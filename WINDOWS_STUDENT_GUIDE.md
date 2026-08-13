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
│  │ WSL 2 (Ubuntu 24.04 LTS)                                         │  │
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

### 🔹 Bước 1: Cài đặt WSL 2 & Ubuntu 24.04 LTS từ Windows Terminal

1. Tìm **PowerShell** hoặc **Command Prompt** trên Windows ➔ Nhấp chuột phải chọn **Run as Administrator** (Chạy với quyền Quản trị viên).
2. Chạy câu lệnh sau để cài đặt WSL 2 với hệ điều hành **Ubuntu 24.04 LTS**:
   ```powershell
   wsl --install -d Ubuntu-24.04
   ```
3. Sau khi lệnh thực thi xong, hãy **Khởi động lại máy tính (Restart)** nếu Windows yêu cầu.
4. Sau khi khởi động lại, cửa sổ **Ubuntu 24.04** sẽ tự động mở ra.
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

### 2. Visual Studio Code (VS Code) / Antigravity IDE + Extension WSL
1. Tải và cài đặt [VS Code trên Windows](https://code.visualstudio.com/) hoặc sử dụng **Antigravity IDE**.
2. Mở VS Code / Antigravity IDE, nhấn `Ctrl + Shift + X` (mục Extensions), tìm và cài đặt extension tên **WSL** (do Microsoft phát triển).
3. Mỗi khi muốn mở một dự án lab trong WSL2:
   - Trong cửa sổ terminal Ubuntu WSL2, di chuyển vào thư mục lab (ví dụ: `cd ~/containerlab-demo`).
   - Gõ lệnh:
     ```bash
     code .
     ```
   - Trình soạn thảo sẽ tự động kết nối trực tiếp vào phân vùng Ubuntu WSL2, giúp bạn sửa file `.clab.yml` và cấu hình router vô cùng thuận tiện.

### 3. Cài đặt Extension Containerlab trong VS Code & Antigravity IDE 🔌

Extension **Containerlab** (phát triển bởi `srl-labs` / Nokia) mang đến trải nghiệm đồ họa tuyệt vời và vô cùng tiện lợi trực tiếp ngay trong trình soạn thảo:

#### 🔹 Các bước cài đặt:
1. Mở **VS Code** hoặc **Antigravity IDE**.
2. Mở trình quản lý Extensions bằng cách nhấn `Ctrl + Shift + X` (Windows/Linux) hoặc `Cmd + Shift + X` (macOS).
3. Nhập từ khóa tìm kiếm: **`containerlab`** (chọn extension do **`srl-labs`** phát hành).
4. Nhấn nút **Install**.
   > *Lưu ý trên máy Windows chạy WSL2:* Khi bạn mở project trong môi trường WSL, hãy nhấn nút **Install in WSL: Ubuntu** (nếu hiển thị) để extension hoạt động đầy đủ tính năng trong phân vùng Linux.

#### 🔹 Các tính năng nổi bật & Cách sử dụng:

- **1. Gợi ý cú pháp tự động (IntelliSense & Syntax Highlighting)**:
  - Tự động gợi ý các thẻ chuẩn của Containerlab (`topology`, `kinds`, `nodes`, `links`, `endpoints`, `env`...) giúp học viên viết file topology chuẩn xác, không bị lỗi thụt lùi dòng (indentation) YAML.

- **2. Xem sơ đồ Topology tương tác trực quan (Interactive Topology Viewer)**:
  - Mở bất kỳ file topology `.clab.yml` nào.
  - Nhấp chuột phải vào nội dung file chọn **Containerlab: View Topology** hoặc bấm biểu tượng **Sơ đồ mạng (Containerlab Preview)** ở góc trên bên phải màn hình biên tập.
  - Trình soạn thảo sẽ mở một sơ đồ mạng dạng đồ họa tương tác: hiển thị các node, đường nối interface, cho phép kéo thả bố cục và thu phóng sơ đồ lab trực quan.

- **3. Thao tác Deploy / Destroy trực tiếp qua giao diện (GUI Context Menu)**:
  - Nhấp chuột phải vào file `.clab.yml` ở thanh quản lý file bên trái (Explorer).
  - Chọn các lệnh thực thi nhanh:
    - **Containerlab: Deploy** ➔ Khởi chạy bài lab.
    - **Containerlab: Destroy** ➔ Hủy và dọn dẹp bài lab.
    - **Containerlab: Inspect** ➔ Xem bảng thông tin địa chỉ IP và trạng thái container.

- **4. Quản lý Node & Bắt gói tin Wireshark trực tiếp từ Sidebar**:
  - Nhấp vào biểu tượng **Containerlab** ở thanh công cụ ngoài cùng bên trái IDE.
  - Danh sách các bài lab và từng node/interface đang hoạt động sẽ hiện ra.
  - Nhấp chuột phải vào node bất kỳ:
    - Chọn **SSH / Attach Shell** ➔ Mở ngay tab Terminal truy cập vào router/host mà không cần gõ lệnh `docker exec`.
    - Chọn **Capture Traffic** ➔ Tự động mở Wireshark bắt gói tin realtime trên giao diện mạng được chọn.

### 4. Cài đặt Extension Remote Explorer (Quản lý WSL & SSH vào máy Ubuntu) 🖥️🌐

Extension **Remote Explorer** (phát triển bởi Microsoft) giúp học viên dễ dàng quản lý, kết nối và mở các workspace trực tiếp từ giao diện đồ họa của VS Code / Antigravity IDE đến phân vùng WSL2 Ubuntu local hoặc bất kỳ máy chủ Ubuntu từ xa nào qua SSH.

#### 🔹 Các bước cài đặt:
1. Mở **VS Code** hoặc **Antigravity IDE**.
2. Nhấn `Ctrl + Shift + X` (Windows/Linux) hoặc `Cmd + Shift + X` (macOS) để mở mục Extensions.
3. Tìm kiếm từ khóa: **`Remote Explorer`** (hoặc cài đặt trọn bộ **`Remote Development`** do **Microsoft** phát hành).
4. Nhấn nút **Install**.

#### 🔹 Hướng dẫn kết nối đến phân vùng WSL Ubuntu 24.04 vừa tạo:
1. Nhấp vào biểu tượng **Remote Explorer** (hình thanh màn hình máy tính kết nối mạng) ở thanh công cụ dọc ngoài cùng bên trái IDE.
2. Tại menu thả xuống ở đầu bảng điều khiển Remote Explorer (Dropdown Menu), chọn mục **WSL Targets**.
3. Bạn sẽ thấy danh sách phân vùng WSL đang chạy, bao gồm **`Ubuntu-24.04`**.
4. Nhấp chuột vào biểu tượng **Connect to WSL in New Window** (hoặc nhấp chuột phải chọn Connect):
   - Trình soạn thảo sẽ khởi tạo môi trường kết nối trực tiếp vào Ubuntu 24.04.
   - Nhấn `Ctrl + O` (hoặc vào `File ➔ Open Folder...`) để chọn và mở ngay thư mục dự án lab trong Linux (ví dụ: `/home/student/containerlab-demo`).

#### 🔹 Hướng dẫn SSH vào máy Ubuntu (Máy chủ từ xa hoặc Máy ảo VM):
1. Trong bảng điều khiển **Remote Explorer**, chuyển mục Dropdown sang **SSH Targets**.
2. Nhấn vào biểu tượng dấu cộng **`+`** (**Add New SSH Host**).
3. Nhập cú pháp kết nối SSH:
   ```bash
   ssh student@<dia-chi-ip-may-ubuntu>
   # Ví dụ: ssh student@192.168.1.50 hoặc ssh student@10.0.0.5 -p 22
   ```
4. Chọn file cấu hình lưu SSH (mặc định chọn `C:\Users\<ten_user_windows>\.ssh\config`).
5. Danh sách host vừa thêm sẽ xuất hiện trong mục **SSH Targets**.
6. Nhấp chuột vào tên máy chủ chọn **Connect to Host in New Window** ➔ Chọn OS loại **Linux** ➔ Nhập mật khẩu tài khoản `student` khi được yêu cầu ➔ Bạn đã truy cập hoàn toàn vào máy Ubuntu từ xa qua giao diện IDE chuyên nghiệp.


---


## 🚀 PHẦN 3: BẮT ĐẦU THỰC HÀNH VỚI CONTAINERLAB

### 1. Clone repository bài lab về môi trường Ubuntu
*(Lưu ý: Nên clone repo vào thư mục nhà `~` trong Linux Ubuntu để đạt hiệu năng đĩa và tốc độ cao nhất)*

Mở Terminal của Ubuntu (hoặc dùng Terminal tích hợp sẵn trong VS Code / Antigravity IDE) và chạy các lệnh:

```bash
cd ~
git clone https://github.com/thangphan205/containerlab-demo.git
cd containerlab-demo
```

---

### 2. Mở thư mục dự án trong VS Code / Antigravity IDE
Nếu đang làm việc từ terminal Ubuntu WSL2, gõ:
```bash
code .
```
Giao diện trình soạn thảo sẽ kết nối trực tiếp vào phân vùng Ubuntu và mở thư mục `containerlab-demo`.

---

### 3. Thực hành Deploy 1 bài lab trong thư mục `bai-tap-ve-nha` bằng Extension Containerlab (GUI)

Học viên có thể triển khai bài lab bằng **Giao diện đồ họa Extension Containerlab** cực kỳ đơn giản theo các bước:

1. **Mở bài tập cần thực hành**:
   - Ở thanh quản lý file bên trái (Explorer), truy cập vào thư mục bài tập mong muốn, ví dụ:
     `bai-tap-ve-nha ➔ 03-static-route-multi-hop ➔ topology ➔ static-route-lab.clab.yml`.
2. **Xem sơ đồ Topology trực quan trước khi Deploy**:
   - Nhấp chuột phải vào file `static-route-lab.clab.yml` chọn **Containerlab: View Topology** *(hoặc nhấp icon Containerlab Preview ở góc trên bên phải màn hình)*.
   - Sơ đồ mạng đồ họa của bài lab sẽ mở ra cho bạn xem cấu trúc kết nối giữa các router và host.
3. **Thực hiện Deploy bài lab qua GUI**:
   - Nhấp chuột phải vào file `static-route-lab.clab.yml` trong thanh Explorer bên trái.
   - Chọn lệnh **Containerlab: Deploy**.
   - Extension sẽ tự động mở tab Terminal bên dưới và chạy lệnh deploy. Chờ trong giây lát cho đến khi bảng kết quả IP hiển thị thông báo bài lab đã sẵn sàng!

> **Mẹo:** Bạn vẫn có thể dùng lệnh CLI truyền thống trong Terminal nếu muốn:
> ```bash
> sudo clab deploy -t bai-tap-ve-nha/03-static-route-multi-hop/topology/static-route-lab.clab.yml
> ```

---

### 4. Truy cập & Thao tác với các thiết bị (Router / Host)

- **Cách 1: Sử dụng Extension Sidebar (Nhanh nhất)**:
  - Bấm vào biểu tượng **Containerlab** ở thanh công cụ ngoài cùng bên trái IDE.
  - Mở rộng bài lab đang chạy ➔ Nhấp chuột phải vào tên Router (ví dụ `clab-static-route-lab-router1`) ➔ Chọn **SSH / Attach Shell**.
  - IDE sẽ mở ngay một tab Terminal truy cập thẳng vào giao diện quản lý router (ví dụ `vtysh` của FRR).
- **Cách 2: Sử dụng lệnh Docker CLI**:
  ```bash
  # Vào CLI router FRR
  docker exec -it clab-static-route-lab-router1 vtysh

  # Vào terminal Linux host
  docker exec -it clab-static-route-lab-pc1 bash
  ```

---

### 5. Bắt gói tin phân tích mạng (Wireshark)
- Nhấp chuột phải vào interface nối giữa các router trong cây danh sách của Extension Containerlab ➔ Chọn **Capture Traffic**.
- Wireshark sẽ tự động bật và hiển thị luồng gói tin bắt realtime.

---

### 6. Hủy bài lab (Destroy) sau khi làm xong
- Nhấp chuột phải vào file `static-route-lab.clab.yml` chọn **Containerlab: Destroy** (hoặc chạy lệnh CLI `sudo clab destroy -t ...`).

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
- 🐙 [GitHub Repository Containerlab Demo](https://github.com/thangphan205/containerlab-demo)


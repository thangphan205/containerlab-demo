# Lab: Linux Networking (iproute2)

Bài lab này tập trung vào các kỹ thuật mạng trên Linux sử dụng `iproute2`.

> **Lưu ý:** Bài demo sử dụng `alpine` image để tối ưu tài nguyên hệ thống. Bạn hoàn toàn có thể thay thế bằng Ubuntu hoặc các hệ điều hành Linux khác trong file cấu hình topology.

## Yêu cầu bài tập

### 1. Cấu hình IP Address

Thực hiện đặt IP Address theo mô hình mạng (tham khảo file `iproute2-topology.png` hoặc bảng dưới đây):

| Device | Interface | IP Address | Gateway |
| :--- | :--- | :--- | :--- |
| **linux1** | eth1 | 192.168.12.1/24 | - |
| | eth2 | 192.168.13.1/24 | - |
| | eth3 | 192.168.11.1/24 | - |
| **linux2** | eth1 | 192.168.12.2/24 | - |
| | eth2 | 192.168.24.2/24 | - |
| **linux3** | eth1 | 192.168.13.3/24 | - |
| | eth2 | 192.168.34.3/24 | - |
| **linux4** | eth1 | 192.168.24.4/24 | - |
| | eth2 | 192.168.34.4/24 | - |
| | eth3 | 192.168.41.1/24 | - |
| **client1** | eth1 | 192.168.11.2/24 | 192.168.11.1 |
| **server1** | eth1 | 192.168.41.2/24 | 192.168.41.1 |

### 2. Định tuyến & Load Balancing

Thực hiện định tuyến để `client1` có thể truy cập `server1`.

- **Yêu cầu:** Cấu hình **Load Balance** (chia tải) qua 2 đường đi qua `linux2` và `linux3`.

### 3. Policy Based Routing (PBR)

Thực hiện điều chỉnh định tuyến để thỏa mãn các yêu cầu sau:

1. **Client IP 192.168.11.11/24** truy cập `server1`: Chỉ đi qua đường `linux2`.
2. **Client IP 192.168.11.12/24** truy cập `server1`: Chỉ đi qua đường `linux3`.
3. **Client IP 192.168.11.13/24** truy cập `server1`:
   - Traffic đến **port 80** đi qua đường `linux2`.
   - Traffic đến **port 22** đi qua đường `linux3`.

Cơm thêm câu 2: Cấu hình **Load Balance** (chia tải) qua 2 đường đi qua `linux2` và `linux3`: Thêm tham số Layer 4 để tối ưu hóa hiệu suất.

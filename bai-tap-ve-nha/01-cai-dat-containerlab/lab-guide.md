# Bài 01: Cài Đặt Containerlab & Deploy Lab Đầu Tiên

**Arc 0 — Chuẩn bị nền tảng (System Ops)**

## Mục tiêu
- Cài containerlab lên server đã chuẩn bị ở Bài 00.
- Deploy thành công 1 topology 2 node, xác minh kết nối giữa 2 container.

## Yêu cầu tiên quyết
Hoàn thành [00-chuan-bi-server](../00-chuan-bi-server/lab-guide.md): Docker đã chạy được không cần `sudo`, đã bật IPv4 forwarding.

## Sơ đồ topology
2 node Linux (`wbitt/network-multitool`) nối trực tiếp bằng 1 link, mỗi node được gán sẵn IP trong subnet `192.168.100.0/24` — xem file [`topology/hello-clab.yml`](./topology/hello-clab.yml).

```
host1 (192.168.100.1/24) --- eth1<->eth1 --- host2 (192.168.100.2/24)
```

## Yêu cầu / Nhiệm vụ

1. Cài containerlab bằng script cài đặt chính thức.
2. Xác nhận phiên bản: `containerlab version`.
3. Deploy topology:
   ```bash
   cd topology
   sudo clab deploy -t hello-clab.yml
   ```
4. Từ `host1`, ping tới `host2` qua IP đã gán, xác nhận thông:
   ```bash
   docker exec -it clab-hello-clab-host1 ping -c 4 192.168.100.2
   ```
5. Chạy `sudo clab inspect -t hello-clab.yml` (vẫn trong thư mục `topology/`) và ghi lại output.
6. Destroy lab: `sudo clab destroy -t hello-clab.yml`.

## Gợi ý
- Nếu ping không thông, kiểm tra lại `exec` trong `hello-clab.yml` đã gán đúng IP cho từng interface chưa, và interface có ở trạng thái `up` không.

## Cách nộp bài
Đăng ảnh/kết quả lệnh `containerlab version`, `clab inspect`, và kết quả ping vào Facebook group/comment bài viết tuần này.
**Hạn nộp:** 1 tuần kể từ ngày đăng bài.

## Bài tiếp theo
→ 02-ip-subnetting-thuc-chien (sắp ra mắt)

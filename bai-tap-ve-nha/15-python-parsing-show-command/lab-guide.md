**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Bài 15: Python Parsing — Tự Động Audit Routing Table

**Arc 3 — Automation/NetDevOps**

## Mục tiêu
- Dùng Python (`subprocess` + `json`) để lấy dữ liệu có cấu trúc từ nhiều router, thay vì đọc output bằng mắt.
- Làm quen `ip -j route show` — cách lấy routing table dạng JSON thay vì phải regex/TextFSM output dạng text.
- Viết 1 script audit nhỏ: kiểm tra router nào đang **thiếu** route tới subnet cần thiết.

## Yêu cầu tiên quyết
Hoàn thành [03-static-route-multi-hop](../03-static-route-multi-hop/lab-guide.md) — hiểu rõ topology chuỗi router + static route (tuần này dùng lại đúng thiết kế đó, nhưng route **đã được cấu hình sẵn**, không cần tự thêm).

## Sơ đồ topology
Giống hệt Bài 03 (4 router nối tiếp, LAN 2 đầu) — nhưng lần này **toàn bộ IP + static route đã cấu hình sẵn** qua `exec`, mạng đã chạy hoàn chỉnh ngay khi deploy. Xem [`topology/audit-lab.clab.yml`](./topology/audit-lab.clab.yml).

```
host-1 (10.0.1.0/24) -- r1 -- r2 -- r3 -- r4 -- host-2 (10.0.2.0/24)
```

## Đề bài / Yêu cầu

1. Deploy topology, xác nhận mạng đã thông sẵn (`ping` từ `host-1` tới `host-2`).
2. Hoàn thiện [`script/audit_routes.py`](./script/audit_routes.py) (đang có hàm `get_routes()` để trống):
   - Chạy `docker exec <router> ip -j route show` bằng `subprocess`, parse output JSON (mỗi phần tử có key `dst`, `gateway`, `dev`, ...).
   - Với mỗi router (`r1`–`r4`), kiểm tra có route tới cả 2 subnet LAN (`10.0.1.0/24` và `10.0.2.0/24`) hay không — in ra `OK` hoặc `MISSING` cho từng router/subnet.
3. Chạy script, xác nhận cả 4 router đều `OK` với cả 2 subnet.
4. **Test khả năng phát hiện lỗi:** xoá 1 static route bất kỳ bằng tay (`docker exec <router> ip route del ...`), chạy lại script — phải thấy đúng router đó báo `MISSING` cho đúng subnet vừa xoá.
5. Ghi lại: nội dung `audit_routes.py` đã hoàn thiện, output script khi mạng bình thường, và output sau khi cố tình xoá 1 route.

## Gợi ý
- `subprocess.run([...], capture_output=True, text=True).stdout` trả về chuỗi JSON — dùng `json.loads()` để parse thành list các dict.
- Route có `dst` là `"default"` (không phải subnet cụ thể) — nhớ bỏ qua khi so khớp, không phải lỗi.

## Thảo luận và hỏi đáp
Bài tập này tự làm và tự xác minh kết quả. Nếu có thắc mắc hoặc cần trao đổi thêm, các bạn hãy đăng bài thảo luận trên group Facebook [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991).
## Bài tiếp theo
→ [16-git-workflow-network-config](../16-git-workflow-network-config/lab-guide.md): Git workflow cho network config.

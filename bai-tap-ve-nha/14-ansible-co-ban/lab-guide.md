# Bài 14: Ansible Cơ Bản — Push Config Cho Nhiều Router

**Arc 3 — Automation/NetDevOps**

## Mục tiêu
- Dùng Ansible để đẩy cùng 1 thay đổi cấu hình cho nhiều router cùng lúc, thay vì gõ tay từng cái.
- Hiểu inventory (khai báo host + biến riêng từng host) và playbook (task chạy trên từng host).
- Verify bằng cách chạy lại lệnh gather ngay trong Ansible, không cần đăng nhập tay vào từng router.

## Yêu cầu tiên quyết
Hoàn thành [10-bgp-ebgp-co-ban](../10-bgp-ebgp-co-ban/lab-guide.md) — đã quen `vtysh -c` và `docker exec`.
Cài Ansible trên server: `sudo apt install -y ansible-core` (hoặc `pip install ansible-core`).

## Sơ đồ topology
3 router FRR độc lập, **không cần link mạng giữa chúng** — bài này tập trung vào automation, không phải routing. Xem [`topology/ansible-lab.clab.yml`](./topology/ansible-lab.clab.yml).

```
r1, r2, r3 — mỗi router 1 container FRR riêng biệt, chỉ có interface quản lý
```

Ansible không SSH vào container (FRR image không chạy sshd) — chạy lệnh qua `docker exec` trực tiếp trên chính server (kết nối `local`). Xem [`ansible/inventory.ini`](./ansible/inventory.ini) — đã khai báo sẵn 3 host + biến `loopback_ip` riêng từng router.

## Đề bài / Yêu cầu

1. Deploy topology (`sudo clab deploy -t ansible-lab.clab.yml`).
2. Hoàn thiện [`ansible/playbook.yml`](./ansible/playbook.yml) (đang để `TODO`):
   - Task 1: dùng module `ansible.builtin.command` (hoặc `shell`) chạy `docker exec {{ inventory_hostname }} vtysh -c "configure terminal" -c "interface lo" -c "ip address {{ loopback_ip }}/32"` để gán loopback riêng cho từng router theo biến đã khai báo trong inventory.
   - Task 2: verify — chạy `docker exec {{ inventory_hostname }} vtysh -c "show ip route"`, `register` kết quả ra biến, in ra bằng module `debug`.
3. Chạy `ansible-playbook -i ansible/inventory.ini ansible/playbook.yml` — cả 3 router phải nhận đúng loopback IP của mình (không bị gán nhầm IP của router khác).
4. Chạy lại playbook lần 2 — xác nhận không có lỗi (idempotent hoặc ít nhất không phá vỡ gì khi chạy lại).
5. Ghi lại: nội dung `playbook.yml` đã hoàn thiện + output `ansible-playbook` chạy thành công + output verify (`show ip route`) của cả 3 router.

## Gợi ý
- Biến `{{ inventory_hostname }}` chính là tên host trong inventory (`r1`, `r2`, `r3`) — trùng tên container containerlab đã đặt, dùng thẳng được cho `docker exec`.
- Nếu Ansible báo lỗi kết nối, kiểm tra `ansible_connection=local` đã khai báo trong `inventory.ini` chưa (bài này không SSH, chạy lệnh ngay trên server).

## Bonus — Jinja2 Template (hướng production)
Trong production, dùng module `command`/`shell` là **anti-pattern** vì không idempotent thực sự (chạy lại là thêm IP trùng). Hãy thử:
1. Tạo file `templates/frr.conf.j2` với nội dung Jinja2:
   ```jinja2
   interface lo
     ip address {{ loopback_ip }}/32
   ```
2. Dùng module `ansible.builtin.template` để render ra file config, sau đó copy vào container bằng `docker cp`.
3. **Mở rộng:** Tìm hiểu thêm các Ansible network modules chuyên dụng (`ansible.netcommon.cli_config`, `community.network.frr`) — trong production, đây là cách đúng để quản lý cấu hình router thay vì `docker exec` + `vtysh -c`.

## Cách nộp bài
Đăng nội dung playbook đã hoàn thiện + output chạy vào Facebook group/comment bài viết tuần này.
**Hạn nộp:** 1 tuần kể từ ngày đăng bài.

## Bài tiếp theo
→ 09-python-parsing-show-command

# Verify checklist — Bài 29 chaos-dhcp (chạy trên server lab)

## Deploy
```bash
cd 29-troubleshooting-chaos-dhcp/topology
sudo clab deploy -t chaos-dhcp.clab.yml
```
- [ ] Deploy sạch, 4 container lên (`dhcp-server r1 client-a client-b`), tên không có prefix `clab-`.

## Triệu chứng (Chaos State)
- [ ] `docker exec client-b udhcpc -i eth1 -n -t 3 -T 2` → Thất bại (no lease / timeout).
- [ ] `docker exec client-a udhcpc -i eth1 -n` → Nhận IP trong dải `10.0.1.100-200`.
- [ ] `docker exec client-a ip route show` → Gateway nhận được là `10.0.1.254` (IP không tồn tại).
- [ ] `docker exec client-a ping -c 2 -W 2 10.0.0.10` → 100% loss (ping gateway không phản hồi).
- [ ] `docker exec dhcp-server cat /var/log/dnsmasq.log` → Thấy dòng `no address range available for DHCP request via 10.0.2.1`.

## Sửa lỗi (Fix)
```bash
docker exec dhcp-server sed -i \
  -e 's/10.0.20.100,10.0.20.200/10.0.2.100,10.0.2.200/' \
  -e 's/tag:hq,3,10.0.1.254/tag:hq,3,10.0.1.1/' /etc/dnsmasq.conf
docker exec dhcp-server pkill dnsmasq
docker exec dhcp-server dnsmasq --conf-file=/etc/dnsmasq.conf
```

## Pass cuối (Sau khi sửa lỗi)
```bash
docker exec client-b udhcpc -i eth1 -n
docker exec client-a udhcpc -i eth1 -n
```
- [ ] `client-b` nhận IP trong dải `10.0.2.100-200` và default gateway `10.0.2.1`.
- [ ] `client-a` nhận IP trong dải `10.0.1.100-200` và default gateway `10.0.1.1`.
- [ ] `docker exec client-a ping -c 3 10.0.0.10` → 0% loss.
- [ ] `docker exec client-b ping -c 3 10.0.0.10` → 0% loss.
- [ ] Ping chéo giữa 2 client thông suốt 0% loss.

## Cleanup / Reset
```bash
# Xoá lab:
sudo clab destroy -t chaos-dhcp.clab.yml

# Hoặc reset lại trạng thái chaos ban đầu cho học viên:
sudo clab deploy -t chaos-dhcp.clab.yml --reconfigure
```

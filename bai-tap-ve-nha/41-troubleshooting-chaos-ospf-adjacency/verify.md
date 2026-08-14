# Verify checklist — Bài 41 chaos-ospf-adjacency (chạy trên server lab)

## Deploy
```bash
cd 41-troubleshooting-chaos-ospf-adjacency/topology
sudo clab deploy -t chaos-ospf-adj.clab.yml
sleep 60
```
- [ ] Deploy sạch, 6 container lên (`r1 r2 r3 host-hq host-cn1 host-cn2`), tên không có prefix `clab-`.
- [ ] `docker exec r1 ip link show eth2 | grep -o 'mtu [0-9]*'` → `mtu 1400`; `docker exec r2 ip link show eth1 | grep -o 'mtu [0-9]*'` → `mtu 1500`.

## Triệu chứng
- [ ] `docker exec host-hq ping -c 3 10.20.1.10` → 100% loss.
- [ ] `docker exec host-cn1 ping -c 3 10.10.1.10` → 100% loss.
- [ ] `docker exec r1 vtysh -c "show ip ospf neighbor"` → `2.2.2.2` kẹt `ExStart` (⚠️ **điểm risk chính**: nếu ra `Full`, nghĩa là exec `ip link set eth2 mtu 1400` chạy **sau** khi adjacency đã hình thành → cần đổi cách cấy: thêm `- ip link set eth2 down` + `- ip link set eth2 up` sau lệnh mtu trong `.clab.yml`, hoặc ghi vào guide bước `clear ip ospf process`. Nếu ra `Exchange`/`Loading` thay vì `ExStart` → chỉnh câu chữ guide cho khớp output thật).
- [ ] `docker exec r2 vtysh -c "show ip ospf neighbor"` → chỉ có `1.1.1.1` (kẹt), **không có** `3.3.3.3`.
- [ ] `docker logs r1 2>&1 | grep -i mtu` → dòng `Packet[DD]: Neighbor ... MTU ... is larger than [eth2]'s MTU 1400` (⚠️ nếu log nằm chỗ khác, thử `docker exec r1 vtysh -c "show log"`; nếu không có log nào → sửa lại guide, bỏ phần trích log).
- [ ] `docker exec r2 vtysh -c "show ip ospf" | grep -A2 -i "area 1"` → hiện `Stub`.

## Fix 1 — MTU mismatch
```bash
docker exec r1 ip link set eth2 mtu 1500
docker exec r1 vtysh -c "clear ip ospf process"
sleep 30
```
- [ ] `docker exec r1 vtysh -c "show ip ospf neighbor"` → `2.2.2.2` = `Full`.
- [ ] `docker exec host-hq ping -c 3 10.20.1.10` → vẫn fail (lỗi 2 và 3 còn nguyên).

## Fix 2 — area 1 stub mismatch
```bash
docker exec r2 vtysh -c "conf t" -c "router ospf" -c "no area 1 stub"
sleep 30
```
- [ ] `docker exec r2 vtysh -c "show ip ospf neighbor"` → cả `1.1.1.1` và `3.3.3.3` = `Full`.
- [ ] `docker exec r2 vtysh -c "show ip route ospf"` → có `10.20.1.0/24` và `10.20.2.0/24`.
- [ ] `docker exec r1 vtysh -c "show ip route ospf"` → **chưa** có `10.20.x` (lỗi 3 chặn ở ABR).
- [ ] `docker exec r1 vtysh -c "show ip ospf database summary"` → không có prefix `10.20.x` (⚠️ đối chiếu output thật, chỉnh tên lệnh nếu FRR 10.5.1 in khác).
- [ ] Kiểm tra thêm cách B: `docker exec r3 vtysh -c "conf t" -c "router ospf" -c "area 1 stub"` cũng lên `Full` (chạy trên lab sạch khác, hoặc bỏ qua nếu tốn thời gian).

## Fix 3 — area range not-advertise
```bash
docker exec r2 vtysh -c "conf t" -c "router ospf" -c "area 1 range 10.20.0.0/22 advertise"
sleep 20
```
- [ ] `docker exec r1 vtysh -c "show ip route ospf"` → có `10.20.0.0/22` (⚠️ xác nhận FRR 10.5.1 nhận cú pháp `advertise`; nếu báo lỗi cú pháp → dùng `no area 1 range 10.20.0.0/22` và sửa lời giải cho khớp).

## Pass cuối
- [ ] `docker exec host-hq ping -c 3 10.20.1.10` → 0% loss.
- [ ] `docker exec host-hq ping -c 3 10.20.2.10` → 0% loss.
- [ ] `docker exec host-cn1 ping -c 3 10.10.1.10` → 0% loss.
- [ ] `docker exec r3 vtysh -c "show ip route ospf"` → có `10.10.1.0/24`.

## Cleanup
```bash
sudo clab destroy -t chaos-ospf-adj.clab.yml
```
- [ ] Không còn container sót (`docker ps -a | grep -E 'r1|r2|r3|host-'`).

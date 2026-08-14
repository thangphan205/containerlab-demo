# Verify checklist — Bài 43 chaos-routing-loop (chạy trên server lab)

## Deploy
```bash
cd 43-troubleshooting-chaos-routing-loop/topology
sudo clab deploy -t chaos-routing-loop.clab.yml
sleep 60
```
- [ ] Deploy sạch, 6 container (`core b1 b2 isp host-hq srv-inet`).
- [ ] `docker exec core vtysh -c "show ip ospf neighbor"` → `2.2.2.2` và `3.3.3.3` đều `Full`.

## Triệu chứng
- [ ] `docker exec host-hq ping -c 3 198.51.100.10` → fail, thông báo có chữ **`Time to live exceeded`** (⚠️ nếu ra `Destination Host Unreachable` hoặc timeout im lặng → kiểm tra lại 2 điều: `docker exec core vtysh -c "show ip route 198.51.100.10"` phải là static via `10.0.2.2`, và `docker exec b2 vtysh -c "show ip route 0.0.0.0/0"` phải là static via `10.0.2.1`).
- [ ] `docker exec host-hq traceroute -n -m 10 198.51.100.10` → dãy hop lặp `10.0.2.1`/`10.0.2.2` (⚠️ ghi lại **dãy thật** và chỉnh câu chữ trong lời giải cho khớp; nếu image thiếu `traceroute` → dùng `tracepath -n`).
- [ ] `docker exec core vtysh -c "show ip route 0.0.0.0/0"` → `O E2` via `10.0.2.2`, metric 5 (⚠️ **điểm risk chính**: xác nhận FRR 10.5.1 dùng đúng metric khai trong `default-information originate ... metric N` và default của b2 thắng default của b1. Nếu core cài **cả hai** (ECMP) → sửa config: hạ metric b2 xuống 1 hoặc nâng b1 lên 100, rồi cập nhật lời giải).
- [ ] `docker exec core vtysh -c "show ip route 198.51.100.10"` → `S>*` `[1/0]` via `10.0.2.2`.
- [ ] `docker exec b1 vtysh -c "show ip route 0.0.0.0/0"` → static via `203.0.113.2` (b1 vẫn khoẻ, đường ra thật vẫn tốt).
- [ ] `docker exec b2 vtysh -c "show ip ospf database external"` → có LSA default do `3.3.3.3` phát.

## Fix 1 — b2 ngừng phát default `always`
```bash
docker exec b2 vtysh -c "conf t" -c "router ospf" -c "no default-information originate"
sleep 20
```
- [ ] `docker exec core vtysh -c "show ip route 0.0.0.0/0"` → chuyển sang `O E2` via `10.0.1.2` (b1), metric 10.
- [ ] `docker exec host-hq ping -c 2 203.0.113.2` → OK (đích ngoài dải bị ghim static đã đi đúng đường).
- [ ] `docker exec host-hq ping -c 3 198.51.100.10` → vẫn fail, vẫn `Time to live exceeded` (static /24 + default ngược trên b2 còn nguyên).

## Fix 2 — gỡ static default trỏ ngược trên b2
```bash
docker exec b2 vtysh -c "conf t" -c "no ip route 0.0.0.0/0 10.0.2.1"
sleep 5
```
- [ ] `docker exec b2 vtysh -c "show ip route static"` → trống.
- [ ] `docker exec host-hq ping -c 3 198.51.100.10` → vẫn fail nhưng **đổi triệu chứng** thành `Destination Net Unreachable` (⚠️ đối chiếu chuỗi thật; b2 giờ drop và trả ICMP unreachable — nếu ra timeout im lặng thì sửa câu chữ guide).

## Fix 3 — gỡ static /24 sót trên core
```bash
docker exec core vtysh -c "conf t" -c "no ip route 198.51.100.0/24 10.0.2.2"
sleep 5
```
- [ ] `docker exec core vtysh -c "show ip route 198.51.100.0/24"` → chỉ còn đường theo default (hoặc không có entry riêng).

## Pass cuối
- [ ] `docker exec host-hq ping -c 3 198.51.100.10` → 0% loss.
- [ ] `docker exec host-hq traceroute -n 198.51.100.10` → `10.50.1.1 → 10.0.1.2 → 203.0.113.2 → 198.51.100.10`, không lặp.
- [ ] `docker exec core vtysh -c "show ip route 0.0.0.0/0"` → duy nhất 1 default via `10.0.1.2`.
- [ ] `docker exec b2 vtysh -c "show ip route static"` → trống.

## Cleanup
```bash
sudo clab destroy -t chaos-routing-loop.clab.yml
```
- [ ] Không còn container sót.

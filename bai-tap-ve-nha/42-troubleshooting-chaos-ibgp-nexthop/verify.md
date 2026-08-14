# Verify checklist — Bài 42 chaos-ibgp-nexthop (chạy trên server lab)

## Deploy
```bash
cd 42-troubleshooting-chaos-ibgp-nexthop/topology
sudo clab deploy -t chaos-ibgp.clab.yml
sleep 60
```
- [ ] Deploy sạch, 7 container (`core b1 b2 isp-a isp-b host-lan srv-inet`).
- [ ] `docker exec core vtysh -c "show ip ospf neighbor"` → `10.255.0.2` và `10.255.0.3` đều `Full`.
- [ ] `docker exec b1 vtysh -c "show bgp summary"` → eBGP `203.0.113.2` Established; `docker exec b2 vtysh -c "show bgp summary"` → eBGP `203.0.113.6` Established (⚠️ nếu Established mà 0 prefix → kiểm tra `no bgp ebgp-requires-policy` đã có trong cả 4 router BGP).

## Triệu chứng
- [ ] `docker exec host-lan ping -c 3 198.51.100.10` → 100% loss.
- [ ] `docker exec core vtysh -c "show ip route 198.51.100.0/24"` → không có route.
- [ ] `docker exec core vtysh -c "show ip bgp 198.51.100.0/24"` → có đường qua next-hop `203.0.113.2`, kèm chữ **`(inaccessible)`**, không có dấu `>` (⚠️ đối chiếu chính xác chuỗi FRR 10.5.1 in ra — nếu là `inaccessible` viết khác thì sửa guide).
- [ ] `docker exec core vtysh -c "show bgp summary"` → `10.255.0.2` Established, `10.255.0.3` **Active/Connect**.
- [ ] `docker exec core ping -c 2 10.255.0.3` → fail; `docker exec core vtysh -c "show ip route 10.255.0.3"` → không có route.

## Fix 1 — b1 thiếu next-hop-self
```bash
docker exec b1 vtysh -c "conf t" -c "router bgp 65001" -c "address-family ipv4 unicast" -c "neighbor 10.255.0.1 next-hop-self"
sleep 15
```
- [ ] `docker exec core vtysh -c "show ip route 198.51.100.0/24"` → via `10.0.1.2`.
- [ ] `docker exec host-lan ping -c 3 198.51.100.10` → **OK** (mạng thông tạm thời).
- [ ] `docker exec core vtysh -c "show bgp summary"` → `10.255.0.3` vẫn Active.

## Fix 2 — loopback b2 chưa vào OSPF (mạng sẽ đứt lại — đúng kịch bản)
```bash
docker exec b2 vtysh -c "conf t" -c "router ospf" -c "network 10.255.0.3/32 area 0"
sleep 45
```
- [ ] `docker exec core vtysh -c "show ip route 10.255.0.3"` → via `10.0.2.2`.
- [ ] `docker exec core vtysh -c "show bgp summary"` → cả 2 iBGP `Established`.
- [ ] `docker exec core vtysh -c "show ip bgp 198.51.100.0/24"` → best (`>`) chuyển sang next-hop `10.255.0.3`, local-pref 200.
- [ ] `docker exec host-lan ping -c 3 198.51.100.10` → **fail trở lại** (⚠️ mấu chốt của bài — nếu vẫn thông, kiểm tra `docker exec isp-b vtysh -c "show ip route 198.51.100.0/24"` có đúng là `blackhole` không, và `docker exec core vtysh -c "show ip bgp 198.51.100.0/24"` best path có thật sự qua b2 không).
- [ ] `docker exec host-lan traceroute -n -m 6 198.51.100.10` → chết sau `203.0.113.6` (⚠️ nếu image thiếu `traceroute`, đổi guide sang `tracepath` hoặc bỏ bước này).

## Fix 3 — gỡ route-map local-preference
```bash
docker exec core vtysh -c "conf t" -c "router bgp 65001" -c "address-family ipv4 unicast" -c "no neighbor 10.255.0.3 route-map PREF-BACKUP in"
docker exec core vtysh -c "clear ip bgp * soft in"
sleep 15
```
- [ ] `docker exec core vtysh -c "show ip bgp 198.51.100.0/24"` → best (`>`) qua `10.255.0.2`; đường qua `10.255.0.3` còn trong bảng với AS-path `65020 65020 65020` (⚠️ xác nhận prepend của isp-b có hiệu lực; nếu AS-path 2 đường bằng nhau → best path thành không xác định, phải chỉnh config isp-b).

## Pass cuối
- [ ] `docker exec core vtysh -c "show bgp summary"` → 2 phiên iBGP Established.
- [ ] `docker exec host-lan ping -c 3 198.51.100.10` → 0% loss.
- [ ] `docker exec host-lan traceroute -n 198.51.100.10` → qua `10.0.1.2` rồi `203.0.113.2`.
- [ ] `docker exec isp-a vtysh -c "show ip bgp"` → có `10.30.1.0/24`.

## Cleanup
```bash
sudo clab destroy -t chaos-ibgp.clab.yml
```
- [ ] Không còn container sót.

# Verify checklist — Bài 45 chaos-ospf-full-no-ping (chạy trên server lab)

## Deploy
```bash
cd 45-troubleshooting-chaos-ospf-full-no-ping/topology
sudo clab deploy -t chaos-ospf-fullnoping.clab.yml
sleep 45
```
- [ ] Deploy sạch, 6 container (`r1 r2 r3 host-hq host-a host-b`).
- [ ] **Điều kiện sống còn của bài** — neighbor `Full` ở mọi router, mọi bước:
  ```bash
  for n in r1 r2 r3; do echo "== $n"; docker exec $n vtysh -c "show ip ospf neighbor"; done
  ```
  ⚠️ Nếu bất kỳ lúc nào ra khác `Full` thì lỗi cấy sai chỗ — phải sửa lại config, không được để bài mất tính chất "Full mà không ping được".
- [ ] `docker exec r3 ip -br addr` → `eth2` = `10.20.1.1/25`, `eth3` = `10.20.2.1/24`.
- [ ] `docker exec host-b ip route` → `default via 10.20.2.254`, và **không còn** default qua `eth0` (mgmt).
- [ ] `docker exec host-a ip route` → `default via 10.20.1.1`; `docker exec host-hq ip route` → `default via 10.60.1.1`.

## Triệu chứng
- [ ] `docker exec host-hq ping -c 3 10.20.1.200` → fail, `Destination Net Unreachable` (⚠️ ghi lại chuỗi thật; nếu ra timeout im lặng thì sửa câu chữ trong guide).
- [ ] `docker exec host-hq ping -c 3 10.20.2.10` → fail, cũng `Destination Net Unreachable`.
- [ ] `docker exec r1 vtysh -c "show ip route ospf"` → **có** `10.20.1.0/25`, **không có** `10.20.2.0/24` (⚠️ **điểm risk chính**: xác nhận FRR quảng bá prefix theo **mask của interface** (`/25`) chứ không theo câu lệnh `network ... /24`. Nếu ra `/24` → đổi cách cấy: giữ `host-a` ở `.200` nhưng khai interface `/26`, hoặc chuyển `host-a` sang `.130`; rồi cập nhật lời giải + guide).
- [ ] `docker exec r3 vtysh -c "show ip protocols"` → chỉ liệt kê `10.0.23.0/30` và `10.20.1.0/24`.
- [ ] `docker exec r3 vtysh -c "show ip ospf interface brief"` → có `eth1`, `eth2`; **không có** `eth3` (⚠️ đối chiếu tên cột/format thật của FRR 10.5.1).
- [ ] `docker exec r3 ping -c 2 10.20.1.200` → **fail** (do mask /25, `.200` ngoài dải).
- [ ] `docker exec r3 ping -c 2 10.20.2.10` → **OK** (host-b sống, chỉ thiếu đường về).

## Fix 1 — khai LAN-B vào OSPF
```bash
docker exec r3 vtysh -c "conf t" -c "router ospf" -c "network 10.20.2.0/24 area 0"
sleep 20
```
- [ ] `docker exec r3 vtysh -c "show ip ospf interface brief"` → `eth3` xuất hiện.
- [ ] `docker exec r1 vtysh -c "show ip route ospf"` → có `10.20.2.0/24`.
- [ ] `docker exec host-hq ping -c 3 10.20.2.10` → **vẫn fail** nhưng đổi triệu chứng thành **timeout** (không còn `unreachable`) — lỗi 3 lộ ra.
- [ ] Neighbor vẫn `Full` cả 3 router.

## Fix 2 — sửa subnet mask LAN-A
```bash
docker exec r3 vtysh -c "conf t" -c "interface eth2" -c "no ip address 10.20.1.1/25" -c "ip address 10.20.1.1/24"
sleep 20
```
- [ ] `docker exec r3 ip -br addr show eth2` → `10.20.1.1/24` (⚠️ xác nhận zebra nhận cặp lệnh `no ip address ... /25` + `ip address ... /24`; nếu FRR từ chối, thử `docker exec r3 ip addr del 10.20.1.1/25 dev eth2 && docker exec r3 ip addr add 10.20.1.1/24 dev eth2` rồi ghi cách chạy được vào lời giải).
- [ ] `docker exec r1 vtysh -c "show ip route ospf"` → `10.20.1.0/24` (không còn `/25`).
- [ ] `docker exec r3 ping -c 2 10.20.1.200` → OK.
- [ ] `docker exec host-hq ping -c 3 10.20.1.200` → **OK**.
- [ ] ⚠️ Neighbor `r2`↔`r3` **không được rớt** khi đổi IP trên eth2 (khác interface). Kiểm lại `show ip ospf neighbor`.

## Fix 3 — sửa default gateway host-b
```bash
docker exec host-b ip route replace default via 10.20.2.1 dev eth1
```
- [ ] `docker exec host-b ip route` → `default via 10.20.2.1`.
- [ ] `docker exec host-hq ping -c 3 10.20.2.10` → **OK**.

## Pass cuối
- [ ] `docker exec host-hq ping -c 3 10.20.1.200` → 0% loss.
- [ ] `docker exec host-hq ping -c 3 10.20.2.10` → 0% loss.
- [ ] `docker exec r1 vtysh -c "show ip route ospf"` → có cả `10.20.1.0/24` và `10.20.2.0/24`.
- [ ] `for n in r1 r2 r3; do docker exec $n vtysh -c "show ip ospf neighbor"; done` → toàn `Full`.
- [ ] Chiều ngược: `docker exec host-a ping -c 3 10.60.1.10` và `docker exec host-b ping -c 3 10.60.1.10` → OK.

## Cleanup
```bash
sudo clab destroy -t chaos-ospf-fullnoping.clab.yml
```
- [ ] Không còn container sót.

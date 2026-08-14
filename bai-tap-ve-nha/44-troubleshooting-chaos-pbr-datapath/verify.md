# Verify checklist — Bài 44 chaos-pbr-datapath (chạy trên server lab)

## Deploy
```bash
cd 44-troubleshooting-chaos-pbr-datapath/topology
sudo clab deploy -t chaos-pbr.clab.yml
```
- [ ] Deploy sạch, 5 container (`gw isp host-kd host-kt srv-web`).
- [ ] `docker exec gw nft list ruleset` → có `table ip nat` với đúng 1 dòng `oifname "eth3" masquerade` (⚠️ nếu `nft -f` fail lúc deploy → kiểm tra `apk add nftables` có chạy được không: `apk` cần default route mgmt, mà exec `ip route del default dev eth0` phải nằm **sau** `apk add` trong file topology).
- [ ] `docker exec gw ip rule show` → có đủ 3 rule tự thêm: `90 ... unreachable`, `100 ... lookup 100`, `110 ... lookup 200` (⚠️ **điểm risk**: xác nhận iproute2 trong multitool nhận cú pháp `ip rule add from X unreachable priority N`; nếu báo lỗi cú pháp → đổi sang `ip rule add from 10.40.2.0/24 type unreachable priority 90` trong topology **và** trong lời giải).
- [ ] `docker exec gw ip route show table 201` → có default via `203.0.113.6`; `ip route show table 200` → **trống**.

## Triệu chứng
- [ ] `docker exec host-kd ping -c 3 198.51.100.10` → 0% loss (phòng Kinh doanh bình thường).
- [ ] `docker exec host-kt ping -c 3 198.51.100.10` → fail với `Destination Net Unreachable` (⚠️ nếu ra timeout im lặng → ghi lại output thật và chỉnh guide).
- [ ] `docker exec host-kd curl -s -m 5 -o /dev/null -w "%{http_code}\n" http://198.51.100.10` → `200`.
- [ ] `docker exec srv-web tail -n 3 /var/log/nginx/access.log` → thấy request với IP nguồn `203.0.113.1` (⚠️ **điểm risk**: xác nhận path log của nginx trong `wbitt/network-multitool:3.22.2`; nếu log ghi ra stdout thì dùng `docker logs srv-web` và sửa mọi chỗ nhắc `access.log` trong guide, hoặc chuyển hẳn sang cách kiểm chứng bằng `tcpdump` trên `isp`).

## Fix 1 — gỡ rule cách ly
```bash
docker exec gw ip rule del from 10.40.2.0/24 unreachable priority 90
```
- [ ] `docker exec gw ip rule show` → không còn rule priority 90.
- [ ] `docker exec host-kt ping -c 3 198.51.100.10` → **OK** (thông nhưng sai circuit).
- [ ] `docker exec host-kt curl -s -m 5 -o /dev/null -w "%{http_code}\n" http://198.51.100.10` → `200`.
- [ ] `docker exec srv-web tail -n 3 /var/log/nginx/access.log` → request của Kỹ thuật vẫn mang IP `203.0.113.1` (sai circuit).
- [ ] `docker exec gw ip route get 198.51.100.10 from 10.40.2.10 iif eth2` → `dev eth3` (⚠️ nếu lệnh báo lỗi thiếu tham số, thử bỏ `iif eth2`; ghi lại dạng lệnh chạy được để sửa guide).

## Fix 2 — chuyển route sang đúng table 200 (mạng sẽ đứt lại — đúng kịch bản)
```bash
docker exec gw ip route add default via 203.0.113.6 dev eth4 table 200
docker exec gw ip route del default via 203.0.113.6 dev eth4 table 201
```
- [ ] `docker exec gw ip route get 198.51.100.10 from 10.40.2.10 iif eth2` → `dev eth4`.
- [ ] `docker exec host-kt ping -c 3 198.51.100.10` → **fail trở lại**, lần này là timeout (100% loss), không phải `unreachable`.
- [ ] `docker exec gw timeout 10 tcpdump -nni eth4 icmp` (chạy song song với ping từ host-kt) → thấy `10.40.2.10 > 198.51.100.10`, tức **IP nguồn nội bộ, chưa NAT**.
- [ ] `docker exec isp timeout 10 tcpdump -nni eth2 icmp` → gói có tới nhà mạng, không có gói trả về.
- [ ] `docker exec host-kd ping -c 3 198.51.100.10` → vẫn OK (phòng Kinh doanh không bị ảnh hưởng).

## Fix 3 — thêm NAT cho circuit B
```bash
docker exec gw nft add rule ip nat postrouting oifname "eth4" masquerade
```
- [ ] `docker exec gw nft list ruleset` → có cả 2 dòng masquerade (`eth3`, `eth4`).
- [ ] `docker exec host-kt ping -c 3 198.51.100.10` → 0% loss.

## Pass cuối
- [ ] `docker exec host-kd curl -s -m 5 -o /dev/null -w "kd=%{http_code}\n" http://198.51.100.10` → `200`.
- [ ] `docker exec host-kt curl -s -m 5 -o /dev/null -w "kt=%{http_code}\n" http://198.51.100.10` → `200`.
- [ ] `docker exec srv-web tail -n 10 /var/log/nginx/access.log` → request từ `host-kd` mang IP `203.0.113.1`, từ `host-kt` mang `203.0.113.5`.
- [ ] `docker exec gw ip rule show` → còn đúng 2 rule policy (100, 110), không còn rule chặn.

## Cleanup
```bash
sudo clab destroy -t chaos-pbr.clab.yml
```
- [ ] Không còn container sót.

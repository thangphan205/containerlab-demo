# Verify checklist — Bài 39 chaos-ntp-2 (chạy trên server lab)

## Deploy
```bash
cd 39-troubleshooting-chaos-ntp-2/topology
sudo clab deploy -t chaos-ntp2.clab.yml
```
- [ ] Deploy sạch; dnsmasq + 2 chronyd đều sống (`ps aux | grep -E 'chronyd|dnsmasq'` từng node).
- [ ] DNS healthy: `docker exec client dig +short ntp.corp.local` → `10.0.6.123`.

## Triệu chứng (chờ ~1 phút sau deploy)
- [ ] `docker exec client chronyc tracking` → Not synchronised / Stratum 0.
- [ ] `docker exec client chronyc sources -v` → nguồn `ntp.corp.locl` unresolved (⚠️ ghi lại chính xác cách chrony hiển thị nguồn chưa resolve — `?` ở Reach hay tên bị ẩn — chỉnh guide theo thực tế).

## Fix 1 (typo hostname client)
```bash
docker exec client sed -i 's/server ntp.corp.locl iburst/server ntp.corp.local iburst/' /etc/chrony/chrony.conf
docker exec client pkill chronyd
docker exec client chronyd -x
```
- [ ] `chronyc sources` giờ thấy nguồn resolve ra `10.0.6.123` / tên ntp.corp.local, Reach tăng dần nhưng **không bao giờ lên `^*`** (chỉ `^?`).
- [ ] `docker exec ntp tcpdump -c 4 -ni eth1 udp port 123` — thấy request + reply (server có trả lời).
- [ ] `docker exec client chronyc ntpdata` → Stratum 16, Leap: Not synchronised. (⚠️ confirm chronyd unsynced vẫn reply thay vì im lặng — nếu im lặng thì triệu chứng khác, sửa guide.)
- [ ] `docker exec ntp chronyc tracking` → chính server Not synchronised.

## Fix 2 (server thiếu local stratum)
```bash
docker exec ntp sh -c 'echo "local stratum 8" >> /etc/chrony/chrony.conf'
docker exec ntp pkill chronyd
docker exec ntp chronyd -x
```
- [ ] Chờ vài chu kỳ poll (hoặc `docker exec client chronyc burst 4/4`): `docker exec client chronyc sources` → `^*` ntp.corp.local.
- [ ] `docker exec client chronyc tracking` → Stratum 9, Leap status: Normal.
- [ ] ⚠️ Nếu sau fix client vẫn kẹt lâu: thử `docker exec client chronyc makestep` hoặc restart chronyd client — nếu cần bước này thì bổ sung vào guide.

## Cleanup
```bash
sudo clab destroy -t chaos-ntp2.clab.yml
```
- [ ] Không còn container sót.

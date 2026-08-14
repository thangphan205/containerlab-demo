# Verify checklist — Bài 38 chaos-dns-2 (chạy trên server lab)

## Deploy
```bash
cd 38-troubleshooting-chaos-dns-2/topology
sudo clab deploy -t chaos-dns2.clab.yml
```
- [ ] Deploy sạch, dnsmasq start OK trên cả `resolver` lẫn `auth` (`docker exec resolver ps aux | grep dnsmasq`).
- [ ] `docker exec auth dig @10.0.8.54 erp.corp.local +short` → `10.0.8.90` (authoritative tự trả lời được).
- [ ] `docker exec auth dig @10.0.8.54 app.corp.local` → status **NXDOMAIN** (⚠️ nếu ra REFUSED thay vì NXDOMAIN → `local=/corp.local/` không hoạt động như kỳ vọng, chỉnh guide theo status thực tế).

## Triệu chứng
- [ ] `docker exec client curl -m 5 http://app.corp.local` fail — không phân giải.
- [ ] `docker exec client dig erp.corp.local` → timeout (`no servers could be reached`) — do resolv.conf trỏ .55.
- [ ] `docker exec client dig @10.0.8.53 erp.corp.local` → timeout/SERVFAIL (do resolver forward .64). **Ghi lại status thực tế** (dnsmasq có thể trả SERVFAIL sau retry hoặc để client timeout), chỉnh guide theo đúng.
- [ ] Trên resolver: `cat /var/log/dnsmasq.log` có dòng `forwarded ... to 10.0.8.64`.

## Fix 1 (client resolv.conf)
```bash
docker exec client sh -c 'echo "nameserver 10.0.8.53" > /etc/resolv.conf'
```
- [ ] `dig erp.corp.local` từ client giờ chết ở tầng resolver (chưa hết lỗi).

## Fix 2 (resolver upstream .64 → .54)
```bash
docker exec resolver sed -i 's|server=/corp.local/10.0.8.64|server=/corp.local/10.0.8.54|' /etc/dnsmasq.conf
docker exec resolver pkill dnsmasq
docker exec resolver dnsmasq --conf-file=/etc/dnsmasq.conf
```
- [ ] `docker exec client dig +short erp.corp.local` → `10.0.8.90` ✅
- [ ] `docker exec client dig app.corp.local` → **NXDOMAIN** (còn lỗi 3).

## Fix 3 (auth record typo)
```bash
docker exec auth sed -i 's|address=/app.corplocal/10.0.8.90|address=/app.corp.local/10.0.8.90|' /etc/dnsmasq.conf
docker exec auth pkill dnsmasq
docker exec auth dnsmasq --conf-file=/etc/dnsmasq.conf
```
- [ ] `docker exec client dig +short app.corp.local` → `10.0.8.90`.
  - ⚠️ Resolver có thể còn **cache negative** cho app.corp.local — nếu vẫn NXDOMAIN, đợi TTL hoặc restart dnsmasq trên resolver; nếu gặp, ghi chú vào guide (dạy luôn về negative cache).
- [ ] `docker exec client curl -s http://app.corp.local` → `<h1>app.corp.local OK</h1>`.

## Cleanup
```bash
sudo clab destroy -t chaos-dns2.clab.yml
```
- [ ] Không còn container sót.

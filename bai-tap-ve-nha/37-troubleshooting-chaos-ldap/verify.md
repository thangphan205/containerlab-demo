# Verify checklist — Bài 37 chaos-ldap (chạy trên server lab)

⚠️ Bài risk cao nhất đợt này — slapd trên Alpine chưa từng verify. Soi kỹ từng bước deploy.

## Deploy
```bash
cd 37-troubleshooting-chaos-ldap/topology
sudo clab deploy -t chaos-ldap.clab.yml
```
- [ ] `apk add openldap openldap-back-mdb openldap-clients` cài được (⚠️ confirm tên gói đúng trên Alpine 3.22; nếu thiếu schema file → có thể cần thêm gói `openldap-overlay-all` hoặc kiểm tra path `/etc/openldap/schema/`).
- [ ] `slapadd` chạy OK (warning "no DB_CONFIG" / checkpoint là benign). Nếu lỗi `moduleload back_mdb.so` → back_mdb có thể built-in, thử xoá 2 dòng modulepath/moduleload.
- [ ] slapd start được từ script và **tự fork** (exec không treo). Nếu treo → đổi script sang `sh -c "nohup slapd ... &"` kiểu bài 35, ghi gotcha.
- [ ] `docker exec ldap ps aux | grep slapd` — process sống.
- [ ] `docker exec ldap ldapsearch -H ldapi:/// -x -s base -b "" namingContexts` → `dc=ntc,dc=vn` (⚠️ nếu ldapi socket path khác default → chỉnh guide).

## Triệu chứng
- [ ] `docker exec client ldapsearch -x -LLL "(uid=*)" cn mail` → `Can't contact LDAP server (-1)`.
- [ ] `docker exec client ldapsearch -x -d 1 ...` output có IP 10.0.7.88 (đối chiếu error string thật, chỉnh guide nếu khác).
- [ ] `docker exec ldap ss -tlnp` — KHÔNG có :389.

## Fix 1 (client URI)
```bash
docker exec client sed -i 's|URI  ldap://10.0.7.88|URI  ldap://10.0.7.89|' /etc/openldap/ldap.conf
```
- [ ] ldapsearch vẫn fail (giờ do listener) — connection refused tới .89.

## Fix 2 (listener TCP)
```bash
docker exec ldap sed -i 's|SLAPD_SERVICES="ldapi:///"|SLAPD_SERVICES="ldap:/// ldapi:///"|' /etc/openldap/start-slapd.sh
docker exec ldap pkill slapd
docker exec ldap sh /etc/openldap/start-slapd.sh
```
- [ ] `ss -tlnp` giờ có `*:389` slapd.
- [ ] `docker exec client ldapwhoami -x` → `anonymous` (bind OK).
- [ ] `docker exec client ldapsearch -x -LLL "(uid=*)" cn mail` → rỗng hoặc `No such object (32)` (**ghi lại behavior thực tế** — err=32 hay 0 kết quả — chỉnh guide theo đúng).
- [ ] `docker exec client ldapsearch -x -D "cn=admin,dc=ntc,dc=vn" -w ntc123 -LLL "(uid=*)" cn mail` → đủ 3 user.

## Fix 3 (ACL)
```bash
docker exec ldap sed -i 's/    by \* none/    by * read/' /etc/openldap/slapd.conf
docker exec ldap pkill slapd
docker exec ldap sh /etc/openldap/start-slapd.sh
```
- [ ] `docker exec client ldapsearch -x -LLL "(uid=*)" cn mail` → 3 user (an.nguyen, binh.tran, chi.le), anonymous.

## Cleanup
```bash
sudo clab destroy -t chaos-ldap.clab.yml
```
- [ ] Không còn container sót.

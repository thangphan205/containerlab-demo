**Language / Ngôn ngữ:** [English](README.md) | [Tiếng Việt](README_vi.md)

# Hướng Dẫn Cấu Hình Mạng PCIO APRICOT 2026 - Chi Tiết Hoàn Chỉnh

## Tổng Quan Phòng Lab

Trong phòng lab này, bạn sẽ cấu hình một mạng gồm hai hệ tự trị (group) kết nối qua một nhà cung cấp trung chuyển. Mỗi group có giao thức định tuyến nội bộ riêng và kết nối với nhà cung cấp trung chuyển bằng eBGP.

### Kiến Trúc Mạng

```
Group 1 (AS10)  <---> Nhà cung cấp trung chuyển (AS121) <---> Group 2 (AS20)
  OSPF IGP          eBGP Peering              IS-IS IGP
```

### Vai Trò Router

**Group 1 (AS10) - OSPF IGP:**

- **Router-C1**: Core router (Route Reflector)
- **Router-B1**: Border router (kết nối Transit Provider)
- **Router-A1**: Access router
- **Router-P1**: Peering router
- **Router-Cust1**: Customer router (AS65001)

**Group 2 (AS20) - IS-IS IGP:**

- **Router-C2**: Core router (Route Reflector)
- **Router-B2**: Border router (kết nối Transit Provider)
- **Router-A2**: Access router
- **Router-P2**: Peering router
- **Router-Cust2**: Customer router (AS65002)

**Transit Provider (AS121):**

- **Router-TR1**: Transit router (kết nối cả hai group)

</details>

## Bảng Tóm Tắt IP Address Cho Tất Cả Các Interface

### Group 1 (AS10) - OSPF IGP

#### Router-C1 (Core / Route Reflector)

| Interface | IPv4 Address | IPv6 Address | Mục Đích |
|-----------|--------------|--------------|---------|
| lo | 100.68.1.2/32 | 2001:db8:1:2::1/128 | Loopback (Router ID) |
| eth1 | 100.68.1.16/31 | 2001:db8:1:16::1/64 | Link to C1-B1 |
| eth2 | 100.68.1.18/31 | 2001:db8:1:18::1/64 | Link to C1-A1 |
| eth3 | 100.68.1.20/31 | 2001:db8:1:20::1/64 | Link to C1-P1 |

#### Router-B1 (Border Router)

| Interface | IPv4 Address | IPv6 Address | Mục Đích |
|-----------|--------------|--------------|---------|
| lo | 100.68.1.1/32 | 2001:db8:1:1::1/128 | Loopback (Router ID) |
| eth1 | 100.68.1.17/31 | 2001:db8:1:17::1/64 | Link to B1-C1 |
| eth2 | 100.121.1.1/31 | 2001:db8:121:1::1/64 | eBGP to Transit (TR1) |

#### Router-A1 (Access Router)

| Interface | IPv4 Address | IPv6 Address | Mục Đích |
|-----------|--------------|--------------|---------|
| lo | 100.68.1.4/32 | 2001:db8:1:4::1/128 | Loopback (Router ID) |
| eth1 | 100.68.1.19/31 | 2001:db8:1:19::1/64 | Link to A1-C1 |

#### Router-P1 (Peering Router)

| Interface | IPv4 Address | IPv6 Address | Mục Đích |
|-----------|--------------|--------------|---------|
| lo | 100.68.1.3/32 | 2001:db8:1:3::1/128 | Loopback (Router ID) |
| eth1 | 100.68.1.21/31 | 2001:db8:1:21::1/64 | Link to P1-C1 |

---

### Group 2 (AS20) - IS-IS IGP

#### Router-C2 (Core / Route Reflector)

| Interface | IPv4 Address | IPv6 Address | Mục Đích |
|-----------|--------------|--------------|---------|
| lo | 100.68.2.2/32 | 2001:db8:2:2::1/128 | Loopback (Router ID) |
| eth1 | 100.68.2.16/31 | 2001:db8:2:16::1/64 | Link to C2-B2 |
| eth2 | 100.68.2.18/31 | 2001:db8:2:18::1/64 | Link to C2-A2 |
| eth3 | 100.68.2.20/31 | 2001:db8:2:20::1/64 | Link to C2-P2 |

#### Router-B2 (Border Router)

| Interface | IPv4 Address | IPv6 Address | Mục Đích |
|-----------|--------------|--------------|---------|
| lo | 100.68.2.1/32 | 2001:db8:2:1::1/128 | Loopback (Router ID) |
| eth1 | 100.68.2.17/31 | 2001:db8:2:17::1/64 | Link to B2-C2 |
| eth2 | 100.121.2.2/31 | 2001:db8:121:2::1/64 | eBGP to Transit (TR1) |

#### Router-A2 (Access Router)

| Interface | IPv4 Address | IPv6 Address | Mục Đích |
|-----------|--------------|--------------|---------|
| lo | 100.68.2.4/32 | 2001:db8:2:4::1/128 | Loopback (Router ID) |
| eth1 | 100.68.2.19/31 | 2001:db8:2:19::1/64 | Link to A2-C2 |

#### Router-P2 (Peering Router)

| Interface | IPv4 Address | IPv6 Address | Mục Đích |
|-----------|--------------|--------------|---------|
| lo | 100.68.2.3/32 | 2001:db8:2:3::1/128 | Loopback (Router ID) |
| eth1 | 100.68.2.21/31 | 2001:db8:2:21::1/64 | Link to P2-C2 |

---

### Transit Provider (AS121)

#### Router-TR1 (Transit Router)

| Interface | IPv4 Address | IPv6 Address | Mục Đích |
|-----------|--------------|--------------|---------|
| lo | 100.121.1.0/32 | 2001:db8:121:0::1/128 | Loopback (Router ID) |
| eth1 | 100.121.1.0/31 | 2001:db8:121:1::2/64 | eBGP to B1 (Group 1) |
| eth2 | 100.121.2.2/31 | 2001:db8:121:2::2/64 | eBGP to B2 (Group 2) |

---

## Yêu cầu bài tập

1. **Cấu hình OSPF cho Group 1 (AS10)**: Thiết lập giao thức định tuyến nội bộ (IGP) để đảm bảo kết nối thông suốt giữa các router trong cùng AS.
2. **Cấu hình IS-IS cho Group 2 (AS20)**: Triển khai IS-IS làm IGP cho cả IPv4 và IPv6, thực hiện gán NET và tối ưu hóa metric.
3. **Thiết lập iBGP với Route Reflector**: Cấu hình iBGP nội bộ cho từng group, sử dụng router core làm Route Reflector để tối ưu hóa bảng định tuyến.
4. **Kết nối eBGP và Lọc Route**: Thiết lập peering với Transit Provider (AS121), cấu hình Prefix-list và Route-map để kiểm soát việc quảng bá/nhận route.

---

## Pha 1: Cấu Hình OSPF cho Group 1 (AS10)

### Mục Tiêu

Cấu hình OSPF làm giao thức định tuyến nội bộ cho tất cả router trong Group 1 để cho phép định tuyến động trong hệ tự trị.

### Bước 1.1: Cấu Hình Loopback Interface (Tất cả router Group1)

Mỗi router cần một interface loopback luôn hoạt động, dùng làm router ID và cho iBGP peering.

**Trên Router-C1:**

```
interface lo
  ip address 100.68.1.2/32
  ipv6 address 2001:db8:1:2::1/128
  ip ospf cost 1
!
```

**Trên Router-B1:**

```
interface lo
  ip address 100.68.1.1/32
  ipv6 address 2001:db8:1:1::1/128
  ip ospf cost 1
!
```

**Trên Router-A1:**

```
interface lo
  ip address 100.68.1.4/32
  ipv6 address 2001:db8:1:4::1/128
  ip ospf cost 1
!
```

**Trên Router-P1:**

```
interface lo
  ip address 100.68.1.3/32
  ipv6 address 2001:db8:1:3::1/128
  ip ospf cost 1
!
```

### Bước 1.2: Bật OSPF trên các Interface Kết Nối

Kích hoạt OSPF trên từng interface kết nối đến các router khác.

**Ví dụ trên Router-C1:**

```
interface eth1
  ip address 100.68.1.16/31
  ipv6 address 2001:db8:1:16::1/64
  ip ospf cost 10
!
interface eth2
  ip address 100.68.1.18/31
  ipv6 address 2001:db8:1:18::1/64
  ip ospf cost 10
!
interface eth3
  ip address 100.68.1.20/31
  ipv6 address 2001:db8:1:20::1/64
  ip ospf cost 10
!
```

### Bước 1.3: Cấu Hình OSPF Process

Tạo OSPF routing process trên mỗi router. Router-id phải khớp với loopback address.

**Trên Router-C1:**

```
router ospf
  router-id 100.68.1.2
  network 100.68.1.0/25 area 0
  network 100.68.1.2/32 area 0
  redistribute connected
  default-information originate route-map DEFAULT-ORIGv4
!
```

**Lặp lại cho các router khác với router-id tương ứng.**

### Bước 1.4: Kiểm Tra OSPF

```
show ip ospf neighbor              # Kiểm tra adjacencies
show ip ospf database              # Kiểm tra database synchronization
show ip route ospf                 # Kiểm tra learned routes
ping 100.68.1.2 (từ router khác)   # Kiểm tra connectivity
```

---

## Pha 2: Cấu Hình IS-IS cho Group 2 (AS20)

### Mục Tiêu

Cấu hình IS-IS làm IGP cho Group 2.

### Bước 2.1: Cấu Hình Loopback Interface (Tất cả router Group2)

**Trên Router-C2:**

```
interface lo
  ip address 100.68.2.2/32
  ipv6 address 2001:db8:2:2::1/128
  ip router isis AREA20
  ipv6 router isis AREA20
!
```

**Trên Router-B2:**

```
interface lo
  ip address 100.68.2.1/32
  ipv6 address 2001:db8:2:1::1/128
  ip router isis AREA20
  ipv6 router isis AREA20
!
```

**Trên Router-A2:**

```
interface lo
  ip address 100.68.2.4/32
  ipv6 address 2001:db8:2:4::1/128
  ip router isis AREA20
  ipv6 router isis AREA20
!
```

**Trên Router-P2:**

```
interface lo
  ip address 100.68.2.3/32
  ipv6 address 2001:db8:2:3::1/128
  ip router isis AREA20
  ipv6 router isis AREA20
!
```

### Bước 2.2: Bật IS-IS trên các Interface Kết Nối

**Ví dụ trên Router-C2:**

```
interface eth1
  ip address 100.68.2.16/31
  ipv6 address 2001:db8:2:16::1/64
  ip router isis AREA20
  ipv6 router isis AREA20
  isis metric 10
!
interface eth2
  ip address 100.68.2.18/31
  ipv6 address 2001:db8:2:18::1/64
  ip router isis AREA20
  ipv6 router isis AREA20
  isis metric 10
!
```

### Bước 2.3: Cấu Hình IS-IS Process

Tạo IS-IS routing process với định dạng NET (Network Entity Title).

**Trên Router-C2:**

```
router isis AREA20
  net 49.0001.0020.0002.0002.00
  !
  address-family ipv4 unicast
    redistribute connected
    default-information originate route-map DEFAULT-ORIGv4
  exit-address-family
  !
  address-family ipv6 unicast
    redistribute connected
    default-information originate route-map DEFAULT-ORIGv6
  exit-address-family
!
```

**Cấu hình các router khác với NET tương ứng:**

- Router-B2: `net 49.0001.0020.0002.0001.00`
- Router-A2: `net 49.0001.0020.0002.0004.00`
- Router-P2: `net 49.0001.0020.0002.0003.00`

### Bước 2.4: Kiểm Tra IS-IS

```
show isis neighbors            # Kiểm tra adjacencies
show isis database             # Kiểm tra database
show ip route isis             # Kiểm tra learned routes
ping 100.68.2.2 (từ router khác)  # Kiểm tra connectivity
```

---

## Pha 3: Cấu Hình iBGP Trong Mỗi Group

### Mục Tiêu

Thiết lập iBGP trong mỗi group sử dụng kiến trúc Route Reflector để giảm số lượng kết nối full-mesh.

### Bước 3.1: iBGP cho Group 1 (AS10)

Route Reflector (Router-C1) nghe tất cả prefix từ các router khác và phản xạ chúng lại.

**Trên Router-C1 (Route Reflector):**

```
router bgp 10
  bgp router-id 100.68.1.2
  bgp bestpath as-path multipath-relax
  
  ! iBGP neighbors (tất cả các router khác trong AS10)
  neighbor 100.68.1.1 remote-as 10
  neighbor 100.68.1.1 description iBGP to B1
  neighbor 100.68.1.1 update-source lo
  
  neighbor 100.68.1.3 remote-as 10
  neighbor 100.68.1.3 description iBGP to P1
  neighbor 100.68.1.3 update-source lo
  
  neighbor 100.68.1.4 remote-as 10
  neighbor 100.68.1.4 description iBGP to A1
  neighbor 100.68.1.4 update-source lo
  
  address-family ipv4 unicast
    network 100.68.1.0/24
    network 100.68.1.2/32
    
    neighbor 100.68.1.1 activate
    neighbor 100.68.1.1 route-reflector-client
    
    neighbor 100.68.1.3 activate
    neighbor 100.68.1.3 route-reflector-client
    
    neighbor 100.68.1.4 activate
    neighbor 100.68.1.4 route-reflector-client
  exit-address-family
!
```

**Trên Router-B1, Router-P1, Router-A1 (Clients):**

```
router bgp 10
  bgp router-id 100.68.1.1  (dùng loopback IP tương ứng)
  bgp bestpath as-path multipath-relax
  
  ! iBGP connection chỉ tới Route Reflector
  neighbor 100.68.1.2 remote-as 10
  neighbor 100.68.1.2 description iBGP to C1 (Route Reflector)
  neighbor 100.68.1.2 update-source lo
  
  address-family ipv4 unicast
    network 100.68.1.1/32  (dùng loopback IP tương ứng)
    neighbor 100.68.1.2 activate
  exit-address-family
!
```

### Bước 3.2: iBGP cho Group 2 (AS20)

Làm theo cùng mẫu như Group 1, nhưng dùng địa chỉ Group 2 và AS20:

**Trên Router-C2 (Route Reflector):**

- Router-ID: 100.68.2.2
- Neighbors: 100.68.2.1 (B2), 100.68.2.3 (P2), 100.68.2.4 (A2)

**Trên Router-B2, Router-P2, Router-A2 (Clients):**

- Chỉ peer với Route Reflector (100.68.2.2)

### Bước 3.3: Kiểm Tra iBGP

```
show ip bgp summary            # Kiểm tra BGP session status
show ip bgp neighbors          # Kiểm tra neighbor details
show ip bgp                    # Xem BGP routing table
```

**Kết quả kỳ vọng:** Tất cả iBGP neighbors phải có trạng thái "Established".

---

## Pha 4: Cấu Hình eBGP với Transit Provider

### Mục Tiêu

Thiết lập eBGP với nhà cung cấp trung chuyển để kết nối hai group và nhận route Internet.

### Bước 4.1: Cấu Hình Prefix-list Lọc Route

Prefix lists xác định những route nào được phép vào/ra khỏi eBGP session.

**Trên Router-B1 (Group 1 Border Router):**

```
ip prefix-list GROUP1-AGGREGATE permit 100.68.1.0/24
ip prefix-list DEFAULT-ROUTEv4 permit 0.0.0.0/0
ip prefix-list FULL-ROUTESv4 permit 0.0.0.0/0 le 32

ipv6 prefix-list DEFAULT-ROUTEv6 permit ::/0
ipv6 prefix-list FULL-ROUTESv6 permit ::/0 le 128
!
```

**Trên Router-B2 (Group 2 Border Router):**

```
ip prefix-list GROUP2-AGGREGATE permit 100.68.2.0/24
ip prefix-list DEFAULT-ROUTEv4 permit 0.0.0.0/0
ip prefix-list FULL-ROUTESv4 permit 0.0.0.0/0 le 32

ipv6 prefix-list DEFAULT-ROUTEv6 permit ::/0
ipv6 prefix-list FULL-ROUTESv6 permit ::/0 le 128
!
```

### Bước 4.2: Cấu Hình Route-map Outbound

Route-maps kiểm soát prefix nào được gửi tới Transit Provider. Chỉ quảng bá aggregate riêng.

**Trên Router-B1:**

```
route-map Transit-out permit 5
  description Send only GROUP1 aggregate to Transit Provider
  match ip address prefix-list GROUP1-AGGREGATE
!
route-map Transit-out permit 10
  description Allow customer prefixes
!
```

**Trên Router-B2:**

```
route-map Transit-out permit 5
  description Send only GROUP2 aggregate to Transit Provider
  match ip address prefix-list GROUP2-AGGREGATE
!
route-map Transit-out permit 10
  description Allow customer prefixes
!
```

### Bước 4.3: Cấu Hình Route-map Inbound

Inbound route-maps kiểm soát route nào được chấp nhận từ Transit Provider. Default route được tag "no-advertise" để ngăn lan qua iBGP.

**Trên Router-B1:**

```
route-map Transitv4-in permit 5
  description Do not propagate the default route by iBGP
  match ip address prefix-list DEFAULT-ROUTEv4
  set community no-advertise
!
route-map Transitv4-in permit 10
  description Allow full routes from transit
  match ip address prefix-list FULL-ROUTESv4
!

route-map Transitv6-in permit 5
  description Do not propagate the default route by iBGP
  match ipv6 address prefix-list DEFAULT-ROUTEv6
  set community no-advertise
!
route-map Transitv6-in permit 10
  description Allow full routes from transit
  match ipv6 address prefix-list FULL-ROUTESv6
!
```

**Lặp lại trên Router-B2** (cho Transitv4-in và Transitv6-in route-maps)

### Bước 4.4: Cấu Hình Default Route Có Điều Kiện

**Trên Router-B1 (OSPF):**
Trước tiên, tạo prefix-list và route-map cho default route:

```
route-map DEFAULT-ORIGv4 permit 10
  description Allow default route origination if exists in RIB
  match ip address prefix-list DEFAULT-ROUTEv4
!
```

Sau đó cập nhật OSPF process:

```
router ospf
  router-id 100.68.1.1
  network 100.68.1.0/25 area 0
  network 100.68.1.1/32 area 0
  redistribute connected
  default-information originate route-map DEFAULT-ORIGv4
!
```

**Trên Router-B2 (IS-IS):**

```
ip prefix-list DEFAULT-ROUTEv4 permit 0.0.0.0/0
ipv6 prefix-list DEFAULT-ROUTEv6 permit ::/0

route-map DEFAULT-ORIGv4 permit 10
  description Allow default route origination if exists in RIB (IS-IS)
  match ip address prefix-list DEFAULT-ROUTEv4
!
route-map DEFAULT-ORIGv6 permit 10
  description Allow default route origination if exists in RIB (IS-IS)
  match ipv6 address prefix-list DEFAULT-ROUTEv6
!
```

Cập nhật IS-IS process:

```
router isis AREA20
  net 49.0001.0020.0002.0001.00
  !
  address-family ipv4 unicast
    redistribute connected
    default-information originate route-map DEFAULT-ORIGv4
  exit-address-family
  !
  address-family ipv6 unicast
    redistribute connected
    default-information originate route-map DEFAULT-ORIGv6
  exit-address-family
!
```

### Bước 4.5: Cấu Hình eBGP Neighbors và Route-map

**Trên Router-B1:**

```
router bgp 10
  bgp router-id 100.68.1.1
  bgp bestpath as-path multipath-relax
  
  neighbor 100.68.1.2 remote-as 10
  neighbor 100.68.1.2 description iBGP to C1
  neighbor 100.68.1.2 update-source lo
  
  ! eBGP neighbor tới Transit Provider
  neighbor 100.121.1.0 remote-as 121
  neighbor 100.121.1.0 description eBGP to TR1
  neighbor 100.121.1.0 route-map Transit-out out
  neighbor 100.121.1.0 route-map Transitv4-in in
  
  address-family ipv4 unicast
    network 100.68.1.0/24
    network 100.68.1.1/32
    
    neighbor 100.68.1.2 activate
    neighbor 100.68.1.2 route-reflector-client
    
    neighbor 100.121.1.0 activate
  exit-address-family
!
```

**Trên Router-B2:**

```
router bgp 20
  bgp router-id 100.68.2.1
  bgp bestpath as-path multipath-relax
  
  neighbor 100.68.2.2 remote-as 20
  neighbor 100.68.2.2 description iBGP to C2
  neighbor 100.68.2.2 update-source lo
  
  ! eBGP neighbor tới Transit Provider
  neighbor 100.121.2.2 remote-as 121
  neighbor 100.121.2.2 description eBGP to TR1
  neighbor 100.121.2.2 route-map Transit-out out
  neighbor 100.121.2.2 route-map Transitv4-in in
  
  address-family ipv4 unicast
    network 100.68.2.0/24
    network 100.68.2.1/32
    
    neighbor 100.68.2.2 activate
    neighbor 100.68.2.2 route-reflector-client
    
    neighbor 100.121.2.2 activate
  exit-address-family
!
```

### Bước 4.6: Cấu Hình Transit Router (TR1)

**Trên Router-TR1 (AS121):**

```
! Prefix lists
ip prefix-list GROUP1-AGGREGATE permit 100.68.1.0/24
ip prefix-list GROUP2-AGGREGATE permit 100.68.2.0/24
ip prefix-list FULL-ROUTESv4 permit 0.0.0.0/0 le 32

! Inbound route-maps
route-map FromGROUP1v4-in permit 5
  match ip address prefix-list GROUP1-AGGREGATE
!
route-map FromGROUP1v4-in permit 10
  match ip address prefix-list FULL-ROUTESv4
!

route-map FromGROUP2v4-in permit 5
  match ip address prefix-list GROUP2-AGGREGATE
!
route-map FromGROUP2v4-in permit 10
  match ip address prefix-list FULL-ROUTESv4
!

! Outbound route-map
route-map ToGROUPs-out permit 5
  description Send routes to groups
!

! BGP Configuration
router bgp 121
  bgp router-id 100.121.1.0
  bgp bestpath as-path multipath-relax
  
  neighbor 100.121.1.1 remote-as 10
  neighbor 100.121.1.1 description eBGP to B1 (AS10)
  neighbor 100.121.1.1 route-map FromGROUP1v4-in in
  neighbor 100.121.1.1 route-map ToGROUPs-out out
  neighbor 100.121.1.1 default-originate
  
  neighbor 100.121.2.2 remote-as 20
  neighbor 100.121.2.2 description eBGP to B2 (AS20)
  neighbor 100.121.2.2 route-map FromGROUP2v4-in in
  neighbor 100.121.2.2 route-map ToGROUPs-out out
  neighbor 100.121.2.2 default-originate
  
  address-family ipv4 unicast
    network 100.121.0.0/16
    network 100.121.1.0/32
    
    neighbor 100.121.1.1 activate
    neighbor 100.121.2.2 activate
  exit-address-family
!

! Static default route (mô phỏng Internet connectivity)
ip route 0.0.0.0/0 Null0
!
```

---

## Pha 5: Kiểm Tra & Thử Nghiệm

### Bước 5.1: Kiểm Tra IGP Routing

<details>
<summary>Nhấn để xem các câu lệnh kiểm tra</summary>
<br>

**Kiểm tra OSPF (Group 1):**

```
show ip ospf neighbor
show ip route ospf
show ip ospf database
```

**Kiểm tra IS-IS (Group 2):**

```
show isis neighbor
show ip route isis
show isis database
```

### Bước 5.2: Kiểm Tra iBGP

```
show ip bgp summary
show ip bgp neighbors
show ip bgp
```

Kỳ vọng: Tất cả iBGP sessions phải có trạng thái "Established"

### Bước 5.3: Kiểm Tra eBGP

```
show ip bgp neighbors | include "BGP state"
show ip bgp neighbors 100.121.1.0 advertised-routes
show ip bgp neighbors 100.121.1.0 received-routes
```

Kỳ vọng: eBGP sessions phải có trạng thái "Established"

### Bước 5.4: Kiểm Tra Truyền Route

```
show ip bgp 0.0.0.0/0           # Kiểm tra default route
show ip bgp 100.68.2.0          # Kiểm tra Group2 aggregate
show ip bgp 100.68.1.0          # Kiểm tra Group1 aggregate
```

### Bước 5.5: Kiểm Tra Kết Nối

```
ping 100.68.1.2 (loopback từ group khác)
ping 100.68.2.1 (loopback từ group khác)
traceroute 100.68.1.2
traceroute 100.68.2.1
```

---

## Hướng Dẫn Xử Lý Sự Cố

### Vấn đề IGP

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|-------------|-----------|
| Không thấy neighbor | Chưa bật IGP trên interface | Bật IGP trên interface kết nối |
| Không học được route | Thiếu network statement | Thêm network statement vào IGP |
| Loopback không reach được | Loopback chưa vào IGP | Thêm loopback vào IGP với /32 |

### Vấn đề iBGP

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|-------------|-----------|
| iBGP "Active" | Không reach loopback | Kiểm tra IGP, ping loopback |
| iBGP "Connect" | Port 179 bị chặn | Kiểm tra firewall |
| Không học route | Chưa cấu hình route-reflector | Kiểm tra RR configuration |

### Vấn đề eBGP

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|-------------|-----------|
| eBGP "Active" | Sai IP trên link | Kiểm tra neighbor IP |
| eBGP "Connect" | Port 179 bị chặn | Kiểm tra firewall |
| Không quảng bá route | Route-map lọc | Kiểm tra prefix-list |
| Không nhận default route | Default tag no-advertise | Kiểm tra inbound route-map |

---

## Những Khái Niệm Quan Trọng Cần Ghi Nhớ

1. **IGP Selection**: Group 1 dùng OSPF, Group 2 dùng IS-IS
2. **Route Reflector**: Giảm phức tạp iBGP mesh
3. **Prefix Filtering**: Kiểm soát route quảng bá/nhận
4. **Default Route Handling**: Tag no-advertise để không lan qua iBGP
5. **Conditional Origination**: Chỉ originate default route nếu có trong RIB

---

## Tham Khảo File Cấu Hình

Các file cấu hình sinh ra nằm ở:

- `group1-router-B1/group1-router-B1.conf`
- `group1-router-C1/group1-router-C1.conf`
- `group1-router-A1/group1-router-A1.conf`
- `group1-router-P1/group1-router-P1.conf`
- `group2-router-B2/group2-router-B2.conf`
- `group2-router-C2/group2-router-C2.conf`
- `group2-router-A2/group2-router-A2.conf`
- `group2-router-P2/group2-router-P2.conf`
- `transit-router-TR1/transit-router-TR1.conf`

Dùng file topology `pcio-result.clab.yml` để triển khai lab với các cấu hình này.

---

## Phụ Lục: Tóm Tắt Của Tất Cả các Đường Kết Nối (Link Connections)

| Link | Router 1 | Interface | IP Address | Router 2 | Interface | IP Address |
|------|----------|-----------|------------|----------|-----------|------------|
| 1 | C1 | eth1 | 100.68.1.16/31 | B1 | eth1 | 100.68.1.17/31 |
| 2 | C1 | eth2 | 100.68.1.18/31 | A1 | eth1 | 100.68.1.19/31 |
| 3 | C1 | eth3 | 100.68.1.20/31 | P1 | eth1 | 100.68.1.21/31 |
| 4 | C2 | eth1 | 100.68.2.16/31 | B2 | eth1 | 100.68.2.17/31 |
| 5 | C2 | eth2 | 100.68.2.18/31 | A2 | eth1 | 100.68.2.19/31 |
| 6 | C2 | eth3 | 100.68.2.20/31 | P2 | eth1 | 100.68.2.21/31 |
| 7 | B1 | eth2 | 100.121.1.1/31 | TR1 | eth1 | 100.121.1.0/31 |
| 8 | B2 | eth2 | 100.121.2.2/31 | TR1 | eth2 | 100.121.2.2/31 |

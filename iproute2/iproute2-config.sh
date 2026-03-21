# Linux 1 configuration
ip addr add 192.168.12.1/24 dev eth1
ip addr add 192.168.13.1/24 dev eth2
ip addr add 192.168.11.1/24 dev eth3
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

ip route add 192.168.0.0/16 nexthop via 192.168.12.2 weight 1 nexthop via 192.168.13.3 weight 1

# Linux 2 configuration
ip addr add 192.168.12.2/24 dev eth1
ip addr add 192.168.24.2/24 dev eth2
ip link set eth1 up
ip link set eth2 up
ip route add 192.168.11.0/24 via 192.168.12.1
ip route add 192.168.41.0/24 via 192.168.24.4

# Linux 3 configuration
ip addr add 192.168.13.3/24 dev eth1
ip addr add 192.168.34.3/24 dev eth2
ip link set eth1 up
ip link set eth2 up
ip route add 192.168.11.0/24 via 192.168.13.1
ip route add 192.168.41.0/24 via 192.168.34.4

# Linux 4 configuration
ip addr add 192.168.24.4/24 dev eth1
ip addr add 192.168.34.4/24 dev eth2
ip addr add 192.168.41.1/24 dev eth3
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

ip route add 192.168.0.0/16 nexthop via 192.168.24.2 weight 1 nexthop via 192.168.34.3 weight 1

# Client 1 configuration
ip addr add 192.168.11.2/24 dev eth1
ip link set eth1 up
ip route add 192.168.0.0/16 via 192.168.11.1

# Server 1 configuration
ip addr add 192.168.41.2/24 dev eth1
ip link set eth1 up
ip route add 192.168.0.0/16 via 192.168.41.1
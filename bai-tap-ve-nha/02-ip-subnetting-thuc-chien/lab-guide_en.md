**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 02: Practical IP Subnetting

**Arc 1 — Advanced Networking Fundamentals**

## Objectives
- Subnet a production address block using VLSM to meet specific host capacity requirements per department.
- Assign calculated IP addresses to physical interfaces on Containerlab nodes and configure default gateways for host containers.
- Verify routing between 3 departmental subnets through a central gateway router without wasting IP space.

## Prerequisites
Completion of [01-cai-dat-containerlab](../01-cai-dat-containerlab/lab-guide_en.md): Containerlab operational, familiarity with executing commands inside containers using `docker exec`.

## Topology Diagram
1 central gateway router `gw` connecting 3 LAN segments — each LAN has 1 host container representing a department. See [`topology/subnet-lab.clab.yml`](./topology/subnet-lab.clab.yml).

```
host-a (Sales, requires 50 hosts)       --- eth1 ---\
host-b (Engineering, requires 20 hosts) --- eth2 --- gw (router, ip_forward=1)
host-c (Operations, requires 10 hosts)  --- eth3 ---/
```

Allocated Network Block: **172.20.4.0/22**.

## Tasks & Instructions

1. Using VLSM, subnet `172.20.4.0/22` into 3 subnets, each providing sufficient host capacity **without wasting excessive IP address space** (select the smallest prefix length meeting requirements + 2 reserve addresses):
   - Sales (host-a): 50 hosts
   - Engineering (host-b): 20 hosts
   - Operations (host-c): 10 hosts
2. Deploy the topology, then assign IP addresses to each interface using `docker exec ... ip addr add <ip>/<prefix> dev eth1` based on your calculation table (`gw` has 3 LAN interfaces, each host has 1 interface).
3. Verify `ip_forward` is active on `gw` (pre-configured in topology via `exec`, verify with `sysctl net.ipv4.ip_forward`).
4. Set default routes on each host pointing to `gw`'s interface IP on the same subnet. **Note:** Containers have a default route via `eth0` (Containerlab management network), so `ip route add default ...` will error with `File exists` — use `ip route replace default via <ip-gw> dev eth1` instead of `add`.
5. Verification: from `host-a`, ping `host-b` and `host-c` through `gw`.
6. Document for submission: Subnet allocation table (Network ID, Subnet Mask, Broadcast IP, Usable IP Range per department) + output of `ip addr` on `gw` + ping verification output.

## Technical Hints
- VLSM best practice: Sort department requirements from largest to smallest before calculating subnets.
- `topology/subnet-lab.clab.yml` intentionally **omits pre-assigned IPs** — calculating and applying them is part of your task.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [03-static-route-multi-hop](../03-static-route-multi-hop/lab-guide_en.md): Multi-Hop Static Routing.

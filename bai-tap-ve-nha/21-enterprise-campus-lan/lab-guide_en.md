**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 21: HQ Campus LAN Deployment (Access–Distribution Architecture)

**Arc 7 — Enterprise Network Deployment Project**

## Objectives
- Design a 2-tier campus LAN (**access–distribution**) — standard enterprise office architecture.
- Configure VLANs spanning **multiple switches** (access ports and trunk ports on Linux VLAN-aware bridges).
- Centralize inter-VLAN routing at the FRR distribution gateway (802.1Q sub-interfaces).
- Translate business requirements into technical configurations without step-by-step pre-written commands.

## Prerequisites
- Completion of [04-linux-bridge-vlan](../04-linux-bridge-vlan/lab-guide_en.md) — `bridge vlan` commands on single switches.
- Completion of [02-ip-subnetting-thuc-chien](../02-ip-subnetting-thuc-chien/lab-guide_en.md) — manual IP assignments.

## Enterprise Business Case
You are a newly hired network engineer at **NTC Enterprise** (HQ office). The CTO initiated a 4-week project to rebuild the enterprise network infrastructure — delivering one layer per week. **Week 1: HQ Campus LAN.**

Business Requirements from the CTO:
1. The **Sales** department (~40 users, Floors 1 & 2) and **IT** department (~15 users, Floor 1) must be **isolated into separate broadcast domains** — broadcast/ARP traffic from one department must not bleed into the other.
2. Sales employees seated across **both floors** (connected to two distinct access switches) must share a single Layer 2 broadcast domain.
3. Both departments must communicate, but **all inter-departmental traffic must route through the central gateway** (enabling security inspection/firewalling in upcoming project weeks).
4. Approved IP addressing standard: Sales `172.16.10.0/24` (VLAN 10), IT `172.16.20.0/24` (VLAN 20), gateway for each subnet is always `.1`.

## Topology Diagram
```
        FLOOR 1                             FLOOR 2
  pc-sales-1        pc-it-1              pc-sales-2
  (VLAN 10)         (VLAN 20)            (VLAN 10)
      | eth1            | eth1               | eth1
      |  access,        |  access,            |  access,
      |  untagged VID10 |  untagged VID20     |  untagged VID10
      |                 |                     |
  ====+=================+====             ====+====
  eth1              eth2                   eth1
  +---------------------------+          +-------------+
  |          sw-acc1          |          |   sw-acc2   |   Access Switches
  +---------------------------+          +-------------+
              | eth3                        | eth2
              |  trunk, tagged VID 10+20     |  trunk, tagged VID 10+20
              |                              |
              +------------+   +-------------+
                           |   |
                        eth1| |eth2
                        +---------+
                        | sw-dist |                          Distribution Switch
                        +---------+
                             | eth3
                             |  trunk, tagged VID 10+20
                             |
                         eth1|
                       +-----------+
                       |  dist-1   |   FRR Gateway (Router-on-a-Stick)
                       +-----------+
                       eth1.10 → 172.16.10.1/24 (VLAN 10 — Sales)
                       eth1.20 → 172.16.20.1/24 (VLAN 20 — IT)
```

See [`topology/campus-lan-lab.clab.yml`](./topology/campus-lan-lab.clab.yml).

Pre-configured state:
- 3 switches (`sw-acc1`, `sw-acc2`, `sw-dist`): VLAN-aware `br0` bridges created, ports enslaved — **VLAN memberships unassigned**.
- `dist-1` (FRR): `eth1.10`/`eth1.20` sub-interfaces created and IP gateways configured in `frr.conf`.
- 3 PCs: unconfigured host IPs.

## Tasks & Instructions

1. Prepare a **VLAN Allocation Matrix** prior to configuration: map access ports (VLAN ID, PVID/untagged) and trunk ports (tagged VLAN IDs) for each switch.
2. Configure VLAN memberships across **all 3 switches** using `bridge vlan add/del`:
   - Host-facing ports: Access ports assigned to department VLANs.
   - Switch-to-switch and switch-to-gateway links: Trunk ports tagging VLAN 10 + 20.
3. Assign static IPs to the 3 PCs following corporate standards: `pc-sales-1` = `172.16.10.11`, `pc-sales-2` = `172.16.10.12`, `pc-it-1` = `172.16.20.11`, setting default gateway `.1`. Use `ip route replace default via <ip> dev eth1`.
4. Verify business requirements:
   - `pc-sales-1` pings `pc-sales-2` — **succeeds** (same VLAN across 3 switches — Requirement 2).
   - `pc-sales-1` pings `pc-it-1` — **succeeds**, with `traceroute` demonstrating a **2-hop path** via gateway `172.16.10.1` (Requirement 3).
   - `bridge vlan show` outputs across all 3 switches match your planning matrix.
5. Capture 802.1Q tags (Requirement 1): execute `tcpdump -e -i eth1 -c 20` on `dist-1` during inter-departmental pings — identify frames tagged with VLAN 10 vs VLAN 20.
6. Record outputs for submission.

## Technical Hints
- VLAN-aware Linux bridges assign default VID 1 untagged/PVID upon enslavement — remove default VID 1 prior to adding target VIDs.
- Access ports require both `pvid` and `untagged`; trunk ports require tagged VIDs.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ Lab 22 — Enterprise Project Week 2: Gateway Redundancy (VRRP) + OSPF Core Routing + Server Farm. (Coming soon)

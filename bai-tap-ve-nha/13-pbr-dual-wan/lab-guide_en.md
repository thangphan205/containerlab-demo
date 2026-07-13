**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 13: Policy-Based Routing (PBR) — Dual-WAN

**Arc 2 — Deep-Dive Routing Protocols**

## Objectives
- Implement `ip rule` + multiple routing tables on Linux to forward traffic based on Source IP (Policy-Based Routing).
- Model a common enterprise scenario: Sales department routed out via ISP-A, Engineering department routed out via ISP-B.
- Verify path isolation using `traceroute` — confirming each department egresses via its designated provider.

## Prerequisites
Completion of [03-static-route-multi-hop](../03-static-route-multi-hop/lab-guide_en.md) — Linux static routing fundamentals.

## Topology Diagram
```mermaid
graph TD
    subgraph WAN_Segment ["WAN / Internet Destination"]
        server["server<br>10.0.200.10/24"]
    end

    subgraph ISP_Transit ["ISP Providers"]
        isp-a["isp-a<br>10.0.100.2/30"] -- "eth2 <-> eth1" --- server
        isp-b["isp-b<br>10.0.101.2/30"] -- "eth2 <-> eth2" --- server
    end

    subgraph Router_PBR ["PBR Gateway"]
        r1["r1<br>Policy-Based Routing<br>eth1: 10.0.1.1/24 (sales)<br>eth2: 10.0.2.1/24 (tech)<br>eth3: 10.0.100.1/30 (ISP-A)<br>eth4: 10.0.101.1/30 (ISP-B)"]
    end

    subgraph Private_LAN ["Private LAN Subnets"]
        host-sales["host-sales<br>10.0.1.10/24"]
        host-tech["host-tech<br>10.0.2.10/24"]
    end

    isp-a -- "eth1 <-> eth3" --- r1
    isp-b -- "eth1 <-> eth4" --- r1
    r1 -- "eth1" --- host-sales
    r1 -- "eth2" --- host-tech
```
- `r1`: 4 interfaces — 2 LANs (sales, tech), 2 WANs (ISP-A, ISP-B). IPs pre-assigned; **PBR rules not yet configured**.
- `isp-a`, `isp-b`: Routers simulating separate ISPs connecting to `server`.
- `server`: Destination target server connected to both ISPs.

See [`topology/pbr-lab.clab.yml`](./topology/pbr-lab.clab.yml).

## Tasks & Instructions

1. Deploy topology. Interface IPs are pre-assigned across all nodes.
2. **Initial Baseline Check:** `host-sales` and `host-tech` can both ping `server` — but both egress through the default route via ISP-A (verify with `traceroute`).
3. **Configure PBR** on `r1`:
   - Create dedicated routing tables for ISP-A (table ID 100) and ISP-B (table ID 200):
     ```bash
     ip route add default via 10.0.100.2 table 100
     ip route add default via 10.0.101.2 table 200
     ```
   - Add policy rules steering traffic by source subnet:
     ```bash
     ip rule add from 10.0.1.0/24 table 100   # sales → ISP-A
     ip rule add from 10.0.2.0/24 table 200   # tech → ISP-B
     ```
4. Verification:
   - `traceroute` from `host-sales` to `server` → must transit **ISP-A** (`10.0.100.2`).
   - `traceroute` from `host-tech` to `server` → must transit **ISP-B** (`10.0.101.2`).
   - On `r1`: `ip rule show` — verify rules; `ip route show table 100` and `table 200` — verify default gateways.
5. Record outputs for submission.

## Technical Hints
- `ip rule` policies evaluate **prior** to standard destination routing tables based on rule priorities.
- Adding custom tables (100/200) does not clear default routes in the main table — allowing parallel routing structures.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [14-ansible-co-ban](../14-ansible-co-ban/lab-guide_en.md): Ansible Fundamentals.

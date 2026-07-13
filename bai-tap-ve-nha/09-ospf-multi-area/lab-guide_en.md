**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 09: OSPF Multi-Area Architecture

**Arc 2 — Deep-Dive Routing Protocols**

## Objectives
- Design a multi-area OSPF network: Area 1 — Area 0 (Backbone) — Area 2.
- Understand the role of Area Border Routers (ABRs) and the golden rule of OSPF: all non-backbone areas must connect directly or virtually to Area 0.
- Verify convergence via `show ip ospf neighbor` and `show ip route ospf`.

## Prerequisites
Completion of [03-static-route-multi-hop](../03-static-route-multi-hop/lab-guide_en.md) — multi-hop routing principles prior to dynamic routing.

## Topology Diagram
```
srv1 --- R1 ======= R2 ======= R3 ======= R4 --- srv2
       (Area 1)  (Area1|Area0)(Area0|Area2) (Area 2)
```
- `R1`: Internal router in Area 1.
- `R2`: ABR between Area 1 and Area 0.
- `R3`: ABR between Area 0 and Area 2.
- `R4`: Internal router in Area 2.

Node details and IP addressing are in [`topology/ospf-lab.clab.yml`](./topology/ospf-lab.clab.yml). Interface IPs are pre-assigned in `configs/<router>/frr.conf`, with OSPF sections left as `TODO`.

## Tasks & Instructions

1. On each router (`r1`–`r4`), complete the `router ospf` configuration inside `configs/<router>/frr.conf`:
   - Assign a unique `router-id` (Loopback IP or interface IP).
   - Declare network interfaces into their designated areas per topology design.
2. Redeploy lab after updating configs (`sudo clab destroy` and `deploy`, or modify live via `docker exec ... vtysh` and save using `write memory`).
3. Verify on **R2 and R3** (ABR routers): `show ip ospf neighbor` must display neighbors on both interfaces in state `Full`; `show ip route ospf` must show routes learned from remote areas.
4. Inspect the Link-State Database (LSDB): execute `show ip ospf database` on R2 — verify Type 1 (Router-LSAs) from both Area 1 and Area 0. Understand that LSDB inspection is vital for deep OSPF troubleshooting beyond routing tables.
5. From `srv1`, execute `ping` and `traceroute` to `srv2` — verify transit hops R1 → R2 → R3 → R4.
6. Record outputs: `show ip ospf neighbor` on R2 + R3, `show ip ospf database` on R2, `show ip route ospf` on R1 + R4, and `traceroute` output.

## Technical Hints
- If neighbors fail to form between adjacent routers in the same area, verify matching Area IDs on both ends (`show ip ospf interface`).
- R2 and R3 are ABRs — their interfaces belong to **two separate areas**.
- **Production Extension:** In large enterprise networks, edge areas are often configured as **stub areas** or **totally stubby areas** to reduce LSDB sizing on internal routers.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [10-bgp-ebgp-co-ban](../10-bgp-ebgp-co-ban/lab-guide_en.md): eBGP Fundamentals.

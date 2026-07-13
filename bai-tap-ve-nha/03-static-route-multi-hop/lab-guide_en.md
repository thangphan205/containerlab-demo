**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 03: Multi-Hop Static Routing

**Arc 1 — Advanced Networking Fundamentals**

## Objectives
- Configure multi-hop static routes across a chain of routers (without relying on default routes on intermediate transit routers).
- Understand why every intermediate transit router requires explicit static routes for **each specific destination network**, rather than forwarding traffic to a default gateway.
- Use `traceroute` to verify end-to-end packet forwarding paths across all intermediate hops.

## Prerequisites
Completion of [02-ip-subnetting-thuc-chien](../02-ip-subnetting-thuc-chien/lab-guide_en.md).

## Topology Diagram
A linear chain of 4 routers connecting two end LANs with host containers. See [`topology/static-route-lab.clab.yml`](./topology/static-route-lab.clab.yml). Point-to-point transit link IPs are **pre-assigned**, while LAN IPs and static routes must be configured manually.

```
host-1 (10.0.1.0/24) -- R1 -- R2 -- R3 -- R4 -- host-2 (10.0.2.0/24)
                       10.0.12.0/30  10.0.23.0/30  10.0.34.0/30  (pre-configured on inter-router links)
```

## Tasks & Instructions

1. Assign IP addresses to `host-1` (within `10.0.1.0/24`), `host-2` (within `10.0.2.0/24`), and corresponding LAN interfaces on `R1` and `R4`.
2. On **every router** (R1, R2, R3, R4), add static routes enabling bidirectional traffic between `host-1` and `host-2`.
   - **Do NOT use default routes (`0.0.0.0/0`) on R2 and R3** — these transit routers must contain explicit static routes to destination subnets (`10.0.1.0/24` and `10.0.2.0/24`). This reinforces the core lesson: intermediate routers require explicit route knowledge for every transit network.
   - `R1` and `R4` may use default routes pointing to neighboring routers if preferred.
3. Configure default routes on `host-1` and `host-2` pointing to local gateway interfaces on `R1` and `R4`.

> [!NOTE]
> All nodes contain a pre-existing default route via `eth0` (Containerlab management network). Use `ip route replace default via <ip> dev <iface>` instead of `add` to avoid `File exists` errors. Specific subnet routes use `ip route add <subnet> via <ip> dev <iface>` normally without conflicts.

4. Verification: execute `traceroute` from `host-1` to `host-2` — output must show 4 intermediate hops in exact sequence: R1 → R2 → R3 → R4.
5. Record your output: Static routing table on each router (`ip route show`) + `traceroute` verification output.

## Technical Hints
- If `ping` reaches the target host but `traceroute`/replies fail to return, check static routes for the **return path** on every router along the chain.

## Bonus Challenge — Why Dynamic Routing Matters
After completing the primary lab tasks, **shut down an intermediate transit interface** (e.g., `docker exec r2 ip link set eth2 down`). Observe:
- Connectivity between `host-1` and `host-2` will be **permanently lost** — static routing cannot detect link state changes dynamically (convergence time = infinity).
- Compare this with OSPF in subsequent labs: upon link failure, dynamic routing automatically recalculates active topology paths within seconds.

This scenario illustrates why production networks rely on dynamic routing protocols rather than static routing alone.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [09-ospf-multi-area](../09-ospf-multi-area/lab-guide_en.md): OSPF Multi-Area.

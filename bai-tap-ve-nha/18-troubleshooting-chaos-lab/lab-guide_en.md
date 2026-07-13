**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 18: Troubleshooting Chaos Lab — OSPF

**Arc 5 — Troubleshooting Chaos Lab**

## Objectives
- Develop structured network troubleshooting skills: isolate failure domains systematically without random guessing.
- Practice root-cause diagnosis without pre-disclosed fault hints — simulating real-world production outage tickets ("network is down").

## Prerequisites
Completion of [09-ospf-multi-area](../09-ospf-multi-area/lab-guide_en.md) — this lab reuses the multi-area OSPF topology structure.

## Outage Scenario

The lab environment below is **pre-configured completely** (no skeleton templates or `TODO` items). However, a ticket reports:

> "srv1 cannot ping srv2, connectivity appears broken somewhere in the path."

Topology mirrors Lab 09 (`srv1 -- R1 -- R2 -- R3 -- R4 -- srv2`, OSPF Area 1 — Area 0 — Area 2). See [`topology/chaos-lab.clab.yml`](./topology/chaos-lab.clab.yml).

## Tasks & Instructions

1. Deploy topology (`sudo clab deploy -t chaos-lab.clab.yml`).
2. Confirm the failure: `srv1` fails to ping `srv2`.
3. Investigate and diagnose the root cause. **No fault locations are provided** — use systematic troubleshooting techniques:
   - Check OSPF neighbor adjacency states across all routers (`show ip ospf neighbor`) — which router fails to reach state `Full`?
   - Compare interface configurations on suspect links — identify mismatched parameters (Area ID, subnets, interface status...).
   - Inspect routing tables (`show ip route ospf`) — which router is missing expected routes?
4. Resolve the issue live via `vtysh` on the affected router.
5. Verification: `srv1` successfully pings `srv2`, and all relevant router neighbors establish `Full` adjacencies.
6. Record your investigation process: Diagnostic steps taken, hypotheses eliminated, root cause identified, and resolution steps applied.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [19-troubleshooting-chaos-bgp](../19-troubleshooting-chaos-bgp/lab-guide_en.md): Troubleshooting Chaos Lab — BGP.

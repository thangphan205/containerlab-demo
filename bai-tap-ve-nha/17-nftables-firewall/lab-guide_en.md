**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 17: nftables Firewall — Inter-Subnet Filtering

**Arc 4 — Security & Observability**

## Objectives
- Author `nftables` rulesets on a transit gateway to filter routed traffic (utilizing the `forward` chain rather than `input`).
- Implement default-deny security posture: default `drop` policy, permitting explicitly allowed traffic (ICMP + designated TCP ports).
- Verify firewall behavior using active connection tests (`nc` / `ping`).

## Prerequisites
Completion of [02-ip-subnetting-thuc-chien](../02-ip-subnetting-thuc-chien/lab-guide_en.md) — intermediate gateway routing between subnets.

## Topology Diagram
```
host-a (10.20.1.0/24) --- gw (nftables, ip_forward=1) --- host-b (10.20.2.0/24)
```
`gw` has `nftables` pre-installed (`apk add nftables` in `exec`). See [`topology/nft-lab.clab.yml`](./topology/nft-lab.clab.yml).

## Tasks & Instructions

1. Deploy topology. Assign IP addresses to `host-a`, `host-b`, and `gw` interfaces. Set default routes on hosts (`ip route replace`).
2. On `host-b`, open two test TCP listeners:
   ```bash
   nc -l -p 8080 &
   nc -l -p 2323 &
   ```
3. Complete [`nftables/ruleset.nft`](./nftables/ruleset.nft) (currently missing rule permitting TCP port 8080), then load ruleset into `gw`:
   ```bash
   nft -f nftables/ruleset.nft
   ```
4. From `host-a`, verify filtering:
   - `ping -c 2 <host-b IP>` → must **succeed** (ICMP explicitly allowed).
   - `nc -zv -w 2 <host-b IP> 8080` → must **succeed** (TCP port 8080 explicitly allowed).
   - `nc -zv -w 2 <host-b IP> 2323` → must **fail/timeout** (unlisted port dropped by default policy).
5. On `gw`, inspect ruleset counters: `nft list ruleset` — verify rule match packet counters increment appropriately.
6. Record outputs: Completed `ruleset.nft` + verification command outputs (all 3 steps) + `nft list ruleset` output.

## Technical Hints
- Rules belong in the `forward` chain (transit traffic **through** the router), not the `input` chain (traffic destined **to** the router itself).
- Include `counter` keywords in rules to track matched packet/byte counts for easier debugging.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [18-troubleshooting-chaos-lab](../18-troubleshooting-chaos-lab/lab-guide_en.md): Troubleshooting Chaos Lab — OSPF.

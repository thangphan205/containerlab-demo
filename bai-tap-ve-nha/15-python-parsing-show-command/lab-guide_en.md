**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 15: Python Parsing — Automated Routing Table Auditing

**Arc 3 — Automation & NetDevOps**

## Objectives
- Use Python (`subprocess` + `json`) to extract structured data across multiple routers, eliminating manual CLI reading.
- Leverage `ip -j route show` — parsing routing tables natively formatted as JSON without complex regular expressions or TextFSM templates.
- Write an auditing script to automatically flag routers missing required target subnets.

## Prerequisites
Completion of [03-static-route-multi-hop](../03-static-route-multi-hop/lab-guide_en.md) — multi-hop router chain topology (reused in this lab with pre-configured static routes).

## Topology Diagram
Identical topology to Lab 03 (4 sequential routers with 2 edge LANs) — but **all IP addresses and static routes are pre-configured** via `exec` commands, providing end-to-end connectivity immediately upon deployment. See [`topology/audit-lab.clab.yml`](./topology/audit-lab.clab.yml).

```
host-1 (10.0.1.0/24) -- r1 -- r2 -- r3 -- r4 -- host-2 (10.0.2.0/24)
```

## Tasks & Instructions

1. Deploy topology and verify baseline end-to-end connectivity (`ping` from `host-1` to `host-2`).
2. Complete [`script/audit_routes.py`](./script/audit_routes.py) (currently contains empty `get_routes()` function):
   - Execute `docker exec <router> ip -j route show` via `subprocess` and parse returned JSON structures (each dictionary entry contains `dst`, `gateway`, `dev`, etc.).
   - For each router (`r1`–`r4`), verify routes exist for both LAN subnets (`10.0.1.0/24` and `10.0.2.0/24`) — print `OK` or `MISSING` per router/subnet combination.
3. Run script and verify all 4 routers report `OK` for both subnets.
4. **Fault Verification Test:** Manually delete a static route (`docker exec <router> ip route del ...`), re-run script — verify script accurately flags `MISSING` for the deleted subnet on that specific router.
5. Record outputs: Completed `audit_routes.py` + script output during normal operation + script output following manual route deletion.

## Technical Hints
- `subprocess.run([...], capture_output=True, text=True).stdout` returns raw JSON strings — use `json.loads()` to convert into Python lists of dictionaries.
- Routes with `dst` set to `"default"` indicate default routes — handle these appropriately when matching specific subnets.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [16-git-workflow-network-config](../16-git-workflow-network-config/lab-guide_en.md): Git Workflows for Network Configurations.

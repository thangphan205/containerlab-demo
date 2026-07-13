**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 14: Ansible Basics — Multi-Node Config Push

**Arc 3 — Automation & NetDevOps**

## Objectives
- Utilize Ansible to push configuration updates simultaneously across multiple routers.
- Understand Ansible inventory files (declaring target hosts and per-host variables) and playbooks (tasks executed per target host).
- Verify configuration execution directly within Ansible playbooks without manually SSHing into individual routers.

## Prerequisites
Completion of [10-bgp-ebgp-co-ban](../10-bgp-ebgp-co-ban/lab-guide_en.md) — familiarity with `vtysh -c` and `docker exec`.
Install Ansible on control node: `sudo apt install -y ansible-core` (or `pip install ansible-core`).

## Topology Diagram
3 independent FRR routers, **without interconnecting data links** — this lab focuses exclusively on network automation patterns. See [`topology/ansible-lab.clab.yml`](./topology/ansible-lab.clab.yml).

```
r1, r2, r3 — 3 standalone FRR containers connected to management network
```

Ansible executes commands via local container execution (`docker exec`) directly on the host server (`local` connection). See [`ansible/inventory.ini`](./ansible/inventory.ini) — pre-configured with 3 target hosts and per-host `loopback_ip` variables.

## Tasks & Instructions

1. Deploy topology (`sudo clab deploy -t ansible-lab.clab.yml`).
2. Complete [`ansible/playbook.yml`](./ansible/playbook.yml) (marked `TODO`):
   - Task 1: Use `ansible.builtin.command` (or `shell`) to execute `docker exec {{ inventory_hostname }} vtysh -c "configure terminal" -c "interface lo" -c "ip address {{ loopback_ip }}/32"` to assign unique loopback IPs defined in inventory.
   - Task 2: Verification — execute `docker exec {{ inventory_hostname }} vtysh -c "show ip route"`, register results to a variable, and display output using the `debug` module.
3. Execute playbook: `ansible-playbook -i ansible/inventory.ini ansible/playbook.yml` — confirm all 3 routers receive their assigned loopback IPs.
4. Execute playbook a second time — verify execution completes without errors (idempotency check).
5. Record outputs: Completed `playbook.yml` + successful `ansible-playbook` run output + verification (`show ip route`) outputs across all 3 routers.

## Technical Hints
- `{{ inventory_hostname }}` matches host names defined in inventory (`r1`, `r2`, `r3`) — matching Containerlab container names directly for `docker exec`.
- Ensure `ansible_connection=local` is specified in `inventory.ini` since container access uses local execution rather than SSH.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [15-python-parsing-show-command](../15-python-parsing-show-command/lab-guide_en.md): Python Parsing CLI Outputs.

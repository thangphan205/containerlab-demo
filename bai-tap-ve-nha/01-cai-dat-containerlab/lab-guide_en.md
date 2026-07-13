**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 01: Containerlab Installation & First Lab Deployment

**Arc 0 — Foundations & System Ops**

## Objectives
- Install Containerlab on the Linux server prepared in Lab 00.
- Successfully deploy a 2-node topology and verify network connectivity between containers.

## Prerequisites
Completion of [00-chuan-bi-server](../00-chuan-bi-server/lab-guide_en.md): Docker running without `sudo`, IPv4 forwarding enabled.

## Topology Diagram
2 Linux nodes (`wbitt/network-multitool`) directly connected via 1 point-to-point link, with static IP addresses assigned in subnet `192.168.100.0/24` — see [`topology/hello-clab.yml`](./topology/hello-clab.yml).

```
host1 (192.168.100.1/24) --- eth1<->eth1 --- host2 (192.168.100.2/24)
```

## Lab Tasks & Instructions

1. Install Containerlab using the official installation script:
   ```bash
   bash -c "$(curl -sL https://get.containerlab.dev)"
   ```
2. Verify installation: `containerlab version`.
3. Deploy the topology:
   ```bash
   cd topology
   sudo clab deploy -t hello-clab.yml
   ```
4. From `host1`, ping `host2` across the point-to-point link to verify reachability:
   ```bash
   docker exec -it clab-hello-clab-host1 ping -c 4 192.168.100.2
   ```
5. Run `sudo clab inspect -t hello-clab.yml` (inside the `topology/` directory) and record the output.
6. Destroy the lab: `sudo clab destroy -t hello-clab.yml`.

## Technical Hints
- If pings fail, check `exec` commands in `hello-clab.yml` to ensure correct IP assignments per interface and verify interface status is `up`.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [02-ip-subnetting-thuc-chien](../02-ip-subnetting-thuc-chien/lab-guide_en.md): Practical IP Subnetting.

**Language / Ngôn ngữ:** [English](README_en.md) | [Tiếng Việt](README.md)

# 📚 Hands-on Network Labs — Network Thực Chiến

A long-term series of practical network engineering labs designed for engineers with CCNA-level fundamentals — containerized labs built with **Containerlab**, closely reflecting real-world enterprise deployments rather than pure theory.

**No single solution is perfect.** The reference solutions published each week are provided as a benchmark — not the sole standard. The true value lies in the hands-on process: deploying the topology, troubleshooting issues, querying AI for deeper insights, and comparing against production practices. Real engineering expertise comes from overcoming obstacles during implementation, not from copying configs.

Each week a lab is released without pre-packaged answers — learners work through the tasks independently and discuss ideas in the community. Reference solutions and video explanations are published approximately 1 week later on [YouTube - Network Thực Chiến](https://www.youtube.com/@NetworkThucChien).

All content is **open source** (see [LICENSE](../LICENSE)) — feel free to use, modify, and contribute new labs. See [CONTRIBUTING_en.md](./CONTRIBUTING_en.md).

## How to Participate

1. Select any lab from GitHub and read its corresponding `lab-guide_en.md` (or `lab-guide.md`). Topics cover network deployment and essential Linux services.
2. Deploy the topology using Containerlab and work through the task checklist. If stuck, leverage AI tools (ChatGPT/Claude...) to understand *why* a technology behaves a certain way rather than just requesting copy-paste configurations.
3. Share progress and discuss in the Facebook community: https://www.facebook.com/profile.php?id=61591373979991.
4. Compare your approach with the reference solution once released, and consider contributing feedback or improvements on GitHub.

---

## Lab Catalog by Topic

> Labs are categorized into independent **Arcs (Topics)**. Feel free to choose any lab relevant to your learning goals or project requirements without following a strict linear order.

---

### Arc 0 — Getting Started

> Install Containerlab and deploy your first network topology. Prerequisites: A Linux server (Ubuntu 24.04, 4 vCPU / 8GB RAM recommended) with Docker installed.

| Lab ID | Lab Title | Status | Video |
|:---:|:---|:---|:---|
| [01](./01-cai-dat-containerlab/lab-guide_en.md) | Install Containerlab + Deploy First Topology | 🟢 Active | — |

---

### Arc 1 — Advanced Networking Fundamentals

> IP addressing, static routing, switching, gateway redundancy (HA), NAT, and DHCP — core enterprise networking foundations.

| Lab ID | Lab Title | Status | Video |
|:---:|:---|:---|:---|
| [02](./02-ip-subnetting-thuc-chien/lab-guide_en.md) | Practical IP Subnetting (Data Center Subnet Design) | 🟢 Active | — |
| [03](./03-static-route-multi-hop/lab-guide_en.md) | Multi-Hop Static Routing | 🟢 Active | — |
| [04](./04-linux-bridge-vlan/lab-guide_en.md) | VLAN Trunking on Linux Bridges | 🟢 Active | — |
| [05](./05-stp-rstp-chong-loop/lab-guide_en.md) | STP/RSTP — Layer 2 Loop Prevention (Triangle Topology) | 🟢 Active | — |
| [06](./06-vrrp-ecmp-gateway-ha/lab-guide_en.md) | VRRP + ECMP — Gateway High Availability (< 3s Failover) | 🟢 Active | [Watch video](https://youtu.be/7SjFpp2h_aM) |
| [07](./07-dhcp-server-relay/lab-guide_en.md) | Linux DHCP Server (dnsmasq Multi-Subnet) | 🟢 Active | [Watch video](https://youtu.be/uJw78eOtZ58) |
| [08](./08-nat-masquerade-linux/lab-guide_en.md) | Linux NAT/Masquerade (nftables Source NAT for LAN) | 🟢 Active | — |

---

### Arc 2 — Deep-Dive Routing Protocols

> OSPF, BGP, and policy-based routing — dynamic routing protocols used in enterprise & ISP networks.

| Lab ID | Lab Title | Status | Video |
|:---:|:---|:---|:---|
| [09](./09-ospf-multi-area/lab-guide_en.md) | OSPF Multi-Area (Area Segmentation, ABR, Route Summarization) | 🟢 Active | — |
| [10](./10-bgp-ebgp-co-ban/lab-guide_en.md) | eBGP Fundamentals (Inter-AS Peering) | 🟢 Active | — |
| [11](./11-bgp-route-map-policy/lab-guide_en.md) | BGP Route-Maps & Filtering Policies | 🟢 Active | — |
| [12](./12-bgp-local-pref-prefix-list/lab-guide_en.md) | BGP Local Preference + Prefix-Lists (Inbound Traffic Engineering) | 🟢 Active | — |
| [13](./13-pbr-dual-wan/lab-guide_en.md) | Policy-Based Routing — Dual-WAN Traffic Steering | 🟢 Active | — |

---

### Arc 3 — Automation / NetDevOps

> Ansible, Python, and Git — automating network operations and configuration management.

| Lab ID | Lab Title | Status | Video |
|:---:|:---|:---|:---|
| [14](./14-ansible-co-ban/lab-guide_en.md) | Ansible Basics (Pushing Configs to Multiple Routers) | 🟢 Active | — |
| [15](./15-python-parsing-show-command/lab-guide_en.md) | Python Parsing (Auditing Routing Tables from Show Outputs) | 🟢 Active | — |
| [16](./16-git-workflow-network-config/lab-guide_en.md) | Git Workflows for Network Configurations (Branch/Merge/Deploy) | 🟢 Active | — |

---

### Arc 4 — Security & Observability

> Firewall rules and traffic filtering in containerized environments.

| Lab ID | Lab Title | Status | Video |
|:---:|:---|:---|:---|
| [17](./17-nftables-firewall/lab-guide_en.md) | nftables Firewall Fundamentals (Inter-Subnet Filtering) | 🟢 Active | — |

---

### Arc 5 — Troubleshooting Chaos Labs

> Pre-faulted environments — diagnose and resolve network failures systematically.

| Lab ID | Lab Title | Status | Video |
|:---:|:---|:---|:---|
| [18](./18-troubleshooting-chaos-lab/lab-guide_en.md) | Chaos Lab — OSPF Troubleshooting (Area Mismatch) | 🟢 Active | — |
| [19](./19-troubleshooting-chaos-bgp/lab-guide_en.md) | Chaos Lab — BGP Troubleshooting (Prefix-List Errors) | 🟢 Active | — |

---

### Arc 6 — Advanced Security & VPN

> Secure site-to-site connectivity over simulated public infrastructure.

| Lab ID | Lab Title | Status | Video |
|:---:|:---|:---|:---|
| [20](./20-wireguard-vpn-site-to-site/lab-guide_en.md) | WireGuard Site-to-Site VPN (Tunneling across Simulated WAN) | 🟢 Active | — |

---

### Arc 7 — Enterprise Network Deployment (Multi-Week Project)

> 4-week project: Step into the shoes of a lead network engineer deploying an end-to-end network for **NTC Enterprise** — Campus LAN → Routing Core & Gateway HA → Branch WAN → Internet Edge. Unlike previous standalone labs, this Arc builds a unified enterprise topology layer by layer from business requirements. Each lab is self-contained with pre-configured baseline dependencies.

| Lab ID | Lab Title | Status | Video |
|:---:|:---|:---|:---|
| [21](./21-enterprise-campus-lan/lab-guide_en.md) | HQ Campus LAN (Access–Distribution VLAN Architecture) | 🟢 Active | — |
| [22](./22-enterprise-routing-core-ha/lab-guide_en.md) | Routing Core OSPF + Gateway HA (VRRP) | 🟢 Active | — |
| [23](./23-enterprise-wan-branch/lab-guide_en.md) | Branch Office WAN Interconnect (eBGP) | 🟢 Active | — |
| [24](./24-enterprise-internet-edge/lab-guide_en.md) | Enterprise Edge: NAT & nftables Stateful Firewall | 🟢 Active | — |

---

## Series Arc Overview

- **Arc 0 — Getting Started:** Containerlab setup and first topology deployment.
- **Arc 1 — Advanced Fundamentals:** Subnetting, static routes, VLANs, L2 RSTP loop prevention, VRRP/ECMP HA gateways, dnsmasq DHCP, nftables NAT/Masquerade.
- **Arc 2 — Deep-Dive Routing Protocols:** OSPF multi-area, BGP (eBGP, route-maps, Local Preference, prefix-lists), Policy-Based Routing (dual-WAN).
- **Arc 3 — Automation / NetDevOps:** Ansible multi-node config push, Python CLI output parsing, Git branching/merging pipelines.
- **Arc 4 — Security & Observability:** nftables inter-subnet security policies.
- **Arc 5 — Troubleshooting Chaos Labs:** Troubleshooting pre-faulted OSPF and BGP environments.
- **Arc 6 — Advanced Security & VPN:** WireGuard site-to-site VPN tunnels.
- **Arc 7 — Enterprise Network Deployment:** End-to-end enterprise network buildout (NTC Enterprise project).

---

## Key Considerations for Learning & Practical Execution

### 💡 Host Server Resource Optimization
When executing large labs (Arc 2 onwards with 10+ FRR nodes), optimize RAM/CPU usage on local VMs or WSL2:
- Disable unused routing daemons in `/etc/frr/daemons` (e.g., enable only `ospfd` or `bgpd`, set `ripd=no`, `pimd=no`).
- Apply RAM limits to individual containers within `.clab.yml` topology definitions if necessary.

### 🌐 Bridging the Gap Between Labs and Production
- **Configuration Persistence:** Direct `ip addr` or `ip route` commands run inside containers will reset upon lab destruction. In production environments, always persist configurations in system configuration files (`/etc/network/interfaces`, `/etc/netplan/`, or `write memory` in FRR).
- **Out-of-Band (OOB) Management Isolation:** Containerlab creates `eth0` for management access. In production networks, OOB management should always run over dedicated physical interfaces or isolated VRFs for security.

### 🏢 Transitioning from Courseware to Enterprise Production
This series focuses on core networking and automation using FRR and Linux containers. For enterprise deployment readiness, consider adding:
- **Multi-Vendor Validation:** While FRR models standard protocol behavior, production networks are often multi-vendor (Cisco, Arista, Juniper). Validate configurations on target physical hardware or vendor emulators (GNS3, EVE-NG).
- **Staging & CI Automation Gates:** Avoid pushing unverified configurations directly to production. Implement staging environments and automated CI validation pipelines (see Arc 3) with rollback strategies.
- **Capacity Planning & Load Testing:** Perform performance benchmark testing under high load and evaluate scaling capacity before going live.
- **Security Compliance & Auditing:** Conduct regular vulnerability assessments, penetration testing, and compliance audits (PCI-DSS, ISO 27001).

---

## 💬 Feedback & Contributions

Contributions, bug reports, and lab proposals are welcome!
- Review contribution guidelines in [CONTRIBUTING_en.md](./CONTRIBUTING_en.md).
- Open an **Issue** or submit a **Pull Request** directly on this repository.
- Join the discussion and share progress in the **Network Thực Chiến** community.

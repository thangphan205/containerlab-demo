**Language / Ngôn ngữ:** [English](lab-guide_en.md) | [Tiếng Việt](lab-guide.md)

# Lab 00: Server Preparation

**Arc 0 — Foundations & System Ops**

## Objectives
- Prepare a Linux server/VM ready to run Containerlab for the entire series.
- Install Docker Engine and configure non-root execution (`without sudo`).
- Verify system resources are sufficient for multi-node labs (subsequent routing labs can run up to 10+ containers).

## Prerequisites
None — this is the first lab in the series.

## Tasks & Instructions

1. Prepare a server running **Ubuntu 24.04 LTS** (Cloud VM, VirtualBox/Proxmox, or bare metal). Recommended specifications:
   * **Minimum**: 2 vCPU / 4 GB RAM / 30 GB disk (requires configuring 2 GB Swap as in step 6) — sufficient for basic FRR + Linux labs.
   * **Recommended**: 4 vCPU / 8 GB RAM / 40 GB - 50 GB disk to smoothly run all labs and comfortably store Docker images.
   
   > [!NOTE]
   > **Note on Disk & RAM sizing:**
   > - Major enterprise vendor NOS Docker images can be large (e.g., Arista cEOS ~1.5GB - 2GB, Cisco Catalyst 8000v ~1.5GB). When running, each cEOS node requires ~1.5GB RAM, Cisco requires ~3GB - 4GB RAM.
   > - If you plan to experiment with enterprise vendor images alongside FRR, prepare a server with at least **8 GB - 16 GB RAM** and **50 GB+ Disk**.
2. Install Docker Engine following official guidelines (avoid snap or docker-desktop on Linux server installs).
3. Add current user to the `docker` group, verifying `docker run hello-world` executes **without `sudo`**.
4. Enable IPv4 forwarding: ensure `net.ipv4.ip_forward = 1` (required by Containerlab for routing between containers).
5. Configure **SSH key-based authentication** (disable password login if using cloud VM) — baseline security practice for production servers.
6. Configure **swap space** (minimum 2GB): labs running multiple FRR containers simultaneously can trigger OOM (Out Of Memory) conditions on lower-spec machines without swap.
   ```bash
   sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
   sudo mkswap /swapfile && sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```
7. Record the output of the following commands for lab completion check:
   - `docker version`
   - `uname -a`
   - `free -h` (swap row must show a non-zero value)
   - `nproc`
   - `sysctl net.ipv4.ip_forward`
   - `ss -tlnp | grep 22` (verify SSH daemon is running)

## Technical Hints
- If using a cloud VM, open necessary firewall ports (SSH at minimum). Some cloud providers (AWS, GCP) use SSH keys by default — verify password login is disabled (`PasswordAuthentication no` in `/etc/ssh/sshd_config`).
- For servers with low RAM (2GB - 4GB), swap is vital — without swap, the Linux OOM killer may terminate containers randomly.
- Containerlab installation is not required in this lab — reserved for Lab 01.

## Discussion & Community Support
This lab is self-guided. If you have questions or feedback, discuss them in the [Network Thực Chiến](https://www.facebook.com/profile.php?id=61591373979991) community.

## Next Lab
→ [01-cai-dat-containerlab](../01-cai-dat-containerlab/lab-guide_en.md): Install Containerlab and deploy your first topology.

# Containerlab Practice & Labs 🚀

A collection of network simulation labs and demonstrations using **Containerlab**, featuring topology definitions, router configurations, and practice environments.

## 📌 Repository Overview

This repository contains containerized network lab implementations with:

- **Network Topologies**: `.clab.yml` files defining network architectures
- **Router Configurations**: Complete FRR (Free Range Routing) and Linux routing configs
- **Practice Environments**: Ready-to-deploy labs for hands-on learning
- **Automation**: Ansible inventory files and integration support

## 📂 Available Labs

| Lab | Vendor | Technologies | Description | Status |
|:---|:---|:---|:---|:---|
| **apricot2026** | FRR | OSPF, IS-IS, BGP, Route-Maps | APRICOT 2026 PCIO networking lab with multi-AS design | ✅ Active |
| **iproute2** | Linux | iproute2, netlink | Linux networking fundamentals | ✅ Complete |
| **iproute2-tc** | Linux | Traffic Control (TBF, netem) | Advanced traffic shaping and QoS | ✅ Complete |

## 🚀 Getting Started

### Prerequisites

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

# Install Containerlab
bash -c "$(curl -sL https://get.containerlab.dev)"
```

### Deploy a Lab

```bash
cd <lab-directory>
sudo clab deploy -t <topology-file>.clab.yml
```

### Access Routers

```bash
docker exec -it clab-<lab-name>-<router-name> vtysh
```

### Destroy Lab

```bash
sudo clab destroy -t <topology-file>.clab.yml
```

## 📖 Documentation

- Each lab directory contains its own **requirements.md** with step-by-step guides
- Configuration files include detailed comments explaining each section
- Lab diagrams (`.jpg` files) show network topology and IP addressing

## 🛠 Repository Management

### File Structure

The `.gitignore` is configured to:
- **Ignore**: Generated `clab-*/` directories, `*.sav`, `frr.conf` (runtime-generated), TLS certificates, metadata files
- **Track**: Topology files, router configs, documentation, daemon configs, images

This ensures clean version control with only source files committed.

## 📝 License

Educational use for NSRC workshops and networking practice.

## 🔗 Resources

- [Containerlab Documentation](https://containerlab.dev/)
- [FRR Project](https://frrouting.org/)
- [NSRC Workshop Materials](https://nsrc.org/workshops/)
- [YouTube Channel - Network Thực Chiến](https://www.youtube.com/@NetworkThucChien)

# Lab: Linux Networking (iproute2)

This lab focuses on Linux networking techniques using `iproute2`.

> **Note:** The demo uses `alpine` images for lightweight execution. You can replace them with Ubuntu or other Linux distributions in the topology file.

## Lab Requirements

### 1. IP Configuration

Configure IP Addresses according to the network topology (refer to `iproute2-topology.png` or the table below):

| Device | Interface | IP Address | Gateway |
| :--- | :--- | :--- | :--- |
| **linux1** | eth1 | 192.168.12.1/24 | - |
| | eth2 | 192.168.13.1/24 | - |
| | eth3 | 192.168.11.1/24 | - |
| **linux2** | eth1 | 192.168.12.2/24 | - |
| | eth2 | 192.168.24.2/24 | - |
| **linux3** | eth1 | 192.168.13.3/24 | - |
| | eth2 | 192.168.34.3/24 | - |
| **linux4** | eth1 | 192.168.24.4/24 | - |
| | eth2 | 192.168.34.4/24 | - |
| | eth3 | 192.168.41.1/24 | - |
| **client1**| eth1 | 192.168.11.2/24 | 192.168.11.1 |
| **server1**| eth1 | 192.168.41.2/24 | 192.168.41.1 |

### 2. Routing & Load Balancing

Configure routing so that `client1` can access `server1`.

- **Requirement:** Configure **Load Balancing** (ECMP) across the two paths via `linux2` and `linux3`.

### 3. Policy Based Routing (PBR)

Adjust routing policies to satisfy the following requirements:

1. **Client IP 192.168.11.11/24** accessing `server1`: Must use the path via `linux2`.
2. **Client IP 192.168.11.12/24** accessing `server1`: Must use the path via `linux3`.
3. **Client IP 192.168.11.13/24** accessing `server1`:
   - Traffic to **port 80** uses the path via `linux2`.
   - Traffic to **port 22** uses the path via `linux3`.

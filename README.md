# 🛡️ Active Directory & Cyber Range Lab (Marvel Domain)

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

Welcome to the **Active Directory Lab (Marvel Domain)** cyber range setup. This lab simulates an enterprise network environment featuring a Samba Active Directory Domain Controller (`marvel.local`), multiple employee workstations, pivot servers, and vulnerable web portals. 

> [!WARNING]
> **Educational Use Only**
> This repository contains deliberately vulnerable configurations and services. It is designed **strictly for educational purposes and authorized penetration testing**. Do not deploy this lab in a production environment or expose it to the public internet.

---

## 📑 Table of Contents
- [🏗️ Lab Architecture & Network Topology](#lab-architecture--network-topology)
  - [🖥️ Services & Hosts](#services--hosts)
- [🚀 Quick Start (Linux & macOS)](#quick-start-linux--macos)
- [🪟 Setup Guide: Windows OS](#setup-guide-windows-os)
- [🛠️ Troubleshooting & Utilities](#troubleshooting--utilities)
- [🔍 Initial Access / Footholds](#initial-access--footholds)
- [📄 License](#license)

---

## 🏗️ Lab Architecture & Network Topology

The lab consists of **11 containers** segmented across two Docker networks:

1. **`lab_net` (`10.10.1.0/24`)**: The external/DMZ network.
2. **`internal_net` (`172.168.1.0/24`)**: The corporate AD network (isolated, accessible via `machine1` pivot or host routing).

### 🖥️ Services & Hosts

| Container Name | Hostname | IP Address | Exposed Host Port | Description / Services |
| :--- | :--- | :--- | :--- | :--- |
| **`target_machine1`** | `ubuntu-server` | `10.10.1.1` <br> `172.168.1.1` | `80`, `2121`, `2222`, `1399`, `4445`, `2525`, `20499`, `11111`, `33061` | **DMZ Pivot Host** <br> Nginx, vsftpd, SMB, SSH, NFS, MySQL, Postfix SMTP |
| **`target_machine2`** | `marvel-dc` | `172.168.1.43` | *None (Internal)* | **Active Directory Domain Controller** <br> Samba AD DC (LDAP, Kerberos, DNS, SMB) |
| **`target_machine3`** | `stark-portal` | `172.168.1.65` | *None (Internal)* | Stark Enterprise Portal (Web App) |
| **`target_machine4`** | `rogers-portal`| `172.168.1.15` | *None (Internal)* | Rogers Portal (Web App) |
| **`target_machine5`** | `lpe-sandbox`   | `172.168.1.69` | `22222` | Sandbox host for local privilege escalation (SSH) |
| **`target_machine6`** | `shield-joomla` | `172.168.1.55` | *None (Internal)* | Vulnerable SHIELD Joomla Portal (v4.2.5 - CVE-2023-23752) |
| **`stark_workstation`** | `stark-workstation` | `172.168.1.10` | *None (Internal)* | User workstation |
| **`cap_workstation`** | `cap-workstation`   | `172.168.1.11` | *None (Internal)* | User workstation |
| **`blackwidow_workstation`** | `blackwidow-workstation` | `172.168.1.12` | *None (Internal)* | User workstation |
| **`hulk_workstation`** | `hulk-workstation` | `172.168.1.13` | *None (Internal)* | User workstation |
| **`spidey_workstation`** | `spidey-workstation` | `172.168.1.14` | *None (Internal)* | User workstation |

---

## 🚀 Quick Start (Linux & macOS)

### 1. Prerequisites
Ensure you have the following installed:
- **Docker Engine** (v20.10+)
- **Docker Compose** (v2.0+)

### 2. Deploying the Lab
To easily start the lab, we have provided convenient shell scripts:

```bash
# Clone the repository and enter the directory
git clone git@github.com:haltacademy/Marvle-AD-Lab.git
cd Marvle-AD-Lab

# Start the lab in the background
./start.sh
```

To stop the lab when you are finished:
```bash
./stop.sh
```

### 3. Routing to the Internal Network (Optional)
To access the internal subnet (`172.168.1.0/24`) directly from your Linux host machine, you can add a route pointing to the Docker gateway bridge:
```bash
# Determine the Docker bridge interface name (e.g., br-xxxxxxxxxxxx)
sudo ip route add 172.168.1.0/24 via 172.168.1.254
```
Otherwise, use `machine1` (`10.10.1.1` via local port mappings) as a pivot host (e.g., using SSH dynamic port forwarding/SOCKS proxy).

---

## 🪟 Setup Guide: Windows OS

### 1. Prerequisites
Ensure you have the following installed and configured:
- **WSL 2 (Windows Subsystem for Linux)**
- **Docker Desktop for Windows** (with WSL 2 backend integration enabled)
- **Git for Windows** (or run commands inside a WSL terminal)

### 2. Deploying the Lab
1. Open **PowerShell** or **Command Prompt** (as Administrator) and navigate to the project directory:
   ```powershell
   cd "C:\path\to\Marvle-AD-Lab"
   ```
2. Build and start the containers:
   ```powershell
   docker compose up -d --build
   ```
   *(To stop the lab, use `docker compose down`)*

### 3. Routing to the Internal Network on Windows
Because Docker Desktop on Windows runs inside a virtualized utility VM (WSL2), you cannot easily add a direct host route to the internal `172.168.1.0/24` subnet. 

**Recommended Pivoting Approach:**
Use **SSH Dynamic Port Forwarding** through `machine1` (which exposes SSH on port `2222` to the Windows host).
1. Establish a SOCKS proxy:
   ```powershell
   ssh -D 1080 -N -p 2222 tonystark@127.0.0.1
   # Use the password found/cracked or setup during exploitation
   ```
2. Configure your browser (using extensions like FoxyProxy) or tools (Proxychains/SocksCap64) to route traffic through `socks5://127.0.0.1:1080` to interact with the internal services (e.g., Stark Portal at `http://172.168.1.65`).

---

## 🛠️ Troubleshooting & Utilities

Because this lab uses static subnets, Docker may throw an error if the `172.168.1.0/24` subnet overlaps with existing interfaces or virtual networks. 

* **Fix Network Collisions**: Run the provided network fixer script if you encounter IP allocation issues.
  ```bash
  sudo bash fix_network.sh
  ```
* **Diagnose Container Health**: Run the diagnostics script to check the status of all lab components.
  ```bash
  sudo bash diagnose.sh
  ```

---

## 🔍 Initial Access / Footholds

* **FTP Server**: Accessible on `ftp://127.0.0.1:2121`. Tony Stark left a note here containing credentials and hints.
* **HTTP Portal**: Accessible on `http://127.0.0.1:80`. Contains a web panel for verification utilities.
* **SSH Pivot**: Accessible on `ssh -p 2222 tonystark@127.0.0.1`.

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).

# Docker Lab Recreation (GOAD Docker Lab)

## Executive Summary

GOAD ("Game of Active Directory") is an open‑source, multi‑domain Active Directory pentest lab originally built with Windows Server VMs. It spans **3 domains in 2 forests** (sevenkingdoms.local with child north.sevenkingdoms.local, and essos.local) across 5 Windows VMs providing AD DS, DNS, IIS, MS‑SQL, SMB shares, and intentionally mis‑configured accounts for classic AD attacks (Kerberoasting, AS‑REP roasting, NTLM relay, password spray, unconstrained delegation, etc.).

The original lab is heavy and relies on Windows evaluation images, making it resource‑intensive and time‑consuming to provision. This Docker‑based recreation emulates the same topology using **Samba AD DC containers**, lightweight Linux‑based service containers, and a Kali attacker container, allowing rapid spin‑up on any Linux host with Docker support.

---

## Architecture Diagram

![Docker Lab Architecture](file:///home/hackerhalt/.gemini/antigravity/brain/be440501-2961-4844-8b8c-b0adad0596be/docker_lab_architecture_1780131888919.png)

The diagram illustrates the three Samba AD DCs (SEVENKINGDOMS.LOCAL, NORTH.SEVENKINGDOMS.LOCAL, ESSOS.LOCAL), two MS‑SQL containers, a vulnerable web application (DVWA), and a Kali attacker container, all connected on a **macvlan** network `192.168.56.0/24`. Static IPs match the original GOAD topology.

---

## Prerequisites

- Docker Engine ≥ 20.10
- A network interface that supports **macvlan** (e.g., `eth0`). Adjust the `parent` field in `docker-compose.yml` if your interface differs.
- At least **12 GB RAM** (2 GB per Samba DC, 2–4 GB for each SQL container, plus host overhead).
- Optional: `docker-compose` (or use `docker compose`).

---

## Quick Start

1. **Clone or copy the `docker‑lab` directory** to your workstation.
2. **Create the macvlan network** (Docker will do this automatically when you run compose). Ensure no other Docker network uses the `192.168.56.0/24` subnet.
3. **Start the lab**:
   ```bash
   cd "AD Lab/docker-lab"
   docker compose up -d
   ```
4. **Run the initialization script** (populates AD users, groups, ACLs, and forest trusts):
   ```bash
   ./scripts/setup.sh
   ```
5. **Validate** – see the *Verification* section below.

---

## Verification

```bash
# Verify domain provisioning
docker exec dc1-sev samba-tool domain info

# LDAP query from host
ldapsearch -H ldap://192.168.56.10 -x -b "" -s base "(objectclass=*)"

# From the Kali container, test BloodHound connectivity
docker exec -it kali-attack bash -c "bloodhound-python -d sevenkingdoms.local -u arya.stark -p P@ssw0rd1"

# Test a Kerberoast request (example)
# (run inside Kali) impacket-getusername.py -hashes :<hash> 192.168.56.10
```

Successful output indicates the AD forest, trusts, and service containers are reachable.

---

## Cleanup

To stop and remove all containers and volumes:
```bash
docker compose down -v
```
All Samba databases and SQL data are stored in Docker volumes (`dc1-data`, `dc2-data`, `dc3-data`). Removing the volumes resets the lab to a clean state.

---

## Security Notice

- The lab **must remain isolated**; do **not** expose ports `389`, `636`, `445`, or `88` to the public internet.
- These containers intentionally contain weak credentials and mis‑configurations; never run this lab in a production environment.

---

## Extensibility (Optional)

- Replace the generic DVWA web app with a custom vulnerable IIS container (requires a Windows host).
- Add ELK/Wazuh containers for logging and detection.
- Include Windows Server 2019 containers for a true Windows DC (requires Docker on Windows).

---

## License

This Docker recreation is provided under the same MIT‑style license as the original GOAD project. See the original GOAD repository for full attribution.

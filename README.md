# Azure Home Lab


![Azure](https://img.shields.io/badge/Azure-East%20US-0078D4?logo=microsoftazure&logoColor=white)
![Windows Server](https://img.shields.io/badge/Windows%20Server-2022-0078D6?logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Ubuntu-24.04%20LTS-E95420?logo=ubuntu&logoColor=white)
![Status](https://img.shields.io/badge/Status-Step%206%20of%208-orange)
![Started](https://img.shields.io/badge/Started-Oct%202026-lightgrey)


A working Azure environment I'm building from scratch while completing the IT Security and Administration program at MyComputerCareer. Every step is written up as I go: what I built, why it matters, what broke, and how I fixed it.


**Goal:** a small, hardened company network in Azure that covers the day-to-day skills of a systems administrator and the foundation for AZ-104 and AZ-500.


## Progress


| # | Step | What it proves | Status |
|---|------|----------------|--------|
| 1 | [Foundation](01-foundation/) | Networking, segmentation, firewall rules, cost control | ✅ Done |
| 2 | [Windows Server domain](02-windows-domain/) | Active Directory, DNS, Group Policy, domain join | ✅ Done |
| 3 | [Cloud identity](03-entra-id/) | Entra ID, cloud users, MFA enrollment | ✅ Done |
| 4 | [Linux](04-linux/) | Ubuntu, nginx, SSH hardening, ufw, Bash | ✅ Done |
| 5 | [Security posture](05-defender/) | Defender for Servers, just-in-time VM access | ✅ Done |
| 6 | Backup and recovery | Azure Backup, test restore | 🔧 Next |
| 7 | Monitoring | Log Analytics, alert rules | ⬜ |
| 8 | Automation | PowerShell and Bash scripts | ⬜ |


## Architecture


```mermaid
flowchart TB
    Home["🏠 My laptop<br/>RDP 3389 / HTTP 80 from my IP<br/>SSH 22 on request only"]
    subgraph RG["Resource group: rg-homelab (East US)"]
        subgraph VNET["Virtual network: vnet-homelab (10.0.0.0/16)"]
            subgraph SRV["Subnet: snet-servers (10.0.1.0/24)"]
                NSG["🔒 nsg-servers<br/>Allow RDP + HTTP from my IP<br/>SSH closed until requested (JIT)<br/>Deny everything else"]
                DC["🖥️ vm-dc01 (10.0.1.4)<br/>Windows Server 2022<br/>Domain controller: homelab.local<br/>AD DS + DNS"]
                MEM["🖥️ vm-member01 (10.0.1.5)<br/>Windows Server 2022<br/>Domain member"]
                LNX["🐧 vm-linux01 (10.0.1.6)<br/>Ubuntu 24.04 LTS<br/>nginx + ufw<br/>SSH key only, no root"]
            end
            subgraph CLI["Subnet: snet-clients (10.0.2.0/24)"]
                WS["💻 workstations<br/>(later)"]
            end
        end
        BUDGET["💵 Budget alert: $30/month"]
    end
    Home -->|"public IP"| NSG
    NSG --> DC
    NSG --> MEM
    NSG --> LNX
    DC -. "domain join" .-> MEM
```


## What's in here


```
azure-home-lab/
  01-foundation/        resource group, VNet, subnets, NSG, budget
  02-windows-domain/    Windows Server 2022 VM, domain controller, AD, GPO
  03-entra-id/          Entra ID tenant, cloud users, MFA
  04-linux/             Ubuntu VM, nginx, ufw, SSH hardening, Bash script
  05-defender/          Defender for Servers Plan 2, just-in-time VM access
  06-backup/
  07-monitoring/
  08-scripts/
```


Each folder has a `README.md` with the write-up and a `screenshots/` folder.

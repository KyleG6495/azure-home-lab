# Azure Home Lab

A hands-on Azure environment I'm building from scratch while completing the IT Security and Administration program at MyComputerCareer. Everything here is documented as I go: what I built, why, what broke, and how I fixed it.

**Goal:** a working, hardened environment that covers the core skills of a systems administrator and the foundation for AZ-104 and AZ-500.

**Status:** In progress. Started October 2026.

## Lab plan

- [ ] **1. Foundation.** Free Azure account, resource group, virtual network with two subnets, network security group with real inbound and outbound rules.
- [ ] **2. Windows Server domain.** Two Windows Server VMs. Promote one to a domain controller, join the other as a member server. Create users, groups, and OUs. Apply a group policy.
- [ ] **3. Cloud identity.** Enable Microsoft Entra ID. Sync a few accounts. Turn on MFA and a conditional access policy.
- [ ] **4. Linux.** One Ubuntu VM. Install and configure a web server, harden SSH, set up ufw, and write a script that checks the auth log for failed logins.
- [ ] **5. Security posture.** Enable Microsoft Defender for Cloud. Work through every recommendation it gives. Before and after screenshots.
- [ ] **6. Backup and recovery.** Configure Azure Backup for one VM. Do a test restore and document it.
- [ ] **7. Monitoring.** Set up Log Analytics and one alert rule that actually fires.
- [ ] **8. Automation.** One PowerShell script and one Bash script that do something useful (user creation, patch check, log review).

## Layout

```
azure-home-lab/
  01-foundation/
  02-windows-domain/
  03-entra-id/
  04-linux/
  05-defender/
  06-backup/
  07-monitoring/
  08-scripts/
```

Each folder gets a `README.md` with the write-up and a `screenshots/` folder.

## How I write these up

Every step follows the same format so it's easy to read:

1. **What I built** and why it matters in a real environment.
2. **How I did it**, with enough detail that someone could repeat it.
3. **What went wrong** and how I fixed it. This is the part that matters most.
4. **What I'd do differently** next time.

## Background

Twenty-three years running a business taught me how to keep things working when it counts. This lab is me putting that same habit into Azure. Resume and the rest of the story are on [LinkedIn](https://www.linkedin.com/in/kyle-goneau-4728a187/).

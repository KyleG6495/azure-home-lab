# Step 2: Windows Server domain

**Status:** 🔧 In progress (started October 15, 2026)

## Done so far

- [x] Windows Server 2022 VM (`vm-dc01`, Standard_B2ls_v2, `10.0.1.4`) in `snet-servers`
- [x] Auto-shutdown at 11 PM Eastern
- [x] Connected over RDP through the NSG rule
- [x] Installed the Active Directory Domain Services role
- [x] Promoted to domain controller for a new forest: `homelab.local`
- [x] DNS installed automatically as part of promotion
- [ ] Organizational units (Staff, Servers, Workstations)
- [ ] Test user account
- [ ] Second VM (`vm-member01`) joined to the domain
- [ ] One Group Policy object applied and verified on the member server

## Why it matters

A domain is what turns a pile of computers into a company. One directory holds every user and computer, one login works everywhere, and one rule pushed from the domain controller lands on every machine. Almost every business with more than a handful of PCs runs on this, which is why Active Directory is on every sysadmin job posting.

## How I did it

**The VM.** Virtual machines → Create. Resource group `rg-homelab`, name `vm-dc01`, East US, no infrastructure redundancy, Security type Standard, image Windows Server 2022 Datacenter x64 Gen2, size B2ls_v2 (2 vCPU, 4 GB). Public inbound ports: **None** (the subnet NSG handles access). Networking: `vnet-homelab` / `snet-servers`, new public IP, NIC security group None. Management: auto-shutdown 11:00 PM Eastern.

**Connecting.** Remote Desktop Connection → public IP from the VM overview page → username `.\kyleadmin`.

**Domain controller.** Server Manager → Add roles and features → Active Directory Domain Services → Install. Then the notification flag → Promote this server to a domain controller → Add a new forest → root domain `homelab.local` → DSRM password → defaults through the rest → Install. The server reboots. Log back in as `HOMELAB\kyleadmin`.

## What went wrong

**Zero VM quota on a new account.** Every B-series size showed "0 vCPUs (of 0) remain" and then "NotAvailableForSubscription" in East US, East US 2, and North Central US. New pay-as-you-go accounts start locked. Filed a support request (Service and subscription limits → Compute-VM cores → BS and Bsv2 series, 10 vCPUs, East US). Approved in under an hour.

**The size I wanted was hidden.** The size picker groups sizes under headings like "Size not available," "Insufficient quota," and "Incompatible with Trusted launch." B2s was under the last one because the VM defaulted to Trusted launch. Switching Security type to Standard, and using the v2 sizes once quota was granted, fixed it.

**VM agent status "not ready" for 30 minutes.** A Restart from the portal cleared it in two minutes. Should have restarted sooner.

**Password rejected on first RDP.** The Azure Basics tab defaults the username to `azureuser`; I'd typed my password but hadn't changed the name. Used Help → Reset password in the portal to create `kyleadmin` as an administrator. Both accounts now show in Active Directory Users and Computers, which is how I confirmed what happened.

**Closed the wizard before promoting.** The "promote this server" link lives in the install wizard's results page and also under the notification flag in Server Manager. Found it under the flag.

## What I'd do differently

- Request quota before building the first VM, not after.
- Check the username field on the Basics tab every time.
- Restart a stuck VM at the 5 minute mark, not the 30.

## Screenshots

See [`screenshots/`](screenshots/).

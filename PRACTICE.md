# Practice exercises

Building this lab with help is not the same as being able to build it. These are the same tasks written as tickets, with no instructions.

**Rules:**

- Allowed: `--help`, the Azure portal, Microsoft Learn, and the write-ups in this repository.
- Not allowed: step-by-step instructions from anyone, including AI.
- If stuck for more than 15 minutes, look it up, then note what you had to look up.
- Record the time taken and what tripped you up.

The point is not speed. It is whether the documentation in this repository is good enough to work from, and whether the understanding is there when nobody is dictating commands.

---

## Tracker

| # | Exercise | Attempted | Completed unaided | Time | Notes |
|---|----------|-----------|-------------------|------|-------|
| 1 | Network foundation | | | | |
| 2 | Domain controller | | | | |
| 3 | Cloud identity | | | | |
| 4 | Linux server | | | | |
| 5 | Just-in-time access | | | | |
| 6 | Restore a deleted file | | | | |
| 7 | Alert on high CPU | | | | |
| 8 | Build the network from a script | | | | |
| 9 | Join Linux to the domain | | | | |
| 10 | Group-controlled share | | | | |
| 11 | Diagnose a dead service | | | | |
| 12 | Samba share for Windows | | | | |

---

## Exercise 1: Network foundation

Build a resource group containing a virtual network with two subnets, a network security group allowing RDP, SSH and HTTP from one address only, and a budget alert.

Delete it afterwards.

**Target:** 20 minutes.

## Exercise 2: Domain controller

On a fresh Windows Server VM, install Active Directory Domain Services and promote it to a domain controller for a new forest. Create an OU, create a user in it, and link a Group Policy object that applies to that user.

Prove the policy applied.

**Target:** 45 minutes. **Note:** do not use a `.local` suffix. Read `02-windows-domain/README.md` for why.

## Exercise 3: Cloud identity

Create a user in Entra ID and enforce multi-factor authentication across the tenant. Prove MFA is enforced by signing in as that user.

Explain out loud, without notes, why this user cannot log into the Windows domain.

**Target:** 20 minutes.

## Exercise 4: Linux server

Deploy an Ubuntu VM with key-based authentication. Install and start a web server. Open the port in both the NSG and the host firewall. Disable password and root login over SSH, and verify a new session works before closing the old one.

**Target:** 40 minutes.

## Exercise 5: Just-in-time access

Configure just-in-time access on a VM so that SSH is closed by default. Prove the port is closed while the machine is running, then request access and prove it opens.

Then tear it down, including the rule it leaves behind.

**Target:** 30 minutes.

## Exercise 6: Restore a deleted file

> A user reports that an important file was deleted from the shared folder this morning. They need it back.

Recover it. Verify the contents and the ownership are correct. Clean up anything the recovery process left mounted.

**Target:** 30 minutes, assuming a recovery point already exists.

## Exercise 7: Alert on high CPU

Configure an alert that emails you if a VM sustains high CPU for several minutes. Explain why the time window matters.

**Target:** 15 minutes.

## Exercise 8: Build the network from a script

Without opening `build-lab.sh`, write a script that creates a resource group, virtual network, two subnets, a network security group with inbound rules, and attaches the NSG to a subnet. It should take the resource group name and an IP address as arguments and refuse to run without them.

Test it against a throwaway resource group, then delete it.

Compare yours to the one in `08-scripts/` afterwards.

**Target:** 45 minutes.

## Exercise 9: Join Linux to the domain

Join a Linux machine to the Windows domain so a domain account can log into it and gets a home directory on first login.

Make the DNS configuration survive a reboot, and prove it by rebooting.

**Target:** 45 minutes.

## Exercise 10: Group-controlled share

Create a directory that only members of a specific Active Directory group can enter. Prove a member can write to it and a non-member cannot. Explain why a local administrator can still get in.

Then schedule a script to run daily and confirm it fires.

**Target:** 30 minutes.

## Exercise 11: Diagnose a dead service

> Have someone else break a service on the Linux box without telling you what they did.

Find the fault and fix it. Write down the order you checked things in.

**Target:** 15 minutes. This is the one that matters most, and the only one where the answer cannot be looked up.

## Exercise 12: Samba share for Windows

Share a folder from the Linux server so a Windows machine can open it as a network drive, with access decided by Active Directory group membership.

**Target:** 60 minutes. Eight things went wrong the first time. `12-samba-ad-share/README.md` lists all of them.

---

## Why this file exists

I built this lab with assistance. Following instructions and understanding something are different, and the gap between them only shows up when the instructions stop.

These exercises close that gap, and the tracker above is an honest record of which ones I can do unaided.

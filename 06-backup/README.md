# Step 6: Backup and tested restore

**Status:** ✅ Complete (October 31, 2026)

## What I built

| Item | Detail |
|------|--------|
| Recovery Services vault | `rsv-homelab`, East US. Storage for backups, separate from the VM so it survives the VM being destroyed. |
| Protected machine | `vm-linux01`, using Azure's `DefaultPolicy` — daily backup, 30 day retention. |
| On-demand backup | Triggered manually rather than waiting for the nightly run. 26 minutes, `FileSystemConsistent`. |
| Restore test | Deleted a real file, recovered it from the backup, verified contents and ownership. |

**Proof it works:** `/srv/staff/notes.txt` was deleted from the running machine, recovered from the 12:00 recovery point, and came back with the correct contents (`hello from tuser`) and the correct owner and group (`tuser@homelab.local`, `domain users@homelab.local`).

## Why it matters

Setting up backup is the easy half and plenty of organisations stop there. The half that matters is proving a restore works, because an untested backup is an assumption, not a safeguard.

The specific failure this guards against is ordinary: someone deletes a file they needed. That is a help desk ticket, not a disaster, and knowing the recovery path is everyday work.

## How I did it

**Vault and protection.**

```
az backup vault create --resource-group rg-homelab --name rsv-homelab --location eastus
az backup protection enable-for-vm --resource-group rg-homelab --vault-name rsv-homelab --vm vm-linux01 --policy-name DefaultPolicy
```

**On-demand backup.**

```
az backup protection backup-now --resource-group rg-homelab --vault-name rsv-homelab \
  --container-name vm-linux01 --item-name vm-linux01 \
  --backup-management-type AzureIaasVM --retain-until 15-11-2026
```

**Verify the recovery point exists before destroying anything.**

```
az backup recoverypoint list --resource-group rg-homelab --vault-name rsv-homelab \
  --container-name vm-linux01 --item-name vm-linux01 --backup-management-type AzureIaasVM --output table
```

Returned one point, `638879532132797`, marked `FileSystemConsistent` — meaning writes were quiesced before the snapshot, so files are in a settled state rather than caught mid-write.

**Then delete the file, and restore it.** File recovery works by mounting the recovery point onto a machine as temporary read-only drives, copying what you need, and unmounting. The portal's File Recovery wizard generates a script and a one-time password; the script runs on the target machine.

```
scp restore.py linux01:~/
ssh linux01
sudo python3 restore.py
```

It mounted the backup at `/home/kyleadmin/vm-linux01-<timestamp>/Volume1`, a full copy of the disk as it was at noon.

```
sudo cp -p .../Volume1/srv/staff/notes.txt /srv/staff/
```

`-p` preserves owner, group and timestamp. Without it the restored file arrives owned by root, which would have broken the Active Directory group access set up in step 10.

**Cleanup, which is part of the job:**

```
sudo python3 restore.py clean      # remove local mount folders
```

Then **Unmount Disks** in the portal to close the connection. Left alone, the mount persists for 12 hours.

## What went wrong

**The Recovery Services provider was not registered.**

```
MissingSubscriptionRegistration
The subscription is not registered to use namespace 'Microsoft.RecoveryServices'
```

Azure does not enable every service family on every subscription by default. The portal usually registers providers silently; the CLI does not. Fixed with `az provider register --namespace Microsoft.RecoveryServices` and waiting for `registrationState` to read `Registered`.

Worth noting the inconsistency: when `az monitor action-group create` hit the same situation for `microsoft.insights`, it registered the provider automatically and carried on. Both behaviours exist.

**`backup-now` rejected the friendly VM name.** `--backup-management-type is required when providing container's friendly name`. Adding `--backup-management-type AzureIaasVM` resolved it.

**`restore files mount-rp` failed with an error that said nothing useful.**

```
BMSUserErrorInvalidInput: Input provided for the call is invalid. Please check the required inputs
```

No indication of which input. Listing the real identifiers showed the CLI wanted the full internal names, not the friendly ones:

```
IaasVMContainer;iaasvmcontainerv2;rg-homelab;vm-linux01
VM;iaasvmcontainerv2;rg-homelab;vm-linux01
```

Those contain semicolons, which the shell treats as command separators, so they have to be quoted. Even with the full quoted names the command kept failing, so I switched to the portal's File Recovery wizard, which produced the script and password without complaint. This was the mirror image of step 5, where the portal was broken and the CLI worked.

**DNS failed on the Linux box mid-restore.** The script could not resolve `azure.archive.ubuntu.com` or the Azure backup endpoint. Cause: `vm-linux01` uses `10.0.1.4` as its DNS server, and `vm-dc01` was powered off. One domain controller down and an unrelated machine loses all name resolution.

This is the single point of failure noted in step 2's "what I'd do differently." Starting the DC fixed it immediately. Worth having hit it rather than only having written it down.

**The vendor script expected a Python module that no longer exists.** `asyncore is not available (likely Python 3.12+)` — removed from Python 3.12, which Ubuntu 24.04 ships. The script offered to install `pyasyncore` as a replacement and continued. A vendor tool lagging the OS is common; handling it gracefully is not.

## What I'd do differently

- Verify the recovery point exists before deleting anything. Done here, and it should be automatic.
- Use `cp -p` on every restore. A file that comes back with the wrong owner is only partly restored.
- Check what else depends on a machine before shutting it down. Powering off the domain controller broke DNS on a server doing something unrelated.
- Reach for the portal sooner when a CLI error gives no detail. `Input provided for the call is invalid` is not a diagnosis, and the wizard did the same job in two clicks.

## Cost

Azure Backup bills roughly $5 per protected instance per month, prorated, plus storage. Teardown is `az backup protection disable` followed by deleting the vault.

## Screenshots

See [`screenshots/`](screenshots/).

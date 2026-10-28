# Step 4: Linux server

**Status:** ✅ Complete (October 27 to 28, 2026)

## What I built

| Resource | Name | Details |
|----------|------|---------|
| Linux VM | `vm-linux01` | Ubuntu 24.04 LTS, B2ls_v2, `10.0.1.6`. Same subnet as the Windows servers. |
| Authentication | SSH key pair | `vm-linux01_key.pem` on my laptop. No password login. |
| Web server | nginx | Serving the default page on port 80 over the VM's public IP. |
| Host firewall | `ufw` | Enabled, allowing 22 and 80 only. |
| SSH hardening | `60-cloudimg-settings.conf` | `PasswordAuthentication no`, `PermitRootLogin no`. |
| Script | `ssh-report.sh` | Bash. Reports successful and rejected SSH attempts from the last 24 hours. |

**Proof it works:** nginx page loads in a browser over the public IP, `sudo ufw status` shows active with 22 and 80 allowed, and `ssh-report.sh` returns three accepted logins and two rejected attempts, all from my own address.

## Why it matters

Most of the infrastructure in a real environment is Linux, and it is administered over SSH with no desktop at all. This step covers the daily basics: connect with a key, edit config files from the terminal, run a service, control the host firewall, and read the logs. The two firewalls are the point worth noticing. The Azure network security group blocks traffic before it ever reaches the machine. `ufw` blocks it again on the machine itself. Either one alone is a single point of failure.

## How I did it

**VM.** Virtual machines → Create. Ubuntu Server 24.04 LTS, B2ls_v2, `vnet-homelab` / `snet-servers`. Authentication type **SSH public key**, which generates a key pair and downloads the private key once. Saved `vm-linux01_key.pem` to my user folder on Windows.

**Connect.** From Command Prompt:

```
ssh -i vm-linux01_key.pem kyleadmin@<public-ip>
```

`-i` points at the private key. The command only finds the key if the prompt is sitting in the folder that holds it, or the full path is given.

**nginx.**

```
sudo apt update
sudo apt install nginx
systemctl status nginx
```

Then added an inbound rule for port 80 on `nsg-servers` and loaded the public IP in a browser.

**ufw.**

```
sudo ufw allow 22
sudo ufw allow 80
sudo ufw enable
sudo ufw status
```

**SSH hardening.**

```
sudo nano /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
```

The file already contained `PasswordAuthentication no` because the VM was built with key authentication. Added `PermitRootLogin no`. Then:

```
sudo sshd -t                  # test the config, silence means it passed
sudo systemctl restart ssh
```

Opened a second Command Prompt and connected again before closing the first one. Never close the working session until a new one is proven.

**Script.** `~/ssh-report.sh`:

```bash
#!/bin/bash
echo "Who tried to log in:"
journalctl -u ssh --since "24 hours ago" | grep -i accepted
echo "Who got turned away:"
journalctl -u ssh --since "24 hours ago" | grep -E "Failed|invalid|reset"
```

```
chmod +x ~/ssh-report.sh
sudo ~/ssh-report.sh
```

## What went wrong

**Typed the config filename wrong.** `60-clouding-settings.conf` instead of `60-cloudimg-settings.conf`. Linux did not error. `nano` opened an empty new file and showed `[ New File ]` at the bottom, which was the only clue. Exited without saving, ran `ls /etc/ssh/sshd_config.d/` to get the real name, and started using Tab completion. If Tab will not complete a name, the thing being typed does not exist.

**`grep accepted` matched nothing.** The log writes `Accepted` with a capital A, and `grep` is case sensitive. The successful-login half of the report came back empty while the rejected half worked. Fixed with `grep -i`, which ignores case. Coming from Windows, where filenames and text are treated case-insensitively, this is an easy one to lose an hour to.

**Ran `sudo nano` at the Windows prompt.** The SSH session had dropped with `client_loop: send disconnect: Connection reset` and I did not notice. Windows answered with "Sudo is disabled on this machine." The prompt is the tell: `C:\Users\kgone>` is the laptop, `kyleadmin@vm-linux01:~$` is the server.

**Key not found from an Administrator prompt.** An elevated Command Prompt opens in `C:\Windows\System32`, not the user folder, so `ssh -i vm-linux01_key.pem` could not see the key and the server answered `Permission denied (publickey)`. The warning line above it said the identity file was not accessible. Giving the full path to the key avoids this entirely.

**NSG source IP went stale again.** Third time. My public IP changes depending on where I am working that day, and every change breaks RDP and SSH until the rules are updated by hand. Just-in-time VM access in step 5 is the fix.

**HTTP rule did not work at first.** Created the port 80 rule but set Source port ranges to 80 as well. Source port should be `*`. Destination port is the one that matters.

## What I'd do differently

- Use Tab completion for every path instead of typing filenames.
- Assume case matters, always, for both filenames and text being searched.
- Check the prompt before typing a command, every time.
- Give full paths to key files so the command works from any folder.
- Test with `sshd -t` before restarting SSH, and keep the old session open until a new one connects. Getting this wrong locks you out of your own server.

## Screenshots

See [`screenshots/`](screenshots/).

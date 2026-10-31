# Step 7: Monitoring and alerts

**Status:** ✅ Complete (October 31, 2026)

## What I built

| Item | Detail |
|------|--------|
| Action group | `ag-homelab-email` — who gets told when something fires. One email recipient. |
| Alert rule | `alert-cpu-high` — fires if `vm-linux01` averages over 80% CPU for five minutes. |
| Evaluation | Checked every minute, over a five minute window. Severity 2. |

## Why it matters

Nobody watches a dashboard. Monitoring only does anything if it reaches a person when something is wrong, which is why the alert and the notification are configured separately: the rule decides what counts as a problem, the action group decides who hears about it.

The five minute window is the part worth thinking about. Without it, every brief CPU spike sends an email, people start ignoring the emails, and the one that mattered goes unread along with the rest. Alert fatigue is how real outages get missed, and the fix is in the threshold, not the inbox.

## How I did it

**Who to notify:**

```
az monitor action-group create --resource-group rg-homelab --name ag-homelab-email \
  --short-name homelab --action email kyle kgoneau@gmail.com
```

**Get the VM's resource ID**, because the alert needs to target something specific:

```
VMID=$(az vm show -g rg-homelab -n vm-linux01 --query id -o tsv)
```

The `$( )` runs the inner command and stores the result in a variable. Avoids pasting a 140 character resource path by hand.

**The rule:**

```
az monitor metrics alert create --name alert-cpu-high --resource-group rg-homelab \
  --scopes "$VMID" \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m --evaluation-frequency 1m --severity 2 \
  --action ag-homelab-email \
  --description "CPU above 80 percent for 5 minutes on vm-linux01"
```

## What went wrong

Nothing, which is worth recording as much as the failures. `az monitor action-group create` found that the `microsoft.insights` provider was unregistered and registered it automatically before continuing — the opposite of the Recovery Services provider in step 6, which failed and made me register it by hand.

Same underlying situation, two different behaviours from the same CLI. Worth knowing both exist so the failing kind does not look like a broken subscription.

## What I'd do differently

- Add an availability alert as well as a CPU one. A machine at 0% CPU because it has stopped responding is a worse problem than one at 85%, and this rule would not catch it.
- Send alerts somewhere other than personal email for anything real. Email is fine for a lab and a poor fit for anything that needs a response at 3am.
- Set the threshold from observed behaviour rather than a round number. 80% is a convention, not a measurement.

## Screenshots

See [`screenshots/`](screenshots/).

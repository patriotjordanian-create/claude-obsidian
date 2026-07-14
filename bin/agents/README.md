# bin/agents — scheduled vault maintenance

Four cron-safe scripts that keep the vault tidy between Claude sessions. They
handle the mechanical half of maintenance (locks, delta scans, git hygiene,
reports). The judgment half (synthesis, hot-cache rewrites, real lint) still
belongs to a Claude session; each script says which skill picks up its output.

| Script | What it does | Suggested schedule |
|---|---|---|
| `morning.sh` | transport refresh, stale-lock cleanup, pending-ingest report | daily 08:00 |
| `nightly.sh` | 5-phase consolidation: locks, delta scan, structural scan, local auto-commit of wiki changes, status log | daily 22:00 |
| `weekly-review.sh` | writes `wiki/meta/weekly-review-YYYY-MM-DD.md` from 7 days of git history | Friday 18:00 |
| `health-check.sh` | manifest validity, locks, address counter, git cleanliness, `make test`; nonzero exit on failure | Sunday 21:00 |

All scripts locate the vault root themselves, take no arguments, need no
network, and never push.

## Linux: crontab

`crontab -e`, then (replace the path with your real clone location):

```cron
0 8  * * * bash /path/to/claude-obsidian/bin/agents/morning.sh
0 22 * * * bash /path/to/claude-obsidian/bin/agents/nightly.sh
0 18 * * 5 bash /path/to/claude-obsidian/bin/agents/weekly-review.sh
0 21 * * 0 bash /path/to/claude-obsidian/bin/agents/health-check.sh
```

## macOS: launchd

Save as `~/Library/LaunchAgents/com.obsidian.nightly.plist` (one per job,
adjust Label/script/Hour), then `launchctl load` it:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>com.obsidian.nightly</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/path/to/claude-obsidian/bin/agents/nightly.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict><key>Hour</key><integer>22</integer><key>Minute</key><integer>0</integer></dict>
    <key>WorkingDirectory</key><string>/path/to/claude-obsidian</string>
</dict>
</plist>
```

## Windows

There is no crontab. Use Task Scheduler with WSL or Git Bash:
`Program: bash.exe`, `Arguments: /c/path/to/claude-obsidian/bin/agents/nightly.sh`.

## Claude Code on the web (remote sessions)

Containers are ephemeral, so a crontab inside one dies with it. Use Routines
(scheduled triggers) instead — they start a fresh Claude session on schedule,
which can run these scripts AND do the judgment half the scripts cannot.
Ask Claude: "create a routine that runs the nightly consolidation at 22:00".

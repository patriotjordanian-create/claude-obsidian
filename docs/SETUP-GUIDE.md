# claude-obsidian Setup Guide

Complete step-by-step workflow to initialize your vault and enable background agents.

---

## Prerequisites

- ✅ Repository cloned: `git clone https://github.com/AgriciDaniel/claude-obsidian`
- ✅ Obsidian installed on your machine
- ✅ Claude Code installed

---

## Phase 1: Core Vault Setup

### Step 1: Run Setup Script

```bash
cd /path/to/claude-obsidian
bash bin/setup-vault.sh
```

**What it does:**
- Configures `graph.json` (filter + colors)
- Configures `app.json` (excludes plugin dirs)
- Enables CSS snippets in `appearance.json`
- Creates base folder structure

### Step 2: Open Vault in Obsidian

1. Launch **Obsidian**
2. Go to **Manage Vaults → Open folder as vault**
3. Select the `claude-obsidian/` directory

You should see:
- File explorer with color-coded folders
- `wiki/` structure with sample pages
- Graph view showing connected nodes

### Step 3: Initialize Vault in Claude Code

Restart Claude Code, then run one of:

```
/obsidian-init
```

or

```
initialize vault
```

**What it creates:**
- `CLAUDE.md` — your vault's operating manual (loaded every session)
- `wiki/index.md` — master catalog of all notes
- `wiki/log.md` — append-only operation log
- `wiki/hot.md` — recent context cache (~500 words)

---

## Phase 2: Background Agent Setup (Optional)

Background agents maintain your vault unattended. They run on a schedule and write directly to your vault.

### Step 4a: Enable Environment Variables (Linux/macOS)

Edit or create `~/.claude/settings.json`:

```json
{
  "env": {
    "OBSIDIAN_VAULT_PATH": "/path/to/claude-obsidian",
    "OBSIDIAN_BG_AGENT_ENABLED": "1"
  }
}
```

**Note:** Change `OBSIDIAN_BG_AGENT_ENABLED` to `0` to disable background agents anytime.

### Step 4b: Enable Environment Variables (Windows)

Set environment variables via System Settings:

```
OBSIDIAN_VAULT_PATH = C:\path\to\claude-obsidian
OBSIDIAN_BG_AGENT_ENABLED = 1
```

Then restart Claude Code.

---

## Phase 3: Schedule Background Agents

Choose your platform:

### Option A: Linux/macOS (crontab)

```bash
crontab -e
```

Add these lines:

```bash
# 8 AM - Morning context refresh
0 8 * * * cd /path/to/claude-obsidian && bash bin/agents/morning.sh

# 10 PM - Nightly consolidation (5-phase)
0 22 * * * cd /path/to/claude-obsidian && bash bin/agents/nightly.sh

# Friday 6 PM - Weekly review
0 18 * * 5 cd /path/to/claude-obsidian && bash bin/agents/weekly-review.sh

# Sunday 9 PM - Health check
0 21 * * 0 cd /path/to/claude-obsidian && bash bin/agents/health-check.sh
```

**Verify cron is running:**

```bash
crontab -l
```

### Option B: macOS (launchd)

Create `~/Library/LaunchAgents/com.obsidian.nightly.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.obsidian.nightly</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/path/to/claude-obsidian/bin/agents/nightly.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>22</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>WorkingDirectory</key>
    <string>/path/to/claude-obsidian</string>
</dict>
</plist>
```

Load it:

```bash
launchctl load ~/Library/LaunchAgents/com.obsidian.nightly.plist
```

### Option C: Windows (Task Scheduler)

1. Open **Task Scheduler**
2. Create New Task
3. **Trigger:** Set time (e.g., 10 PM daily)
4. **Action:** Run `bash /path/to/claude-obsidian/bin/agents/nightly.sh`
5. **Conditions:** Check "Wake the computer to run this task"

---

## Phase 4: Verification

### Check Setup Status

In Claude Code, run:

```
/wiki
```

This will show:
- ✅ Vault health status
- ✅ Recent activity
- ✅ Configuration summary

### Monitor Background Agent Logs

**Background agent log:**

```bash
tail -f /tmp/obsidian-bg-agent.log
```

**Vault health check:**

```bash
python ~/.claude/skills/obsidian-second-brain/scripts/health-check.py /path/to/claude-obsidian
```

### Test a Background Agent Manually

```bash
cd /path/to/claude-obsidian
bash bin/agents/health-check.sh --dry-run
```

(Outputs what would happen without making changes)

---

## Phase 5: Start Using Commands

Your vault is now ready. Use these commands in Claude Code:

| Command | What it does |
|---------|-------------|
| `/wiki` | Check status, view recent activity, scaffold new areas |
| `ingest [file]` | Read a source, extract entities/concepts, file into wiki |
| `what do you know about X?` | Query the wiki, cite specific pages |
| `/save` | File the current conversation as a wiki note |
| `/autoresearch [topic]` | Run autonomous research: search → fetch → synthesize → file |
| `lint the wiki` | Health check: orphans, dead links, gaps |
| `/canvas` | Visual layer: add images, PDFs, notes |

---

## Troubleshooting

### Vault not appearing in Obsidian?

```bash
ls -la /path/to/claude-obsidian/.obsidian
```

Should show config files. If empty, re-run:

```bash
bash bin/setup-vault.sh
```

### Background agents not running?

Check cron is installed:

```bash
which cron
# or on macOS:
launchctl list | grep obsidian
```

Check logs:

```bash
tail -f /tmp/obsidian-bg-agent.log
grep "ERROR" /tmp/obsidian-bg-agent.log
```

### Claude Code not finding vault?

Verify environment variable:

```bash
echo $OBSIDIAN_VAULT_PATH
```

Should print your vault path. If blank:

1. Edit `~/.claude/settings.json` 
2. Restart Claude Code
3. Re-check

### Permissions errors on macOS?

```bash
chmod +x bin/agents/*.sh
chmod +x bin/setup-vault.sh
```

---

## Next Steps

1. **Drop your first source** into `.raw/`
2. **Run** `ingest [filename]`
3. **Ask a question** from your vault
4. **Enable lint** every 10-15 ingests
5. **Let background agents run** — they maintain the vault for you

The vault runs itself. You just work. 🧠

---

## Quick Reference: Vault Paths

```
/path/to/claude-obsidian/
├── wiki/                    ← All your knowledge (Claude writes here)
├── .raw/                    ← Source documents (you manage)
├── bin/                     ← Setup scripts
│   └── agents/              ← Background agents
├── .vault-meta/             ← Runtime config (auto-generated)
└── CLAUDE.md                ← Vault operating manual (auto-generated)
```

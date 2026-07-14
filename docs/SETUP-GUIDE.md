# claude-obsidian: Real Setup (What You Actually Need to Do)

The vault exists here (remote). To use it, you need to:

1. Get it on your machine
2. Open it in Obsidian
3. Run one command
4. Install 3 plugins
5. Done

---

## Step 1: Get the Vault to Your Machine

**Option A: Clone the repo**

```bash
git clone https://github.com/patriotjordanian-create/claude-obsidian
cd claude-obsidian
```

**Option B: If you want the latest session work**

```bash
git clone https://github.com/patriotjordanian-create/claude-obsidian
cd claude-obsidian
git checkout claude/skill-learning-3rs0kb
```

Then:

```bash
bash bin/setup-vault.sh
```

---

## Step 2: Open in Obsidian

1. Launch **Obsidian**
2. Click **Manage Vaults** (bottom left)
3. Click **Open folder as vault**
4. Select your `claude-obsidian/` folder
5. Click **Open**

You should see the file tree on the left with color-coded folders.

---

## Step 3: Install 3 Community Plugins

In Obsidian:

1. **Settings** → **Community Plugins** → Turn off "Restricted Mode"
2. Click **Browse**
3. Search for and install:
   - **Dataview** (query vault as database)
   - **Templater** (auto-fill note templates)
   - **Obsidian Git** (auto-backup every 15 min)
4. For each one, after install, click **Enable**

---

## Step 4: Set Up Environment Variables

So Claude Code knows where your vault is.

**On macOS/Linux:**

Edit or create `~/.claude/settings.json`:

```json
{
  "env": {
    "OBSIDIAN_VAULT_PATH": "/path/to/claude-obsidian",
    "OBSIDIAN_BG_AGENT_ENABLED": "1"
  }
}
```

Replace `/path/to/claude-obsidian` with your actual path (e.g., `/Users/yourname/claude-obsidian`).

**On Windows:**

1. Right-click **This PC** → **Properties**
2. Click **Advanced system settings**
3. Click **Environment Variables**
4. Click **New** under User variables
5. Add:
   - `OBSIDIAN_VAULT_PATH` = `C:\Users\yourname\claude-obsidian`
   - `OBSIDIAN_BG_AGENT_ENABLED` = `1`
6. Click OK, restart Claude Code

---

## Step 5: Restart Claude Code

Close and reopen Claude Code so it picks up the new environment variables.

---

## Step 6: Initialize the Vault

Open Claude Code in your vault folder:

```bash
cd /path/to/claude-obsidian
```

Then in Claude Code chat, type:

```
/obsidian-init
```

or

```
initialize vault
```

Claude will create `CLAUDE.md`, index, log, and hot cache.

---

## Step 7: You're Done

Now you can:

**Drop a source into `.raw/` and run:**

```
ingest [filename]
```

**Ask a question:**

```
what do you know about [topic]?
```

**Run maintenance:**

```
lint the wiki
```

**Check status:**

```
/wiki
```

---

## Optional: Set Up Local Scheduled Agents

If you want background agents running on your machine:

### macOS (launchd)

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

Then:

```bash
launchctl load ~/Library/LaunchAgents/com.obsidian.nightly.plist
```

Create 3 more `.plist` files for morning (08:00), weekly-review (Fri 18:00), and health-check (Sun 21:00).

### Linux (crontab)

```bash
crontab -e
```

Add:

```bash
0 8 * * * cd /path/to/claude-obsidian && bash bin/agents/morning.sh
0 22 * * * cd /path/to/claude-obsidian && bash bin/agents/nightly.sh
0 18 * * 5 cd /path/to/claude-obsidian && bash bin/agents/weekly-review.sh
0 21 * * 0 cd /path/to/claude-obsidian && bash bin/agents/health-check.sh
```

### Windows (Task Scheduler)

1. Open **Task Scheduler**
2. Right-click **Task Scheduler Library** → **Create Basic Task**
3. Name: `obsidian-nightly`
4. Trigger: Daily at 10 PM
5. Action: Run `bash /path/to/claude-obsidian/bin/agents/nightly.sh`
6. Click OK

Repeat for the other 3 agents.

---

## Checklist

- [ ] Clone repo to your machine
- [ ] Run `bash bin/setup-vault.sh`
- [ ] Open folder in Obsidian
- [ ] Install Dataview, Templater, Obsidian Git
- [ ] Edit `~/.claude/settings.json` with vault path
- [ ] Restart Claude Code
- [ ] Run `/obsidian-init` in Claude Code
- [ ] Drop a file in `.raw/` and run `ingest [filename]`

Done. Your vault is live.

# Jarvis Dashboard

A visual kanban board and project tracking dashboard for Bob — view what Jarvis is working on in real-time.

## Features

- **📊 Quick Stats** — Tasks completed, in progress, to do, active projects
- **📋 Kanban Board** — Visual 4-column board (To Do, In Progress, Blocked, Done)
- **🚀 Active Projects** — Progress bars for ongoing projects with sub-tasks
- **📜 Recent Activity Log** — Last 10 activities from memory files
- **🔄 Auto-refresh** — Updates every 5 minutes

## Usage

### Open Dashboard

```bash
dashboard
```

This will:
1. Read your `KANBAN.md` and memory files
2. Generate an HTML dashboard
3. Open it in your browser automatically

### Update Dashboard

When you update `KANBAN.md` or make changes, re-run:

```bash
dashboard
```

The dashboard updates instantly and shows the latest data.

## Data Sources

### KANBAN.md

The kanban board reads from `~/.openclaw/workspace/KANBAN.md`.

Format:
```markdown
## 📋 To Do
- [ ] Task one
- [ ] Task two

## 🔄 In Progress
- [ ] Project A
  - [x] Subtask 1
  - [ ] Subtask 2

## ⏸️ Blocked
- [ ] Blocked task

## ✅ Done
- [x] Completed task
```

### Memory Files

Recent activity is pulled from `~/.openclaw/workspace/memory/YYYY-MM-DD.md` files.

Lines containing keywords like:
- "created"
- "built"
- "updated"
- "added"
- "completed"

...are shown in the activity log.

## Customization

### Auto-refresh Interval

Edit `dashboard.py` and change the timeout value:

```python
# Auto-refresh every 5 minutes (in milliseconds)
setTimeout(() => location.reload(), 300000);
```

### Styling

All CSS is inline in `dashboard.py`. Edit the `<style>` section to customize colors, fonts, layouts, etc.

## Files

- `dashboard.py` — Main Python script
- `dashboard` — Shell wrapper
- `KANBAN.md` — Task data source
- `memory/` — Activity log source
- `DASHBOARD.html` — Generated dashboard (auto-created)

## Pushed to GitHub

Dashboard code is available at:
https://github.com/maidanytimeau-arch/day-starter

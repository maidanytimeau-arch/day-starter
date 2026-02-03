#!/usr/bin/env python3
"""
Jarvis Dashboard - Visual Kanban Board and Project Tracking
Generates an HTML dashboard for viewing in browser
"""

import re
from datetime import datetime
from pathlib import Path
from html import escape as html_escape

# Paths
WORKSPACE = Path.home() / ".openclaw" / "workspace"
KANBAN_FILE = WORKSPACE / "KANBAN.md"
MEMORY_DIR = WORKSPACE / "memory"
DASHBOARD_FILE = WORKSPACE / "DASHBOARD.html"

def parse_kanban():
    """Parse KANBAN.md into structured data"""
    if not KANBAN_FILE.exists():
        return {"todo": [], "in_progress": [], "blocked": [], "done": []}

    content = KANBAN_FILE.read_text()
    sections = {"todo": [], "in_progress": [], "blocked": [], "done": []}

    current_section = None
    for line in content.split('\n'):
        if '## 📋 To Do' in line or '## To Do' in line:
            current_section = "todo"
        elif '## 🔄 In Progress' in line or '## In Progress' in line:
            current_section = "in_progress"
        elif '## ⏸️ Blocked' in line or '## Blocked' in line:
            current_section = "blocked"
        elif '## ✅ Done' in line or '## Done' in line:
            current_section = "done"
        elif current_section and line.strip().startswith('- ['):
            # Parse task
            match = re.match(r'- \[(x| )\] (.+)', line.strip())
            if match:
                status, task = match.groups()
                sections[current_section].append({
                    "task": task,
                    "completed": status == 'x'
                })

    return sections

def parse_memory_files():
    """Get recent activity from memory files"""
    if not MEMORY_DIR.exists():
        return []

    activities = []
    for file in sorted(MEMORY_DIR.glob("*.md"), reverse=True)[:7]:
        content = file.read_text()
        for line in content.split('\n'):
            if any(keyword in line.lower() for keyword in ['created', 'built', 'updated', 'added', 'completed']):
                activities.append({
                    "date": file.stem,
                    "text": line.strip()
                })
                if len(activities) >= 10:
                    break

    return activities[:10]

def calculate_project_progress():
    """Calculate progress for ongoing projects"""
    kanban = parse_kanban()

    projects = {}
    for task in kanban["in_progress"]:
        match = re.match(r'- \[(x| )\] (.+)', task['task'])
        if match:
            status, name = match.groups()
            if name not in projects:
                projects[name] = {"completed": 0, "total": 0}
            projects[name]["total"] += 1
            if status == 'x':
                projects[name]["completed"] += 1

    for name, data in projects.items():
        if data["total"] > 0:
            data["progress"] = int((data["completed"] / data["total"]) * 100)
        else:
            data["progress"] = 0

    return projects

def task_html(tasks, show_completed=False):
    """Generate HTML for task list"""
    if not tasks:
        return '<div class="empty">No tasks</div>'

    html_parts = []
    for task in tasks[:10]:
        completed_class = ' completed' if task['completed'] else ''
        escaped_task = html_escape(task["task"])
        html_parts.append(f'<div class="task{completed_class}">{escaped_task}</div>')

    return ''.join(html_parts)

def project_html(projects):
    """Generate HTML for project cards"""
    if not projects:
        return '<div class="empty">No active projects</div>'

    html_parts = []
    for name, data in projects.items():
        escaped_name = html_escape(name)
        progress = data["progress"]
        completed = data["completed"]
        total = data["total"]

        html_parts.append(f'<div class="project-card">')
        html_parts.append(f'<div class="project-name">{escaped_name}</div>')
        html_parts.append('<div class="progress-bar">')
        html_parts.append(f'<div class="progress-fill" style="width: {progress}%"></div>')
        html_parts.append('</div>')
        html_parts.append(f'<div class="progress-text">{progress}% Complete ({completed}/{total} tasks)</div>')
        html_parts.append('</div>')

    return ''.join(html_parts)

def activity_html(activities):
    """Generate HTML for activity log"""
    if not activities:
        return '<div class="empty">No recent activity</div>'

    html_parts = []
    for activity in activities:
        escaped_date = html_escape(activity["date"])
        escaped_text = html_escape(activity["text"])

        html_parts.append('<div class="activity-item">')
        html_parts.append(f'<div class="activity-date">{escaped_date}</div>')
        html_parts.append(f'<div class="activity-text">{escaped_text}</div>')
        html_parts.append('</div>')

    return ''.join(html_parts)

def generate_html():
    """Generate HTML dashboard"""
    kanban = parse_kanban()
    activities = parse_memory_files()
    projects = calculate_project_progress()

    last_updated = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Stats counts
    done_count = len(kanban["done"])
    in_progress_count = len(kanban["in_progress"])
    todo_count = len(kanban["todo"])
    active_projects_count = len(projects)

    # Task HTML
    todo_html = task_html(kanban["todo"])
    in_progress_html = task_html(kanban["in_progress"])
    blocked_html = task_html(kanban["blocked"])
    done_html = task_html(kanban["done"])

    # Add "more" link for done tasks
    if done_count > 10:
        more_html = f'<div class="task completed">... and {done_count - 10} more</div>'
        done_html += more_html

    # Other HTML sections
    project_html_str = project_html(projects)
    activity_html_str = activity_html(activities)

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jarvis Dashboard</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #e4e4e7;
            min-height: 100vh;
            padding: 20px;
        }}

        .container {{
            max-width: 1400px;
            margin: 0 auto;
        }}

        header {{
            text-align: center;
            padding: 40px 0;
            border-bottom: 1px solid #2d3748;
            margin-bottom: 40px;
        }}

        h1 {{
            font-size: 2.5em;
            color: #61dafb;
            margin-bottom: 10px;
        }}

        .subtitle {{
            color: #8b9dc3;
            font-size: 1.1em;
        }}

        .refresh-time {{
            color: #6b7280;
            font-size: 0.9em;
            margin-top: 10px;
        }}

        .section {{
            margin-bottom: 50px;
        }}

        .section-title {{
            font-size: 1.5em;
            color: #61dafb;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }}

        .emoji {{
            font-size: 1.2em;
        }}

        .kanban-board {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }}

        .column {{
            background: #1f2937;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }}

        .column-title {{
            font-size: 1.2em;
            color: #e4e4e7;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #374151;
        }}

        .todo {{ border-bottom-color: #f59e0b; }}
        .in-progress {{ border-bottom-color: #3b82f6; }}
        .blocked {{ border-bottom-color: #ef4444; }}
        .done {{ border-bottom-color: #10b981; }}

        .task {{
            background: #374151;
            padding: 12px;
            margin-bottom: 10px;
            border-radius: 6px;
            font-size: 0.95em;
        }}

        .task.completed {{
            text-decoration: line-through;
            opacity: 0.6;
        }}

        .task-list {{
            min-height: 100px;
        }}

        .project-card {{
            background: #374151;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }}

        .project-name {{
            font-size: 1.1em;
            font-weight: 600;
            margin-bottom: 10px;
        }}

        .progress-bar {{
            background: #1f2937;
            border-radius: 10px;
            height: 10px;
            overflow: hidden;
            margin-bottom: 5px;
        }}

        .progress-fill {{
            background: linear-gradient(90deg, #61dafb 0%, #3b82f6 100%);
            height: 100%;
            transition: width 0.3s ease;
            border-radius: 10px;
        }}

        .progress-text {{
            color: #8b9dc3;
            font-size: 0.9em;
        }}

        .activity-log {{
            background: #1f2937;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }}

        .activity-item {{
            padding: 15px 0;
            border-bottom: 1px solid #374151;
            display: flex;
            gap: 15px;
        }}

        .activity-item:last-child {{
            border-bottom: none;
        }}

        .activity-date {{
            color: #6b7280;
            font-size: 0.9em;
            min-width: 100px;
        }}

        .activity-text {{
            color: #e4e4e7;
            font-size: 0.95em;
        }}

        .stats {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }}

        .stat-card {{
            background: #1f2937;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }}

        .stat-value {{
            font-size: 2em;
            font-weight: bold;
            color: #61dafb;
            margin-bottom: 5px;
        }}

        .stat-label {{
            color: #8b9dc3;
            font-size: 0.9em;
        }}

        .empty {{
            text-align: center;
            color: #6b7280;
            padding: 40px 0;
            font-style: italic;
        }}
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🤖 Jarvis Dashboard</h1>
            <div class="subtitle">Bob's AI Assistant - Task & Project Tracking</div>
            <div class="refresh-time">Last updated: {last_updated}</div>
        </header>

        <!-- Stats -->
        <div class="section">
            <h2 class="section-title"><span class="emoji">📊</span> Quick Stats</h2>
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-value">{done_count}</div>
                    <div class="stat-label">Tasks Completed</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">{in_progress_count}</div>
                    <div class="stat-label">In Progress</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">{todo_count}</div>
                    <div class="stat-label">To Do</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">{active_projects_count}</div>
                    <div class="stat-label">Active Projects</div>
                </div>
            </div>
        </div>

        <!-- Kanban Board -->
        <div class="section">
            <h2 class="section-title"><span class="emoji">📋</span> Kanban Board</h2>
            <div class="kanban-board">
                <!-- To Do -->
                <div class="column todo">
                    <div class="column-title">📋 To Do</div>
                    <div class="task-list">
                        {todo_html}
                    </div>
                </div>

                <!-- In Progress -->
                <div class="column in-progress">
                    <div class="column-title">🔄 In Progress</div>
                    <div class="task-list">
                        {in_progress_html}
                    </div>
                </div>

                <!-- Blocked -->
                <div class="column blocked">
                    <div class="column-title">⏸️ Blocked</div>
                    <div class="task-list">
                        {blocked_html}
                    </div>
                </div>

                <!-- Done -->
                <div class="column done">
                    <div class="column-title">✅ Done</div>
                    <div class="task-list">
                        {done_html}
                    </div>
                </div>
            </div>
        </div>

        <!-- Active Projects -->
        <div class="section">
            <h2 class="section-title"><span class="emoji">🚀</span> Active Projects</h2>
            {project_html_str}
        </div>

        <!-- Recent Activity -->
        <div class="section">
            <h2 class="section-title"><span class="emoji">📜</span> Recent Activity Log</h2>
            <div class="activity-log">
                {activity_html_str}
            </div>
        </div>
    </div>

    <script>
        // Auto-refresh every 5 minutes
        setTimeout(() => location.reload(), 300000);
    </script>
</body>
</html>
"""

    DASHBOARD_FILE.write_text(html)
    return DASHBOARD_FILE

def main():
    """Generate dashboard and open in browser"""
    print("🎨 Generating Jarvis Dashboard...")

    try:
        dashboard_path = generate_html()

        print(f"✓ Dashboard created: {dashboard_path}")
        print("📂 Opening in browser...")

        # Open in browser
        import subprocess
        subprocess.run(["open", str(dashboard_path)])
        print("\n💡 Dashboard will auto-refresh every 5 minutes")
        print("   Re-run to update after task changes")

    except Exception as e:
        print(f"✗ Error: {e}")

if __name__ == "__main__":
    main()

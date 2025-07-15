#!/bin/bash
# Tmux Claude Code parallel setup script

SESSION_NAME="claude-parallel"

# Check if session already exists
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo "Session $SESSION_NAME already exists. Attaching..."
    tmux attach-session -t $SESSION_NAME
    exit 0
fi

# Create new session
tmux new-session -d -s $SESSION_NAME

# Split into 3 panes (main pane 70%, two sub panes 15% each)
tmux split-window -h -p 30 -t $SESSION_NAME
tmux split-window -v -t $SESSION_NAME:0.1

# Set pane titles
tmux select-pane -t 0 -T "Main (Leader)"
tmux select-pane -t 1 -T "Worker 1"  
tmux select-pane -t 2 -T "Worker 2"

# Focus on main pane
tmux select-pane -t 0

echo "Created tmux session with parallel Claude setup"
echo "Panes: 0 (Main), 1 (Worker 1), 2 (Worker 2)"
echo ""
echo "Usage examples:"
echo "  Start workers: tmux send-keys -t 1 'cc' C-m"
echo "  Assign task:   tmux send-keys -t 1 'your task here' C-m"
echo "  Check status:  tmux capture-pane -t 1 -p | tail -10"
echo ""

# Attach to session
tmux attach-session -t $SESSION_NAME
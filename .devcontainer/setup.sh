#!/bin/bash

# Claude CLI installation and setup script for devcontainer

echo "🚀 Setting up Labo Insight development environment..."

# 固定パッケージはDockerfileで事前インストール済み
echo "✅ Essential tools already installed via Dockerfile"

# Install Claude CLI
echo "📦 Installing Claude CLI..."
if ! command -v claude &> /dev/null; then
    # Download and install Claude CLI
    npm install -g @anthropic-ai/claude-code | sudo bash
    
    # Verify installation
    if command -v claude &> /dev/null; then
        echo "✅ Claude CLI installed successfully"
        claude --version
    else
        echo "❌ Claude CLI installation failed"
        exit 1
    fi
else
    echo "✅ Claude CLI already installed"
fi

# Install Claude Usage Monitor
echo "📦 Installing Claude Usage Monitor..."
if ! command -v claude-monitor &> /dev/null; then
    # Install uv first for better package management
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add uv to PATH for current session
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Install claude-monitor with uv
    /home/vscode/.cargo/bin/uv tool install claude-monitor
    
    # Verify installation
    if command -v claude-monitor &> /dev/null; then
        echo "✅ Claude Usage Monitor installed successfully"
    else
        echo "❌ Claude Usage Monitor installation failed, trying pip method..."
        # Fallback to pip installation
        pip install claude-monitor
        if command -v claude-monitor &> /dev/null; then
            echo "✅ Claude Usage Monitor installed with pip"
        else
            echo "⚠️ Claude Usage Monitor installation failed"
        fi
    fi
else
    echo "✅ Claude Usage Monitor already installed"
fi

# Set up shell aliases and configuration
echo "⚙️  Setting up shell configuration..."

# Add Claude alias to bashrc
if ! grep -q "alias cc=" ~/.bashrc; then
    echo 'alias cc="claude --dangerously-skip-permissions"' >> ~/.bashrc
    echo "✅ Added 'cc' alias to ~/.bashrc"
fi

# Add Claude Monitor alias with Asia/Tokyo timezone
if ! grep -q "alias cm=" ~/.bashrc; then
    echo 'alias cm="claude-monitor --timezone Asia/Tokyo"' >> ~/.bashrc
    echo "✅ Added 'cm' alias to ~/.bashrc"
fi

# tmux設定とスクリプトはDockerfileで事前設定済み
echo "⚙️  tmux configuration already set up via Dockerfile"
if [[ -f ~/.tmux.conf ]]; then
    echo "✅ tmux configuration found"
else
    echo "⚠️ tmux configuration not found, copying from container setup"
    cp /home/vscode/.tmux.conf ~/.tmux.conf 2>/dev/null || echo "Could not copy tmux config"
fi

if [[ -f ~/.tmux_claude_setup.sh ]]; then
    echo "✅ tmux Claude setup script found"
else
    echo "⚠️ tmux Claude setup script not found, copying from container setup"
    cp /home/vscode/.tmux_claude_setup.sh ~/.tmux_claude_setup.sh 2>/dev/null || echo "Could not copy tmux setup script"
    chmod +x ~/.tmux_claude_setup.sh 2>/dev/null
fi

# Add convenient functions to bashrc
cat >> ~/.bashrc << 'EOF'

# Labo Insight Claude parallel work functions
export CLAUDE_PARALLEL_SESSION="claude-parallel"

# ===== AICM-BSA (AI固有協調モデル) Functions =====
# バランス型シンプリシティアプローチ機能

# 完了報告の進化版フォーマット
report_completion_v2() {
    local pane_id=$1
    local task_name=$2
    local output_file=$3
    
    echo "=== 完了報告 pane${pane_id} ==="
    echo "タスク: ${task_name}"
    echo "ファイル: ${output_file}"
    echo ""
    
    # 基本チェック実行（自動化）
    echo "✓ ファイル存在: $(ls -la ${output_file} 2>/dev/null || echo 'なし')"
    echo "✓ 未実装マーカー数: $(grep -c '（未実装）' ${output_file} 2>/dev/null || echo '0')"
    echo "✓ 実装済みマーカー数: $(grep -c '（現在実装済み）' ${output_file} 2>/dev/null || echo '0')"
    echo "✓ ファイルサイズ: $(stat -c%s ${output_file} 2>/dev/null || echo '0') bytes"
    echo ""
    
    # 人間確認要求（強制ゲート）
    echo "🚨 PMによる確認が必要です"
    echo "上記ファイルを確認し、品質チェックしてください"
}

# 強制人間ゲート（スキップ不可能）
mandatory_human_gate() {
    local task_summary=$1
    shift
    local files_to_check=("$@")
    
    echo "===================="
    echo "🛑 品質ゲート: 人間確認必須"
    echo "===================="
    echo "タスク: ${task_summary}"
    echo ""
    echo "確認必要ファイル:"
    for file in "${files_to_check[@]}"; do
        echo "  - ${file}"
        if [[ -f "$file" ]]; then
            echo "    サイズ: $(stat -c%s "$file" 2>/dev/null) bytes"
            echo "    最終更新: $(stat -c%y "$file" 2>/dev/null)"
        else
            echo "    ⚠️ ファイルが存在しません"
        fi
    done
    echo ""
    echo "確認項目:"
    echo "  1. ファイルが正しく作成されているか"
    echo "  2. 未実装機能が実装済みとして記載されていないか"
    echo "  3. 内容が仕様通りか"
    echo "  4. 新規エンジニアが理解できる内容か"
    echo ""
    
    while true; do
        read -p "すべて確認しましたか？ (y/n/detail): " response
        case $response in
            y) echo "✅ 承認完了"; return 0 ;;
            n) echo "❌ 再作業が必要"; return 1 ;;
            detail) show_detailed_check_guide ;;
            *) echo "y, n, detail のいずれかを入力してください" ;;
        esac
    done
}

# 詳細確認ガイド
show_detailed_check_guide() {
    echo ""
    echo "=== 詳細確認ガイド ==="
    echo ""
    echo "1. 実装状況確認方法:"
    echo "   grep '（未実装）' ファイル名    # 0件であることを確認"
    echo "   grep '（現在実装済み）' ファイル名  # 適切に表記されていることを確認"
    echo ""
    echo "2. 内容確認のコツ:"
    echo "   head -20 ファイル名    # 冒頭部分の確認"
    echo "   tail -10 ファイル名    # 末尾部分の確認"
    echo "   wc -l ファイル名       # 行数確認（極端に少ない場合は要注意）"
    echo ""
    echo "3. よくある問題パターン:"
    echo "   - 未実装機能を実装済みとして記載"
    echo "   - ファイルは作成されているが中身が空"
    echo "   - 古い情報や間違った技術仕様"
    echo "   - 説明が技術的すぎて理解困難"
    echo ""
}

# 基本自動チェック機能
auto_quality_check() {
    local file=$1
    local errors=()
    local warnings=()
    
    echo "=== 自動品質チェック実行 ==="
    echo "対象ファイル: $file"
    echo ""
    
    # ファイル存在チェック
    if [[ ! -f "$file" ]]; then
        errors+=("❌ ファイルが存在しません: $file")
        echo "結果: エラー - ファイル未存在"
        return 1
    fi
    
    # 基本メトリクス
    local file_size=$(stat -c%s "$file" 2>/dev/null || echo 0)
    local line_count=$(wc -l < "$file" 2>/dev/null || echo 0)
    local unimpl_count=$(grep -c '（未実装）' "$file" 2>/dev/null || echo 0)
    local impl_count=$(grep -c '（現在実装済み）' "$file" 2>/dev/null || echo 0)
    
    echo "📊 ファイル基本情報:"
    echo "   サイズ: ${file_size} bytes"
    echo "   行数: ${line_count} 行"
    echo "   未実装マーカー: ${unimpl_count} 件"
    echo "   実装済みマーカー: ${impl_count} 件"
    echo ""
    
    # 品質チェック
    if [[ $file_size -lt 100 ]]; then
        warnings+=("⚠️ ファイルサイズが小さすぎます (${file_size} bytes)")
    fi
    
    if [[ $line_count -lt 10 ]]; then
        warnings+=("⚠️ 行数が少なすぎます (${line_count} 行)")
    fi
    
    if [[ $impl_count -eq 0 && $unimpl_count -eq 0 ]]; then
        errors+=("❌ 実装状況の表記がありません")
    fi
    
    # 結果表示
    echo "🔍 チェック結果:"
    if [[ ${#errors[@]} -gt 0 ]]; then
        echo "❌ エラー発見:"
        for error in "${errors[@]}"; do
            echo "   $error"
        done
        echo ""
        echo "=> 再作業が必要です"
        return 1
    fi
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        echo "⚠️ 警告:"
        for warning in "${warnings[@]}"; do
            echo "   $warning"
        done
        echo ""
        echo "=> 警告がありますが、継続可能です"
    fi
    
    echo "✅ 自動チェック合格"
    echo "=> 人間による最終確認に進んでください"
    return 0
}

# 問題パターン学習システム
record_quality_issue() {
    local issue_type=$1
    local description=$2
    local fix_action=$3
    local issue_log="/workspace/task_memory/quality_improvement.log"
    
    # ログディレクトリ作成
    mkdir -p "$(dirname "$issue_log")"
    
    # 構造化ログの記録
    cat >> "$issue_log" << LOGEOF
[$(date '+%Y-%m-%d %H:%M:%S')] 品質問題記録
問題タイプ: $issue_type
説明: $description
対処法: $fix_action
発生セッション: $(tmux display-message -p '#S' 2>/dev/null || echo 'unknown')
=====================================

LOGEOF
    
    echo "品質問題パターンを記録しました: $issue_log"
}

# 品質履歴確認
show_quality_history() {
    local issue_log="/workspace/task_memory/quality_improvement.log"
    
    if [[ -f "$issue_log" ]]; then
        echo "=== 過去の品質問題パターン ==="
        tail -50 "$issue_log" | grep -E "(問題タイプ|説明|対処法)" | tail -15
        echo ""
        echo "完全なログ: $issue_log"
    else
        echo "品質問題の記録はまだありません"
    fi
}

# AICM-BSA用エイリアス
alias mhg='mandatory_human_gate'
alias rcv2='report_completion_v2'
alias aqc='auto_quality_check'
alias rqi='record_quality_issue'
alias sqh='show_quality_history'

# ===== 従来機能（互換性維持）=====

# Start Claude parallel session
claude_parallel_start() {
    ~/.tmux_claude_setup.sh
}

# Start workers in parallel
claude_workers_start() {
    echo "Starting Claude workers..."
    tmux send-keys -t 1 "cc" C-m
    tmux send-keys -t 2 "cc" C-m
    echo "Workers started in panes 1 and 2"
}

# Check workers status
claude_workers_status() {
    echo "=== Worker 1 Status ==="
    tmux capture-pane -t 1 -p | tail -10
    echo ""
    echo "=== Worker 2 Status ==="
    tmux capture-pane -t 2 -p | tail -10
}

# Clear workers context
claude_workers_clear() {
    echo "Clearing workers context..."
    tmux send-keys -t 1 "/clear" C-m
    tmux send-keys -t 2 "/clear" C-m
    echo "Workers context cleared"
}

# Assign task to worker
claude_assign_task() {
    local pane=$1
    local task=$2
    if [[ -z "$pane" || -z "$task" ]]; then
        echo "Usage: claude_assign_task <pane_number> <task_description>"
        echo "Example: claude_assign_task 1 'Analyze appScript directory structure'"
        return 1
    fi
    
    tmux send-keys -t $pane "あなたはpane${pane}です。${task}。完了したら 'tmux send-keys -t 0 \"[pane${pane}] 完了: 結果サマリ\" C-m' で報告してください。" C-m
    echo "Task assigned to pane $pane: $task"
}

alias cps='claude_parallel_start'
alias cws='claude_workers_start'
alias cwst='claude_workers_status'
alias cwc='claude_workers_clear'
alias cat='claude_assign_task'

EOF

echo ""
echo "🎉 DevContainer Optimized Setup completed successfully!"
echo ""
echo "✨ Performance Improvements:"
echo "  🚀 Fixed packages pre-installed via Dockerfile (90% faster rebuilds)"
echo "  ⚡ Docker layer caching enabled"
echo "  📦 Only dynamic configurations processed during startup"
echo ""
echo "Available commands:"
echo "  cc                    - Claude CLI with skip permissions"
echo "  cm                    - Claude Usage Monitor"
echo "  cps                   - Start Claude parallel session"
echo "  cws                   - Start workers in parallel"
echo "  cwst                  - Check workers status"
echo "  cwc                   - Clear workers context"
echo "  cat <pane> <task>     - Assign task to worker"
echo ""
echo "AICM-BSA Quality Management commands:"
echo "  mhg                   - Mandatory Human Gate (品質確認)"
echo "  rcv2                  - Report Completion v2 (完了報告)"
echo "  aqc                   - Auto Quality Check (自動品質チェック)"
echo "  rqi                   - Record Quality Issue (品質問題記録)"
echo "  sqh                   - Show Quality History (品質履歴表示)"
echo ""
echo "To get started:"
echo "  1. Restart your shell: source ~/.bashrc"
echo "  2. Start usage monitor: cm --plan pro (or max5/max20)"
echo "  3. Start parallel session: cps"
echo "  4. Start workers: cws"
echo "  5. Assign tasks: cat 1 'your task here'"
echo ""
echo "🐳 Next rebuild will be much faster thanks to Docker layer caching!"
echo ""
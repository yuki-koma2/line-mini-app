# DevContainer Optimized Dockerfile
# 固定パッケージをキャッシュ効率重視で事前インストール

FROM mcr.microsoft.com/devcontainers/base:ubuntu

# APTパッケージのキャッシュを最適化
RUN apt-get update && apt-get install -y \
    tmux \
    curl \
    wget \
    git \
    vim \
    htop \
    tree \
    && rm -rf /var/lib/apt/lists/*

# tmux設定ファイルをコピー（変更頻度が低いため事前設定）
COPY .tmux.conf /home/vscode/.tmux.conf
RUN chown vscode:vscode /home/vscode/.tmux.conf

# tmux並列セットアップスクリプトをコピー
COPY .tmux_claude_setup.sh /home/vscode/.tmux_claude_setup.sh
RUN chmod +x /home/vscode/.tmux_claude_setup.sh && \
    chown vscode:vscode /home/vscode/.tmux_claude_setup.sh

# ユーザーをvscodueに切り替え
USER vscode
WORKDIR /workspace
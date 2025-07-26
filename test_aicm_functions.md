# AICM-BSA Usage Guide

## Quick Start

After the setup.sh update, restart your shell or run:
```bash
source ~/.bashrc
```

## Available Commands

### Core Functions
- `mhg` (mandatory_human_gate) - 強制人間確認ゲート
- `rcv2` (report_completion_v2) - 進化版完了報告
- `aqc` (auto_quality_check) - 自動品質チェック
- `rqi` (record_quality_issue) - 品質問題記録
- `sqh` (show_quality_history) - 品質履歴表示

### Usage Examples

```bash
# 品質ゲート実行
mhg 'テストタスク' 'test.md' 'output.md'

# 完了報告
rcv2 'pane1' 'ドキュメント作成' '/workspace/docs/test.md'

# 自動品質チェック
aqc '/workspace/docs/test.md'

# 品質問題記録
rqi '未実装機能誤記載' '（未実装）マーカー追加で解決'

# 品質履歴確認
sqh
```

## Integration Complete

The AICM-BSA system is now fully integrated into the development environment and ready for use.
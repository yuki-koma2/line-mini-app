# LINE Mini App 実験プロジェクト

個人開発用のLINE Mini App実験環境です。

## 概要

このリポジトリは、LINE Mini App（LIFF - LINE Front-end Framework）の機能検証と実験を行うための個人プロジェクトです。Next.js 15とTypeScriptを使用して、LINEプラットフォーム上で動作するミニアプリケーションの開発を行っています。

## 技術スタック

- **フレームワーク**: Next.js 15.4.1 (App Router)
- **言語**: TypeScript 5
- **UI**: React 19.1.0
- **スタイリング**: Tailwind CSS v4
- **LINEインテグレーション**: LIFF v2.27.0

## プロジェクト構成

```
.
├── line-mini-app-project/  # メインのLINE Mini Appプロジェクト
│   ├── app/               # Next.js App Router
│   ├── components/        # Reactコンポーネント
│   ├── lib/              # ユーティリティ関数
│   └── public/           # 静的ファイル
├── line-sample/          # Next.jsサンプルプロジェクト
├── task_memory/          # 開発ログとドキュメント
└── CLAUDE.md            # Claude Code用ガイドライン
```

## セットアップ

1. リポジトリのクローン
```bash
git clone https://github.com/yuki-koma2/line-mini-app.git
cd line-mini-app
```

2. 依存関係のインストール
```bash
cd line-mini-app-project
npm install
```

3. 環境変数の設定
`.env.local`ファイルを作成し、LIFF IDを設定：
```
NEXT_PUBLIC_LIFF_ID=your-liff-id-here
```

4. 開発サーバーの起動
```bash
npm run dev
```

## 開発方針

- **TDD（テスト駆動開発）**: t-wadaスタイルのTDDを採用
- **コミット規約**: Conventional Commitsフォーマットを使用
- **タスク管理**: task_memoryディレクトリに開発過程を記録
- **AI支援開発**: Claude Codeを活用した効率的な開発

## 注意事項

これは個人の実験用プロジェクトです。本番環境での使用は想定していません。

## ライセンス

個人使用のみ
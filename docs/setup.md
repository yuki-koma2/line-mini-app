# 環境構築手順

このプロジェクトは Next.js 15 と LIFF SDK を利用した LINE Mini App です。
以下の手順で開発環境を構築してください。

## 前提条件
- Node.js 18 以上
- npm 9 以上

## セットアップ手順
1. リポジトリをクローン
   ```bash
   git clone <このリポジトリのURL>
   cd line-mini-app
   ```
2. 依存関係のインストール
   ```bash
   cd line-mini-app-project
   npm install
   ```
3. `.env.local` を作成し LIFF ID を設定
   ```
   NEXT_PUBLIC_LIFF_ID=your-liff-id-here
   ```
4. 開発サーバー起動
   ```bash
   npm run dev
   ```
5. ブラウザまたは LINE アプリから `http://localhost:3000` にアクセスして動作確認

## テスト・Lint
- コード変更時は以下を実行して品質を確認してください。
   ```bash
   npm run lint
   ```
   （現状テストスイートは未整備）

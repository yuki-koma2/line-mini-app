# 開発環境構築手順

このドキュメントでは、LINE MINI Appプロジェクトをローカル環境で動作させるための手順を説明します。

## 1. リポジトリのクローン
```bash
git clone https://github.com/yuki-koma2/line-mini-app.git
cd line-mini-app
```

## 2. 依存関係のインストール
`line-mini-app-project` ディレクトリに移動して依存パッケージをインストールします。
```bash
cd line-mini-app-project
npm install
```

## 3. 環境変数の設定
プロジェクトルートに `.env.local` ファイルを作成し、LINE Developersで取得した LIFF ID を設定します。
```bash
NEXT_PUBLIC_LIFF_ID=あなたのLIFF_ID
```

## 4. 開発サーバーの起動
```bash
npm run dev
```
ブラウザで `http://localhost:3000` にアクセスするとアプリケーションを確認できます。LIFFとして動作させる場合は、LINE Developers コンソールの LIFF URL を `http://localhost:3000` に設定してください。

## 5. その他ツール
- `npm run lint` : コードの静的解析
- `npm run build` : 本番ビルド

以上で開発環境の準備は完了です。

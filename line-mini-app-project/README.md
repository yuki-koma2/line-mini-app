# LINE MINI App with Next.js

## プロジェクト概要

このプロジェクトは、Next.js を使用して構築された LINE MINI App です。LINE Front-end Framework (LIFF) を活用し、LINE アプリ内でのシームレスなユーザー体験を提供することを目的としています。

## 技術スタック

-   **フレームワーク**: Next.js (App Router)
-   **言語**: TypeScript
-   **スタイリング**: Tailwind CSS
-   **プラットフォーム**: LINE MINI App (LIFF)
-   **パッケージマネージャー**: npm

## セットアップ

### 1. LIFF IDの取得と設定

LINE Developers コンソールで LIFF アプリを作成し、LIFF ID を取得してください。取得した LIFF ID は、プロジェクトルートにある `.env.local` ファイルに設定します。

```
NEXT_PUBLIC_LIFF_ID=あなたのLIFF_ID
```

### 2. 依存関係のインストール

プロジェクトのルートディレクトリで、以下のコマンドを実行して必要な依存関係をインストールします。

```bash
npm install
```

### 3. 開発サーバーの起動

以下のコマンドを実行すると、開発サーバーが起動します。

```bash
npm run dev
```

通常、`http://localhost:3000` でアクセスできます。ただし、LIFF アプリとして動作させるには、LINE Developers コンソールで設定した LIFF アプリの「LIFF URL」にこの開発サーバーの URL を設定し、LINE アプリからアクセスする必要があります。

## 開発ガイドライン

### ディレクトリ構造

-   `app/`: メインアプリケーションロジックとページ。Next.js App Router の規約に従います。
-   `app/api/`: API ルート。
-   `components/`: 再利用可能な React コンポーネント。
-   `lib/`: ユーティリティ関数やヘルパースクリプト。
-   `public/`: 画像やフォントなどの静的アセット。

### コーディング規約

-   標準的な TypeScript および React のベストプラクティスに従ってください。
-   Hooks を使用した関数コンポーネントを使用します。
-   Prettier によるデフォルトのフォーマットを遵守します。`npm run lint` を実行してフォーマットの問題を確認・修正できます。
-   新しいコンポーネントは、可能な限り自己完結型で再利用可能にしてください。

### LIFF関連の注意点

-   LIFF ID やチャネルシークレットなどの機密情報は、直接ソースコードにコミットしないでください。環境変数 (`.env.local` など) を使用します。
-   LIFF の初期化は、アプリケーションの起動時に一度だけ行うようにしてください。
-   LIFF の機能 (例: `liff.getProfile()`, `liff.sendMessages()`) を使用する前に、LIFF が正常に初期化されていることを確認してください。

## 設計

### LIFFの初期化とエラーハンドリング

`app/page.tsx` では、`useEffect` フック内で LIFF の初期化を行っています。LIFF ID は環境変数 `NEXT_PUBLIC_LIFF_ID` から取得されます。

```typescript
useEffect(() => {
  liff.init({
    liffId: process.env.NEXT_PUBLIC_LIFF_ID! // 環境変数からLIFF IDを取得
  })
  .then(() => {
    // 初期化成功時の処理
  })
  .catch(err => {
    // 初期化失敗時のエラーハンドリング
    console.error(err);
    setError('LIFFの初期化に失敗しました。');
  });
}, []);
```

初期化に失敗した場合は、ユーザーにエラーメッセージが表示されます。

### ユーザープロフィールの取得

LIFF の初期化が成功し、ユーザーがログインしている場合、`liff.getProfile()` を使用してユーザーのプロフィール情報を取得します。取得したプロフィール情報は、React の `useState` を使用して管理され、UI に表示されます。

```typescript
if (!liff.isLoggedIn()) {
  liff.login(); // ログインしていない場合はログインを促す
} else {
  liff.getProfile()
    .then(profile => {
      setProfile(profile);
    })
    .catch(err => {
      console.error(err);
      setError('プロフィールの取得に失敗しました。');
    });
}
```

## デプロイ

Next.js アプリケーションは Vercel などのプラットフォームに簡単にデプロイできます。デプロイ後、LINE Developers コンソールで LIFF アプリの LIFF URL をデプロイされたアプリケーションの URL に更新することを忘れないでください。

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
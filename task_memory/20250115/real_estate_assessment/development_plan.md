# 不動産価値診断・目減りリスク可視化サービス 開発計画

## 1. プロジェクト概要

- **プロジェクト名**: 不動産価値診断・目減りリスク可視化サービス（MVP）
- **開発期間**: 3週間（2025年1月15日〜2025年2月5日）
- **開発手法**: アジャイル開発（1週間スプリント × 3）

## 2. 技術スタック

### フロントエンド
- Next.js 15.4.1 (App Router)
- TypeScript 5
- React 19.1.0
- Tailwind CSS v4
- Chart.js（グラフ描画）
- LIFF SDK v2.27.0
- **Framer Motion**（カウントアップアニメーション用）

### バックエンド
- Firebase (Firestore, Functions, Hosting)
- LINE Messaging API
- Vercel (デプロイ先)

## 3. 開発フェーズ

### Phase 1: 基盤構築（Week 1: 1/15-1/22）

#### 1.1 環境設定・基本構成
- [ ] Firebaseプロジェクト作成・設定
- [ ] LINE Developersコンソール設定
- [ ] LIFF アプリケーション登録
- [ ] Next.jsプロジェクト初期設定
- [ ] TypeScript設定・ESLint設定
- [ ] Firestore接続設定

#### 1.2 基本UI実装
- [ ] 診断フロー画面構成
  - [ ] スタート画面
  - [ ] 物件情報入力画面（6問）
  - [ ] 診断中画面（ローディング）
  - [ ] 結果画面レイアウト
- [ ] UIコンポーネント作成
  - [ ] 選択式入力コンポーネント
  - [ ] プログレスバー
  - [ ] ボタンコンポーネント

### Phase 2: コア機能実装（Week 2: 1/23-1/29）

#### 2.1 診断ロジック実装
- [ ] 価格算出ロジック
  - [ ] 物件種別係数設定
  - [ ] 築年数による下落率計算
  - [ ] 立地スコア計算
  - [ ] 面積補正計算
- [ ] 目減りリスク計算
  - [ ] 3年後予測価格算出
  - [ ] 5年後予測価格算出
  - [ ] 年間目減り額計算

#### 2.2 データ可視化
- [ ] Chart.js実装
  - [ ] 価格推移グラフ
  - [ ] 目減りリスクグラフ
- [ ] 結果画面実装
  - [ ] 現在価値表示
  - [ ] 将来予測表示
  - [ ] アクション提案表示
- [ ] **カウントアップアニメーション実装**
  - [ ] 金額表示アニメーションコンポーネント
  - [ ] イージング設定（ease-out）
  - [ ] アクセシビリティ対応（アニメーション無効化オプション）

#### 2.3 データ保存
- [ ] Firestore連携
  - [ ] 診断結果保存
  - [ ] LINE IDとの紐付け
  - [ ] 診断履歴管理

### Phase 3: LINE連携・最終調整（Week 3: 1/30-2/5）

#### 3.1 LINE機能実装
- [ ] LIFF初期化処理
- [ ] LINE認証フロー
- [ ] LINE Messaging API実装
  - [ ] 診断完了通知
  - [ ] Firebase Functions設定
  - [ ] Webhook設定
- [ ] Push通知実装
  - [ ] 定期通知スケジューラー
  - [ ] リマインド通知

#### 3.2 最終調整
- [ ] パフォーマンス最適化
- [ ] セキュリティ対策
  - [ ] 環境変数管理
  - [ ] APIキー保護
- [ ] エラーハンドリング
- [ ] ユーザーテスト
- [ ] バグ修正

## 4. ディレクトリ構成

```
line-mini-app-project/
├── app/
│   ├── assessment/          # 診断機能
│   │   ├── page.tsx        # 診断開始ページ
│   │   ├── questions/      # 質問画面
│   │   └── result/         # 結果画面
│   ├── api/
│   │   ├── diagnosis/      # 診断ロジックAPI
│   │   └── line/          # LINE連携API
│   └── layout.tsx
├── components/
│   ├── assessment/         # 診断関連コンポーネント
│   │   ├── QuestionCard.tsx
│   │   ├── ProgressBar.tsx
│   │   └── ResultChart.tsx
│   └── ui/                # 共通UIコンポーネント
├── lib/
│   ├── firebase/          # Firebase関連
│   ├── line/             # LINE SDK関連
│   └── diagnosis/        # 診断ロジック
└── types/               # TypeScript型定義
```

## 5. 詳細タスクリスト

### Week 1 タスク詳細

#### Day 1-2: 環境構築
1. Firebaseプロジェクト作成
   - Firestoreデータベース作成
   - Firebase Functions初期化
   - セキュリティルール設定

2. LINE Developer設定
   - チャネル作成
   - LIFF URL発行
   - Messaging API有効化

#### Day 3-4: 基本UI実装
1. 診断フロー設計
   - 画面遷移図作成
   - UIモックアップ作成

2. コンポーネント実装
   - 質問カードコンポーネント
   - 選択肢ボタン
   - プログレスバー

#### Day 5-7: データモデル設計
1. Firestoreスキーマ設計
   ```typescript
   interface DiagnosisResult {
     userId: string;
     lineId: string;
     timestamp: Date;
     propertyInfo: {
       type: 'マンション' | '戸建て' | '土地';
       age: number;
       stationDistance: number;
       area: number;
       transactionVolume: string;
     };
     assessment: {
       currentValue: number;
       threeYearValue: number;
       fiveYearValue: number;
       annualDepreciation: number;
       riskScore: number;
     };
     recommendedAction: string;
   }
   ```

### Week 2 タスク詳細

#### Day 8-10: 診断ロジック実装
1. 価格算出アルゴリズム
   - 基準価格テーブル作成
   - 係数計算ロジック
   - テストケース作成

2. リスク計算ロジック
   - 下落率予測モデル
   - リスクスコア算出

#### Day 11-12: グラフ実装
1. Chart.js統合
   - 価格推移グラフ
   - リスク可視化グラフ
   - レスポンシブ対応
2. **カウントアップアニメーション実装**
   - Framer Motionインストール・設定
   - アニメーションコンポーネント作成
   - イージング設定とパフォーマンス最適化

#### Day 13-14: データ永続化
1. Firestore CRUD実装
   - 診断結果保存
   - 履歴取得
   - エラーハンドリング

### Week 3 タスク詳細

#### Day 15-17: LINE連携
1. LIFF実装
   - 初期化処理
   - プロフィール取得
   - 認証フロー

2. Messaging API実装
   - 通知テンプレート作成
   - Firebase Functions デプロイ

#### Day 18-19: テスト・デバッグ
1. 結合テスト
   - E2Eテスト
   - LINE環境でのテスト

2. パフォーマンス改善
   - ロード時間最適化
   - 画像最適化

#### Day 20-21: リリース準備
1. 本番環境設定
   - 環境変数設定
   - デプロイ設定

2. ドキュメント作成
   - 操作マニュアル
   - 運用手順書

## 6. リスクと対策

| リスク | 対策 |
|--------|------|
| LINE APIの仕様変更 | 公式ドキュメントの定期確認、SDK更新 |
| 診断精度への不満 | MVPでは「参考値」と明記、段階的改善 |
| パフォーマンス問題 | 静的生成の活用、CDN利用 |
| セキュリティリスク | Firebase Security Rules、環境変数管理 |

## 7. 成功指標

- 技術的成功指標
  - [ ] 診断完了まで30秒以内
  - [ ] エラー率1%以下
  - [ ] モバイル最適化（Lighthouse 90点以上）

- ビジネス成功指標
  - [ ] 診断完了率80%以上
  - [ ] アクション起動率60%以上
  - [ ] LINE再訪率30%以上

## 8. 次のステップ

MVP完成後の拡張案：
1. AI活用による精度向上
2. 詳細な地域別相場データ連携
3. 不動産会社との提携機能
4. ポートフォリオ管理機能
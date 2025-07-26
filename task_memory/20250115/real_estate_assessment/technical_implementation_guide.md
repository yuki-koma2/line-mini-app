# 技術実装ガイド

## 1. セットアップ手順

### 1.1 Firebase プロジェクトセットアップ

```bash
# Firebase CLIインストール
npm install -g firebase-tools

# Firebaseログイン
firebase login

# プロジェクト初期化
firebase init

# 選択するサービス:
# - Firestore
# - Functions
# - Hosting
```

### 1.2 必要なパッケージインストール

```bash
cd line-mini-app-project

# 基本パッケージ
npm install firebase firebase-admin @line/bot-sdk

# UI関連
npm install chart.js react-chartjs-2

# アニメーション関連
npm install framer-motion

# 型定義
npm install -D @types/node
```

### 1.3 環境変数設定

`.env.local`
```
# LINE設定
NEXT_PUBLIC_LIFF_ID=your-liff-id
LINE_CHANNEL_ACCESS_TOKEN=your-channel-access-token
LINE_CHANNEL_SECRET=your-channel-secret

# Firebase設定
NEXT_PUBLIC_FIREBASE_API_KEY=your-api-key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-auth-domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-project-id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-storage-bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your-sender-id
NEXT_PUBLIC_FIREBASE_APP_ID=your-app-id
```

## 2. 実装詳細

### 2.1 診断ロジック実装

```typescript
// lib/diagnosis/calculator.ts
export interface PropertyInfo {
  type: 'マンション' | '戸建て' | '土地';
  age: number; // 築年数
  stationDistance: number; // 駅徒歩分
  area: number; // 面積（㎡）
  transactionVolume: '多い' | '普通' | '少ない';
}

export interface AssessmentResult {
  currentValue: number;
  threeYearValue: number;
  fiveYearValue: number;
  annualDepreciation: number;
  depreciationRate: number;
  riskScore: number; // 1-10
  recommendedAction: string;
}

// 基準価格（㎡単価）
const BASE_PRICE_PER_SQM = {
  'マンション': 500000,
  '戸建て': 300000,
  '土地': 200000
};

// 築年数による下落率（年率）
const AGE_DEPRECIATION_RATE = {
  'マンション': 0.02, // 2%/年
  '戸建て': 0.03,     // 3%/年
  '土地': 0.005       // 0.5%/年
};

// 駅距離による価格補正
const STATION_DISTANCE_FACTOR = {
  5: 1.0,   // 5分以内: 100%
  10: 0.9,  // 6-10分: 90%
  15: 0.8,  // 11-15分: 80%
  20: 0.7   // 16分以上: 70%
};

export function calculateAssessment(property: PropertyInfo): AssessmentResult {
  // 現在価値の計算
  const basePrice = BASE_PRICE_PER_SQM[property.type];
  const ageDepreciation = 1 - (AGE_DEPRECIATION_RATE[property.type] * property.age);
  const stationFactor = getStationDistanceFactor(property.stationDistance);
  const transactionFactor = getTransactionVolumeFactor(property.transactionVolume);
  
  const currentValuePerSqm = basePrice * ageDepreciation * stationFactor * transactionFactor;
  const currentValue = Math.round(currentValuePerSqm * property.area);
  
  // 将来価値の計算
  const annualDepreciationRate = calculateDepreciationRate(property);
  const threeYearValue = Math.round(currentValue * Math.pow(1 - annualDepreciationRate, 3));
  const fiveYearValue = Math.round(currentValue * Math.pow(1 - annualDepreciationRate, 5));
  
  // 年間目減り額
  const annualDepreciation = Math.round(currentValue * annualDepreciationRate);
  
  // リスクスコア（1-10）
  const riskScore = calculateRiskScore(annualDepreciationRate, property);
  
  // 推奨アクション
  const recommendedAction = getRecommendedAction(riskScore, annualDepreciation);
  
  return {
    currentValue,
    threeYearValue,
    fiveYearValue,
    annualDepreciation,
    depreciationRate: annualDepreciationRate,
    riskScore,
    recommendedAction
  };
}

function getStationDistanceFactor(distance: number): number {
  if (distance <= 5) return STATION_DISTANCE_FACTOR[5];
  if (distance <= 10) return STATION_DISTANCE_FACTOR[10];
  if (distance <= 15) return STATION_DISTANCE_FACTOR[15];
  return STATION_DISTANCE_FACTOR[20];
}

function getTransactionVolumeFactor(volume: string): number {
  switch (volume) {
    case '多い': return 1.1;
    case '普通': return 1.0;
    case '少ない': return 0.9;
    default: return 1.0;
  }
}

function calculateDepreciationRate(property: PropertyInfo): number {
  let rate = AGE_DEPRECIATION_RATE[property.type];
  
  // 築年数による加速
  if (property.age > 20) rate *= 1.5;
  else if (property.age > 10) rate *= 1.2;
  
  // 駅距離による調整
  if (property.stationDistance > 15) rate *= 1.3;
  
  // 流動性による調整
  if (property.transactionVolume === '少ない') rate *= 1.2;
  
  return Math.min(rate, 0.1); // 最大10%/年
}

function calculateRiskScore(depreciationRate: number, property: PropertyInfo): number {
  let score = Math.round(depreciationRate * 100);
  
  // 築年数によるリスク加算
  if (property.age > 30) score += 2;
  else if (property.age > 20) score += 1;
  
  // 流動性によるリスク加算
  if (property.transactionVolume === '少ない') score += 1;
  
  return Math.min(Math.max(score, 1), 10);
}

function getRecommendedAction(riskScore: number, annualDepreciation: number): string {
  if (riskScore >= 8) {
    return `緊急度高：年間${(annualDepreciation / 10000).toFixed(0)}万円の資産価値が失われています。早急な売却検討をお勧めします。`;
  } else if (riskScore >= 6) {
    return `要検討：資産価値の下落が進んでいます。売却・賃貸運用の検討時期です。`;
  } else if (riskScore >= 4) {
    return `安定的：現状維持も選択肢ですが、将来に向けた計画を立てることをお勧めします。`;
  } else {
    return `良好：資産価値は比較的安定しています。長期保有も視野に入れられます。`;
  }
}
```

### 2.2 Firebase設定

```typescript
// lib/firebase/config.ts
import { initializeApp, getApps } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getFunctions } from 'firebase/functions';

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

// Initialize Firebase
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];
export const db = getFirestore(app);
export const functions = getFunctions(app);
```

### 2.3 LIFF初期化

```typescript
// lib/line/liff.ts
import liff from '@line/liff';

export const initializeLiff = async () => {
  try {
    await liff.init({
      liffId: process.env.NEXT_PUBLIC_LIFF_ID!,
    });
    
    if (!liff.isLoggedIn()) {
      liff.login();
    }
    
    return true;
  } catch (error) {
    console.error('LIFF initialization failed', error);
    return false;
  }
};

export const getUserProfile = async () => {
  try {
    if (!liff.isLoggedIn()) {
      throw new Error('User is not logged in');
    }
    
    const profile = await liff.getProfile();
    return {
      userId: profile.userId,
      displayName: profile.displayName,
      pictureUrl: profile.pictureUrl,
    };
  } catch (error) {
    console.error('Failed to get user profile', error);
    return null;
  }
};
```

### 2.4 カウントアップアニメーションコンポーネント

```typescript
// components/ui/CountUpAnimation.tsx
import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';

interface CountUpAnimationProps {
  endValue: number;
  duration?: number;
  startValue?: number;
  suffix?: string;
  className?: string;
  onAnimationComplete?: () => void;
}

export const CountUpAnimation: React.FC<CountUpAnimationProps> = ({
  endValue,
  duration = 2,
  startValue = 0,
  suffix = '',
  className = '',
  onAnimationComplete,
}) => {
  const [currentValue, setCurrentValue] = useState(startValue);
  const [isAnimating, setIsAnimating] = useState(false);

  useEffect(() => {
    if (isAnimating) return;
    
    setIsAnimating(true);
    const increment = (endValue - startValue) / (duration * 60); // 60fps
    let current = startValue;
    
    const timer = setInterval(() => {
      current += increment;
      
      if (current >= endValue) {
        current = endValue;
        setCurrentValue(current);
        clearInterval(timer);
        setIsAnimating(false);
        onAnimationComplete?.();
      } else {
        setCurrentValue(current);
      }
    }, 1000 / 60);
    
    return () => clearInterval(timer);
  }, [endValue, duration, startValue, isAnimating, onAnimationComplete]);

  return (
    <motion.span
      className={className}
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3, ease: 'easeOut' }}
    >
      {Math.round(currentValue).toLocaleString()}{suffix}
    </motion.span>
  );
};
```

### 2.5 結果表示コンポーネント

```typescript
// components/assessment/ResultChart.tsx
import React, { useState } from 'react';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  BarElement,
} from 'chart.js';
import { Line, Bar } from 'react-chartjs-2';
import { motion } from 'framer-motion';
import { AssessmentResult } from '@/lib/diagnosis/calculator';
import { CountUpAnimation } from '@/components/ui/CountUpAnimation';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
);

interface ResultChartProps {
  result: AssessmentResult;
}

export const ResultChart: React.FC<ResultChartProps> = ({ result }) => {
  const priceData = {
    labels: ['現在', '1年後', '2年後', '3年後', '4年後', '5年後'],
    datasets: [
      {
        label: '資産価値推移',
        data: [
          result.currentValue,
          result.currentValue * (1 - result.depreciationRate),
          result.currentValue * Math.pow(1 - result.depreciationRate, 2),
          result.threeYearValue,
          result.currentValue * Math.pow(1 - result.depreciationRate, 4),
          result.fiveYearValue,
        ],
        borderColor: 'rgb(255, 99, 132)',
        backgroundColor: 'rgba(255, 99, 132, 0.5)',
        tension: 0.1,
      },
    ],
  };

  const depreciationData = {
    labels: ['年間目減り額'],
    datasets: [
      {
        label: '万円',
        data: [result.annualDepreciation / 10000],
        backgroundColor: 'rgba(255, 99, 132, 0.5)',
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1,
      },
    ],
  };

  const options = {
    responsive: true,
    plugins: {
      legend: {
        position: 'top' as const,
      },
      title: {
        display: true,
        text: '資産価値の推移予測',
      },
    },
    scales: {
      y: {
        beginAtZero: false,
        ticks: {
          callback: function(value: any) {
            return (value / 10000).toFixed(0) + '万円';
          },
        },
      },
    },
  };

  const [animationStage, setAnimationStage] = useState(0);

  const handleAnimationComplete = () => {
    setAnimationStage(prev => prev + 1);
  };

  return (
    <div className="space-y-6">
      <motion.div 
        className="bg-white p-6 rounded-lg shadow"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <Line options={options} data={priceData} />
      </motion.div>
      
      {/* 現在価値表示 */}
      <motion.div 
        className="bg-blue-50 p-6 rounded-lg"
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5, delay: 0.2 }}
      >
        <h3 className="text-lg font-semibold text-blue-800 mb-4">
          現在の資産価値
        </h3>
        <div className="text-3xl font-bold text-blue-600">
          <CountUpAnimation 
            endValue={result.currentValue / 10000}
            duration={1.5}
            suffix="万円"
            onAnimationComplete={handleAnimationComplete}
          />
        </div>
      </motion.div>
      
      {/* 将来価値表示 */}
      {animationStage >= 1 && (
        <motion.div 
          className="bg-yellow-50 p-6 rounded-lg"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5 }}
        >
          <h3 className="text-lg font-semibold text-yellow-800 mb-4">
            3年後予測価値
          </h3>
          <div className="text-3xl font-bold text-yellow-600">
            <CountUpAnimation 
              endValue={result.threeYearValue / 10000}
              duration={1.5}
              suffix="万円"
              onAnimationComplete={handleAnimationComplete}
            />
          </div>
        </motion.div>
      )}
      
      {/* 目減りリスク表示 */}
      {animationStage >= 2 && (
        <motion.div 
          className="bg-red-50 p-6 rounded-lg"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5 }}
        >
          <h3 className="text-lg font-semibold text-red-800 mb-4">
            年間目減りリスク
          </h3>
          <div className="text-3xl font-bold text-red-600">
            <CountUpAnimation 
              endValue={result.annualDepreciation / 10000}
              duration={2}
              suffix="万円"
              onAnimationComplete={handleAnimationComplete}
            />
          </div>
          <p className="text-sm text-red-600 mt-2">
            何もしないと毎年これだけの資産価値が失われます
          </p>
        </motion.div>
      )}
      
      {/* 推奨アクション */}
      {animationStage >= 3 && (
        <motion.div 
          className="bg-green-50 p-6 rounded-lg"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <h3 className="text-lg font-semibold text-green-800 mb-4">
            推奨アクション
          </h3>
          <p className="text-green-700">{result.recommendedAction}</p>
        </motion.div>
      )}
    </div>
  );
};
```

### 2.6 Firebase Functions (LINE通知)

```typescript
// functions/src/index.ts
import * as functions from 'firebase-functions';
import { Client } from '@line/bot-sdk';
import * as admin from 'firebase-admin';

admin.initializeApp();

const config = {
  channelAccessToken: functions.config().line.channel_access_token,
  channelSecret: functions.config().line.channel_secret,
};

const client = new Client(config);

// 診断完了通知
export const sendAssessmentComplete = functions.firestore
  .document('assessments/{assessmentId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    const message = {
      type: 'text' as const,
      text: `診断完了🎉\n現在の資産価値：${(data.assessment.currentValue / 10000).toFixed(0)}万円\n3年後予測：${(data.assessment.threeYearValue / 10000).toFixed(0)}万円（${((data.assessment.currentValue - data.assessment.threeYearValue) / 10000).toFixed(0)}万円の目減り）\n\n詳細はこちら👇`,
      quickReply: {
        items: [
          {
            type: 'action' as const,
            action: {
              type: 'uri' as const,
              label: '詳細を見る',
              uri: `https://your-app-url/assessment/result/${context.params.assessmentId}`,
            },
          },
        ],
      },
    };
    
    try {
      await client.pushMessage(data.lineId, message);
    } catch (error) {
      console.error('Error sending LINE message:', error);
    }
  });

// 定期リマインド（毎週月曜日9時）
export const weeklyReminder = functions.pubsub
  .schedule('0 9 * * 1')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
    
    const assessments = await admin.firestore()
      .collection('assessments')
      .where('timestamp', '>=', oneWeekAgo)
      .get();
    
    const messages = assessments.docs.map(async (doc) => {
      const data = doc.data();
      const message = {
        type: 'text' as const,
        text: '最近の周辺相場：平均1.5%下落傾向📉\n資産価値の再診断をお勧めします。',
      };
      
      return client.pushMessage(data.lineId, message);
    });
    
    await Promise.all(messages);
  });
```

## 3. テスト戦略

### 3.1 単体テスト

```typescript
// __tests__/diagnosis/calculator.test.ts
import { calculateAssessment } from '@/lib/diagnosis/calculator';

describe('calculateAssessment', () => {
  it('マンションの資産価値を正しく計算する', () => {
    const property = {
      type: 'マンション' as const,
      age: 10,
      stationDistance: 5,
      area: 70,
      transactionVolume: '普通' as const,
    };
    
    const result = calculateAssessment(property);
    
    expect(result.currentValue).toBeGreaterThan(0);
    expect(result.threeYearValue).toBeLessThan(result.currentValue);
    expect(result.fiveYearValue).toBeLessThan(result.threeYearValue);
    expect(result.riskScore).toBeGreaterThanOrEqual(1);
    expect(result.riskScore).toBeLessThanOrEqual(10);
  });
});
```

### 3.2 E2Eテスト

```typescript
// e2e/assessment.spec.ts
import { test, expect } from '@playwright/test';

test('診断フロー完了まで', async ({ page }) => {
  // LIFF環境での動作確認
  await page.goto('https://liff.line.me/YOUR_LIFF_ID');
  
  // スタート画面
  await expect(page.locator('h1')).toContainText('不動産価値診断');
  await page.click('button:has-text("診断を開始")');
  
  // 質問に回答
  await page.click('button:has-text("マンション")');
  await page.click('button:has-text("6-10年")');
  await page.click('button:has-text("5分以内")');
  await page.click('button:has-text("51-80㎡")');
  await page.click('button:has-text("普通")');
  
  // 結果画面
  await expect(page.locator('h2')).toContainText('診断結果');
  await expect(page.locator('[data-testid="current-value"]')).toBeVisible();
  await expect(page.locator('[data-testid="depreciation-chart"]')).toBeVisible();
});
```

## 4. デプロイ手順

### 4.1 Vercelデプロイ

```bash
# Vercel CLIインストール
npm i -g vercel

# デプロイ
vercel --prod

# 環境変数設定（Vercelダッシュボード）
# - すべての環境変数を設定
```

### 4.2 Firebase Functionsデプロイ

```bash
# Functions設定
firebase functions:config:set line.channel_access_token="YOUR_TOKEN"
firebase functions:config:set line.channel_secret="YOUR_SECRET"

# デプロイ
firebase deploy --only functions
```

### 4.3 LIFF設定

1. LINE Developersコンソールにログイン
2. LIFFアプリのエンドポイントURLを更新
3. スコープ設定（profile, openid）
4. LIFFサイズ：Full

## 5. 運用・監視

### 5.1 エラー監視

```typescript
// lib/monitoring/error-handler.ts
export const reportError = async (error: Error, context?: any) => {
  console.error('Error occurred:', error, context);
  
  // Firebaseに エラーログ保存
  await addDoc(collection(db, 'errors'), {
    message: error.message,
    stack: error.stack,
    context,
    timestamp: new Date(),
    userAgent: navigator.userAgent,
  });
};
```

### 5.2 アナリティクス

```typescript
// lib/analytics/events.ts
export const trackEvent = (eventName: string, parameters?: any) => {
  // Google Analytics
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', eventName, parameters);
  }
  
  // Firebaseにイベント保存
  addDoc(collection(db, 'events'), {
    name: eventName,
    parameters,
    timestamp: new Date(),
    userId: liff.getContext()?.userId,
  });
};
```
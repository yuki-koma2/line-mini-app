# カウントアップアニメーション仕様書

## 1. 概要

不動産価値診断結果の金額表示において、数値が0からカウントアップするアニメーションを実装し、視覚的インパクトを強化してユーザーの注目度を高める。

## 2. 要件

### 2.1 機能要件

#### 基本機能
- 全ての金額表示（現在価値、3年後価値、5年後価値、年間目減り額）でカウントアップアニメーション
- 0から目標値まで段階的に数値が増加
- アニメーション時間：1-2秒
- イージング：ease-out（最初速く、徐々に減速）

#### 表示フロー
1. 現在価値のカウントアップ（1.5秒）
2. 完了後、3年後価値のカウントアップ（1.5秒）
3. 完了後、年間目減り額のカウントアップ（2秒）
4. 完了後、推奨アクション表示

### 2.2 技術要件

#### 使用ライブラリ
- **Framer Motion**: アニメーション制御・コンポーネント表示
- **React Hooks**: 状態管理・アニメーション制御

#### パフォーマンス要件
- 60fps でのスムーズなアニメーション
- モバイル環境での動作保証
- CPU使用率の最適化

### 2.3 UX要件

#### 視覚的効果
- 数値変化の視認性を高める
- 重要な金額（目減り額）により多くの注目を集める
- 段階的な情報開示によりユーザーの理解を促進

#### アクセシビリティ
- `prefers-reduced-motion` 設定に対応
- アニメーション無効化オプション提供
- スクリーンリーダー対応

## 3. 実装仕様

### 3.1 コンポーネント構成

```typescript
// コンポーネント階層
ResultChart
├── CountUpAnimation (現在価値)
├── CountUpAnimation (3年後価値)
├── CountUpAnimation (年間目減り額)
└── RecommendedAction
```

### 3.2 CountUpAnimation コンポーネント

#### Props
```typescript
interface CountUpAnimationProps {
  endValue: number;        // 最終表示値
  duration?: number;       // アニメーション時間（秒）
  startValue?: number;     // 開始値（デフォルト: 0）
  suffix?: string;         // 単位（例: "万円"）
  className?: string;      // スタイリング用クラス
  onAnimationComplete?: () => void; // 完了時コールバック
}
```

#### 実装詳細
- **更新頻度**: 60fps (16.67ms間隔)
- **数値計算**: 線形補間による段階的増加
- **表示形式**: 千の位区切りカンマ + 単位
- **完了判定**: 目標値到達時にコールバック実行

### 3.3 アニメーション制御

#### 段階的表示制御
```typescript
const [animationStage, setAnimationStage] = useState(0);

// stage 0: 現在価値アニメーション
// stage 1: 3年後価値アニメーション  
// stage 2: 年間目減り額アニメーション
// stage 3: 推奨アクション表示
```

#### Framer Motion 統合
```typescript
// 各セクションの表示アニメーション
initial={{ opacity: 0, scale: 0.9 }}
animate={{ opacity: 1, scale: 1 }}
transition={{ duration: 0.5 }}
```

### 3.4 アクセシビリティ対応

#### Reduced Motion 対応
```typescript
const shouldReduceMotion = useReducedMotion();

// アニメーション無効化時は即座に最終値を表示
if (shouldReduceMotion) {
  return <span>{endValue.toLocaleString()}{suffix}</span>;
}
```

#### ARIA対応
```typescript
<span 
  aria-live="polite" 
  aria-label={`資産価値 ${endValue.toLocaleString()}万円`}
>
  {currentValue.toLocaleString()}万円
</span>
```

## 4. 実装例

### 4.1 CountUpAnimation コンポーネント

```typescript
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
  const shouldReduceMotion = useReducedMotion();

  useEffect(() => {
    if (shouldReduceMotion) {
      setCurrentValue(endValue);
      onAnimationComplete?.();
      return;
    }

    if (isAnimating) return;
    
    setIsAnimating(true);
    const increment = (endValue - startValue) / (duration * 60);
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
  }, [endValue, duration, startValue, isAnimating, onAnimationComplete, shouldReduceMotion]);

  return (
    <motion.span
      className={className}
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3, ease: 'easeOut' }}
      aria-live="polite"
    >
      {Math.round(currentValue).toLocaleString()}{suffix}
    </motion.span>
  );
};
```

### 4.2 useReducedMotion Hook

```typescript
function useReducedMotion(): boolean {
  const [shouldReduceMotion, setShouldReduceMotion] = useState(false);

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    setShouldReduceMotion(mediaQuery.matches);

    const handleChange = (event: MediaQueryListEvent) => {
      setShouldReduceMotion(event.matches);
    };

    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, []);

  return shouldReduceMotion;
}
```

## 5. テスト仕様

### 5.1 単体テスト

#### CountUpAnimation コンポーネント
```typescript
describe('CountUpAnimation', () => {
  it('指定された値まで正しくカウントアップする', async () => {
    const onComplete = jest.fn();
    render(
      <CountUpAnimation 
        endValue={1000} 
        duration={0.1} 
        onAnimationComplete={onComplete}
      />
    );
    
    await waitFor(() => {
      expect(onComplete).toHaveBeenCalled();
    });
  });

  it('prefers-reduced-motion 設定時は即座に最終値を表示', () => {
    // モックでreduced motionを有効化
    Object.defineProperty(window, 'matchMedia', {
      writable: true,
      value: jest.fn().mockImplementation(query => ({
        matches: query === '(prefers-reduced-motion: reduce)',
        media: query,
        addListener: jest.fn(),
        removeListener: jest.fn(),
      })),
    });

    const { getByText } = render(
      <CountUpAnimation endValue={1000} suffix="万円" />
    );
    
    expect(getByText('1,000万円')).toBeInTheDocument();
  });
});
```

### 5.2 統合テスト

#### アニメーション フロー
```typescript
describe('Result Display Animation Flow', () => {
  it('段階的にアニメーションが実行される', async () => {
    const result = {
      currentValue: 30000000,
      threeYearValue: 27000000,
      annualDepreciation: 1000000,
      recommendedAction: 'テストアクション'
    };

    render(<ResultChart result={result} />);

    // 現在価値が最初に表示
    expect(await screen.findByText(/現在の資産価値/)).toBeInTheDocument();
    
    // 3年後価値が次に表示
    await waitFor(() => {
      expect(screen.getByText(/3年後予測価値/)).toBeInTheDocument();
    });
    
    // 年間目減り額が表示
    await waitFor(() => {
      expect(screen.getByText(/年間目減りリスク/)).toBeInTheDocument();
    });
    
    // 推奨アクションが最後に表示
    await waitFor(() => {
      expect(screen.getByText(/推奨アクション/)).toBeInTheDocument();
    });
  });
});
```

## 6. パフォーマンス最適化

### 6.1 最適化ポイント

#### メモリ使用量
- `setInterval` の適切なクリーンアップ
- 不要な再レンダリング防止

#### CPU使用率
- 60fps での効率的な更新
- 計算処理の最適化

#### モバイル対応
- Touch事象との競合回避
- バッテリー消費の最小化

### 6.2 監視指標

- アニメーション実行時間の計測
- フレームレート (fps) 監視
- メモリリーク検出

## 7. 今後の拡張可能性

### 7.1 改善案

#### 視覚効果の強化
- 数値変化時の色変化
- パルス効果の追加
- 背景グラデーション

#### インタラクション
- タップによるアニメーション再生
- スワイプによる段階スキップ
- 音声効果の追加

### 7.2 A/Bテスト候補

- アニメーション速度の最適化
- 表示順序の効果測定
- 色彩・エフェクトの比較検証
"use client";
import { useEffect, useState } from 'react';
import liff from '@line/liff';
import type { Liff } from '@line/liff';

const Home = () => {
  const [profile, setProfile] = useState<any>(null);
  const [error, setError] = useState('');
  const [liffObject, setLiffObject] = useState<Liff | null>(null);

  useEffect(() => {
    // LIFFの初期化
    liff.init({
      liffId: 'YOUR_LIFF_ID' // あなたのLIFF IDに置き換えてください
    })
    .then(() => {
      // 初期化成功
      setLiffObject(liff);
      if (!liff.isLoggedIn()) {
        // ログインしていない場合は、ログインを促す
        liff.login();
      } else {
        // ログイン済みであれば、ユーザープロフィールを取得
        liff.getProfile()
          .then(profile => {
            setProfile(profile);
          })
          .catch(err => {
            console.error(err);
            setError('プロフィールの取得に失敗しました。');
          });
      }
    })
    .catch(err => {
      // 初期化失敗
      console.error(err);
      setError('LIFFの初期化に失敗しました。');
    });
  }, []); // 空の依存配列で、コンポーネントのマウント時に一度だけ実行

  return (
    <div>
      <h1>LINE MINI App with Next.js</h1>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      {profile ? (
        <div>
          <p>Display Name: {profile.displayName}</p>
          <p>User ID: {profile.userId}</p>
          {profile.pictureUrl && <img src={profile.pictureUrl} alt="Profile" width={100} height={100} />}
        </div>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
};

export default Home;
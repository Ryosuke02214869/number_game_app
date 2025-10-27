# Number Game App

数字パズルゲームのFlutterアプリです。複数のゲームを楽しめる構成になっています。

## ゲーム一覧

### ヌメロン

重複のない4桁の数字を当てるゲームです。

**ルール:**
- コンピュータが0-9の数字から重複なしで4桁の数字を生成します
- プレイヤーは4桁の数字を予想して入力します
- 結果が HIT と BITE で表示されます
  - **HIT**: 位置と数字が一致している数
  - **BITE**: 数字は含まれているが位置が異なる数
- すべての数字が HIT（4HIT）になったら正解です
- 何回で正解できたかが記録されます

**例:**
- 正解: 1234
- 予想: 1357 → 1HIT 1BITE（1は位置も数字も正解、3は数字は正解だが位置が違う）
- 予想: 1243 → 2HIT 2BITE（1と2は位置も数字も正解、4と3は数字は正解だが位置が違う）

## 機能

- ゲーム選択画面
- ヌメロンゲーム
  - 数字入力フォーム
  - HIT/BITE の結果表示
  - 試行回数のカウント
  - 履歴表示
  - リセット機能
  - 正解時のお祝いダイアログ

## 技術スタック

- Flutter 3.35.7
- Dart
- Material Design 3

## セットアップ

### 必要なもの

- Flutter SDK 3.35.7 以上
- Dart 3.7.1 以上

### インストール手順

1. リポジトリをクローン
```bash
git clone https://github.com/Ryosuke02214869/number_game_app.git
cd number_game_app
```

2. 依存関係をインストール
```bash
flutter pub get
```

3. アプリを実行
```bash
flutter run
```

## ビルド

### Android APK をビルド

```bash
flutter build apk --release
```

生成されたAPKは `build/app/outputs/flutter-apk/app-release.apk` にあります。

### iOS をビルド

```bash
flutter build ios --release
```

## GitHub Actions

このプロジェクトではGitHub Actionsを使用してAPKファイルを自動生成します。

### トリガー

- 手動実行（workflow_dispatch）
- pushイベント時

### 成果物

ビルドされたAPKファイルは、GitHub ActionsのArtifactsからダウンロードできます。

1. GitHubリポジトリの「Actions」タブを開く
2. 実行されたワークフローを選択
3. 「Artifacts」セクションから `android-apk` をダウンロード

## プロジェクト構造

```
lib/
├── main.dart                          # アプリのエントリーポイント、ゲーム選択画面
├── screens/
│   └── numeron_game_page.dart        # ヌメロンゲームのUI
└── models/
    └── numeron_game.dart             # ヌメロンゲームのロジック
```

## 今後の拡張予定

- 他の数字パズルゲームの追加
- 難易度設定（桁数の変更など）
- ハイスコアの保存
- サウンドエフェクト
- アニメーション効果

## ライセンス

MIT License

## 作者

Ryosuke02214869

# kwik5-project-template

- step1 kwik exporterのインストール
- step2 プロジェクトフォルダでkwik exporterをセットアップ
  - step2-1 update_kwikスクリプトでセットアップ
- step3 kwik exporterからパブリッシュされたコードでSolar2Dシミュレータを実行

## Step1 - Photoshop UXP .ccx

このリポジトリのリリースから、Photoshop用のkwik exporter ccxをダウンロードできます。

  - https://github.com/kwiksher/kwik5-project-template/releases/latest/download/com.kwiksher.kwik5.exporter_PS.ccx

    - ccxをダウンロードし、ダブルクリックしてインストールします。
    - Creative Cloudアプリが開き、ダイアログが表示されたらインストールボタンをクリックします。

      <img src="./img/2025-03-23-15-47-42.png" width="800" class="popup-image">

      「はい」をクリック

      <img src="./img/2025-03-23-15-48-24.png" width="800" class="popup-image">

      Photoshopを開きます

      <img src="./img/2025-03-23-15-49-01.png" width="600" class="popup-image">

### kwik5-project-templateのソースファイル

kwik exporterにはこのリポジトリと同じコードベースが含まれており、kwik exporterの設定タブから新しいプロジェクトを作成すると、指定したフォルダの下にPhotoshopとSolar2Dフォルダが作成されます。

  - BookServer (作業中)
  - **Photoshop** > book
    - landscape.psd
    - portrait.psd

      <img src="./img/2025-03-23-16-15-10.png" width="400" class="popup-image">

  - Scripts(作業中)

  - **Solar2D**/main.lua

     Solar2Dシミュレータで開きます

      - kwikEditorLandscape.lua: update_kwik.shまたは手動で~/Library/Application Support/Corona/Simulator/Skinsフォルダにコピーしてください

   - UXP/kwik-exporter

      gh action: Create Releaseでcom.kwiksher.kwik5.exporter_PS.ccxにパックします

## Step2 - Photoshop kwik-exporter

  Photoshopの「プラグイン > Kwik Exporter」から開きます。Kwik Exporterは、Photoshopファイルの場所、Solar2D/App/bookフォルダの場所、そしてpsdファイルの画像やluaファイルの出力先を指定する必要があります。

  1. **~/Documents/GitHub/kwik5-project-template/** のようなプロジェクトのルートディレクトリを選択
  1. .psdファイルを含む **Photoshop/{book}** フォルダを選択
  1. 画像/luaファイルの出力先となる **Solar2D/App/{book}** フォルダを選択

  <img src="./img/2025-03-23-15-59-19.png" width="600" class="popup-image">

1. 設定タブ

    New Projectでプロジェクト名とブック名を設定できます。

    <img src="./img/2025-07-14-12-46-19.png" width="600" class="popup-image">

    - Createボタン > New Kwik Project

      <img src="./img/2025-07-14-12-44-43.png" width="600" class="popup-image">

      Browseボタンで出力先フォルダを選択し、Exportボタンで新規プロジェクトを作成します

   - Finder(mac)やエクスプローラー(win)でプロジェクトフォルダを開く

      <img src="./img/2025-07-17-11-19-50.png" width="600" class="popup-image">

      初回はShow Folderボタンでフォルダを表示

      <img src="./img/2025-07-17-11-28-47.png" width="400" class="popup-image">

      <img src="./img/2025-07-14-12-52-36.png" width="1200" class="popup-image">

      ### (オプション) update_kwikスクリプト

        作成されたプロジェクトにはupdate_kwik.sh(mac)、update_kwik.bat(win)があります。Solar2Dシミュレータ実行時にlua_modules/kwiksher/kwikが見つからない場合、自動で実行されます。手動で実行することもできます。

        <img src="./img/2025-07-18-10-27-19.png" width="600" class="popup-image">

        #### Windows

        update_kwik.bat実行時、solar2dプロトコルのインストール確認が表示されます。これはSolar2D simulatorをsolar2d://で開く実験的機能です。

        ```
        Do you want to install the Solar2D protocol handler? (y/n):
        ```

        - solar2d.regでURLスキームを設定します。**Yes**を選択してください。

        <img src="./img/2025-07-17-11-17-22.png" width="400" class="popup-image">

        <img src="./img/2025-07-17-11-36-25.png" width="600" class="popup-image">

        [Solar2D URL scheme](https://github.com/kwiksher/kwik5-project-template/blob/main/Scripts/readme.md)

       Windowsでは下記のようなURLをブラウザで入力できます

      ```
      solar2d://open?url=file://C:/Users/ymmtny/Documents/Solar2D/kwik-visual-code/develop/Solar2D/kwik5-project-template/Solar2D/main.lua&skin=KwikEditorLandscape
      ```

      > Solar2DのURLスキームを使って、ブラウザから直接Solar2D simulatorを起動するWebページも作成できます。

###

1. メニュータブ - Photoshop Files

    > Resetチェックボックスでボタン状態がOpenに変わります

    - Openボタンで.psdファイルのあるフォルダを選択

      <img src="./img/2025-07-14-12-55-25.png" width="600" class="popup-image">

    - psdファイル名をクリックして開くことができます

      <img src="./img/2025-07-14-13-00-25.png" width="600" class="popup-image">

    - ガイドレイアウトはKwik_ATNアクションで作成されます。独自のガイドレイアウトも利用可能です

      <img src="./img/2025-03-23-16-29-02.png" width="300" class="popup-image">

    - 設定タブ > ツール

      セーフエリア用ガイドラインも利用できます

      <img src="./img/2025-07-14-13-04-39.png" width="600" class="popup-image">

1. Solar2Dプロジェクト

    kwik exporterが画像とluaファイルを作成するApp/{book}フォルダを選択

    <img src="./img/2025-07-14-13-12-09.png" width="600" class="popup-image">

### パブリッシュ

1. パブリッシュするpsdファイルを選択します。**all**チェックボックスも利用できます。その後Publishボタンをクリック。チェックマークの付いたpsdファイルがデフォルトでパブリッシュされます。

  <img src="./img/2025-07-14-13-15-49.png" width="600" class="popup-image">

  1. パブリッシュダイアログ

      <img src="./img/2025-03-23-16-34-23.png" width="400" class="popup-image">

      Photoshop UXPの既知のバグのため、自動化スクリプトを使う前に画像のエクスポートが動作するか確認してください。動作しない場合はPhotoshopを再起動してください。

      確認方法は、手動でPNGを書き出してみるだけです。

      - レイヤーを選択し、右クリックで「Quick Export as PNG」を選択。一度できれば再確認は不要です。

        <img src="./img/2025-03-23-16-38-23.png" width="400" class="popup-image">

      問題なければ再度Publishを選択し、**Continue**をクリックして選択したpsdファイルをパブリッシュします。

      パブリッシュオプションのチェックやApp/bookフォルダのパスも確認してください。

      <img src="./img/2025-03-23-16-42-02.png" width="400" class="popup-image">

      Kwik exporterがpsdファイルとレイヤーを処理し、最後にダイアログを表示します。

      <img src="./img/2025-03-23-16-47-50.png" width="300" class="popup-image">

 1. シミュレータをロード

    **Load Simulator**ボタンでSolar2D simulatorを開けます。

    <img src="./img/2025-07-14-13-18-08.png" width="600" class="popup-image">

    許可ダイアログが表示されたら「Allow」を選択

    <img src="./img/2025-03-23-20-29-59.png" width="400" class="popup-image">

    #### Windows

      ルートフォルダがエクスプローラーで開くので、**startStar2D.bat**をダブルクリックしてSolar2D simulatorを起動してください

      > WindowsではKwik exporter(UXP拡張)からSolar2D.exeを自動起動できません

      <img src="./img/2025-07-17-16-22-04.png" width="600" class="popup-image">

    Solar2D Simulatorが開いたら、Window > View AsでKwik Editor Landscapeやportraitスキンに切り替えられます。

    <img src="./img/2025-03-23-20-47-38.png" width="600" class="popup-image">

---

 ### アクティブドキュメント

<img src="./img/2025-07-14-13-19-35.png" width="600" class="popup-image">

  - 名前と不透明度の検証

    カタカナはアルファベットに変換されます

    不透明度ゼロは、Photoshopが透明レイヤーをpngとしてエクスポートしないため調整されます

  - コードのエクスポート

    luaファイルのみをエクスポートします

  - シーンをスキップ: Photoshopファイルリストにないpsdファイルを開く場合に便利です

      チェックを外すと、シーン（ページ）インデックスは常にPhotoshopファイルリストで更新されます（デフォルト動作）

  - 画像のエクスポート

    - （オプション）shiftキーを押すと、アクティブドキュメントの**Export images**で選択した単一レイヤーのみエクスポート

    - "-"（ハイフン）で始まるレイヤー名は、コード・画像のエクスポート時に無視されます

 ### レイヤーグループ

<img src="./img/2025-07-14-13-20-09.png" width="600" class="popup-image">

  - 非マージ

    レイヤーパネルでレイヤーグループを選択し、各子レイヤーを個別にエクスポートできます

  - キャンセル

    非マージをキャンセル

  - 更新

    App/book/assets/images/pageにレイヤーグループと同名のサブフォルダがある場合、非マージがトリガーされます。手動でサブフォルダを作成した場合は更新ボタンを使ってください

---

詳細はオンラインドキュメント（WIP）をご覧ください

- https://kwiksher.github.io/kwik5docs/get_started/index.html

---

## Step3 - Solar2D Simulator > main.lua

開発時はmain.luaをdevelopmentモード、config.luaをadaptiveに設定します。デバイスビルド用の本番環境では、productionモードに切り替え、config.luaをletterboxにしてください。本番環境ではkwik editorは不要なのでdevelopmentモードは使いません。

### config.lua

デバイス用の最終ビルドではscaleを "letterbox" に変更してください

scale = "adaptive" を "letterbox" に

```lua
application = {
	content =
	{
		fps = 60,
		width = 320,
		height = 480,
		-- scale = "adaptive",
		scale = "letterbox",
		xAlign = "center",
		yAlign = "center",
```

### main.lua

env.mode = "development" を "production" に

> productionモードではkwik editorはロードされません

env.propsのbookやpage名はご自身のプロジェクトに合わせて編集してください

> kwik editorでエラーが出る場合はenv.restore = trueを試してください（.bakファイルで回復）。回復後はfalseに戻してください

開発時は`turnOffNativeVideo`がtrue（動画再生オフ）です。動画再生したい場合はfalseにしてください。

```lua
local env = require("env")
env.book   = "book"
env.goPage = "landscape"
env.lang   = ""
--
env.restore = false
--
env.mode = "development"
-- env.mode = "production"
-- env.mode = "debug" -- kwiksherリポジトリのkwik5-plugin srcが必要

--
if env.mode == "development" or env.mode == "debug" then
  env.props = {
    name = env.book,
    editor = true,
    gotoPage = env.goPage,
    language = env.lang, -- 空文字列 "" は単一言語プロジェクト用
    position = {x = 0, y = 0},
    gotoLastBook = false,
    unitTest = false,
    httpServer = false,
    showPageName = true,
    turnOffNativeVideo = true
  }
elseif env.mode == "production" then
  env.props = {
    name = env.book,
    editor = false,
    gotoPage = env.goPage,
    language = env.lang, -- 空文字列 "" は単一言語プロジェクト用
    position = {x = 0, y = 0},
    gotoLastBook = false,
    unitTest = false,
    httpServer = false,
    showPageName = false,
    turnOffNativeVideo = false
  }
end
--
--
system.setTapDelay(0.2)
--
--
if env.setPlugin(env.mode)  then
  local kwik = require("kwiksher.kwik")
  --
  --display.setDefault( "background", 0.2, 0.2, 0.2, 0.1 )
  kwik.useGradientBackground()
  --

  if env.restore and  kwik.restore() then
    native.showAlert("kwik", "restored comment it out kwik.restore()")
    return
  end

  kwik.setCustomModule(
    "custom",
    {
      commands = {"myEvent"},
      components = {
        -- "align",
        "myComponent",
        "thumbnailNavigation",
        "index"
        -- "keyboardNavigation",
      }
    }
  )
  --
  kwik.bootstrap(env.props)
  --
end
```

### kwikモジュールの更新

update_kwik.sh (mac)、update_kwik.batは最新リリースを取得し、Solar2Dのlua_modulesフォルダを上書きします

<img src="./img/2025-07-14-13-40-59.png" width="300" class="popup-image">

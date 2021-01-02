[README(EN-DeepL)](README.md) / [README(JP)](README_JP.md)

# Group.ini/lua
StepManiaの一部のテーマで利用可能なGroup.iniの情報まとめと、新しいフォーマットとなるGroup.luaの仕様です。

## Group.iniとは
StepMania5.0専用テーマWAIEIで実装された機能で、グループフォルダ直下にGroup.iniというファイルを作成することで様々なカスタマイズが可能となります。
例えば以下のような機能があります。
- グループフォルダの日本語表記
- 選曲画面での楽曲文字色
- 難易度の数値が何段階かの設定
 
日本製のパッケージの多くでGroup.iniが採用されており、WAIEIシリーズだけではなくいくつかのテーマでも扱うことができます。

## Group.lua
Group.iniは多くの機能を追加しますが、独自の書式であるため、作成するために書き方を学習する必要があります。
拡張子はINIですが、一般的なINIとは異なる書式のためテーマ側で扱うためにも解析が必要となります。
また、特定条件下にのみ適用させるといった高度な使い方は出来ません。

そういった問題を解決するために、Luaのテーブルで定義出来るように対応しました。それがGroup.luaです。
基本的な書式はGroup.iniに合わせ、機能によってバラバラだった書き方をまとめています。
また、テーブルのため、テーマ側ではそのまま受け取るだけで対応できます。

例）
Group.ini
```Plain Text
#NAME:グループ名（マルチバイト文字可）;
#MENUCOLOR:
1,0,0,1
:
0,0,1,1
|song1
|song2
|song3
;
#SORTLIST_FRONT:
song1:
song2
;
```

Group.lua（草案）
```Lua
return {
    Name = 'グループ名（マルチバイト文字可）',
    MenuColor = {
        {
            Default = color('1,0,0,1'),
            Blue    = color('0,0,1,1'),
        },
        Blue = {
            'song1',
            'song2',
            'song3',
        },
    },
    SortList = {
        Front = {
            'song1',
            'song2',
            'song3',
        },
    },
}
```

## ドキュメント
[こちらをご覧ください](doc/jp/README.md)
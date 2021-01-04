# MenuColor：楽曲カラーを設定する

選曲画面で表示される楽曲のカラーを設定します。  
StepMania3.9Plusで実装されていた`#MENUCOLOR`と同等の動作をします。StepMania5では本体が対応していないためOffsetの更新等でSMファイルが更新されると記述が消えてしまいます。

Group.ini/luaに記述することで消えてしまうことを回避でき、さらに全楽曲をひとつのファイルで管理できるようになります。

## 基本

MenuColorキーに対して色を指定してください。  
color型、文字列どちらでも設定可能です。

`Group.lua`
```Lua
return {
    MenuColor = Color('Green'),
}
```

```Lua
return {
    MenuColor = '0.0, 1.0, 0.0, 1.0',
}
```

Group.iniではMenuColorキーに対して色を設定してください。  
値に記述できるのは0～1の値4つをコンマで区切った値です。

`Group.ini`
```Plain Text
#MENUCOLOR:0.0, 1.0, 0.0, 1.0;
```

## 楽曲ごとに設定

キーの無いテーブルを作成し、Defaultキーと任意のキーを作成します。
それぞれのキーに、設定したい色を指定してください。
次に、キーの無いテーブルと同じ階層に先に指定した任意のキーと同じ名前のキーを指定し、対象の楽曲フォルダをリスト化していきます。

`Group.lua`
```Lua
return {
    MenuColor = {
        {
            Default = '0,1,0,1',
            Aqua = color('#00ffffff'),
            Boss = Color('Red'),
        },
        Aqua = {
            'songB',
            'songC',
        },
        Boss = {
            'bossSong',
        },
    },
}
```
上記の場合、songB、songCフォルダの楽曲は水色、bossSongフォルダの楽曲は赤色、その他は緑色になります。

---
Group.iniでは`:`で定義を区切って複数書くことができます。楽曲フォルダは`|`で区切ります。

`Group.ini`
```Plain Text
#MENUCOLOR:0,1,0,1:0,0,1,1|songB|songC:1,0,0,1|bossSong;
```
一行で書くこともできますが、非常に見づらいため改行することを推奨します。  
改行することで途中でコメントを入れることもできます。

```Plain Text
#MENUCOLOR:
// Green(Default)
0,1,0,1
:
// Aqua
0,0,1,1
|songB
|songC
:
// Red
1,0,0,1
|bossSong
;
```

# MeterType：楽曲難易度尺度を設定する

楽曲の難易度がおおまかに何段階かを設定します。  
StepMania3.9Plusで実装されていた`#METERTYPE`と同等の動作をします。StepMania5では本体が対応していないためOffsetの更新等でSMファイルが更新されると記述が消えてしまいます。

Group.ini/luaに記述することで消えてしまうことを回避でき、さらに全楽曲をひとつのファイルで管理できるようになります。

MeterTypeによってどのように挙動が変わるかはテーマの実装次第です。  
例として、WAIEI2ではMenuColorが指定されていないときに赤色（ボス曲）扱いとなる難易度が変わります。

## 基本

MeterTypeキーに対して尺度を表す文字列を指定してください。  
10段階難易度の「DDR」、19段階難易度の「DDR X」、DDRを拡張して10段階以上を細分化した「ITG」が一般的に多く使用されています。

`Group.lua`
```Lua
return {
    MeterType = 'DDR X',
}
```

`Group.ini`
```Plain Text
#METERTYPE:DDR X;
```

## 楽曲ごとに設定

キーの無いテーブルを作成し、Defaultキーと任意のキーを作成します。
それぞれのキーに、設定したい尺度を表す文字列を指定してください。
次に、キーの無いテーブルと同じ階層に先に指定した任意のキーと同じ名前のキーを指定し、対象の楽曲フォルダをリスト化していきます。

`Group.lua`
```Lua
return {
    MeterType = {
        {
            Default = 'DDR',
            Over10 = 'ITG',
        },
        Over10 = {
            'songA',
            'bossSong',
        },
    },
}
```
上記の場合、songA、bossSongフォルダの楽曲はITG難易度として扱い、そのほかの楽曲はDDR難易度扱いとなります。

---
Group.iniでは`:`で定義を区切って複数書くことができます。楽曲フォルダは`|`で区切ります。

`Group.ini`
```Plain Text
#METERTYPE:DDR:ITG|songA|bossSong;
```
一行で書くこともできますが、非常に見づらいため改行することを推奨します。  
改行することで途中でコメントを入れることもできます。

```Plain Text
#METERTYPE:
// Default
DDR
:
// Over10
ITG
|songA
|bossSong
;
```

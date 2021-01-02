# テーマから呼び出す

当リポジトリで配布しているGroup_LuaとGroup_Iniを使用して、テーマ側でGroup.ini/luaを扱えるようにします。

## スクリプトの準備

1. [group_lua.luaとgroup_ini.lua](../../lua)をダウンロードし、対応したいテーマのフォルダにコピーしてください。
1. LoadActorやdofile等でgroup_lua.luaを読み込んでください。
1. Scan()を実行後、各情報を取得することができるようになります。
```Lua
local groupLua = LoadActor('group_lua.lua')
groupLua:Scan()
```

## 追加される関数
パラメータの説明に()で値が記載されている項目は引数の指定が任意で、未指定の場合の値となります。

### フォルダ情報を取得

<dl>
    <dt>Scan(p1, p2)</dt>
    <dd>
        p1(false) : group.iniの強制再読み込み<br>
        p2(nil) : 読み込み対象のグループフォルダ名
    </dd>
</dl>

Group_luaを使用可能な状態にします。
以降の関数を利用するためには、必ずこの関数を実行しておく必要があります。

Group.iniを読み込むと、Group.luaへの変換処理が入ります。
高速化のために一度Scan()を実行すると再度Scan()を実行しても再読み込みがされません。
再読み込みを行いたい場合はp1にtrueを指定してください。
なお、Group.luaはp1の値に関係なくScan()を呼び出すたびに再読み込みが行われます。

p2にグループフォルダ名を指定すると、そのグループのみの再読み込みが行われます。

```Lua
-- Theme
groupLua:Scan()
```

### グループ名を取得
<dl>
    <dt>Name(p1)</dt>
    <dd>
        p1 : グループフォルダ名
    </dd>
</dl>

Group.luaのNameキーで指定されたグループ名を取得します。
定義されていない場合は`SONGMAN:ShortenGroupName`実行後のフォルダ名が返却されます。

```Lua
-- Songs/MyTest/group.lua
return {
    Name = 'マイテスト',
}
```

```Lua
-- Theme
local groupName = groupLua:Name('MyTest')
self:settext(groupName)
```

結果
```Text
マイテスト
```

### グループカラーを取得
<dl>
    <dt>GroupColor(p1)</dt>
    <dd>
        p1 : グループフォルダ名
    </dd>
</dl>

Group.luaのGroupColorキーで指定されたグループカラーを取得します。
定義されていない場合はデフォルトカラー、`SONGMAN:GetSongGroupColor`の順で取得されます。

```Lua
-- Songs/MyTest/group.lua
return {
    GroupColor = color('0.5, 1.0, 0.0, 1.0'),
}
```

```Lua
-- Theme
local groupColor = groupLua:GroupColor('MyTest')
self:diffuse(groupColor)
```

### オリジナルフォルダ名を取得
<dl>
    <dt>OriginalName(p1)</dt>
    <dd>
        p1 : Song型
    </dd>
</dl>

Group.luaのOriginalNameキーで指定されたオリジナルのグループフォルダ名を取得します。
これは、指定した楽曲が特定の名前のグループに入っているものとして動作させる機能となります。例えば、一部のテーマで実装されているリザルトのシェア機能やライバル機能は、グループ名まで一致させておく必要がありますが、OriginalNameを指定しておくことにより異なるグループフォルダ名でも動作するようにします。
定義されていない場合はグループフォルダ名が返却されます。

```Lua
-- Songs/MyTest/group.lua
return {
    OriginalName = 'TestGroup',
}
```

```Lua
-- Theme
local originalName = groupLua:OriginalName('MyTest')
self:settext(originalName)
```

結果
```Text
TestGroup
```

### 難易度尺度を取得
<dl>
    <dt>MeterType(p1)</dt>
    <dd>
        p1 : Song型
    </dd>
</dl>

Group.luaのMeterTypeキーで指定された難易度尺度を取得します。
10段階難易度の「DDR」、19段階難易度の「DDR X」、DDRを拡張して10段階以上を細分化した「ITG」が一般的に多く使用されています。

```Lua
-- Songs/MyTest/group.lua
return {
    MeterType = 'DDR X',
}
```

```Lua
-- Theme
local meterType = groupLua:MeterType(GAMESTATE:GetCurrentSong())
self:settext(meterType)
```

結果
```Text
DDR X
```

### 楽曲カラーを取得
<dl>
    <dt>MenuColor(p1)</dt>
    <dd>
        p1 : Song型
    </dd>
</dl>

Group.luaのMenuColorキーで指定されたカラーを取得します。
定義されていない場合はデフォルトカラー、`SONGMAN:GetSongColor`の順で取得されます。

```Lua
-- Songs/MyTest/group.lua
return {
    MenuColor = Color('Red'),
}
```

```Lua
-- Theme
local menuColor = groupLua:MenuColor(GAMESTATE:GetCurrentSong())
self:diffuse(menuColor)
```

### デフォルト値を設定
<dl>
    <dt>Default(p1, p2)</dt>
    <dd>
        p1 : キー<br>
        p2 : 値
    </dd>
</dl>

Group.ini/luaで未指定時に設定する値を定義します。
値にはnilも設定可能です。
設定可能な値は次の通りです。

| キー | 初期値 | 説明 |
:----|:----|:----
| GroupColor | nil | グループカラーです |
| MenuColor | nil | 楽曲の色です |
| MeterType | 'DDR' | 難易度尺度です |

```Lua
-- Songs/MyTest/group.lua
return {}
```

```Lua
-- Theme
groupLua:Default('MeterType', 'ITG')

local meterType = groupLua:MeterType(GAMESTATE:GetCurrentSong())
self:settext(meterType)
```

結果
```Text
ITG
```

### オリジナルのデータを取得
<dl>
    <dt>Raw(p1, p2)</dt>
    <dd>
        p1 : グループフォルダ名<br>
        p2(nil) : キー
    </dd>
</dl>

p1で指定したグループのGroup.luaに記述されている情報を直接取得します。
p2で取得したいキーを設定します。未指定の場合はグループの全情報がテーブルで返却されます。
p2で指定したキーの情報が見つからなかった場合はnilが返却されます。
この関数は、専用の取得関数が用意されていないパラメータの取得を行うことを想定しています。
Group.iniしかないグループの場合は、内部でGroup.luaに変換された後のデータを取得します。

```Lua
-- Songs/MyTest/group.lua
return {
    Comment = 'コメントテスト',
}
```

```Lua
-- Theme
self:settext(groupLua:Raw('MyTest', 'Comment') or '')
```

結果
```Text
コメントテスト
```
---

```Ini
// Songs/MyTest/group.ini
#URL:https://sm.waiei.net/;
```

```Lua
-- Theme
self:settext(Serialize(groupLua:Raw('MyTest')))
```

結果
```Text
local tab1 = {}
tab1["Url"] = "https://sm.waiei.net/"
return tab1
```

### ソート用ファイルを作成
<dl>
    <dt>Sort(p1)</dt>
    <dd>
        p1('Group') : ソート名
    </dd>
</dl>

Group.luaのSortListキーで定義されている楽曲順序を読み込み、ユーザーソートファイルとしてテーマのOtherフォルダに出力します。
この関数を呼び出すと`SONGMAN:SetPreferredSongs`も実行されるため、Preferredソートにするだけで楽曲順序の設定が適用されます。
楽曲数によっては非常に時間のかかる処理となるため、関数の呼び出しタイミングには注意してください。
なお、グループフォルダはNameで定義された名前を優先してソートされます。

```Lua
-- Songs/MyTest/group.lua
return {
    SortList = {
        Front = {
            'songCis1st',
            'songAis2nd',
            'songBis3rd',
        },
    },
}
```

```Lua
-- Theme
groupLua:Sort()
```

結果（Themes/MyTheme/Other/SongManager Group.txt）
```Text
---MyTest
MyTest/songCis1st/
MyTest/songAis2nd/
MyTest/songBis3rd/
```

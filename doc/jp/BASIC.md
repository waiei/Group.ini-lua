# 基本の書き方
Group.ini/luaの作成場所と、基本的な書き方についての説明です。

- [Group.lua](#grouplua)
- [Group.ini](#groupini)

## 作成場所

グループフォルダの直下に`Group.ini`または`Group.lua`を作成してください。
ファイル名の大文字小文字は区別しませんが、iniとluaが両方存在する場合は、luaの方を優先して読みこみます。  
日本語等のマルチバイト文字を扱う場合、テキストエンコーディングは[UTF-8](https://ja.wikipedia.org/wiki/UTF-8)にしてください。[BOM](https://ja.wikipedia.org/wiki/%E3%83%90%E3%82%A4%E3%83%88%E9%A0%86%E3%83%9E%E3%83%BC%E3%82%AF)の有無は問いません。

```Plain Text
📂StepMania
｜📂Songs
｜｜📂MyGroup
｜｜｜📂bossSong
｜｜｜📂songA
｜｜｜📂songB
｜｜｜📂songC
｜｜｜📝group.lua
```

## Group.lua

### 基本

テーブルを返却するLuaスクリプトを作成します。  
Group.iniとは異なり、必ず返却値を書いておく必要があります。  
以下、最低限必要な記述になります。

```Lua
return {}
```

Luaを扱ったことが無い人のために簡単に説明すると、テーブルとは複数の値をコンマ区切りで記述することでまとめて管理できる機能です。  
簡単な例として次の例を見て下さい。

```Lua
-- 「--」の後はコメントになり、無視されます。
-- 文字列を記述する場合は「'」または「"」で囲ってください。
return {
    'A',
    'B',
    'C',
}
```

これは、Group.luaを読み込むことでA、B、Cという文字列を読み込み元に渡しています。読み込み元は受け取った値を解析してGroup.luaのパラメータとして受け取りますが、キーが指定されていないため無視されます。  
キーを指定する場合は次のように書きます。

```Lua
--[[
    このように書くことでコメントを複数行にすることができます。
    キーは「'」や「"」で囲んではいけません。
]]
return {
    TestA = 'A',
    TestB = 'B',
    TestC = 'C',
    Name = 'テキスト',
}
```

キーの大文字小文字は区別しません。これにより、TestA、TestB、TestC、Nameキーが認識されます。  
しかし、Group.luaではTestA、TestB、TestCは意味のないキーなので無視されます。　　
最終的にNameキーが認識され、グループ名が「テキスト」として扱われます。

基本的にはGroup.iniと同じように、`#キー:値;`と書いていたものを`キー='値',`に置き換えることができます。

Group.ini
```Plain Text
#Name:テキスト;
```

Group.lua
```Lua
return {
    Name = 'テキスト',
}
```

空白やインデントは見やすくしているだけであり、次のように書くこともできます。

```Lua
return{Name='テキスト'}
```
ただし、後の管理が大変になるため、空白やインデントは入れることを推奨します。

また、値にはLuaの変数や関数を記述することができます。  
これにより条件を指定して値を変更するといった高度な使い方も可能となります。

Group.lua
```Lua
local function DisplayMenuColor()
    -- 先にJOINしたのがPlayer1かどうかで色を変える
    return GAMESTATE:GetMasterPlayerNumber() == PLAYER_1
        and Color('Red')
        or Color('Blue')
end

return {
    MenuColor = DisplayMenuColor(),
}
```

### 複数値が設定できるパラメータ

Group.iniでは`#MenuColor`/`#MeterType`と`#SortList`の書式が異なるため、単純にテキストをコピーするだけでは適用できず、修正する必要がありました。　　
Group.luaではそういった手間をなくすために、複数記述が可能なパラメータの書き方を変更して統一化しています。

```Lua
return {
    Key = {
        -- キーのないテーブル：定義
        {
            Default  = 'デフォルト値',
            KeyName1 = '値1',
            KeyName2 = '値2',
        },
        -- 定義したキーでフォルダを指定する
        KeyName1 = {
            'songB',
            'songC',
        },
        KeyName2 = {
            'bossSong',
        },
    },
}
```

例えば、通常は緑、特定の楽曲は水色と赤にする場合は次のようになります。

```Lua
return {
    MenuColor = {
        -- 定義
        {
            -- 色は文字列として記述も可能
            Default = '0.0, 1.0, 0.0, 1.0',
            -- StepManiaで用意されている関数を使用
            Aqua    = color('#00ffffff'),
            Red     = Color('Red'),
        },
        Aqua = {
            'songB',
            'songC',
        },
        Red = {
            'bossSong',
        },
    },
}
```

`SortList`は次のような記述となっています。

```Lua
return {
    SortList = {
        -- 定義（省略可能）
        {
            Default = 0,
            Front   = -1,
            Rear    = 1,
        },
        -- まず定義した値順にキーを並べ、その中で記述順にフォルダを並べます。
        Front = {
            'songB',
            'songC',
        },
        Rear = {
            'bossSong',
        },
    },
}
```

## Group.ini

### 基本

**拡張子はINIですが、書式はINIではありません。**  
一般的なINI編集ツールは利用できないため、テキストエディタを使用して直接編集する必要があります。　　

`#キー:値;`が基本の書き方となります。`//`から始まる行はコメントとなり、無視されます。  
値は複数行にわたって書くことができ、`;`で終端として扱われます。  
ただし、`#キー:`で検索を行うため、`#～:`の途中で改行することは出来ません。  
同じキーを複数記載した場合は、最後に記載されたものが優先されます。  
なお、キーは大文字小文字を区別しません。`#NAME:`と`#Name:`は同一のキーとして扱われます。

```Plain Text
// OK
#Name:テキスト;

// OK
#Name:テキ
スト;

// OK
#Name:
// コメント
テキスト
;

// NG（スペースが入ってしまいます）
#Name:
        テキスト
        ;

// NG（キーとして認識されません）
#Name
:テキスト;
```

値はテキストのみが設定できます。  
例えば`#MenuColor`のように色を指定する項目では、RGBAの順でカンマ区切りのテキストを指定してください。

```Plain Text
// OK
#MenuColor:1,0,0,1;

// OK
#MenuColor:1.0, 0.0, 0.0, 1.0;

// NG（Luaスクリプトでの指定はできません）
#MenuColor:Color('Red');
```

### 複数値が設定できるパラメータ

値はグループ全体でひとつのみ指定できるものと、楽曲ごとに定義できるものがあります。  
この場合、`:`で定義を区切り、`|`でフォルダを区切る書き方が基本となります。  
一つ目の定義がデフォルト値となります。


```Plain Text
// Nameはグループ全体の定義なので値が一つだけ
#Name:テキスト;

// グループ全体の楽曲カラーを指定したい場合
#MenuColor:0.0, 1.0, 1.0, 1.0;

// 特定の楽曲だけカラーを指定したい場合
#MenuColor:0,1,1,1:1,0,0,1|bossSong;

// これと同じ
#MenuColor:
// デフォルトカラー
0,1,1,1
:
// 赤色
1,0,0,1
|bossSong
;
```

フォルダ名は大文字小文字を区別せずに認識されます。
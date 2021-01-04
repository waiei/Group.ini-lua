# SortList：グループ内楽曲のソート

StepManiaではデフォルトのグループ順ソートとは別にユーザーソート（Preferredソート）が存在します。  
Group.ini/luaのSortListを使用することでPreferredソート用のファイルを生成し、好きな順に楽曲を定義することができます。  
Group.iniでは、前方ソートの`#SORTLIST_FRONT`と後方ソートの`#SORTLIST_REAR`でキーが異なっていましたが、Group.luaでは`SortList`で統一されています。

グループ内に下記フォルダ名の楽曲があるとして説明します。  
`bossSong` `default` `songA` `songB` `songC`  

デフォルトのグループソートではABC順のため、記載したとおりの順序となります。  
`bossSong`→`default`→`songA`→`songB`→`songC`  

## 基本

SortListキーの中に、対象の楽曲フォルダをリスト化したFront/キーRearキーを作成します。

`Group.lua`
```Lua
return {
    SortList = {
        Front = {
            'songC',
            'songA',
            'songB',
        },
        Rear = {
            'bossSong',
        },
    },
}
```
Front→未指定→Rearの順にソートされます。  
上記の場合、次のようにソートされます。  
`songC`→`songA`→`songB`→`default`→`bossSong`

---
`Group.ini`
```Plain Text
#SORTLIST_FRONT:songC:songA:songB;
#SORTLIST_REAR:bossSong;
```
一行で書くこともできますが、非常に見づらいため改行することを推奨します。  
改行することで途中でコメントを入れることもできます。
```Plain Text
#SORTLIST_FRONT:
songC:
songA:
songB;
#SORTLIST_REAR:
bossSong;
```

## 追加機能

### Front/Rear以外の定義

OriginalNameやMenuColorのように値を定義することができますが、省略することもできます。  
省略せずに書くと、下記のようになります。

`Group.lua`
```Lua
return {
    SortList = {
        {
            Default = 0
            Front = -1,
            Rear = 1,
        },
        Front = {
            'songC',
            'songA',
            'songB',
        },
        Rear = {
            'bossSong',
        },
    },
}
```

Group.luaではFront/Rearといったキーそのもののソート順を変更することができます。  
また、キー名そのものも変更することができます。  

`Group.lua`
```Lua
return {
    SortList = {
        {
            Default = 4
            BeforeDefault = 3,
            New = 2,
            Front = 1,
        },
        BeforeDefault = {
            'songC',
            'songA',
        },
        New = {
            'songB',
        },
        Front = {
            'bossSong',
        },
    },
}
```
上記の場合、`Default` `BeforeDefault` `New` `Front`の値でソートを行い、そのあとに各キーの中で指定した順序に並べます。  
結果、下記のような順序となります。  
`bossSong`→`songB`→`songC`→`songA`→`default`

Group.iniにはこの機能はありません。

### デフォルトの非表示

Default/Front/Rearともうひとつ、Hiddenキーが特殊な扱いとなります。  
Hiddenで定義した楽曲フォルダはPreferredソート時には非表示となります。  
タイトルソートやBPMソートといったほかのソートにすると初めて表示されます。  

`Group.lua`
```Lua
return {
    SortList = {
        Front = {
            'songC',
        },
        Rear = {
            'bossSong',
        },
        Hidden = {
            'songA',
            'songB',
        },
    },
}
```
上記の場合、下記のような順序となり、songAとsongBは一覧に表示されません。  
`songC`→`default`→`bossSong`

---
Group.iniにはSORTLIST_HIDDENが追加されています。

`Group.ini`
```Plain Text
#SORTLIST_FRONT:songC;
#SORTLIST_REAR:bossSong;
#SORTLIST_HIDDEN:songA:songB;

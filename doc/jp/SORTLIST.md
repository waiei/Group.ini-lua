[🔙 一覧](README.md)

# SortList：グループ内楽曲のソート

StepManiaではデフォルトのグループ順ソートとは別にユーザーソート（Preferredソート）が存在します。  
Group.ini/luaのSortListを使用することでPreferredソート用のファイルを生成し、好きな順に楽曲を定義することができます。  
Group.iniでは、前方ソートの`#SORTLIST_FRONT`と後方ソートの`#SORTLIST_REAR`でキーが異なっていましたが、Group.luaでは`SortList`で統一されています。

グループ内に下記フォルダ名の楽曲があるとして説明します。  
`bossSong` `default` `songA` `songB` `songC`

デフォルトのグループソートではABC順のため、次の順序となります。  
`bossSong`→`default`→`songA`→`songB`→`songC`

## 基本

SortListキーの中に、対象の楽曲フォルダ名をリスト化したFront/Rearキーを作成します。

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
まず、Front→未指定→Rearの順にソートされ、次に記述したフォルダ名の順序でソートされます。  
上記の場合、次のようにソートされます。  
`songC`→`songA`→`songB`→`default`→`bossSong`

---

Group.iniではFrontとRearが別のパラメータとなっています。

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
また、キー名もFront/Rear以外に定義することができます。  

`Group.lua`
```Lua
return {
    SortList = {
        {
            Default = 10
            BeforeDefault = 9,
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
定義した値でキーのソートを行い、そのあとに各キーのフォルダを指定した順序に並べます。  
つまり、`Front`→`New`→`BeforeDefault`→`Default`の順にソートされた後に、それぞれの楽曲フォルダをソートします。  
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

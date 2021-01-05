[🔙 一覧](../README.md)

# OriginalName：指定グループの楽曲として扱う

一部のテーマで実装しているライバル機能等では、グループフォルダ名まで一致していないと正しく動作しないことがあります。  
例えば、パッケージの新シリーズをリリースしてグループフォルダ名が変更された場合、旧作の曲が別曲として扱われてしまいます。

OriginalNameは楽曲ごとに想定しているグループフォルダ名を指定することができます。  
指定したことによってどのように動作するかはテーマの実装次第です。

## 基本

OriginalNameキーに対してグループフォルダ名を文字列で設定してください。  
フォルダ名なので、基本的にマルチバイト文字は使用しません。

`Group.lua`
```Lua
return {
    OriginalName = 'Folder name',
}
```

`Group.ini`
```Plain Text
#ORIGINALNAME:Folder name;
```

## 楽曲ごとに設定

キーの無いテーブルを作成し、Defaultキーと任意のキーを作成します。  
それぞれのキーに、そのグループフォルダ名として扱いたいフォルダ名を指定してください。  
次に、キーの無いテーブルと同じ階層に先に指定した任意のキーと同じ名前のキーを指定し、対象の楽曲フォルダをリスト化していきます。

`Group.lua`
```Lua
return {
    OriginalName = {
        {
            Default = 'Folder name',
            Sample = 'Original name',
        },
        Sample = {
            'songA',
            'songB',
            'songC',
        },
    },
}
```
上記の場合、songA、songB、songCフォルダの楽曲は`Original name`という名前のグループフォルダにある楽曲として扱われます。

---
Group.iniでは`:`で定義を区切って複数書くことができます。楽曲フォルダは`|`で区切ります。  

`Group.ini`
```Plain Text
#ORIGINALNAME:Folder name:Original name|songA|songB|songC;
```  
一行で書くこともできますが、非常に見づらいため改行することを推奨します。  
改行することで途中でコメントを入れることもできます。

```Plain Text
#ORIGINALNAME:
// DefaultDefault
Folder name
:
// Original
Original name
|songA
|songB
|songC
;
```

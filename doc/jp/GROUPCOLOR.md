# GroupColor：グループの色を設定

グループの色を定義します。  
定義したことによりどのような挙動となるかはテーマの実装次第です。  
この機能は<a href="https://bitbucket.org/inorizushi/xx-starlight-download/src/master/README.md" target="_blank">XX -STARLiGHT-</a>のテーマで追加されたパラメータです。

## 基本

GroupColorキーに対して色を指定してください。  
color型、文字列どちらでも設定可能です。

`Group.lua`
```Lua
return {
    GroupColor = Color('Orange'),
}
```

```Lua
return {
    GroupColor = '1.0, 0.5, 0.0, 1.0',
}
```

Group.iniではGroupColorキーに対して色を設定してください。  
値に記述できるのは0～1の値4つをコンマで区切った値です。

`Group.ini`
```Plain Text
#GROUPCOLOR:1.0,0.5,0.0,1.0;
```

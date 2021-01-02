# テーマから呼び出す

当リポジトリで配布しているGroup_LuaとGroup_Iniを使用して、テーマ側でGroup.ini/luaを扱えるようにします。

## スクリプトの準備

1. [group_lua.luaとgroup_ini.lua](../../lua)をダウンロードし、対応したいテーマのフォルダにコピーしてください。
1. LoadActorやdofile等でgroup_lua.luaを読み込んでください。
1. Scan()を実行後、各情報を取得することができるようになります。
```Lua
-- Scripts/Example.lua
-- グローバル変数で定義すること
GroupLua = LoadActor('group_lua.lua')
```

```Lua
-- Theme
GroupLua:Scan()
```
注意：group_lua.luaの読み込みは一度だけにして、グローバル変数で管理してください。  
スクリプトごとにローカル変数で管理すると、Scan()で取得した情報が使いまわされず、その都度再読み込みが発生します。

[追加される関数](FUNCTIONS.md)
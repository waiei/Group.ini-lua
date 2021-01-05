[🔙 BACK](README.md)

# Using Group.ini/lua with themes

Use Group_Lua and Group_Ini to allow the theme side to handle Group.ini/lua.

## Preparing the Lua script

1. Download [group_lua.lua and group_ini.lua](../../lua), and copy them to the folder of the theme you want to support.
1. Load group_lua.lua using an external file loading function such as LoadActor or dofile.
1. After running Scan(), you will be able to get the information in Group.ini/lua.
```Lua
-- Scripts/Example.lua
-- To be defined in global variables.
GroupLua = LoadActor('group_lua.lua')
```

```Lua
-- Theme
GroupLua:Scan()
```
Note:<br>
group_lua.lua should be loaded only once and managed as a global variable.  
If you manage it in a local variable for each script, the information retrieved by Scan() will not be reused, and you will have to scan it every time you switch screens.

[Available Functions](FUNCTIONS.md)
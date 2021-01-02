# Using Group.ini/lua with themes

Use Group_Lua and Group_Ini to allow the theme side to handle Group.ini/lua.

## Preparing the Lua script

1. Download [group_lua.lua and group_ini.lua](../../lua), and copy them to the folder of the theme you want to support.
1. Load group_lua.lua using an external file loading function such as LoadActor or dofile.
1. After running Scan(), you will be able to get the information in Group.ini/lua.
```Lua
local groupLua = LoadActor('group_lua.lua')
groupLua:Scan()
```

## Available Functions
For items with () in the parameter description, specifying the argument is optional. The value in parentheses () is the value when not specified.

### Scan for folder information

<dl>
    <dt>Scan(p1, p2)</dt>
    <dd>
        p1(false) : Force reload of group.ini<br>
        p2(nil) : Name of the group folder to read.
    </dd>
</dl>

Makes Group_lua available for use.
This function must be executed in order to use the following functions.

When Group.ini is loaded, the conversion process to Group.lua will begin.
To speed up the process, once Scan() is executed, it will not be reloaded even if Scan() is executed again.
If you want to reload the file, set p1 to true.
Note that Group.lua will be reloaded every time Scan() is called regardless of the value of p1.

If you specify a group folder name in p2, only that group will be reloaded.

```Lua
-- Theme
groupLua:Scan()
```

### Get the group name
<dl>
    <dt>Name(p1)</dt>
    <dd>
        p1 : Group folder name
    </dd>
</dl>

Get the group name specified by the Name key of Group.lua.
If it is not defined, the folder name after `SONGMAN:ShortenGroupName` execution is returned.

```Lua
-- Songs/MyTest/group.lua
return {
    Name = 'DisplayGroupName',
}
```

```Lua
-- Theme
local groupName = groupLua:Name('MyTest')
self:settext(groupName)
```

Result
```Text
DisplayGroupName
```

### Get the group color
<dl>
    <dt>GroupColor(p1)</dt>
    <dd>
        p1 : Group folder name
    </dd>
</dl>

Get the group color specified by the GroupColor key of Group.lua.
If it is not defined, the default color will be returned.
If the default color is also not set, the color of `SONGMAN:GetSongGroupColor` will be returned.

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

### Get the original folder name
<dl>
    <dt>OriginalName(p1)</dt>
    <dd>
        p1 : Song
    </dd>
</dl>

Gets the original group folder name specified by the OriginalName key in Group.lua.
This will be the function that makes the specified song work as if it is in a group with a specific name. For example, the result share and rival functions implemented in some themes need to match the group name, but by specifying OriginalName, they will work with different group folder names.
If it is not defined, the group folder name will be returned.

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

Result
```Text
TestGroup
```

### Get a difficulty scale
<dl>
    <dt>MeterType(p1)</dt>
    <dd>
        p1 : Song
    </dd>
</dl>

Get the difficulty scale specified by the MeterType key in Group.lua.
The most commonly used scales are "DDR" with 10 levels of difficulty, "DDR X" with 19 levels of difficulty, and "ITG" which is an extension of DDR with more than 10 levels of subdivision.

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

Result
```Text
DDR X
```

### Get the song color.
<dl>
    <dt>MenuColor(p1)</dt>
    <dd>
        p1 : Song
    </dd>
</dl>

Get the color specified by MenuColor key of Group.lua.
If it is not defined, the default color will be returned.
If the default color is also not defined, `SONGMAN:GetSongColor` will be returned.

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

### Set the default value
<dl>
    <dt>Default(p1, p2)</dt>
    <dd>
        p1 : Key<br>
        p2 : Value
    </dd>
</dl>

Sets the value to be returned when not defined in Group.ini/lua.
The value can also be set to nil.
The values that can be set are as follows

| key | initial value | description |
:----|:----|:----
| GroupColor | nil | Group color. |
| MenuColor | nil | The display color of the song. |
| MeterType | 'DDR' | Difficulty scale. |

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

Result
```Text
ITG
```

### Create a file for sorting
<dl>
    <dt>Sort(p1)</dt>
    <dd>
        p1('Group') : Sort name
    </dd>
</dl>

Reads the song order defined by the SortList key in Group.lua and outputs it as a user sort file to the Other folder of the theme.
When you call this function, `SONGMAN:SetPreferredSongs` will also be executed, so the songs will be sorted in the specified order if you select the Preferred sort.
Be careful about the timing of the function call, as this can be a very time-consuming process depending on the number of songs.
For group folder sorting, the name defined in Name has priority.

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

Result（Themes/MyTheme/Other/SongManager Group.txt）
```Text
---MyTest
MyTest/songCis1st/
MyTest/songAis2nd/
MyTest/songBis3rd/
```

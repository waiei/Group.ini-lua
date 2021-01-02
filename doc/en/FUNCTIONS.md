# Available Functions
For items with () in the parameter description, specifying the argument is optional. The value in parentheses () is the value when not specified.

### Scan()

<dl>
    <dt>Scan for folder information</dt>
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
GroupLua:Scan()
```

## Name()
<dl>
    <dt>Get the group name</dt>
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
local groupName = GroupLua:Name('MyTest')
self:settext(groupName)
```

Result
```Plain Text
DisplayGroupName
```

## GroupColor()
<dl>
    <dt>Get the group color</dt>
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
local groupColor = GroupLua:GroupColor('MyTest')
self:diffuse(groupColor)
```

## OriginalName()
<dl>
    <dt>Get the original folder name</dt>
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
local originalName = GroupLua:OriginalName('MyTest')
self:settext(originalName)
```

Result
```Plain Text
TestGroup
```

## MeterType()
<dl>
    <dt>Get a difficulty scale</dt>
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
local meterType = GroupLua:MeterType(GAMESTATE:GetCurrentSong())
self:settext(meterType)
```

Result
```Plain Text
DDR X
```

## MenuColor()
<dl>
    <dt>Get the song color</dt>
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
local menuColor = GroupLua:MenuColor(GAMESTATE:GetCurrentSong())
self:diffuse(menuColor)
```

## Default()
<dl>
    <dt>Set the default value</dt>
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
GroupLua:Default('MeterType', 'ITG')

local meterType = GroupLua:MeterType(GAMESTATE:GetCurrentSong())
self:settext(meterType)
```

Result
```Plain Text
ITG
```

## Raw()
<dl>
    <dt>Get the raw data</dt>
    <dd>
        p1 : Group folder name<br>
        p2(nil) : Key
    </dd>
</dl>

Get the information described in Group.lua of the group specified in p1 directly.
Set the key to be retrieved in p2. If not specified, all information of the group will be returned as table data.
If the information for the key specified in p2 is not found, nil will be returned.
This function is intended to retrieve parameters for which no dedicated get function is provided.
For groups that only have Group.ini, it will retrieve the data after it has been internally converted to Group.lua.

```Lua
-- Songs/MyTest/group.lua
return {
    Comment = 'Comment test',
}
```

```Lua
-- Theme
self:settext(GroupLua:Raw('MyTest', 'Comment') or '')
```

Result
```Plain Text
Comment test
```
---

```Plain Text
// Songs/MyTest/group.ini
#URL:https://sm.waiei.net/;
```

```Lua
-- Theme
self:settext(Serialize(GroupLua:Raw('MyTest')))
```

Result
```Plain Text
local tab1 = {}
tab1["Url"] = "https://sm.waiei.net/"
return tab1
```

## Sort()
<dl>
    <dt>Create a file for sorting</dt>
    <dd>
        p1('Group') : Sort name<br>
        p2(true) : Sort groups by the value of Name
    </dd>
</dl>

Reads the song order defined by the SortList key in Group.lua and outputs it as a user sort file to the Other folder of the theme.
When you call this function, `SONGMAN:SetPreferredSongs` will also be executed, so the songs will be sorted in the specified order if you select the Preferred sort.
Be careful about the timing of the function call, as this can be a very time-consuming process depending on the number of songs.
If p2 is true, the sorting of group folders will give priority to the name defined in Name.

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
GroupLua:Sort()
```

Result（Themes/MyTheme/Other/SongManager Group.txt）
```Plain Text
---MyTest
MyTest/songCis1st/
MyTest/songAis2nd/
MyTest/songBis3rd/
```

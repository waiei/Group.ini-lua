# Basic Writing Style
This section explains where to create Group.ini/lua and how to write it in a basic way.

- [Group.lua](#grouplua)
- [Group.ini](#groupini)

## Where to create the file

Create a Group.ini or Group.lua file directly under the group folder.  
The file name is not case sensitive, but if both ini and lua exist, the lua file will be read first.  
When handling multi-byte characters such as Japanese, the text encoding should be [UTF-8](https://en.wikipedia.org/wiki/UTF-8).  
The presence or absence of a [BOM](https://en.wikipedia.org/wiki/Byte_order_mark) has no effect.

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

### Basic format

Create a Lua script to return the table.  
Unlike Group.ini, you must write the return value.  
The following is the minimum description required.

```Lua
return {}
```

For those who have never worked with Lua, a table is a comma-separated list of values that can be managed together.  
As a simple example, take a look at the following example.

```Lua
-- Anything after "--" is a comment and will be ignored.
-- To describe a string, enclose it in ' or ".
return {
    'A',
    'B',
    'C',
}
```

This reads Group.lua and passes the strings A, B, and C to the reader. The reader parses the values it receives and takes them as parameters to Group.lua, but ignores them because the keys are not specified.  
To specify the key, write the following

```Lua
--[[
    You can make a comment multi-line by writing it like this.
    Keys should not be enclosed in ' and ".
]]
return {
    TestA = 'A',
    TestB = 'B',
    TestC = 'C',
    Name = 'Text',
}
```

The keys are not case-sensitive. This will cause the TestA, TestB, TestC and Name keys to be recognized.  
However, in Group.lua, TestA, TestB and TestC are ignored because they are meaningless keys.  
Finally, the Name key will be recognized and the group name will be treated as "text".

Basically, replace the `#key:value;` in Group.ini with `key='value',`.

`Group.ini`
```Plain Text
#NAME:Text;
#MENUCOLOR:1.0,0.0,0.0,1.0;
```

`Group.lua`
```Lua
return {
    Name = 'Text',
    MenuColor = '1.0,0.0,0.0,1.0',
}
```

The key is written in uppercase in Group.ini, following the conventional writing style, but it is not case-sensitive.  
Spaces and indentations are just for readability, and can be written as follows

```Lua
return{Name='Text',MenuColor='1.0,0.0,0.0,1.0'}
```
However, it is recommended to include whitespace and indentations, as writing in abbreviated form will make it more difficult to manage later.

You can also write Lua variables and functions in the value.  
This allows for advanced usage such as changing the value by specifying a condition.

`Group.lua`
```Lua
local function DisplayMenuColor()
    -- Change the color depending on whether Player1 is the one who joined first or not.
    return GAMESTATE:GetMasterPlayerNumber() == PLAYER_1
        and Color('Red')
        or Color('Blue')
end

return {
    MenuColor = DisplayMenuColor(),
}
```

### Parameters that can be set to multiple values

In Group.ini, the format of `#MenuColor`/`#MeterType` and `#SortList` is different, so it cannot be applied by simply copying the text, but needs to be modified.  
In Group.lua, in order to eliminate such a hassle, the way to write parameters that can be described in multiple ways has been changed and unified.

```Lua
return {
    Key = {
        -- Table with no key: definition
        {
            Default  = 'Default value',
            KeyName1 = 'Value 1',
            KeyName2 = 'Value 2',
        },
        -- Specify a folder with a defined key
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

For example, if you want to use green for normal, and light blue and red for certain songs, you can use the following

```Lua
return {
    MenuColor = {
        -- Definition
        {
            -- Colors can be described as strings.
            Default = '0.0, 1.0, 0.0, 1.0',
            -- Use the functions provided by StepMania
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

`SortList` will be written as follows.

```Lua
return {
    SortList = {
        -- Definition (optional)
        {
            Default = 0,
            Front   = -1,
            Rear    = 1,
        },
        -- First, arrange the keys in the order of the values you defined,
        -- and then arrange the folders in the order of the array within the keys.
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

### Basic format

**The extension is INI, but the format is not INI.**  
Common INI editing tools are not available, so you will need to edit them directly using a text editor.

`#key:value;` is the basic writing style. Lines beginning with `//` are comments and are ignored.  
Values can be written over multiple lines, and `;` is treated as the end of the line.  
However, since the search is performed using the `#key:`, it is not possible to break a line in the middle of `#~:`.  
If the same key is entered more than once, the last entry will be given priority.  
Note that keys are not case-sensitive. `#NAME:` and `#Name:` are treated as the same key.

```Plain Text
// OK
#NAME:Text;

// OK
#NAME:Te
xt;

// OK
#NAME:
// Comment
Text
;

// NG (A space is inserted in the middle of a string.)
#NAME:
        Text
        ;

// NG (Not recognized as a key)
#NAME
:Text;
```

Only text can be set as the value.  
For example, for items that specify a color, such as `#MENUCOLOR`, the text should be separated by commas in the order of RGBA.

```Plain Text
// OK
#MENUCOLOR:1,0,0,1;

// OK
#MENUCOLOR:1.0, 0.0, 0.0, 1.0;

// NG (Cannot be specified in Lua script)
#MENUCOLOR:Color('Red');
```

### Parameters that can be set to multiple values

Some values can be specified only one for the whole group, while others can be defined for each song.  
In the case of multiple definitions, the basic writing style is to separate the definitions with `:` and the folders with `|`.  
The first definition will be the default value.


```Plain Text
// Name is the definition of the entire group, so it has only one value
#NAME:Text;

// If you want to specify the song color for the entire group
#MENUCOLOR:0.0, 1.0, 1.0, 1.0;

// If you want to specify a color for a specific song
#MENUCOLOR:0,1,1,1:1,0,0,1|bossSong;

// It can be defined in multiple lines,
// which is the same as the next.
#MENUCOLOR:
// Default color
0,1,1,1
:
// Red
1,0,0,1
|bossSong
;
```

Folder names are recognized in a case-insensitive manner.

SortList has a different description method, so please check the individual pages.
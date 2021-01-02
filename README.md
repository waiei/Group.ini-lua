[README(EN-DeepL)](README.md) / [README(JP)](README_JP.md)

**The English documentation has been automatically translated using [DeepL](https://www.deepl.com/home).**

# Group.ini-lua
A summary of information on Group.ini available for some of StepMania's themes and the specification of the new Group.lua format.

## What's Group.ini?
This is a feature implemented in the StepMania 5.0 theme WAIEI, which allows you to create a file called Group.ini directly under the group folder for various customizations.  
For example, the following functions are available.
- Japanese notation for group folders.
- The color of the text on the song selection screen.(MENUCOLOR)
- How many levels of difficulty can be set.(METERTYPE)
 
Group.ini is used in many of the Japanese packages, and can be handled by the WAIEI series as well as several other themes.

## Group.lua
Group.ini adds a lot of functionality, but because of its unique format, you need to learn how to write it in order to create it.  
The extension is INI, but the format is different from the general INI, so it needs to be analyzed to be handled by the theme.  
Also, it does not allow for advanced usage such as script control.

In order to solve the above problem, Group.lua is designed to be defined in Lua tables.  
The basic format is the same as in Group.ini, but the different formats are unified.  
Also, since it is a table, the theme can read it without the need for parsing.

(Example)
Group.ini
```Plain Text
#NAME:Group name (multibyte acceptable);
#MENUCOLOR:
1,0,0,1
:
0,0,1,1
|song1
|song2
|song3
;
#SORTLIST_FRONT:
song1:
song2
;
```

Group.lua (draft)
```Lua
return {
    Name = 'Group name (multibyte acceptable)',
    MenuColor = {
        {
            Default = color('1,0,0,1'),
            Blue    = color('0,0,1,1'),
        },
        Blue = {
            'song1',
            'song2',
            'song3',
        },
    },
    SortList = {
        Front = {
            'song1',
            'song2',
            'song3',
        },
    },
}
```

## Documents
[Please see here.](doc/en/README.md)
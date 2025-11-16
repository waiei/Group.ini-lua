[English (DeepL/Gemini)](README.md) / [日本語](README_JP.md)

# Group.ini/lua
A summary of information on Group.ini, which is available in some StepMania themes, and the specification for the new Group.lua format.

---

## What is Group.ini?
This feature was first implemented in the StepMania 5 exclusive theme, **WAIEI**. By creating a file named `Group.ini` directly within a song group folder, various customizations become possible.

For example, it provides functionalities such as:
* Displaying the song group folder name in Japanese (multibyte characters).
* Setting the text color for songs on the selection screen (`#MENUCOLOR`).
* Configuring the range/scale for difficulty numerical values (`#METERTYPE`).

`Group.ini` has been adopted by many Japanese song packages and can be utilized not only by the WAIEI series but also by several other community themes.

## The Need for Group.lua
While `Group.ini` adds a lot of functionality, its unique, non-standard format requires users to learn a specific syntax to create the files. Even though the extension is `.ini`, the format differs from a general INI file, requiring themes to implement a specific parser to handle it. Furthermore, it does not support advanced usage such as conditional application or complex script control.

To solve these issues, we introduced **Group.lua**, which allows definitions to be written using Lua tables.
The basic structure is aligned with the concepts of `Group.ini`, unifying various syntaxes that were previously fragmented by function. Crucially, because it is a standard Lua table, themes can integrate and utilize the data directly without the need for complex parsing.

### Example Comparison
| Feature | Group.ini (Custom Format) | Group.lua (Lua Table Format) |
| :--- | :--- | :--- |
| **MenuColor** | `#MENUCOLOR:1.0,0.0,0.0,1.0;` | `MenuColor = color('1,0,0,1')` |

`Group.ini`
```Plain Text
#NAME:☆Group Name☆ (Multibyte characters allowed);
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

`Group.lua`
```lua
return {
    Name = '☆Group Name☆ (Multibyte characters allowed)',
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

## Parsing Library

This repository distributes a library that allows theme developers to easily integrate both `Group.ini` and `Group.lua` into their themes.

## Documentation

The Wiki contains detailed documentation on how **Package Creators** should prepare the Group.ini/lua files and how **Theme Developers** can implement the parsing.

[Please see the Wiki here](https://github.com/waiei/Group.ini-lua/wiki)

-----

**This text was translated using DeepL and edited by Gemini.**
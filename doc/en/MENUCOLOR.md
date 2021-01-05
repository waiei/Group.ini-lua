[🔙 BACK](README.md)

# MenuColor - Set the song color

Sets the color of the music displayed in the music selection screen.  
This is equivalent to `#MENUCOLOR` which was implemented in StepMania 3.9Plus.  
It was written as a parameter in the SM file, but since StepMania 5 does not support it, it will disappear when the file is updated with Offset updates.

By writing it in Group.ini/lua, you can avoid the disappearance of the file, and you can manage all the songs in one file.

## Basic format

Specify the color for the MenuColor key.  
Either the color type or a string can be set.

`Group.lua`
```Lua
return {
    MenuColor = Color('Green'),
}
```

```Lua
return {
    MenuColor = '0.0, 1.0, 0.0, 1.0',
}
```

In Group.ini, set the color for the MenuColor key.  
The value can be a string of four comma-separated values between 0 and 1.

`Group.ini`
```Plain Text
#MENUCOLOR:0.0, 1.0, 0.0, 1.0;
```

## Set a value for each song

Create a table with no keys, and create a Default key and an arbitrary key.  
For each key, specify the color you want to set.  
Next, in the same hierarchy as the keyless table, specify a key with the same name as the arbitrary key you specified earlier, and list the target music folders.

`Group.lua`
```Lua
return {
    MenuColor = {
        {
            Default = '0,1,0,1',
            Aqua = color('#00ffffff'),
            Boss = Color('Red'),
        },
        Aqua = {
            'songB',
            'songC',
        },
        Boss = {
            'bossSong',
        },
    },
}
```
In the above case, songs in the songB and songC folders will be aqua blue, songs in the bossSong folder will be red, and others will be green.

---
In Group.ini, you can write multiple definitions by separating them with `:`. Music folders are separated by `|`.  

`Group.ini`
```Plain Text
#MENUCOLOR:0,1,0,1:0,0,1,1|songB|songC:1,0,0,1|bossSong;
```
It can be written on a single line, but it is very difficult to read, so line breaks are recommended.  
You can also add a comment in the middle of the line.

```Plain Text
#MENUCOLOR:
// Green(Default)
0,1,0,1
:
// Aqua
0,0,1,1
|songB
|songC
:
// Red
1,0,0,1
|bossSong
;
```

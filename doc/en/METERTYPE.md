[🔙 BACK](README.md)

# MeterType - Set the song difficulty scale

You can set the difficulty level of the song.  
This is equivalent to the `#METERTYPE` implemented in StepMania 3.9Plus.  
It was written as a parameter in the SM file, but since StepMania 5 does not support it, it will disappear when the file is updated with Offset updates.

By writing it in Group.ini/lua, you can avoid the disappearance of the SM file, and furthermore, you can manage all songs in one file.

How the behavior changes depending on the MeterType depends on the implementation of the theme.  
As an example, in WAIEI2, the threshold of the difficulty level at which the display color becomes red (boss song) changes when MenuColor is not specified.

## Basic format

Specify a string representing the scale in the MeterType key.  
DDR" with 10 levels of difficulty, "DDR X" with 19 levels of difficulty, and "ITG" which is an extension of DDR with more than 10 levels of subdivision are commonly used.

`Group.lua`
```Lua
return {
    MeterType = 'DDR X',
}
```

`Group.ini`
```Plain Text
#METERTYPE:DDR X;
```

## Set a value for each song

Create a table with no keys, and create a Default key and an arbitrary key.  
For each key, specify the color you want to set.  
Next, in the same hierarchy as the keyless table, specify a key with the same name as the arbitrary key you specified earlier, and list the target music folders.

`Group.lua`
```Lua
return {
    MeterType = {
        {
            Default = 'DDR',
            Over10 = 'ITG',
        },
        Over10 = {
            'songA',
            'bossSong',
        },
    },
}
```
In the above case, the songs in the songA and bossSong folders will be treated as ITG difficulty, while the other songs will be treated as DDR difficulty.

---
In Group.ini, you can write multiple definitions by separating them with `:`. Music folders are separated by `|`.  

`Group.ini`
```Plain Text
#METERTYPE:DDR:ITG|songA|bossSong;
```
It can be written on a single line, but it is very difficult to read, so line breaks are recommended.  
You can also add a comment in the middle of the line.

```Plain Text
#METERTYPE:
// Default
DDR
:
// Over10
ITG
|songA
|bossSong
;
```

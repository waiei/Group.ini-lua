# OriginalName - Treats the song as belonging to the specified group

The rival functions and other features implemented in some themes may not work properly unless they match up to the group folder name.  
For example, if a new series of packages is released and the group folder name is changed, the old songs will be treated as different songs.

OriginalName allows you to specify the group folder name that is assumed for each song.  
How it works by specifying it is up to the implementation of the theme.

## Basic format

Set the group folder name as a string for the OriginalName key.  
Since it is a folder name, multi-byte characters are generally not used.

`Group.lua`
```Lua
return {
    OriginalName = 'Folder name',
}
```

`Group.ini`
```Plain Text
#ORIGINALNAME:Folder name;
```

## Set a value for each song

Create a table with no keys, and create a Default key and an arbitrary key.  
For each key, specify the name of the folder you want to treat as its group folder name.  
Next, in the same hierarchy as the keyless table, specify a key with the same name as the arbitrary key you specified earlier, and list the target music folders.

`Group.lua`
```Lua
return {
    OriginalName = {
        {
            Default = 'Folder name',
            Sample = 'Original name',
        },
        Sample = {
            'songA',
            'songB',
            'songC',
        },
    },
}
```
In the above case, the songs in the songA, songB, and songC folders will be treated as songs in the group folder named `Original name`.

---
In Group.ini, you can write multiple definitions by separating them with `:`. Music folders are separated by `|`.  

`Group.ini`
```Plain Text
#ORIGINALNAME:Folder name:Original name|songA|songB|songC;
```  
It can be written on a single line, but it is very difficult to read, so line breaks are recommended.  
You can also add a comment in the middle of the line.

```Plain Text
#ORIGINALNAME:
// DefaultDefault
Folder name
:
// Original
Original name
|songA
|songB
|songC
;
```

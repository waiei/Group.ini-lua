# SortList - Sorting of songs in a group

In addition to the default group sort, StepMania has a user sort (Preferred sort).  
By using SortList in Group.ini/lua, you can generate a file for Preferred sort and define the songs in any order you want.  
In Group.ini, the keys for `#SORTLIST_FRONT` for forward sort and `#SORTLIST_REAR` for backward sort are different, but in Group.lua, they are unified in `SortList`.

Let's assume that there are songs in the group with the following folder names.  
`bossSong` `default` `songA` `songB` `songC`

Since the default group sort is ABC order, the order is as follows.  
`bossSong` -> `default` -> `songA` -> `songB` -> `songC`

## Basic format

Create a SortList key with a table of Front/Rear keys.  
Front/Rear key contains a list of the target song folder names.

`Group.lua`
```Lua
return {
    SortList = {
        Front = {
            'songC',
            'songA',
            'songB',
        },
        Rear = {
            'bossSong',
        },
    },
}
```
First, they are sorted in the order of Front, then unspecified, then Rear, and then in the order of the folder names you describe.  
In the above case, it is sorted as follows.  
`songC` -> `songA` -> `songB` -> `default` -> `bossSong`

---

In Group.ini, Front and Rear are different parameters.

`Group.ini`

```Plain Text
#SORTLIST_FRONT:songC:songA:songB;
#SORTLIST_REAR:bossSong;
```
It can be written on a single line, but it is very difficult to read, so line breaks are recommended.  
You can also add a comment in the middle of the line.
```Plain Text
#SORTLIST_FRONT:
songC:
songA:
songB;
#SORTLIST_REAR:
bossSong;
```

## Additional Features

### Definitions other than Front/Rear

Values can be defined in the same way as OriginalName and MenuColor, but they are usually omitted.  
If written without omission, it will look like the following

`Group.lua`
```Lua
return {
    SortList = {
        {
            Default = 0
            Front = -1,
            Rear = 1,
        },
        Front = {
            'songC',
            'songA',
            'songB',
        },
        Rear = {
            'bossSong',
        },
    },
}
```

In Group.lua, you can change the sort order of the Front/Rear key itself.  
It is also possible to define a key name other than Front/Rear.  

`Group.lua`
```Lua
return {
    SortList = {
        {
            Default = 10
            BeforeDefault = 9,
            New = 2,
            Front = 1,
        },
        BeforeDefault = {
            'songC',
            'songA',
        },
        New = {
            'songB',
        },
        Front = {
            'bossSong',
        },
    },
}
```
It sorts the keys by the value you define, and then sorts the folders for each key in the order you specify.  
In other words, the keys will be sorted in the order of `Front`, `New`, `BeforeDefault`, `Default`, and then each song folder will be sorted.  
As a result, the order is as follows.  
`bossSong` -> `songB` -> `songC` -> `songA` -> `default`

This feature is not available in Group.ini.

### Hide by default

In addition to the Default/Front/Rear keys, the Hidden key is treated in a special way.  
The song folders defined by Hidden will be hidden when sorting Preferred.  
It will only appear when you use other sorts such as Title Sort or BPM Sort.  

`Group.lua`
```Lua
return {
    SortList = {
        Front = {
            'songC',
        },
        Rear = {
            'bossSong',
        },
        Hidden = {
            'songA',
            'songB',
        },
    },
}
```
In the above case, the order would be as follows: songA and songB would not appear in the list.  
`songC` -> `default` -> `bossSong`

---
SORTLIST_HIDDEN has been added to Group.ini.

`Group.ini`
```Plain Text
#SORTLIST_FRONT:songC;
#SORTLIST_REAR:bossSong;
#SORTLIST_HIDDEN:songA:songB;

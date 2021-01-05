[🔙 BACK](../README.md)

# GroupColor - Set the color of the group

Defines the color of the group.  
It is up to the implementation of the theme to decide how the definition will behave.  
This feature is a parameter added to [SN3](https://github.com/MidflightDigital/ddrsn3-theme) theme.

## Basic format

Specify a color for the GroupColor key.  
Either the color type or a string can be set.

`Group.lua`
```Lua
return {
    GroupColor = Color('Orange'),
}
```

```Lua
return {
    GroupColor = '1.0, 0.5, 0.0, 1.0',
}
```

In Group.ini, set the color for the GroupColor key.  
The value can be a string of four comma-separated values between 0 and 1.

`Group.ini`
```Plain Text
#GROUPCOLOR:1.0,0.5,0.0,1.0;
```

# Name - Setting the display group name

In StepMania, the folder name is displayed as the group name.  
If you want to change the group name displayed on the screen, you need to change the folder name, but if you do, the score will be treated differently.  
Also, in order to display multi-byte characters, the character encoding of the OS itself must be taken into account, and it is almost impossible to set it freely.  
The Name parameter is a function to define the display group name to solve this problem.  
It does not have information for each piece of music, but can be defined for a group.

## Basic format

Set a string for the Name key.

`Group.lua`
```Lua
return {
    Name = 'Display Text',
}
```

`Group.ini`
```Plain Text
#NAME:Display Text;
```

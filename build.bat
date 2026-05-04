@echo off

set name=ZodiacCards

xcopy /s /y .\%name%\ %Appdata%\Balatro\Mods\%name%\*

exit
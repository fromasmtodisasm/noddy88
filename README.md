# noddy88
Intel 8086/8088 debugger for MSDOS written in MASM

Written some 30 years ago. I should ask permission, out of courtesy, and I will. This is so out of date, it might just be of 
historical interest. It contains techniques which are still relevant.

The UI used a fixed format display on a standard 80 x 25 line text screen. It used character sequences to set up cursor location.
And a predefined set of characters used to draw the on screen boxes. This is where the altchar.sys file comes in. 

The screen layout was borrowed from a Z80 debugger we had at the time.

It handled COM and EXE files and was used for teaching assembler programming, as well as debugging techniques, at 
North London Polytechnic for some 10 years.

It was written alongside an identical debugger for the 8085 processor at a time when I was almost exclusively writing assembler
code.

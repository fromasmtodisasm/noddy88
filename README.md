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

The principle of operation is quite simple. The COM or EXE file is read and analysed. The debugger loads the file and fixes
up relocatable addresses. The program counter is set to the start location. It operates at assembler level only, no source
code handling. Each instruction is analysed and translated to the equivalent ascii representation which is displayed in a list.
Current location is highlighted. When executed, the machine instruction op code following the current is replaced with the 1 byte INT 3 instruction. The current instruction is executed and the subsequent INT 3 instuction causes the control to break back into the debugger. This provides an opportunity to update the display. The display includes processor flag status, memory locations,
code sequence and messages. The INT 3 instruction is then replaced with the original op code and the cycle repeats. Break points
are set using INT 3 instructions at the target location.

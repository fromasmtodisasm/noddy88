	;Display screen outline etc 
	XORG	EQU	1			; start at column 1
 	YORG	EQU	2			; line 2
 
 	;Dump area definitions
 	DXORD	EQU	02			; DUMP starting column
 	DYORD	EQU	13			; DUMP starting line

 	TRUE	EQU	01			; NOT false
 	FALSE	EQU	00			; NOT true
 	INT3	EQU	0CCH			; INT 3 opcode
 	MAX_BP	EQU	4			; max breaks allowed

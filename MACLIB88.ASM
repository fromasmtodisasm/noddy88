
 ;MACRO to output two character escape sequences
 ; for controlling the screen
 CON_ESC2	MACRO	A
 	MOV	AL,ESC			;; get escape character
 	CALL	OUTPUT_CHAR		;; output the character
 	MOV	AL,'&A' 		;; get control character
 	CALL	OUTPUT_CHAR		;; output this
 	ENDM
 
 
 ;MACRO to output three character escape sequences
 ; for controlling the screen
 CON_ESC3	MACRO	A,B
 	MOV	AL,ESC			;; get escape character
 	CALL	OUTPUT_CHAR		;; output this
 	MOV	AL,'&A' 		;; get set/reset character (x or y)
 	CALL	OUTPUT_CHAR		;; output this
 	MOV	AL,'&B' 		;; get control character
 	CALL	OUTPUT_CHAR		;; output this
 	ENDM
 
 
 ;MACRO to output the graphics characters in ALTCHAR.SYS
 ; this will only work if:
 ;you had ALTCHAR.SYS on your disc at cold boot
 ; graphics mode has been entered
 CON_GRAFIX	MACRO	A
 	MOV	AL,'&A' 		;; get the character=graphics char
 	CALL	OUTPUT_CHAR		;; output it
 	ENDM
 
 
 COMMENT %
 MACRO for use with displaying characters
 is expects:
  ENTRY: BH = line no
 	BL = row position
 	AL = value to output in hex
  EXIT:	doesnt matter
 	%
 CON_HEXB	MACRO
 	CALL	MOVETO			;; go to the location in BX
 	CALL	OUTHEX_AL		;; output AL as HEX
 ENDM
 
 COMMENT	%
 
 MACRO to simplify cursor control
 for moving to a location on the screen
 Š 
 Parameters are:
 	A	line number
 	B	column number
 %
 GOTO	MACRO	A,B
 	MOV	DH,A			;; place the line number
 	MOV	DL,B			;; and the column number
 	CALL	MOVETO			;; go to the location
 	ENDM
  
 ; MACRO to output a character passed as parameter
 OUTPUT		MACRO	A
 IFNB	<A>
 	MOV	AL,'&A' 		;; get the character
 ELSE
 	MOV	AL,' '			;; space otherwise
 ENDIF
 	CALL	OUTPUT_CHAR		;; output it
 	ENDM
 
 COMMENT	%
 
 MACRO to fetch and display the users registers to the screen
 uses GOTO macro
  
 Parameters are:
 A = line number
 B = column number
   address of location holding register contents
 %
 DISPLAY_REG MACRO	A,B,C
 	GOTO	A,B			;; move to the display
 	MOV	AX, C			;; get the contents
 	CALL	OUTHEX_AX		;; output AX
 	ENDM
 
 COMMENT	%
 
 MACRO for display memory locations pointed to by registers
 GOTO macro for moving to screen location
 
 Parameters are:
 A = line number
 B = column number
 C = address of location to get pointer from
 %
 DISPLAY_POINTER	MACRO	A,B,C
 	GOTO	A,B			;; move to display
 	MOV	BX, C			;; get the contents of pointer
	MOV	AX, YOUR_DS		;; assume data segment
	MOV	ES,AX
	MOV	AX,ES:[BX]		;; get value from memory 
	PUSH	AX			;; save copy
	MOV	AL,AH 
	CALL	OUTHEX_AL		;; output high byte
 	MOV	AL,' '			;; then space
 	CALL	OUTPUT_ASC		;; as character
 	POP	AX			;; get copy back
 	CALL	OUTHEX_AL		;; output it
 	ENDM
 
 COMMENT	%
 
 MACRO for use with displaying contents of flag register
 GOTO macro for moving to correct display area
 
 Parameters are:
 A = line number
 B = column number
 C = flag to test
 D = character representing flag
 %
 DISPLAY_FLAG	MACRO	A,B,C,D
 	LOCAL	<LAB1,LAB2>		;; define local symbols
 	GOTO	A,B			;; go to location
 	TEST	AX, C			;; test the flag
 	JZ	LAB1			;; go to label if set
 	OUTPUT	D			;; else output character
 	JMP	LAB2			;; exit
 LAB1:	MOV	AL,' '			;; else space out
 	CALL	OUTPUT_CHAR		;;
 LAB2:					;; continue with next address
 	ENDM
 
 COMMENT	%
 MACRO to generate a subroutine for  creating a pointer
 the opcode tables
  
 Parameter:
 STADECODE_ADDRESS	: start address of the table
 %
 TABLE_ENTRY MACRO	STADECODE_ADDRESS
 	PUSH	AX			;; save the opcode
 	MOV	BX, OFFSET &STADECODE_ADDRESS
 	SHL	AX,1			;; index times 2
 	ADD	BX,AX			;; add to base address
 	POP	AX			;; restore opcode
 	RET				;; done
 	ENDM
 
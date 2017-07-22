	PAGE	45,132

	TITLE Noddy88 debugger

	SUBTTL Noddy88 library routines

	.SALL

	.XLIST
	INCLUDE	ASCII.ASM
	INCLUDE	FLAGDEF.ASM
	INCLUDE	MACLIB88.ASM
	INCLUDE	NOD88DEF.ASM
	INCLUDE	ZDOSFUNC.ASM
	INCLUDE	ZDOSINT.ASM
	.LIST

	EXTRN	ADDRESS_OFFSETS:WORD
	EXTRN	ADDRESS_SEGS:WORD
	EXTRN	BP_FLAGS:BYTE
	EXTRN	BP_OFFSETS:WORD
	EXTRN	BP_SEGS:WORD
	EXTRN	BYTE_COUNT:BYTE
	EXTRN	CURRENT_CS:WORD
	EXTRN	CURRENT_IP:WORD
	EXTRN	CURRENT_OP:BYTE
	EXTRN	DECODE:NEAR
	EXTRN	DISPLAY$FLAG:BYTE
	EXTRN	IBUFFC:BYTE
	EXTRN	IBUFFP:WORD
	EXTRN	LINE_CNT:BYTE
	EXTRN	M_BUFFER:WORD
	EXTRN	M_COUNTER:BYTE
	EXTRN	MNEMONICS_TABLE:WORD
	EXTRN	REGISTER_PAIRS:WORD
	EXTRN	S_COUNT:BYTE
	EXTRN	SINGLE_REGISTERS:WORD
	EXTRN	YOUR_AX:WORD
	EXTRN	YOUR_BX:WORD
	EXTRN	YOUR_CX:WORD
	EXTRN	YOUR_DX:WORD
	EXTRN	YOUR_DI:WORD
	EXTRN	YOUR_SI:WORD
	EXTRN	YOUR_BP:WORD
	EXTRN	YOUR_SP:WORD
	EXTRN	YOUR_SS:WORD
	EXTRN	YOUR_DS:WORD
	EXTRN	YOUR_CS:WORD
	EXTRN	YOUR_ES:WORD
	EXTRN	YOUR_FLAGS:WORD

	PAGE

	PUBLIC	LCURSOR
	PUBLIC	RCURSOR
	PUBLIC	CMD_ERROR
	PUBLIC	GET_CHAR
	PUBLIC	GET_CHARX
	PUBLIC	GET_NEXT_CHARX

	PUBLIC	LEFT_COMMAND
	PUBLIC	RIGHT_COMMAND
	PUBLIC	VERTICAL
	PUBLIC	HORIZONTAL
	PUBLIC	CROSS
	PUBLIC	TOP_LEFT
	PUBLIC	TOP_RIGHT
	PUBLIC	BOTTOM_LEFT
	PUBLIC	BOTTOM_RIGHT
	PUBLIC	TOP_DOWN
	PUBLIC	BOTTOM_UP
	PUBLIC	LEFT2_RIGHT
	PUBLIC	RIGHT2_LEFT

	PUBLIC	DIV32
	PUBLIC	INPUT_CHAR
	PUBLIC	OUTPUT_CHAR
	PUBLIC	OUTPUT_DECIMAL
	PUBLIC	OUTPUT_ASC
	PUBLIC	OUTPUT_STRING
	PUBLIC	OUTHEX_AL
	PUBLIC	OUTHEX_AX
	PUBLIC	OUTPUT_MNEMONIC
	PUBLIC	OUTPUT_BUFFER
	PUBLIC	OUTPUT_BX
	PUBLIC	OUTPUT_BP
	PUBLIC	OUTPUT_SI
	PUBLIC	OUTPUT_DI
	PUBLIC	OUTPUT_LSQB
	PUBLIC	OUTPUT_RSQB
	PUBLIC	OUTPUT_PLUS
	PUBLIC	OUTPUT_MINUS
	PUBLIC	DISPLACEMENT_BYTE
	PUBLIC	DISPLACEMENT_WORD
	PUBLIC	IMMEDIATE_BYTE
	PUBLIC	IMMEDIATE_WORD
	PUBLIC	MOVETO

	PUBLIC	OUTHEX_AL_BUFF
	PUBLIC	OUTHEX_AX_BUFF
	PUBLIC	ALPHA
	PUBLIC	ALPHA_NUMERIC
	PUBLIC	BYTE2_BIN
	PUBLIC	GET_SEGMENT
	PUBLIC	DOUBLE_REG
	PUBLIC	NUMERIC
	PUBLIC	WORD2_BIN
	PUBLIC	SEG_LETTER
	PUBLIC	SINGLE_REG

	PUBLIC	BREAKPOINTS
	PUBLIC	STACK_DISPLAY
	PUBLIC	FLAGS
	PUBLIC	INS_INIT
	PUBLIC	POINTERS
	PUBLIC	REGISTERS

	PUBLIC	CLEAR_SCREEN
	PUBLIC	CLICK_ON
	PUBLIC	CLICK_OFF
	PUBLIC	CURSOR_ON
	PUBLIC	CURSOR_OFF
	PUBLIC	DELETE_EOLN
	PUBLIC	DELETE_LINE
	PUBLIC	DISABLE_25TH
	PUBLIC	ENABLE_25TH
	PUBLIC	GRAPHICS_ON
	PUBLIC	GRAPHICS_OFF
	PUBLIC	REVERSE_ON
	PUBLIC	REVERSE_OFF
	PUBLIC	RESTORE_CURSOR
	PUBLIC	SAVE_CURSOR

	SUBTTL

	PAGE

DATASEG		SEGMENT		PUBLIC

NUMBER_SEEN	DB	FALSE		;flag for word2_bin routine

DATASEG		ENDS

	PAGE

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG,DS:DATASEG

	SUBTTL Character graphics subroutines

; left hand command delimiter
LEFT_COMMAND	PROC
	CON_GRAFIX	l
	RET
LEFT_COMMAND	ENDP
 
; right hand command delimiter
RIGHT_COMMAND	PROC
	CON_GRAFIX	m
	RET
RIGHT_COMMAND	ENDP
 
;vertical line
VERTICAL	PROC
	CON_GRAFIX	`
	RET
VERTICAL	ENDP
 
;horizontal line
HORIZONTAL	PROC
	CON_GRAFIX	a
	RET
HORIZONTAL	ENDP
 
;intersection point
CROSS		PROC
 	CON_GRAFIX	b
 	RET
CROSS		ENDP
 
;top left hand corner character
TOP_LEFT	PROC
	CON_GRAFIX	f
	RET
TOP_LEFT	ENDP
 
;top right corner
TOP_RIGHT	PROC
	CON_GRAFIX	c
	RET
TOP_RIGHT	ENDP
 
;bottom left hand corner
BOTTOM_LEFT	PROC
	CON_GRAFIX	e
	RET
BOTTOM_LEFT	ENDP
 
;bottom right corner
BOTTOM_RIGHT	PROC
	CON_GRAFIX	d
	RET
BOTTOM_RIGHT	ENDP
 
;top edge branching down
TOP_DOWN	PROC
	CON_GRAFIX	s
	RET
TOP_DOWN	ENDP
  
;bottom edge branching up
BOTTOM_UP	PROC
	CON_GRAFIX	u
	RET
BOTTOM_UP	ENDP
 
;left edge branching right
LEFT2_RIGHT	PROC
	CON_GRAFIX	v
	RET
LEFT2_RIGHT	ENDP
 
;right edge branching left
RIGHT2_LEFT	PROC
	CON_GRAFIX	t
	RET
RIGHT2_LEFT	ENDP

	SUBTTL 

	PAGE

 	SUBTTL	Input - Output routines 
 
COMMENT	%

	All input and output routines

	contents:

	DIV32			writes DX:AX as 32 bit unsigned integer to CON:
	INPUT_CHAR		reads character from the CON:
	OUTPUT_CHAR		writes a character to CON:
	OUTPUT_DECIMAL		writes AX to CON: as decimal number
	OUTPUT_ASC		writes a character to CON: non print special
	OUTPUT_STRING		writes a character to CON:
	OUTHEX_AL		writes AL as two hex digits
	OUTHEX_AX		writes AX as four hex digits
	OUTPUT_MNEMONIC		places mnemonic string in output buffer
	MOVETO			moves cursor to screen location

	%

DIV32		PROC	NEAR
; call:	mov	ax,low bytes
;	mov	dx,high bytes
;	call	DIV32
; uses:	ax,bx,cx
	mov	cx,10			;decimal radix
trdxw1: div	cx			;divide it
	push	dx			;save remainder
	xor	dx,dx			;clear remainder
	test	ax,0ffffh		;any number left?
	jz	trdxw2			;no so unwind
	call	trdxw1			;continue to divide
trdxw2:	pop	ax			;get back a digit
	add	al,'0'			;convert to ascii
	call	OUTPUT_CHAR		;type out and return
	RET
DIV32		ENDP

INPUT_CHAR	PROC	NEAR
;reads character from CON: into AL register if one is available
	PUSH	BX			;save registers
	PUSH	CX
	PUSH	DX
	MOV	AH,ZDOS$CONIO		;direct console io function
	MOV	DL,0FFH			;input function required
	INT	BDOS			;make a function call
	POP	DX
	POP	CX
	POP	BX			;restore registers
	RET
INPUT_CHAR	ENDP

OUTPUT_CHAR	PROC	NEAR
;outputs a character from the AL register to CON:
	PUSH	AX
	PUSH	BX			;save the registers
	PUSH	CX
	PUSH	DX
	PUSH	SI			;we use this with string output
	MOV	AH,ZDOS$CONIO		;direct io required
	MOV	DL,AL			;output function required
	INT	BDOS			;make function call
	POP	SI
	POP	DX
	POP	CX
	POP	BX			;restore registers
	POP	AX			;including the character
	RET
OUTPUT_CHAR	ENDP

OUTPUT_ASC	PROC	NEAR
;outputs a character from AL to CON: if character non printing then use '.'
	CMP	AL,DEL			;delete character?
	JNC	ASC_10			;yes it is
	CMP	AL,' '			;control character?
	JNC	ASC_20			;no
ASC_10:	MOV	AL,'.'			;get a substitute
ASC_20:	CALL	OUTPUT_CHAR		;output it
	RET
OUTPUT_ASC	ENDP

OUTPUT_DECIMAL	PROC	NEAR
;outputs AX as decimal number simplistic approach no = 0-99 only
	PUSH	AX			;save number
	PUSH	CX			;save counter
	XOR	CX,CX			;clear counters
OD$10:	CMP	AX,10			;any tens left?
	JC	OD$20			;no so process units
	INC	CH			;tens = tens + 1
	SUB	AX,10			; number = number - 10 decimal
	JMP	OD$10			;keep going
OD$20:	ADD	CH,'0'			;convert tens
	ADD	AL,'0'			;convert units
	PUSH	AX			;save units
	MOV	AL,CH			;output tens
	CALL	OUTPUT_CHAR
	POP	AX			;then units
	CALL	OUTPUT_CHAR
	POP	CX
	POP	AX			;restore status quo
	RET				;finished 
OUTPUT_DECIMAL	ENDP

OUTPUT_STRING	PROC	NEAR
;outputs a string of ascii characters terminated by a '$'
	MOV	AL,[SI]			;get a byte from memory
	CMP	AL,'$'			;is it terminator
	JZ	STR1			;yes so done
	CALL	OUTPUT_CHAR		;output character
	INC	SI			;bump pointer
	JMP	OUTPUT_STRING		;keep going
STR1:	RET				;return
OUTPUT_STRING	ENDP

OUTHEX_AL	PROC	NEAR
;outputs AL as two hex digits
	PUSH	AX			;save a copy
	SHR	AL,1			;shift four bits
	SHR	AL,1
	SHR	AL,1
	SHR	AL,1
	CALL	OH_10
	POP	AX			;get next nibble
OH_10:	AND	AL,0FH			;only bottom nibble
	ADD	AL,90H			;convert to ascii
	DAA
	ADC	AL,40H
	DAA
	CALL	OUTPUT_CHAR		;output character
	RET
OUTHEX_AL	ENDP

OUTHEX_AX	PROC	NEAR
;outputs AX as four hex digits, using OUTHEX_AL
	PUSH	AX			;save a copy
	MOV	AL,AH			;get high byte
	CALL	OUTHEX_AL		;output high byte
	POP	AX			;restore 
	CALL	OUTHEX_AL		;output low byte
	RET
OUTHEX_AX	ENDP


OUTPUT_MNEMONIC PROC
; output an instruction mnemonic to the output buffer
; CURRENT_OP contains the current opcode
	MOV	BL,CURRENT_OP				;get opcode
	XOR	BH,BH					;clear space
	MOV	CX,8					;characters in mnemonic
	SHL	BX,1					;as table index
	MOV	BX,MNEMONICS_TABLE[BX]			;get table entry
OM_10:	MOV	AL,[BX]
	CALL	OUTPUT_BUFFER				;places char in buffer
	INC	BX
	LOOP	OM_10
	RET
OUTPUT_MNEMONIC ENDP

OUTPUT_BUFFER	PROC
;places a character from AL into M_BUFFER - cf OUTPUT_CHAR
	PUSH	BX					;save pointer
	XOR	BH,BH					;clear high byte
	MOV	BL,M_COUNTER				;get buffer pointer
	MOV	BYTE PTR M_BUFFER[BX],AL		;place character
	INC	M_COUNTER				;increase the pointer
	POP	BX					;restore BX
	RET
OUTPUT_BUFFER	ENDP
 
OUTPUT_BX	PROC
; output BX register name
	MOV	AL,'B'
	CALL	OUTPUT_BUFFER
	MOV	AL,'X'
	CALL	OUTPUT_BUFFER
	RET
OUTPUT_BX	ENDP
 
OUTPUT_BP	PROC
; output BP
	MOV	AL,'B'
	CALL	OUTPUT_BUFFER
	MOV	AL,'P'
	CALL	OUTPUT_BUFFER
	RET
OUTPUT_BP	ENDP
  
OUTPUT_SI	PROC
; output SI register name
	MOV	AL,'S'
	CALL	OUTPUT_BUFFER
	MOV	AL,'I'
	CALL	OUTPUT_BUFFER
	RET
OUTPUT_SI	ENDP
 
OUTPUT_DI	PROC
; output DI register name
	MOV	AL,'D'
	CALL	OUTPUT_BUFFER
	MOV	AL,'I'
	CALL	OUTPUT_BUFFER
	RET
OUTPUT_DI	ENDP

OUTPUT_LSQB	PROC
; output left square bracket
	MOV	AL,'['
	CALL	OUTPUT_BUFFER
	RET
OUTPUT_LSQB	ENDP
 
OUTPUT_RSQB	PROC
; output right square bracket
	MOV	AL,']'
	CALL	OUTPUT_BUFFER
	RET
OUTPUT_RSQB	ENDP
 
OUTPUT_PLUS	PROC
; output plus sign
	MOV	AL,'+'
	CALL	OUTPUT_BUFFER
	RET
OUTPUT_PLUS	ENDP
 
OUTPUT_MINUS	PROC
; output minus sign
	MOV	AL,'-'
	CALL	OUTPUT_BUFFER
	RET
OUTPUT_MINUS	ENDP

DISPLACEMENT_BYTE	PROC
; outputs a displacement byte to output buffer
	XOR	BH,BH
	MOV	BL,BYTE_COUNT
	ADD	BX,CURRENT_IP				;get current instruction
	MOV	AX,CURRENT_CS
	MOV	ES,AX
	MOV	AL,ES:[BX]				;get the byte
	CALL	OUTHEX_AL_BUFF				;number in buffer
	INC	BYTE_COUNT
	RET
DISPLACEMENT_BYTE	ENDP

DISPLACEMENT_WORD	PROC
; outputs a displacement word to output buffer
	XOR	BH,BH
	MOV	BL,BYTE_COUNT
	ADD	BX,CURRENT_IP				;get current instruction
	MOV	AX,CURRENT_CS
	MOV	ES,AX
	MOV	AX,ES:[BX]				;get the word
	CALL	OUTHEX_AX_BUFF				;number in buffer
	INC	BYTE_COUNT				;bc=bc+2
	INC	BYTE_COUNT
	RET
DISPLACEMENT_WORD	ENDP

IMMEDIATE_BYTE		PROC
; outputs an immediate byte to output buffer
	XOR	BH,BH
	MOV	BL,BYTE_COUNT
	ADD	BX,CURRENT_IP				;get current instruction
	MOV	AX,CURRENT_CS				;immediate value is
	MOV	ES,AX					;current ip+bc
	MOV	AL,ES:[BX]				;get the byte
	CALL	OUTHEX_AL_BUFF				;number in buffer
	INC	BYTE_COUNT				;bc=bc+1
	RET
IMMEDIATE_BYTE		ENDP

IMMEDIATE_WORD		PROC
; outputs an immediate word to output buffer
	XOR	BH,BH
	MOV	BL,BYTE_COUNT
	ADD	BX,CURRENT_IP				;same as byte version
	MOV	AX,CURRENT_CS				;
	MOV	ES,AX
	MOV	AX,ES:[BX]				;get the word
	CALL	OUTHEX_AX_BUFF				;number in buffer
	INC	BYTE_COUNT				;bc=bc+2
	INC	BYTE_COUNT
	RET
IMMEDIATE_WORD		ENDP

MOVETO		PROC	NEAR
;goes to a screen location DH=col DL=line
	PUSH	AX			;save registers
	PUSH	BX
	PUSH	CX
	PUSH	DX
	CON_ESC2 Y			;macro will output ESC + 'Y'
	MOV	AL,DH			;get line number
	ADD	AL,' '-1		;offset
	CALL	OUTPUT_CHAR		;output line number
	MOV	AL,DL			;get column number
	ADD	AL,' '-1		;add offset
	CALL	OUTPUT_CHAR
	POP	DX
	POP	CX
	POP	BX
	POP	AX			;restore some registers
	RET
MOVETO	ENDP
  
; output AL as two hexadecimal digits into the mnemonics buffer
 
OUTHEX_AL_BUFF	PROC
	PUSH	AX				;same as outhex_al
	CLC
	RCR	AL,1
	RCR	AL,1
	RCR	AL,1
	RCR	AL,1
	CALL	OH_10_B
	POP	AX
OH_10_B:AND	AL,0FH
	ADD	AL,90H
	DAA
	ADC	AL,40H
	DAA
	CALL	OUTPUT_BUFFER			;place in buffer
	RET
OUTHEX_AL_BUFF	ENDP
 
; output AX as four hex digits into mnemonics buffer

OUTHEX_AX_BUFF	PROC
	PUSH	AX
	MOV	AL,AH
	CALL	OUTHEX_AL_BUFF
	POP	AX
	CALL	OUTHEX_AL_BUFF
	RET
OUTHEX_AX_BUFF	ENDP

	SUBTTL

	PAGE

	SUBTTL Command routines
  
LCURSOR 	PROC  
; this routine moves the curser delimiter one character backwards
	MOV	AL,' '			;get space
 	CALL	OUTPUT_CHAR		;output it
 	MOV	AL,BS			;backspace
 	CALL	OUTPUT_CHAR		;output it
 	MOV	AL,BS			;output another backspace
 	CALL	OUTPUT_CHAR		;so
 	CALL	GRAPHICS_ON		;enter graphics mode
 	CALL	RIGHT_COMMAND		;output the delimiter
 	CALL	GRAPHICS_OFF		;turn graphics mode off
 	MOV	AL,BS			;backspace again
 	CALL	OUTPUT_CHAR		;output it
 	RET
LCURSOR 	ENDP
  
RCURSOR 	PROC  
; this routine moves the cursor delimiter one character forward
 	CALL	GRAPHICS_ON		;enter graphics mode
 	CALL	RIGHT_COMMAND		;output the delimiter
 	CALL	GRAPHICS_OFF		;turn graphics mode off
 	MOV	AL,BS			;get backspace
 	CALL	OUTPUT_CHAR		;output the backspace
 	RET
RCURSOR 	ENDP
  
CLEAR_CMD	PROC
; clears up the command line after <return> pressed
 	GOTO	YORG+1,XORG+5		;move to the start
 	MOV	CL,IBUFFC		;get the character count
 	INC	CL			;characters to delete=characters+1
CLR_10: MOV	AL,' '			;get space
	CALL	OUTPUT_CHAR		;output it
	DEC	CL			;decrease counter
	JNZ	CLR_10			;until finished
	GOTO	YORG+1,XORG+50		;move to the ? position
	MOV	AL,' '			;space over it
 	CALL	OUTPUT_CHAR		;output it
	GOTO	YORG+1,XORG+5		;back to the start location
 	CALL	GRAPHICS_ON		;turn the graphics back on
	CALL	RIGHT_COMMAND		;output the delimiter
	CALL	GRAPHICS_OFF		;turn graphics off again
	MOV	AL,BS			;output backspace
	CALL	OUTPUT_CHAR		;now
	RET
CLEAR_CMD	ENDP
 
GET_CHAR	PROC
; gets a character from the command buffer destructively
; decrements count and updates pointer
	PUSH	DI			;save index register
	MOV	DI,IBUFFP		;get the pointer
	MOV	AL,IBUFFC
	SUB	AL,1
 	JC	GET_10			;no more if carry set
	MOV	IBUFFC,AL		;save the new counter 
	MOV	AL,[DI] 		;get the next character
 	INC	DI			;increase the pointer
 	MOV	IBUFFP,DI		;save the new pointer
	CLC				;say we're ok
GET_10:	POP	DI			;restore the register
	RET
GET_CHAR	ENDP

GET_CHARX	PROC

COMMENT	% 
 gets a character from the command buffer non-destructively
 merely retrieves the character at the current pointer location.
 this routine is useful for 'look ahead' type operations
 where a decision has to be made about what to do next without
 touching the buffer contents
% 
	PUSH	DI			;save index register
	MOV	DI,IBUFFP		;get the pointer
	MOV	AL,IBUFFC
	SUB	AL,1
	JC	GET_10X 		;nothing there
	MOV	AL,[DI] 		;get a character
	CLC				;say we're ok
GET_10X:POP	DI			;restore
	RET
GET_CHARX	ENDP
  
GET_NEXT_CHARX	PROC
 
COMMENT	% 
 gets a character from the command buffer non-destructively
 merely retrieves the character at the current pointer location+1.
 this routine is useful for 'look ahead' type operations
 where a decision has to be made about what to do next without
 touching the buffer contents
% 
	PUSH	DI			;save index register
	MOV	DI,IBUFFP		;get the pointer
	INC	DI			;point to next location
	MOV	AL,IBUFFC		;get the counter
	SUB	AL,1			;decrement the counter
	JC	GEN_10X 		;nothing there
	MOV	AL,[DI] 		;get a character
	CLC				;say we're ok
GEN_10X:POP	DI			;restore
	RET
GET_NEXT_CHARX	ENDP
  
CMD_ERROR	PROC
; outputs the question mark if a command error has been made
	GOTO	YORG+1,XORG+50		;move to the ? location
	MOV	AL,'?'
	CALL	OUTPUT_CHAR		;output the question mark
	RET
CMD_ERROR	ENDP

	SUBTTL

	PAGE
 
	SUBTTL Ascii to binary conversion routines
 

COMMENT	%

 These routines take values entered in the command buffer
 as ascii characters and convert them to a binary number
 WORD2_BIN	converts 4 character hex number to a
 		binary number in 16 bits
 BYTE2_BIN	converts a 2 character hex number in ascii
 		to a binary number in 8 bits

%
 
BYTE2_BIN	PROC
	CALL	WORD2_BIN			;get value
	JC	BYT_10				;error
	TEST	DH,0FFH 			;test high byte
	JNZ	BYT_10				;error if something
	MOV	AL,DL				;else get byte
	CLC
	RET					;done
BYT_10: STC					;set carry flag
	RET					;done
BYTE2_BIN	ENDP
 
WORD2_BIN	PROC
; Converts an ascii word to binary in DX
	XOR	DX,DX				;clear work area
	MOV	NUMBER_SEEN,FALSE		;assume the worst
WD_10:	CALL	GET_CHAR			;get a character
	JC	WD_20				;line end
 	CMP	AL,' '				;is it space
 	JZ	WD_20				;end of this number
 	CMP	AL,':'				;is it alternate delimiter
 	JZ	WD_20				;end of this number
 	CALL	NIBBLE				;convert the nibble
 	JC	WD_30				;not hex
	MOV	NUMBER_SEEN,TRUE		;a number found
 	ADD	DX,DX				;times 2
 	ADD	DX,DX				;times 4
 	ADD	DX,DX				;times 8
 	ADD	DX,DX				;times 16
 	OR	AL,DL				;add new value
 	MOV	DL,AL				;
 	JMP	WD_10				;back for another
WD_20:	TEST	NUMBER_SEEN,TRUE		;ok
	JZ	WD_30				;no never saw a number
	CLC					;clear carry
	RET
WD_30:	STC
	RET					;return with carry if error
WORD2_BIN	ENDP
  
NIBBLE		PROC
 	SUB	AL,'0'				;ascii bias
 	JC	NIB_10				;error < '0'
 	CMP	AL,'F'-'0'+1			;
	CMC					;invert
	JC	NIB_10				;error > 'F'
 	CMP	AL,10
 	CMC					;invert
 	JNC	NIB_10				;number 0-9
 	SUB	AL,'A'-'9'-1			;try for letter
 	CMP	AL,10				;test again
NIB_10: RET					;done
NIBBLE		ENDP
 
SEG_LETTER	PROC	NEAR
;test to see if command buffer contains segment register
	CALL	GET_CHARX			;get next char
	JC	SL$20				;error	
	CMP	AL,'C'				;test for segment register
	JZ	SL$10
	CMP	AL,'D'
	JZ	SL$10
	CMP	AL,'E'
	JZ	SL$10
	CMP	AL,'S'				;was it C,D,E,S?
	JZ	SL$10
SL$05:	STC					;indicate none of these
	RET
SL$10:	CALL	GET_NEXT_CHARX			;look ahead to next character
	JC	SL$20				;error in fetching it
	CMP	AL,'S'				;it has to be S
	JNZ	SL$05				;it wasnt
	CLC					;yes we have a segment register
SL$20:	RET
SEG_LETTER	ENDP

ALPHA		PROC	NEAR
;test for alphabetic character
	CMP	AL,'A'				;less than A?
	JC	AL_20				;yes
	CMP	AL,'Z'+1			; > Z?
	JNC	AL_10				;no so set carry
	CMC
	JMP	AL_20				;exit
AL_10:	STC
AL_20:	RET
ALPHA		ENDP

NUMERIC		PROC	NEAR
;test for numeric character
	CMP	AL,'0'				;less than 0?
	JC	NUM_20
	CMP	AL,'9'+1
	JNC	NUM_10
	CMC
	JMP	NUM_20
NUM_10:	STC
NUM_20:	RET
NUMERIC		ENDP

ALPHA_NUMERIC	PROC	NEAR
;test for alpha numeric character
	CALL	ALPHA
	JNC	AN_10
	CALL	NUMERIC
AN_10:	RET
ALPHA_NUMERIC	ENDP

	SUBTTL

	PAGE

	SUBTTL Address/Offset input routine

COMMENT	%
 
 	procedure for decoding the <seg reg or address>
 	part of a command string.
 
	uses:	AL
		BX
		DX

	returns with:
		BX	= segment address
		DX	= offset address

 	used by the following commands:
 	DUMP
 	FILL
 	PROGRAM_COUNTER
 	ZERO
%
 
GET_SEGMENT		PROC
 	CALL	SEG_LETTER			;see if potential segment name
 	JC	DB_30				;no it isnt
 	CALL	SEGMENT_REG			;get segment reg name
 	JC	DB_20				;error
 	CALL	GET_VALUE			;find segment address
	MOV	BX,AX				;save the base address
DB_10: 	CALL	WORD2_BIN			;get the offset address
DB_20:	RET					;finished

DB_30:	CALL	WORD2_BIN			;get first value
 	JC	DB_20				;error
	MOV	BX,DX				;stash the segment
 	JMP	DB_10				; keep going
DB_40:	STC					;set carry
 	RET					;done
GET_SEGMENT	ENDP
  
; routine to analyse a segment register name
  
SEGMENT_REG	PROC
 	CALL	GET_CHAR			;get first character
 	JC	SR_20				;error
 	PUSH	AX				;save this char
 	CALL	GET_CHAR			;get second character
 	JC	SR_01				;error
 	CMP	AL,'S'				;should be S
 	JNZ	SR_01				;error it isnt
 	CALL	GET_CHAR			;get third character
 	JC	SR_01				;error
	CMP	AL,':'				;should be colon
 	JNZ	SR_01				;error if not
 	POP	AX				;restore first char
 	CMP	AL,'C'				;code segment?
 	JZ	SR_30				;yes
 	CMP	AL,'D'				;data segment?
 	JZ	SR_40				;yes
 	CMP	AL,'E'				;extra segment?
 	JZ	SR_50				;yes
 	CMP	AL,'S'				;stack segment?
 	JZ	SR_60				;yes
	JMP	SR_10				;exit

SR_01:	POP	AX				;raise stack  
SR_10:	STC					;error return
SR_20:	RET					;
  
SR_30:	MOV	AX,1				;say it was CS:
 	CLC
 	RET
  
SR_40:	MOV	AX,2				;DS: seen
 	CLC
 	RET
  
SR_50:	MOV	AX,3				;ES: seen
 	CLC
 	RET
  
SR_60:	MOV	AX,4				;SS: seen
 	CLC
 	RET
SEGMENT_REG	ENDP
  
; returns a value from the data area holding contents
; of the different segment registers
  
GET_VALUE	PROC
 	CMP	AL,1
 	JZ	GV_10				;its CS:
 	CMP	AL,2
 	JZ	GV_20				;no its DS:
 	CMP	AL,3
 	JZ	GV_30				; ES:
 	MOV	AX,YOUR_SS			;none so its SS:
 	RET
GV_10:	MOV	AX,YOUR_CS
 	RET
GV_20:	MOV	AX,YOUR_DS
 	RET
GV_30:	MOV	AX,YOUR_ES
 	RET
GET_VALUE	ENDP

	PAGE

COMMENT	%

 gets a register name pointer set up in DI for single registers

%

SINGLE_REG	PROC
	CALL	GET_NEXT_CHARX			;look to see next char
	JC	SR$ERROR
	CMP	AL,'H'				; got to be H,L
	JZ	SR$10
	CMP	AL,'L'
	JZ	SR$20
SR$ERROR:
	STC
	RET
SR$10:	CALL	GET_CHAR			;look at first character
	JC	SR$ERROR
	SUB	AL,'A'				;take off base
	JC	SR$ERROR			; < A
	CMP	AL,4
	JNC	SR$ERROR			; it was > D
	MOV	DI, OFFSET YOUR_AX		;get start of table
	XOR	AH,AH				;clear high byte
	SHL	AL,1				;index * 2
	INC	AL				; plus one
	ADD	DI,AX				;base + index = register loc.
	CALL	GET_CHAR			;get the second character
	RET					;shouldnt have carry
SR$20:	CALL	GET_CHAR			;look at first character
	JC	SR$ERROR
	SUB	AL,'A'				;take off base
	JC	SR$ERROR			; < A
	CMP	AL,4
	JNC	SR$ERROR			; it was > D
	MOV	DI, OFFSET YOUR_AX		;get start of table
	XOR	AH,AH				;clear high byte
	SHL	AL,1				;index * 2
	ADD	DI,AX				;base + index = register loc.
	CALL	GET_CHAR			;get the second character
	RET					;shouldnt have carry
SINGLE_REG	ENDP

COMMENT	%

 gets a register name pointer set up in DI for double registers

%

DOUBLE_REG	PROC
	CALL	GET_NEXT_CHARX			;get the next character
	JC	DR$ERROR
	CMP	AL,'X'				;got to be X,I,P
	JZ	DR$10
	CMP	AL,'I'
	JZ	DR$20
	CMP	AL,'P'
	JZ	DR$30
DR$ERROR:
	STC
	RET
DR$10:	CALL	GET_CHAR			;get first char
	JC	DR$ERROR
	SUB	AL,'A'				;remove offset
	JC	DR$ERROR			; < A
	CMP	AL,4
	JNC	DR$ERROR			; > D
	MOV	DI, OFFSET YOUR_AX		;get base address
	SHL	AL,1				;index * 2
	XOR	AH,AH				;clear high
	ADD	DI,AX				;base + index = table address
	CALL	GET_CHAR			;get second char officially
	RET					;done
DR$20:	CALL	GET_CHAR			;get first character
	CMP	AL,'D'				;got to be D or S
	JZ	DR$21
	CMP	AL,'S'
	JZ	DR$22
	JMP	DR$ERROR
DR$21:	MOV	DI, OFFSET YOUR_DI		;address for move
	CALL	GET_CHAR
	RET
DR$22:	MOV	DI, OFFSET YOUR_SI
	CALL	GET_CHAR
	RET
DR$30:	CALL	GET_CHAR
	CMP	AL,'B'
	JZ	DR$31
	CMP	AL,'S'
	JZ	DR$32
	JMP	DR$ERROR
DR$31:	MOV	DI, OFFSET YOUR_BP
	CALL	GET_CHAR
	RET
DR$32:	MOV	DI, OFFSET YOUR_SP
	CALL	GET_CHAR
	RET
DOUBLE_REG	ENDP

	SUBTTL

	PAGE

	SUBTTL Display contents of the registers etc.
  
COMMENT	%

these routines are for the register and flag display

BREAKPOINTS	display current breakpoints
REGISTERS	output all register contents
POINTERS	output locations pointed to by registers capable of pointing
FLAGS		output the flag statuses

%
  
BREAKPOINTS	PROC  
; display the breakpoints that we have to the screen
	XOR	AH,AH				;clear high count
	CMP	BP_FLAGS,0			;any count?
 	JZ	BP_EXIT				;nothing
	GOTO	YORG+12,XORG+65			;go to display
	XOR	SI,SI				;clear index
 	MOV	CX,MAX_BP			;no of breaks
 	MOV	AL,BP_FLAGS			;pick up flags
BP_10:	RCR	AL,1				;get a bit
	PUSH	AX				;save flags
 	JNC	BP_20				;no carry means no break
 	MOV	AX,BP_OFFSETS[SI]		;show offsets
 	CALL	OUTHEX_AX
 	JMP	BP_30				;increase pointers
BP_20:	OUTPUT					;put out spaces
 	OUTPUT
 	OUTPUT
 	OUTPUT
BP_30:	INC	SI
 	INC	SI
 	INC	DH				;next line
	CALL	MOVETO
	POP	AX				;get flags back
 	LOOP	BP_10				;round until done
	RET
;special exit for when we want to clear all spaces
BP_EXIT:
	MOV	CX,MAX_BP
	GOTO	YORG+12,XORG+65			;cheap and nasty solution
BP_E1:	OUTPUT
	OUTPUT
	OUTPUT
	OUTPUT
	INC	DH
	CALL	MOVETO
	LOOP	BP_E1
	RET
BREAKPOINTS	ENDP

STACK_DISPLAY		PROC
	TEST	S_COUNT,0FFH			;any count?
	JZ	SD$20				;no so exit
	XOR	CH,CH
	MOV	CL,S_COUNT			;get stack count
	MOV	ES,YOUR_SS			;point to their stack
	MOV	BX,YOUR_SP			;get top of stack
	MOV	AX,CX				;adjust with count
	DEC	AX				;make sure first is picked up
	SHL	AX,1				;count * 2 for word entries
	ADD	BX,AX				;make adjustment
	MOV	DH,YORG+5			;start of stack display
	MOV	DL,XORG+73
SD$10:	CALL	MOVETO				;go there
	MOV	AX,ES:[BX]			;pick up entry
	CALL	OUTHEX_AX			;display it
	INC	DH				;next line
	CMP	DH,YORG+17			;are we at end?
	JZ	SD$30				;yes
	DEC	BX				;point to next entry
	DEC	BX
	LOOP	SD$10				;count down
	MOV	CL,S_COUNT			;get count again
	MOV	DL,XORG+73
	MOV	DH,YORG+5
	ADD	DH,CL				;add count
	MOV	AL,(YORG+17)-(YORG+5)
	SUB	AL,CL				;set up remainder counter
	MOV	CL,AL
SD$11:	CALL	MOVETO				;go there
	OUTPUT
	OUTPUT					;fill up with spaces
	OUTPUT					;not elegant but easy!
	OUTPUT
	INC	DH
	LOOP	SD$11
	JMP	SD$30
SD$20:	GOTO	YORG+5,XORG+73			;fill with spaces
	OUTPUT
	OUTPUT
	OUTPUT
	OUTPUT
SD$30:	RET
STACK_DISPLAY		ENDP

INS_INIT	PROC
	MOV	DISPLAY$FLAG,TRUE		;display the start screen
	MOV	BX,4				;start with third entry
	MOV	LINE_CNT,2			;and third line
II$10:	MOV	AX,ADDRESS_SEGS[BX]		;get address from table
	MOV	CURRENT_CS,AX			;set up parameter block
	MOV	ES,AX				;es=code segment
	MOV	SI,ADDRESS_OFFSETS[BX]
	MOV	CURRENT_IP,SI
	CALL	DECODE				;decode and display
	INC	LINE_CNT			;bump line count
	CMP	LINE_CNT,7			;end?
	JZ	II$20				;yes
	INC	BX				;word table pointer
	INC	BX
	XOR	AH,AH				;else calc next ins address
	MOV	AL,BYTE_COUNT			;get instruction length
	ADD	AX,CURRENT_IP			;assume all intersegment****!
	MOV	ADDRESS_OFFSETS[BX],AX		;new ip
	MOV	AX,CURRENT_CS
	MOV	ADDRESS_SEGS[BX],AX		;keep old CS
	JMP	II$10				;round until done
II$20:	RET

INS_INIT	ENDP
REGISTERS	PROC
 	DISPLAY_REG	YORG+3,XORG+58,YOUR_AX		; display AX
 	DISPLAY_REG	YORG+4,XORG+58,YOUR_BX		; BX
 	DISPLAY_REG	YORG+5,XORG+58,YOUR_CX		; CX
 	DISPLAY_REG	YORG+6,XORG+58,YOUR_DX		; DX
 	DISPLAY_REG	YORG+8,XORG+58,YOUR_BP		; BP
 	DISPLAY_REG	YORG+9,XORG+58,YOUR_SI		; SI
 	DISPLAY_REG	YORG+10,XORG+58,YOUR_DI		; DI
 	DISPLAY_REG	YORG+12,XORG+58,YOUR_CS		; CS
 	DISPLAY_REG	YORG+13,XORG+58,YOUR_DS		; DS
 	DISPLAY_REG	YORG+14,XORG+58,YOUR_ES		; ES
 	DISPLAY_REG	YORG+1,XORG+74,YOUR_SS		; SS
 	DISPLAY_REG	YORG+3,XORG+74,YOUR_SP		; SP
 	RET						; done them
REGISTERS	ENDP
  
;display contents pointed to by registers
  
POINTERS	PROC
	DISPLAY_POINTER		YORG+4,XORG+64,YOUR_BX	; (BX)
	DISPLAY_POINTER		YORG+8,XORG+64,YOUR_BP	; (BP)
	DISPLAY_POINTER		YORG+9,XORG+64,YOUR_SI	; (SI)
	DISPLAY_POINTER		YORG+10,XORG+64,YOUR_DI	; (DI)
	RET						; finished
POINTERS	ENDP
  
FLAGS		PROC
; display flags
 	MOV	AX,YOUR_FLAGS			;get your flags
 	PUSH	AX				;save copy
 	DISPLAY_FLAG	YORG+1,XORG+57,OVERFLOW,O 	;overflow
 	POP	AX				;reget copy
 	PUSH	AX				;save again
 	DISPLAY_FLAG	YORG+1,XORG+58,DIRECTION,D	;direction flag
 	POP	AX				;keep going
 	PUSH	AX				;till we've done all
 	DISPLAY_FLAG	YORG+1,XORG+59,INTERRUPT,I
 	POP	AX
 	PUSH	AX
 	DISPLAY_FLAG	YORG+1,XORG+60,TRAP,T
 	POP	AX
 	PUSH	AX
 	DISPLAY_FLAG	YORG+1,XORG+61,SIGN,S
 	POP	AX
 	PUSH	AX
 	DISPLAY_FLAG	YORG+1,XORG+62,ZERO,Z
	POP	AX
 	PUSH	AX
 	DISPLAY_FLAG	YORG+1,XORG+64,AUXILIARY,A
 	POP	AX
 	PUSH	AX
 	DISPLAY_FLAG	YORG+1,XORG+66,PARITY,P
 	POP	AX
 	DISPLAY_FLAG	YORG+1,XORG+68,CARRY,C
 	RET					;thats it
FLAGS		ENDP

	SUBTTL

	PAGE
	
	SUBTTL	Escape sequence subroutines
  
	COMMENT	%

	Escape sequence routines

	contents:

	CLEAR_SCREEN		clears screen and homes cursor
	CURSOR_ON		turns cursor on
	CURSOR_OFF		turns cursor off
	DELETE_EOLN		erases from cursor to end of line
	DELETE_LINE		erases line cursor is on
	DISABLE_25TH		disable 25th line
	ENABLE_25TH		enables the 25th line
	GRAPHICS_ON		switches on character graphics
	GRAPHICS_OFF		switched off character graphics
	REVERSE_ON		turns inverse video on
	REVERSE_OFF		turns inverse video off
	RESTORE_CURSOR		restores saved cursor position
	SAVE_CURSOR		saves current cursor position

	%


CLEAR_SCREEN	PROC	NEAR
	CON_ESC2	E
	RET
CLEAR_SCREEN	ENDP

CLICK_ON	PROC	NEAR
	CON_ESC3	y,2
	RET
CLICK_ON	ENDP

CLICK_OFF	PROC	NEAR
	CON_ESC3	x,2
	RET
CLICK_OFF	ENDP

CURSOR_ON	PROC	NEAR
	CON_ESC3	y,5
	RET
CURSOR_ON	ENDP

CURSOR_OFF	PROC	NEAR
	CON_ESC3	x,5
	RET
CURSOR_OFF	ENDP

DELETE_EOLN	PROC	NEAR
	CON_ESC2	K
	RET
DELETE_EOLN	ENDP

DELETE_LINE	PROC	NEAR
	CON_ESC2	l
	RET
DELETE_LINE	ENDP

DISABLE_25TH	PROC	NEAR
	CON_ESC3	y,1
	RET
DISABLE_25TH	ENDP

ENABLE_25TH	PROC	NEAR
	CON_ESC3	x,1
	RET
ENABLE_25TH	ENDP

GRAPHICS_ON	PROC	NEAR
	CON_ESC2	F
	RET
GRAPHICS_ON	ENDP

GRAPHICS_OFF	PROC	NEAR
	CON_ESC2	G
	RET
GRAPHICS_OFF	ENDP

REVERSE_ON	PROC	NEAR
	CON_ESC2	p
	RET
REVERSE_ON	ENDP

REVERSE_OFF	PROC	NEAR
	CON_ESC2	q
	RET
REVERSE_OFF	ENDP

RESTORE_CURSOR	PROC	NEAR
	CON_ESC2	k
	RET
RESTORE_CURSOR	ENDP

SAVE_CURSOR	PROC	NEAR
	CON_ESC2	j
	RET
SAVE_CURSOR	ENDP


CODESEG		ENDS

	END

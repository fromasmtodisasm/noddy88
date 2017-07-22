	PAGE	45,132

	TITLE Noddy88 debugger

 	SUBTTL Command input routine
   
COMMENT	%
 
 This is the start of the command scanner
  
 The scanner loops until a character is entered
 then places the character in our internal buffer
 and updates a character counter and pointer
 looping continues until a <RETURN> is entered and the
 control passes out of this routine to the command
 processor routine
  
 certain characters are given special treatment:

 <TAB> indicates single stepping of an instruction
 	is required. This character has been chosen
 	purely for compatibility with the program
 	that provided the basis for this.
 <BACKSPACE> and <DELETE> are both taken to mean
 	rubout and the cursor is moved backwards
 	destructively
 
 The <H>, for help command is reacted to immediately, without
 having to press <return>.

%

	.SALL

	.XLIST
	INCLUDE	ASCII.ASM
	INCLUDE	NOD88DEF.ASM
	INCLUDE	MACLIB88.ASM
	.LIST

	EXTRN	LCURSOR:NEAR
	EXTRN	RCURSOR:NEAR
	EXTRN	IBUFF:WORD
	EXTRN	IBUFFC:BYTE
	EXTRN	IBUFFP:NEAR

	PUBLIC	CLEAR_CMD
	PUBLIC	COMMAND_IN


CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG 

	EXTRN	GRAPHICS_OFF:NEAR
	EXTRN	GRAPHICS_ON:NEAR
	EXTRN	INPUT_CHAR:NEAR
	EXTRN	MOVETO:NEAR
	EXTRN	OUTPUT_CHAR:NEAR
	EXTRN	RIGHT_COMMAND:NEAR
	EXTRN	SSTEP:NEAR

  
COMMAND_IN		PROC
 	GOTO	3,6			;move to command start
 	XOR	AX,AX			;clear accumulator
 	MOV	IBUFFC,AL		;clear byte counter
CMD_10: MOV	DI, OFFSET IBUFF	;point to buffer
 	MOV	IBUFFP,DI		;put pointer in safe place
 	MOV	CL,0			;clear counter
CMD_20: CALL	INPUT_CHAR		;get character
 	CMP	AL,0			;anything?
 	JZ	CMD_20			;no not yet
 	CMP	AL,' '-1		;command character?
 	JC	CMD_50			;yes
 	CMP	AL,DEL			;delete?
 	JZ	CMD_60			;yes
 	CMP	AL,'Z'+1		;is it upper case?
 	JC	CMD_30			;already upper case
 	AND	AL,5FH			;convert to upper case
CMD_30: MOV	[DI],AL 		;save it
 	MOV	AL,26			;get maximum size of buffer
 	CMP	AL,CL			;is it at limit?
 	JZ	CMD_20			;yes
 	MOV	AL,[DI] 		;get character back
 	INC	DI			;increase pointer
 	INC	CL			;and counter
CMD_40: CALL	OUTPUT_CHAR		;output the character
 	CALL	RCURSOR 		;move the cursor delimiter
	CMP	CL,1			;is count one?
	JNZ	CMD_20			;no so ignore special case
	CMP	BYTE PTR [DI-1],'H'	;is it HELP command?
	JZ	CMD_HELP		;yes so exit immediately
	JMP	CMD_20			;no so back for more

; here to process a control character

CMD_50: CMP	AL,BS			;is it backspace?
	JZ	CMD_60			;yes
 	CMP	AL,HT			;horizontal tab?
 	JZ	CMD_51			;yes
 	CMP	AL,CR			;return?
 	JNZ	CMD_20			;no so ignore it
 
; end of input line reached
CMD_HELP:  
 	MOV	IBUFFC,CL		;store counter
 	RET				;done
  
; here to process a TAB (single step command)
  
CMD_51: TEST	CL,CL			;test for a count
 	JNZ	CMD_20			;if count non zero ignore tab
	JMP	SSTEP			;single step mode if count=0
  
; here for a delete character
  
CMD_60: CMP	CL,0			;test count
 	JZ	CMD_20			;if nothing there then ignore
 	DEC	DI			;decrease pointer
 	DEC	CL			;and counter
 	CALL	LCURSOR 		;move cursor delimiter backwards
 	JMP	CMD_20			;back for more
COMMAND_IN	ENDP
  
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

CODESEG		ENDS

	END


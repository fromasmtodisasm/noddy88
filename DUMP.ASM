	PAGE	45,132

	TITLE Noddy88 debugger

	SUBTTL Dump memory routines

COMMENT	%

 Here to dump memory locations to the screen
 in either hex or ascii with a choice of
 segment address and offset address

 Find the addresses for the dump
 Routine expects:

 <space>xx:nnnn	where	xx:	= valid segment register name
		 	nnnn	= four digit hex number
 or

 <space>nnnn:mmmm where	nnnn	= four digit hex number
		 	mmmm	=	ditto

 The results are saved in:

 DUMP_BASE	segment address for dump
 DUMP_OFFSET	offset address for dump
%

	.SALL

	.XLIST
	INCLUDE	MACLIB88.ASM
	INCLUDE	NOD88DEF.ASM
	.LIST

	PAGE

	PUBLIC	DUMP
	PUBLIC	DUMP1

	EXTRN	DUMP_BASE:WORD
	EXTRN	DUMP_OFFSET:WORD
	EXTRN	ASCII_FLAG:BYTE



CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

	EXTRN	GET_CHAR:NEAR
	EXTRN	GET_SEGMENT:NEAR
	EXTRN	MOVETO:NEAR
	EXTRN	OUTPUT_CHAR:NEAR
	EXTRN	OUTPUT_ASC:NEAR
	EXTRN	OUTHEX_AL:NEAR
	EXTRN	OUTHEX_AX:NEAR
  
DUMP		PROC
 	CALL	DUMP_TYPE			;ascii or hex?
 	JC	DUMP_ERROR			;error
	CALL	GET_CHAR
	CMP	AL,' '
	JNZ	DUMP_ERROR
 	CALL	GET_SEGMENT			;find the addresses
 	JC	DUMP_ERROR			;error
	MOV	DUMP_BASE,BX			;save addresses
	MOV	DUMP_OFFSET,DX			;in data area
DUMP1: 	CMP	ASCII_FLAG,TRUE 		;is it ascii?
 	JNZ	DMP_10				;no its hex
 	CALL	DUMP_ASCII			;ascii dump
 	JMP	DMP_20				;exit
DMP_10: CALL	DUMP_HEX			;dump in hex
DMP_20: CLC					;finished
	RET
DUMP_ERROR:
	STC
	RET					;carry = error
DUMP		ENDP

	PAGE
  
; find out whether hex or ascii is required
  
DUMP_TYPE	PROC
 	CALL	GET_CHAR			;get next character
 	JC	DT_10				;return error
 	CMP	AL,'A'				;ascii?
 	JZ	DT_20				;yes
 	CMP	AL,'H'				;hex then?
 	JZ	DT_30				;yes
 	STC					;else error
DT_10:	RET					;exit
  
DT_20:	MOV	ASCII_FLAG,TRUE 		;set ascii flag
 	RET					;done
  
DT_30:	MOV	ASCII_FLAG,FALSE		;unset flag
 	RET					;done
DUMP_TYPE	ENDP

	PAGE

; controls the ascii dump to the screen

DUMP_ASCII	PROC
	MOV	AX,DUMP_BASE			;get base address
	MOV	ES,AX				;ES used as seg reg
	MOV	AX,DUMP_OFFSET			;get offset
	MOV	SI,AX				;into index reg
	GOTO	DYORD,DXORD			;go to screen start
	CALL	DUMP_RANGE			;set up range
	MOV	CX,0				;zero line counter
DA_10:	CALL	DUMP_NEWLINE			;set up for new line
	MOV	AL,' '				;output initial space
	CALL	OUTPUT_CHAR			;
DA_20:	MOV	AL,ES:[SI]			;get byte
	CALL	OUTPUT_ASC			;output as ascii
	INC	SI				;increase pointer
	MOV	AX,SI				;get new value
	AND	AL,0FH				;end of line?
	JZ	DA_30				;yes
	OUTPUT					;show two spaces
	OUTPUT
	JMP	DA_20				;no continue
DA_30:	CALL	DUMP_STOP			;end of dump
	INC	CX				;increase line count
	MOV	DL,DXORD			;get column no back
	MOV	DH,CL				;get line count
	ADD	DH,DYORD			;add base line no
	CALL	MOVETO				;go to new line
	JMP	DA_10				;start new line
DUMP_ASCII	ENDP
  
; starts a new line
  
DUMP_NEWLINE	PROC
 	MOV	AX,SI				;get latest offset
 	PUSH	SI
 	CALL	OUTHEX_AX			;output AX as foufour digits
 	MOV	AL,':'				;and seperator
 	CALL	OUTPUT_CHAR			;output it
 	POP	SI
 	RET
DUMP_NEWLINE	ENDP
  
; see if were at end of dump addresses
  
DUMP_STOP	PROC
 	MOV	AX,BX				;get offset address
 	SUB	AX,SI				;see if done
 	JC	DS_10				;finished
 	RET					;not done-back to DUMP
DS_10:	POP	AX				;raise stack
	MOV	DL,59
	CALL	MOVETO				;show the base we used
	MOV	AX,ES
	CALL	OUTHEX_AX
 	RET					;back to command
DUMP_STOP	ENDP

; sets the offset
 
DUMP_RANGE	PROC
 	MOV	AX,SI				;get offset
 	OR	AL,0FH				;set the low bits
 	XOR	AL,0FH				;clear them and flags
 	MOV	BX,AX				;save the new start
 	MOV	SI,AX				;and new offset
 	ADD	BX,50H				;add new line number
 	RET					;done
DUMP_RANGE	ENDP
  
	PAGE

; controls the hex dump
  
DUMP_HEX	PROC
 	MOV	AX,DUMP_BASE			;get base address
 	MOV	ES,AX				;use ES for this
 	MOV	AX,DUMP_OFFSET			;get offset
 	MOV	SI,AX				;use index register
 	GOTO	DYORD,DXORD			;go to start of dump
 	CALL	DUMP_RANGE			;initialise addresses
 	MOV	CX,0				;zero line count
DH_10:	CALL	DUMP_NEWLINE			;set up for new line
DH_20:	MOV	AL,ES:[SI]			;get byte
 	CALL	OUTHEX_AL			;output it
 	INC	SI				;increase pointer
 	MOV	AX,SI				;get offset
 	AND	AL,0FH				;end of line?
 	JZ	DH_30				;yes
 	MOV	AL,' '				;get space
 	CALL	OUTPUT_CHAR			;output it
 	JMP	DH_20				;no
DH_30:	CALL	DUMP_STOP			;end of dump?
 	INC	CX				;no increase line count
 	MOV	DL,DXORD			;move to next line
 	MOV	DH,CL				;get line count
 	ADD	DH,DYORD			;add base line
 	CALL	MOVETO				;go there
 	JMP	DH_10				;back for new line
DUMP_HEX	ENDP

CODESEG		ENDS

	END


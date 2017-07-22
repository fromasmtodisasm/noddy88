	PAGE	45,132

	TITLE Noddy88 debugger

	SUBTTL Breakpoint command processor


COMMENT	%

	sets and unsets break points in user program

	uses the INT 3 instruction

	command line:

	Bn<offset>				;set break point n

	Bn					;remove break point n

	where n = 1-4 inclusive,
	and <offset> is the offset from the current code segment
	given as a four digit hex number.
%

	.SALL

	PUBLIC	BREAK

	EXTRN	BP_FLAGS:BYTE
	EXTRN	BP_OFFSETS:WORD
	EXTRN	BP_SEGS:WORD
	EXTRN	IBUFFC:BYTE

	EXTRN	YOUR_CS:WORD

	EXTRN	BREAKPOINTS:NEAR
	EXTRN	DUMP1:NEAR
	EXTRN	GET_CHAR:NEAR
	EXTRN	WORD2_BIN:NEAR

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

BREAK		PROC
 	CALL	GET_CHAR			;get number
 	JC	BREAK_ERROR1			;wrong
 	CMP	AL,'1'-1			; < '1'
 	JC	BREAK_ERROR1			; yes
 	CMP	AL,'4'+1			; n > '4'?
 	JNC	BREAK_ERROR1			;yes error
	SUB	AL,'1'				;remove offset
 	CMP	IBUFFC,0			;any more count left?
 	JZ	BREAK_UNSET			;no so break reset
 	PUSH	AX				;save index temp
	CALL	GET_CHAR
	CMP	AL,' '
	JNZ	BREAK_ERROR 
	CALL	WORD2_BIN			;get offset
 	JC	BREAK_ERROR			;mistake
	POP	DI				;get index back
	SHL	DI,1				;index * 2 for word table
	MOV	BX,YOUR_CS			;default to code segment
	MOV	BP_SEGS[DI],BX			;save segment
	MOV	BP_OFFSETS[DI],DX		;and offset
	MOV	AL,BP_FLAGS			;get flags
	SHR	DI,1				;restore count
	INC	DI
	MOV	CX,DI				;bit count
	RCR	AL,CL				;get bit
	STC					;show we now have a new break
	MOV	CX,DI				;get count again
	RCL	AL,CL				;put every thing back
	MOV	BP_FLAGS,AL
	JMP	BP_RETURN			;no mistake

BREAK_ERROR:
	POP	AX				;remove the rubbish
BREAK_ERROR1:
	STC
 	RET					;carry=error

 	PAGE

BREAK_UNSET:
 	INC	AX				;increase offset
	PUSH	AX				;save it temp
 	MOV	CX,AX				;get it as counter
 	MOV	AL,BP_FLAGS			;get flags
 	RCR	AL,CL				;rotate
 	CLC					;unset bit
 	POP	CX				;restore offset
 	RCL	AL,CL				;put bit back
 	MOV	BP_FLAGS,AL
 
BP_RETURN:
	CALL	DUMP1				;for now
	CALL	BREAKPOINTS
	CLC
	RET
BREAK		ENDP

CODESEG		ENDS

	END



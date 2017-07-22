	PAGE	45,132

	TITLE Noddy88 debugger

 	SUBTTL Fill command processor
 
COMMENT	%
 
 	This command fills memory with a byte value for a given range
 
 	command format:
 
	F <sr:nnnn> <sr:mmmm> <bb>
or	F <aaaa:nnnn> <bbbb:mmmm> <bb>

	where		sr	= segment register name, eg DS
	aaaa,bbbb,mmmm,nnnn	= 4 digit hexadecimal number
			bb	= 2 digit hexadecimal number

 and lower base & offset values MUST be < higher base & offset values

%
	.SALL

	PAGE

	PUBLIC	FILL
	PUBLIC	F_10

	INCLUDE	MACLIB88.ASM
	EXTRN	IBUFFC:BYTE
	EXTRN	MOVETO:NEAR
	EXTRN	OUTHEX_AL:NEAR
	EXTRN	OUTHEX_AX:NEAR

	EXTRN	BYTE2_BIN:NEAR
	EXTRN	DUMP1:NEAR
	EXTRN	GET_CHAR:NEAR
	EXTRN	GET_SEGMENT:NEAR

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

FILL		PROC
	CALL	GET_CHAR
	JC	FILL_ERROR
	CMP	AL,' '
	JNZ	FILL_ERROR
	CALL	GET_SEGMENT			;get segment value
	JC	FILL_ERROR			;wrong!
	MOV	ES,BX				;set up pointers
	MOV	DI,DX
	CALL	GET_SEGMENT			;get next address
	JC	FILL_ERROR			;error
	CALL	CHECK_ADDRESS			;test the addresses
	JC	FILL_ERROR			;mistake
	PUSH	DX				;save the second offset
	CALL	BYTE2_BIN			;get byte for fill
	POP	DX
	JC	FILL_ERROR
F_10:	MOV	ES:[DI],AL			;deposit byte
	PUSH	AX				;save data byte
	CALL	CHECK_STOP			;finished?
	POP	AX				;restore data byte
	JNZ	F_10				;no
	CALL	DUMP1				;just checking...
FILL_EXIT:
	CLC					;clear carry return
	RET
FILL_ERROR:
	STC
	RET					;return, carry=error
FILL		ENDP


; this subroutine checks for the end of memory fill
; but can be used generally
;
; enter with :
;
;	ES:	- segment address of low address
;	DI	- offset address of low address
;	BX	- segment address of high address
;	DX	- offset address of high address
;
; exits with zero flag set if two addresses are equal
CHECK_STOP	PROC
	CMP	DX,DI				;offsets equal?
	JZ	CS_30				;yes
	INC	DI				;no so low offset = l o + 1
CS_10:	MOV	AH,1				;clear zero flag
	AND	AH,AH
CS_20:	RET

CS_30:	MOV	AX,ES
	CMP	BX,AX				;are segments equal?
	JZ	CS_20				;yes so finish
	MOV	AX,ES				;else bump
	ADD	AX,1000H			;segment
	MOV	ES,AX
	XOR	DI,DI				;reset low offset
	JMP	CS_10
CHECK_STOP	ENDP

 
CHECK_ADDRESS	PROC
	MOV	AX,ES
 	CMP	BX,AX				;high seg - low seg
 	JNZ	CHECK_ERROR			;not right low<>high
 	CMP	DX,DI				;low<high for offsets
	JC	CHECK_ERROR
	RET
CHECK_ERROR:
	STC
 	RET					;carry = error
CHECK_ADDRESS	ENDP


CODESEG		ENDS

	END

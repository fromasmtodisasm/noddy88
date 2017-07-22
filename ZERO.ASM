	PAGE	45,132

	TITLE Noddy88 debugger

	SUBTTL Zero command processor

COMMENT	%
 
 	fills memory range with nuls
 
 	special case of FILL command and uses the fill routines

	command line:

	Z<seg reg OR address>:<offset> <seg reg OR address>:<offset>

	where <seg reg> is one of CS, DS, ES, SS
	and <address> and <offset> are the
	segment address and offset addresses respectively
	written as 4-digit hex numbers.

%
	.SALL

	PUBLIC	ZERO

	EXTRN	F_10:NEAR
	EXTRN	GET_CHAR:NEAR
	EXTRN	GET_SEGMENT:NEAR

	PAGE

CODESEG		SEGMENT	PUBLIC

	ASSUME	CS:CODESEG

ZERO		PROC
	CALL	GET_CHAR
	JC	ZERO_ERROR
	CMP	AL,' '
	JNZ	ZERO_ERROR
	CALL	GET_SEGMENT			;get the addresses
	JC	ZERO_ERROR			;failed
	MOV	ES,BX				;set up segment
	MOV	DI,DX				;save offset
	CALL	GET_SEGMENT			;get second address
	JC	ZERO_ERROR			;error
	XOR	AL,AL				;fill with 0
	JMP	F_10				;use fill routines
ZERO_ERROR:
 	RET					;carry=error
ZERO		ENDP

CODESEG		ENDS

	END


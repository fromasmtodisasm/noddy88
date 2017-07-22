	PAGE	45,132

	TITLE	Noddy88 debugger

 	SUBTTL	Modify the instruction pointer
 
COMMENT	%
 
	sets the CS and IP registers to a new value

	command line:

	P <seg reg or address>:<offset>

	where <seg reg> is one of CS, DS, ES, SS
	and <address> and <offset> are the segment
	and offset addresses respectively

%
	.SALL

	PUBLIC	PROGRAM_COUNTER

	EXTRN	ADDRESS_OFFSETS:WORD
	EXTRN	ADDRESS_SEGS:WORD
	EXTRN	YOUR_CS:WORD
	EXTRN	YOUR_IP:WORD

	EXTRN	FLAGS:NEAR
	EXTRN	GET_CHAR:NEAR
	EXTRN	GET_SEGMENT:NEAR
	EXTRN	INS_INIT:NEAR
	EXTRN	POINTERS:NEAR
	EXTRN	REGISTERS:NEAR

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

PROGRAM_COUNTER	PROC
	CALL	GET_CHAR			;skip space
	CMP	AL,' '
	JNZ	P_ERROR
	CALL	GET_SEGMENT
	JC	P_ERROR				;error in addresses
	MOV	YOUR_CS,BX			;save offset
	MOV	YOUR_IP,DX			;and segment addresses
	MOV	ADDRESS_OFFSETS+4,DX
	MOV	ADDRESS_SEGS+4,BX
	CALL	INS_INIT			;initialise ins display
	CALL	POINTERS
	CALL	REGISTERS			;redisplay registers
	CALL	FLAGS
	CLC					;clear carry
	RET
P_ERROR:
	STC
	RET					;carry=error
PROGRAM_COUNTER	ENDP

CODESEG		ENDS

	END

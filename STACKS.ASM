	PAGE	45,132


	TITLE Noddy88 debugger

	SUBTTL Stack command processor

COMMENT	%

	manipulates the stack

	command line:

	SS <word>		;push word on stack
	SP			;take top word off stack

%

	.SALL

	PUBLIC	STACKS

	EXTRN	S_COUNT:BYTE
	EXTRN	YOUR_SP:WORD
	EXTRN	YOUR_SS:WORD

	EXTRN	DUMP1:NEAR
	EXTRN	FLAGS:NEAR
	EXTRN	GET_CHAR:NEAR
	EXTRN	POINTERS:NEAR
	EXTRN	REGISTERS:NEAR
	EXTRN	STACK_DISPLAY:NEAR
	EXTRN	WORD2_BIN:NEAR
 
	PAGE

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

STACKS		PROC
	CALL	GET_CHAR			;get qualifier
	CMP	AL,'H'				;push?
	JZ	STACK_PUSH			;yes
	CMP	AL,'P'				;pop?
	JZ	STACK_POP			;yes
STACK_ERROR:
	STC					;error then
	RET

STACK_PUSH:
	CALL	GET_CHAR			;skip space
	CMP	AL,' '
	JNZ	STACK_ERROR
	CALL	WORD2_BIN			;get word value
	JC	STACK_ERROR			;error
	MOV	ES,YOUR_SS			;set up segment
	DEC	YOUR_SP				;fake a push
	DEC	YOUR_SP
	MOV	BX,YOUR_SP			;their offset
	MOV	ES:[BX],DX			;place the word
	MOV	YOUR_SS,ES			;save new values
	INC	S_COUNT
 	JMP	STACK_EXIT			;tidy up
 
 STACK_POP:
	TEST	S_COUNT,0FFH			;anything there?
	JZ	STACK_ERROR			;no-so error
	DEC	S_COUNT				;fake a pop
	INC	YOUR_SP
	INC	YOUR_SP

STACK_EXIT:
	CALL	REGISTERS			;update registers
	CALL	POINTERS
	CALL	FLAGS
	CALL	DUMP1				;dump memory
	CALL	STACK_DISPLAY			;display contents of stack 
	CLC
 	RET
STACKS		ENDP

CODESEG		ENDS

	END


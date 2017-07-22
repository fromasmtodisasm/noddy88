	PAGE	45,132

	TITLE Noddy88 debugger

 	SUBTTL Quit program routine

COMMENT	%

	tidies up before exit back to Z-DOS

	functions carried out are:

	1. restore system vectors for INT 1 and INT 3
	2. clear the 25th line
	3. clear screen

%

	.SALL

	.XLIST
	INCLUDE	MACLIB88.ASM
	.LIST

	EXTRN	CLEAR_SCREEN:NEAR
	EXTRN	CURSOR_ON:NEAR
	EXTRN	DELETE_LINE:NEAR
	EXTRN	DISABLE_25TH:NEAR
	EXTRN	MOVETO:NEAR
	EXTRN	RET_ADDRESS:DWORD
	EXTRN	SYSTEM_INT1_IP:WORD
	EXTRN	SYSTEM_INT1_CS:WORD
	EXTRN	SYSTEM_INT3_IP:WORD
	EXTRN	SYSTEM_INT3_CS:WORD

	PAGE

	PUBLIC	QUIT

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

; here to tidy up and exit from the program

QUIT		PROC
	XOR	AX,AX				;clear ES
	MOV	ES,AX
	MOV	BX,4				;initialise pointer
	MOV	AX,SYSTEM_INT1_IP		;get interrupt loc
	MOV	ES:[BX],AX			;get INT1 IP
	MOV	AX,SYSTEM_INT1_CS
	MOV	ES:[BX+2],AX			;get INT1 CS
	MOV	BX,0CH				;point to INT3 bits
	MOV	AX,SYSTEM_INT3_IP		;save INT3 IP
	MOV	ES:[BX],AX
	MOV	AX,SYSTEM_INT3_CS		;save INT3 CS
	MOV	ES:[BX+2],AX
	GOTO	25,1
	CALL	DELETE_LINE			;clear 25th line
	GOTO	1,1
	CALL	CLEAR_SCREEN
	CALL	CURSOR_ON			;turn cursor back on
	CALL	DISABLE_25TH			;turn off the 25th line now
	JMP	RET_ADDRESS			;try this first
QUIT		ENDP

CODESEG		ENDS

	END


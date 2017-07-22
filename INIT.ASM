	PAGE	45,132

	TITLE Noddy88 debugger

 	SUBTTL Initialise memory and screen

	.SALL

	.XLIST
	INCLUDE	ASCII.ASM
	INCLUDE	MACLIB88.ASM
	INCLUDE	NOD88DEF.ASM
	.LIST

	PUBLIC	INITIALISE

	EXTRN	CLEAR_SCREEN:NEAR
	EXTRN	CURSOR_OFF:NEAR
	EXTRN	DECODE:NEAR
	EXTRN	DUMP1:NEAR
	EXTRN	ENABLE_25TH:NEAR
	EXTRN	FLAGS:NEAR
	EXTRN	GRAPHICS_OFF:NEAR
	EXTRN	GRAPHICS_ON:NEAR
	EXTRN	INS_INIT:NEAR
	EXTRN	INTERRUPT_SERVICE:NEAR
	EXTRN	LOAD_CON:NEAR
	EXTRN	MOVETO:NEAR
	EXTRN	POINTERS:NEAR
	EXTRN	OUTPUT_STRING:NEAR
	EXTRN	REGISTERS:NEAR
	EXTRN	REVERSE_OFF:NEAR
	EXTRN	REVERSE_ON:NEAR
	EXTRN	SCREEN_BOXES:NEAR
	EXTRN	SYSTEM_INT1_IP:WORD
	EXTRN	SYSTEM_INT1_CS:WORD
	EXTRN	SYSTEM_INT3_IP:WORD
	EXTRN	SYSTEM_INT3_CS:WORD

	PAGE

DATASEG		SEGMENT		PUBLIC

LINE1	DB	'Noddy88    Debugger$'
LINE2	DB	'Pre-release version$'
LINE3	DB	'PNLCS',CR,LF
	DB	'Feb 1985$'

DATASEG		ENDS

	PAGE

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG,DS:DATASEG
  
; here at start to perform the following functions:
; 1 -  initialise interrupt vectors and save the system's
; 2 -  build the screen first time round
; 3 -  load a file if one given as command parameter
; 4 -  enables the 25th line for input/output

INITIALISE	PROC

	XOR	AX,AX				;clear ES
	MOV	ES,AX
	MOV	BX,4				;initialise pointer
	MOV	AX,ES:[BX]			;get INT1 IP
	MOV	SYSTEM_INT1_IP,AX		;save it
	MOV	AX,ES:[BX+2]			;get INT1 CS
	MOV	SYSTEM_INT1_CS,AX		;save it
	MOV	BX,0CH				;point to INT3 bits
	MOV	AX,ES:[BX]
	MOV	SYSTEM_INT3_IP,AX		;save INT3 IP
	MOV	AX,ES:[BX+2]
	MOV	SYSTEM_INT3_CS,AX		;save INT3 CS
	MOV	AX,SEG CODESEG			;get base of codeseg
	MOV	ES:[BX+2],AX			;save code segment
	MOV	ES:[BX-6],AX			;in INT 1 and 3 locs
	MOV	AX,OFFSET INTERRUPT_SERVICE	;get service routine address
	MOV	ES:[BX-8],AX			;in INT 1 locs
	MOV	ES:[BX],AX			;and INT 3 locs
	CALL	CLEAR_SCREEN			;clear screen
	CALL	CURSOR_OFF			;lose the cursor
	CALL	REVERSE_ON
	GOTO	YORG+7,XORG+30			;show who we are
	MOV	SI,OFFSET LINE1
	CALL	OUTPUT_STRING
	GOTO	YORG+9,XORG+30
	MOV	SI,OFFSET LINE2
	CALL	OUTPUT_STRING
	CALL	REVERSE_OFF
	GOTO	YORG+18,XORG
	MOV	SI,OFFSET LINE3
	CALL	OUTPUT_STRING
	MOV	AL,10
I$1:	MOV	CX,0FFFFH
I$2:	LOOP	I$2
	DEC	AL
	JNZ	I$1
	CALL	CLEAR_SCREEN
	CALL	LOAD_CON			;check for a file
	CALL	GRAPHICS_ON			;build the boxes
	CALL	SCREEN_BOXES
	CALL	GRAPHICS_OFF
	CALL	REGISTERS
	CALL	FLAGS
	CALL	POINTERS
	CALL	INS_INIT			;initialise instructions
	CALL	DUMP1				;initialise the screen dump
	CALL	ENABLE_25TH			;turn on the 25th line
	RET
INITIALISE	ENDP

CODESEG		ENDS

	END


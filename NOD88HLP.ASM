	PAGE	45,132


	TITLE	Noddy88 debugger

	SUBTTL	Help screen


	.SALL
	.XLIST
	INCLUDE	ASCII.ASM
	INCLUDE	MACLIB88.ASM
	INCLUDE	NOD88DEF.ASM
	.LIST

	PUBLIC	HELP

	EXTRN	ADDRESS_OFFSETS:WORD
	EXTRN	ADDRESS_SEGS:WORD
	EXTRN	CLEAR_SCREEN:NEAR
	EXTRN	CURRENT_IP:WORD
	EXTRN	CURRENT_CS:WORD
	EXTRN	DECODE:NEAR
	EXTRN	DISPLAY$FLAG:BYTE
	EXTRN	DUMP1:NEAR
	EXTRN	FLAGS:NEAR
	EXTRN	GRAPHICS_OFF:NEAR
	EXTRN	GRAPHICS_ON:NEAR
	EXTRN	LINE_CNT:BYTE
	EXTRN	MOVETO:NEAR
	EXTRN	OUTPUT_STRING:NEAR
	EXTRN	POINTERS:NEAR
	EXTRN	REGISTERS:NEAR
	EXTRN	REVERSE_OFF:NEAR
	EXTRN	REVERSE_ON:NEAR
	EXTRN	SCREEN_BOXES:NEAR
	EXTRN	INPUT_CHAR:NEAR

	PAGE

DATASEG		SEGMENT		PUBLIC

HELP_MESS1	EQU	$
; first help message is screen title
	DB	'NODDY88 HELP SCREEN'
	DB	'$'

HELP_MESS2	EQU	$
; second message is all the info
	DB	' Commands available:',CR,LF,LF
	DB	'Bn			Remove break n		L<fn>.<e>	Load any file',CR,LF
	DB	'Bn<off>			Set break n		L<fn>.EXE	Load EXE file',CR,LF
	DB	'DA<mem>			Dump ASCII		P<off>		Set IP',CR,LF
	DB	'DH<mem>			Dump hex		Q		Quit  NODDY88',CR,LF
	DB	'EAB<mem> <ch>		Enter ASCII byte	SH<word>	Push word',CR,LF
	DB	'EHB<mem> <byte>		Enter hex byte		SP		Pop word',CR,LF
	DB	'EHW<mem> <word>		Enter hex word		<TAB>		Single step',CR,LF
	DB	'ERB<reg> <byte>		Enter register byte	XF		eXecute fast',CR,LF
	DB	'ERW<reg> <word>		Enter register word	XS		eXecute slow',CR,LF
	DB	'F<mem> <mem> <byte>	Fill range with byte	Z<mem> <mem>	Zero range',CR,LF
	DB	'H			Help screen',CR,LF,LF
	DB	' where:',CR,LF
	DB	' n 	= no of breakpoint (1-4)		<fn>	= valid filename',CR,LF
	DB	' <mem>	= memory address specification		<ch>	= ASCII character',CR,LF
	DB	'	  eg. DS:0F00 or 1000:0F00		<byte>	= two hex digits',CR,LF
	DB	' <off> = offset address eg. 01A0		<word>  = four hex digits',CR,LF
	DB	' <reg> = valid 8088 register',LF
	DB	'		Press any key to return to NODDY88'
	DB	'$'

DATASEG		ENDS

	PAGE

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

HELP		PROC
	CALL	CLEAR_SCREEN			;clear screen for help
	GOTO	1,30				;heading
	CALL	REVERSE_ON
	MOV	SI, OFFSET HELP_MESS1		;header message
	CALL	OUTPUT_STRING
	CALL	REVERSE_OFF
	GOTO	3,1
	MOV	SI, OFFSET HELP_MESS2
	CALL	OUTPUT_STRING
H_10:	CALL	INPUT_CHAR			;read a character
	CMP	AL,0
	JZ	H_10
	CALL	CLEAR_SCREEN			;rebuild screen
	CALL	GRAPHICS_ON
	CALL	SCREEN_BOXES
	CALL	GRAPHICS_OFF
	CALL	REGISTERS
	CALL	POINTERS
	CALL	FLAGS
	CALL	DUMP1
	MOV	DISPLAY$FLAG,TRUE
	XOR	BX,BX				;just display the lot
	MOV	LINE_CNT,0
H_20:	MOV	AX,ADDRESS_SEGS[BX]		;get address from table
	MOV	CURRENT_CS,AX			;set up parameter block
	MOV	ES,AX				;es=code segment
	MOV	SI,ADDRESS_OFFSETS[BX]
	MOV	CURRENT_IP,SI
	CALL	DECODE				;decode and display
	INC	BX				;bump pointer
	INC	BX
	INC	LINE_CNT			;bump line count
	CMP	LINE_CNT,7			;end?
	JNZ	H_20				;yes
	MOV	DISPLAY$FLAG,FALSE
	RET
HELP		ENDP


CODESEG		ENDS

	END

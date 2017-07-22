	PAGE	45,132

	TITLE Noddy88 debugger

	SUBTTL Displays an instruction line

	.SALL

	.XLIST
	INCLUDE	NOD88DEF.ASM
	INCLUDE	MACLIB88.ASM
	.LIST

	EXTRN	BYTE_COUNT:BYTE
	EXTRN	CURRENT_CS:WORD
	EXTRN	CURRENT_IP:WORD
	EXTRN	LINE_CNT:BYTE
	EXTRN	MOVETO:NEAR
	EXTRN	M_BUFFER:BYTE
	EXTRN	M_COUNTER:BYTE
	EXTRN	OUTHEX_AX:NEAR
	EXTRN	OUTHEX_AL:NEAR
	EXTRN	OUTPUT_BUFFER:NEAR
	EXTRN	OUTPUT_CHAR:NEAR
	EXTRN	OUTPUT_MNEMONIC:NEAR
	EXTRN	REVERSE_OFF:NEAR
	EXTRN	REVERSE_ON:NEAR

	PAGE

	PUBLIC	DISPLAY

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

DISPLAY 	PROC
  
; gets the instruction displayed to screen
 
	MOV	DH,YORG+3			;line start
	ADD	DH,LINE_CNT			;add current line no
	MOV	DL,XORG+1			;x ordinate
	CALL	MOVETO
	PUSH	DX				;save coordinates
	MOV	CX,52				;length of line
DISP10:	OUTPUT					;put out spaces
	LOOP	DISP10
	POP	DX
	CALL	MOVETO				;go there
	CMP	LINE_CNT,2			;third line down?
	JNZ	DISP11				;no
	CALL	REVERSE_ON			;yes
DISP11:	CALL	DISPLAY_HEX			;display hex bytes
	CALL	DISPLAY_ADDRESS 		;and addresses
	CALL	DISPLAY_MNEMONICS		;output mnemonics
	CMP	LINE_CNT,2			;still third line
	JNZ	DISP12				;no
	CALL	REVERSE_OFF			;yes
DISP12:	RET
  
DISPLAY 	ENDP
  
 	PAGE
  
DISPLAY_HEX	PROC  
; displays an instruction in hex
	MOV	CL,BYTE_COUNT			;get byte count of ins
	XOR	CH,CH				;clear high
	MOV	ES,CURRENT_CS			;get es as code segment
	MOV	BX,CURRENT_IP
	MOV	DX,16				;space count
DX_10:	MOV	AL,ES:[BX]
	CALL	OUTHEX_AL
	DEC	DX				;decrease counters
	DEC	DX
	INC	BX				;increase pointer
	LOOP	DX_10
	MOV	CX,DX				;fill out with spaces
DX_20:	OUTPUT
	LOOP	DX_20
	RET
DISPLAY_HEX	ENDP
  
 	PAGE

DISPLAY_ADDRESS PROC
; displays current instruction address
	MOV	AX,CURRENT_CS			;get code segment
	CALL	OUTHEX_AX			;output
	MOV	AL,':'
	CALL	OUTPUT_CHAR
	MOV	AX,CURRENT_IP
	CALL	OUTHEX_AX
	OUTPUT
	OUTPUT
	RET
DISPLAY_ADDRESS ENDP

	PAGE

DISPLAY_MNEMONICS	PROC 
; current instruction mnemonics
 	MOV	CL,M_COUNTER			;get count
 	XOR	CH,CH
	XOR	BX,BX 
DM_10:	MOV	AL,M_BUFFER[BX]
 	CALL	OUTPUT_CHAR
	INC	BX
 	LOOP	DM_10
	MOV	M_COUNTER,0
 	RET
DISPLAY_MNEMONICS	ENDP


CODESEG		ENDS

	END


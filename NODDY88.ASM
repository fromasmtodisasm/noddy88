 	PAGE 45,132
    
 	TITLE Noddy88 debugger

	SUBTTL Main program
 
COMMENT	%

	Program NODDY88
	Mark 1
	J RATCLIFFE, PNLCS
	Feb 1985

	This program is the North london polytechnic Online
	Debugger DisplaY oriented ( awful isn't it ).

	What this really means is that the program is a screen
	oriented debugger, written for the ZENITH Z-100 micro
	to run under Zeniths version of MS-DOS known as Z-DOS.

	Mark 1
	Copied from an 8080 debug program written for the same
	machine to run under CPM-85, Zeniths version of CPM-80
	to operate the 8085 processor in the Z-100.

%

 	.SALL

 	PAGE	+

PUBLIC	BP_FLAGS
PUBLIC	BP_OFFSETS
PUBLIC	BP_OPS
PUBLIC	BP_SEGS

PUBLIC	IBUFF 
PUBLIC	IBUFFC
PUBLIC	IBUFFP

PUBLIC	ADDRESS_OFFSETS
PUBLIC	ADDRESS_SEGS
PUBLIC	ASCII_FLAG
PUBLIC	BYTE_COUNT
PUBLIC	COMMAND
PUBLIC	CURRENT_CS
PUBLIC	CURRENT_IP
PUBLIC	CURRENT_OP
PUBLIC	DISPLAY$FLAG
PUBLIC	DUMP_BASE
PUBLIC	DUMP_OFFSET

PUBLIC	INS_CNT
PUBLIC	LINE_CNT

PUBLIC	M_BUFFER
PUBLIC	M_COUNTER
PUBLIC	MY_SP
PUBLIC	MY_SS

PUBLIC	RET_ADDRESS

PUBLIC	S_COUNT

PUBLIC	SS_FLAG
PUBLIC	XS_FLAG
PUBLIC	XF_FLAG

PUBLIC	SYSTEM_INT1_IP
PUBLIC	SYSTEM_INT1_CS
PUBLIC	SYSTEM_INT3_IP
PUBLIC	SYSTEM_INT3_CS

PUBLIC	YOUR_AX
PUBLIC	YOUR_BX
PUBLIC	YOUR_CX
PUBLIC	YOUR_DX
PUBLIC	YOUR_DI
PUBLIC	YOUR_SI
PUBLIC	YOUR_FLAGS
PUBLIC	YOUR_BP
PUBLIC	YOUR_SP
PUBLIC	YOUR_IP
PUBLIC	YOUR_CS
PUBLIC	YOUR_DS
PUBLIC	YOUR_ES
PUBLIC	YOUR_SS

DATASEG		SEGMENT		PUBLIC

INCLUDE		NODDY88.DAT

DATASEG		ENDS
 
 	SUBTTL
  
 	PAGE	+
  
	SUBTTL Stack area
  
; Save space for 100H level stack
 
STACKSEG	SEGMENT STACK

	STACK	DW	100H DUP (0)		;initialise to zero

STACK_START	EQU	$			;start of stack

	USERS	DW	100H DUP (0)		;users stack

USERS_START	EQU	$			;initialise user SP to here

STACKSEG	ENDS

	SUBTTL
 
 	PAGE	+
 
 	SUBTTL Start of code segment

COMMENT	%

 Define the start of code segment as being here
 the whole program is to reside in the same memory
 segment, therefore all CALLs, JUMPs etc dealing
 only with this program need only be of type NEAR.
 this should save a few bytes and speed up execution.

%

	EXTRN	BREAK:NEAR
	EXTRN	COMMAND_IN:NEAR
	EXTRN	CLEAR_CMD:NEAR
	EXTRN	CMD_ERROR:NEAR
	EXTRN	CURSOR_ON:NEAR
	EXTRN	DUMP:NEAR
	EXTRN	ENTER:NEAR
	EXTRN	FILL:NEAR
	EXTRN	GET_CHAR:NEAR
	EXTRN	HELP:NEAR
	EXTRN	INITIALISE:NEAR
	EXTRN	LOAD:NEAR
	EXTRN	PROGRAM_COUNTER:NEAR
	EXTRN	QUIT:NEAR
	EXTRN	STACKS:NEAR
	EXTRN	XECUTE:NEAR
	EXTRN	ZERO:NEAR

	PAGE

CODESEG		 SEGMENT	PUBLIC

ASSUME	CS:CODESEG,DS:DATASEG,SS:STACKSEG

MAIN:	MOV	AX,DATASEG			;get data area set up
	MOV	DS,AX				;into the segment reg
	MOV	AX,STACKSEG			;point to the stack
	MOV	SS,AX				;into the segment reg
	MOV	YOUR_SS,AX			;initialise user as well
 	MOV	SP,OFFSET STACK_START		;set stack pointer
	MOV	AX,OFFSET USERS_START		;set up user as well
	MOV	YOUR_SP,AX
	MOV	WORD PTR RET_ADDRESS+2,ES	;save return address
	MOV	AX,SEG CODESEG			;set up them to our loc
	MOV	YOUR_CS,AX
	MOV	AX,MAIN				;[debug]
	MOV	YOUR_IP,AX
	CALL	INITIALISE			;set up the screen details

; here is the main command input loop and processor call
  
COMMAND:
 	CALL	COMMAND_IN			;get command
	CALL	CLEAR_CMD			;clear command area
	CALL	GET_CHAR			;get the first char
	JC	PROCESS_ERROR			;error
	XOR	AH,AH				;clear high byte
	SUB	AL,'A'				;remove offset
 	JC	PROCESS_ERROR			;error
	CMP	AL,'Z'-'A'+1			;bigger than Z?
	JNC	PROCESS_ERROR			;yes
 	MOV	BX,3				;ready for adjusting
 	MUL	BL				;index times three
 	MOV	BX, OFFSET PROCESS_TABLE	;get table start
	ADD	BX,AX				;add entry offset
	CALL	BX
	JNC	COMMAND				;carry =error return
  
PROCESS_ERROR:
 	CALL	CMD_ERROR			;here if command error
	JMP	COMMAND 			;back to command level
 
	SUBTTL

	PAGE

	SUBTTL Jump vectors for command routine entries

PROCESS_TABLE:
 	JMP	NEAR PTR CMD_ERROR			; A
 	JMP	NEAR PTR BREAK				; B - Break point set and reset
 	JMP	NEAR PTR CMD_ERROR			; C
 	JMP	NEAR PTR DUMP				; D - Dump in hex or asciii
 	JMP	NEAR PTR ENTER				; E - Enter values
 	JMP	NEAR PTR FILL				; F - Fill memory
 	JMP	NEAR PTR CMD_ERROR			; G
 	JMP	NEAR PTR HELP				; H - Help screen
 	JMP	NEAR PTR CMD_ERROR			; I
 	JMP	NEAR PTR CMD_ERROR			; J
 	JMP	NEAR PTR CMD_ERROR			; K
 	JMP	NEAR PTR LOAD				; L - Load file
 	JMP	NEAR PTR CMD_ERROR			; M
 	JMP	NEAR PTR CMD_ERROR			; N
 	JMP	NEAR PTR CMD_ERROR			; O
 	JMP	NEAR PTR PROGRAM_COUNTER		; P - Set program counter
	JMP	NEAR PTR QUIT				; Q - Quit program
	JMP	NEAR PTR CMD_ERROR			; R
	JMP	NEAR PTR STACKS				; S - Stack processing
	JMP	NEAR PTR CMD_ERROR			; T
	JMP	NEAR PTR CMD_ERROR			; U
	JMP	NEAR PTR CMD_ERROR			; V
	JMP	NEAR PTR CMD_ERROR			; W
	JMP	NEAR PTR XECUTE				; X - eXecute program
	JMP	NEAR PTR CMD_ERROR			; Y
	JMP	NEAR PTR ZERO				; Z - Zero memory range

CODESEG 	ENDS

	END	MAIN
 


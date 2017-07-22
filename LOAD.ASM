	PAGE	45,132

	TITLE Noddy88 debugger

	SUBTTL	Load a file for debugging

	.SALL

	.XLIST
	INCLUDE	NOD88DEF.ASM
	INCLUDE	ZDOSFUNC.ASM
	INCLUDE	ZDOSINT.ASM
	.LIST

	PUBLIC	LOAD
	PUBLIC	LOAD_CON

	EXTRN	ADDRESS_OFFSETS:WORD
	EXTRN	ADDRESS_SEGS:WORD
	EXTRN	DUMP1:NEAR
	EXTRN	FLAGS:NEAR
	EXTRN	GET_CHAR:NEAR
	EXTRN	IBUFF:WORD
	EXTRN	IBUFFC:BYTE
	EXTRN	IBUFFP:WORD
	EXTRN	INS_INIT:NEAR
	EXTRN	POINTERS:NEAR
	EXTRN	REGISTERS:NEAR
	EXTRN	YOUR_CS:WORD
	EXTRN	YOUR_IP:WORD
	EXTRN	YOUR_SP:WORD
	EXTRN	YOUR_SS:WORD
	EXTRN	YOUR_ES:WORD
	EXTRN	YOUR_DS:WORD

	PAGE

DATASEG		SEGMENT		PUBLIC

EXE$FLAG	DB	0			;shows filetype
START_SEGMENT	DW	1000H			;start segment for user code

FCB		DB	40 DUP (0)		;fcb area for filename

DTA		DB	128 DUP (0)		;we'll use our dta

DATASEG		ENDS

	PAGE

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG,DS:DATASEG

LOAD		PROC
	CALL	GET_CHAR			;skip space
	CMP	AL,' '
	JNZ	LOAD_ERROR
	CALL	SETUP_FCB			;set up fcb
	JZ	LOAD_ERROR
L$1:	CALL	OPENFILE			;open the file
	JZ	LOAD_ERROR			;failed to open
	MOV	DX,OFFSET DTA
	CALL	SETDTA				;set dta to our area
	CALL	READFILE			;read first block
	CALL	CHECK_TYPE			;now find the type
	TEST	EXE$FLAG,TRUE			;is it an exe file 
	JNZ	EXE				;yes
	CALL	LOAD_COM			;no its a com file
LOAD_CLOSE:	
	MOV	DI,START_SEGMENT		;make new program segment
	SUB	DI,010H				;adjust start address
	MOV	CX,100H
	MOV	ES,DI
	XOR	DI,DI
	XOR	SI,SI
	MOV	AX,CS				;ste up segments for move
	SUB	AX,010H
	PUSH	DS
	MOV	DS,AX
	REP	MOVSB
	POP	DS
	MOV	EXE$FLAG,FALSE			;reset flag
	CALL	CLOSEFILE			;try to close it
	JZ	LOAD_ERROR			;close error
	MOV	AX,YOUR_CS			;reset address tables
	MOV	ADDRESS_SEGS+4,AX		;segment
	MOV	AX,YOUR_IP
	MOV	ADDRESS_OFFSETS+4,AX		;offset
	CALL	INS_INIT			;initialise instruction screen
	CALL	REGISTERS
	CALL	FLAGS
	CALL	POINTERS			;memory locations change
	CALL	DUMP1				;memory dump
	CLC
	RET					;normal return
LOAD_ERROR:
	MOV	EXE$FLAG,FALSE			;reset flag
	STC
	RET					;error return

EXE:	CALL	LOAD_EXE
	JMP	LOAD_CLOSE

	PAGE

LOAD_CON:
	MOV	AX,CS				;pick up code segment
	SUB	AX,100H				;adjust to find defaults
	MOV	ES,AX
	MOV	SI,0F00H			;new offset
	TEST	BYTE PTR ES:[SI+80H],0FFH	;any parameters passed?
	JZ	LOAD_ERROR			;no so exit
	MOV	DI,OFFSET FCB
	MOV	CX,20				;clear fcb to be safe
	XOR	AX,AX
LL$1:	MOV	[DI],AX
	INC	DI
	INC	DI
	LOOP	LL$1
	MOV	DI,OFFSET FCB			;else set up fcb
	ADD	SI,5CH				;start of fcb if there is one 
	MOV	CX,12				;byte count for name
	MOV	AX,ES
	PUSH	DS
	MOV	DS,AX
	POP	ES				;DS:SI=source
	PUSH	ES				;ES:DI=destination
	REP	MOVSB				;move the string
	POP	DS				;restore our data segment
	JMP	L$1				;enter main line code
LOAD		ENDP

	PAGE

SETUP_FCB	PROC
;initialise fcb area and sets up for open
	XOR	AX,AX				;clear the fcb area
	MOV	CX,16				;length of fcb
	MOV	BX, OFFSET FCB			;point to fcb
SF_10:	MOV	[BX],AX
	LOOP	SF_10				;fill with nuls
	MOV	BL,IBUFFC			;place terminal character
	XOR	BH,BH
	ADD	BX,IBUFFP			;add offset
	MOV	BYTE PTR [BX],'='		;place terminator
	MOV	AX,DS				;set up ES:DI
	MOV	ES,AX
	MOV	DI, OFFSET FCB			;point to fcb to set up
	MOV	SI, OFFSET IBUFF+1		;point to string in buffer
	CALL	PARSEFILENAME			;parse the file
	RET
SETUP_FCB	ENDP

	PAGE

CHECK_TYPE		PROC
	MOV	BX, OFFSET FCB			;start of fcb
	CMP	BYTE PTR 9[BX],'E'		;is it exe file?
	JNZ	CT_EXIT				;exit
	CMP	BYTE PTR 10[BX],'X'
	JNZ	CT_EXIT
	CMP	BYTE PTR 11[BX],'E'
	JNZ	CT_EXIT
	MOV	BX, OFFSET DTA			;point to dta
	CMP	BYTE PTR 0[BX],4DH		;link tag for exe files
	JNZ	CT_EXIT
	CMP	BYTE PTR 1[BX],5AH		;must be 4d 5a
	JNZ	CT_EXIT
	MOV	EXE$FLAG,TRUE			;its an exe file
CT_EXIT:
	RET
CHECK_TYPE		ENDP

	PAGE

CLOSEFILE		PROC
; closes a file
; enter with DS:DX pointing to opened FCB
; exit with Z = 0  successful close
;	    Z = 1  close error ( File not found according to manual )
; uses: AX
	MOV	DX, OFFSET FCB				;point to fcb
	MOV	AH,ZDOS$CLOSE				;close file function
	INT	BDOS					;call the system
	INC	AL					;check result
	RET						;zero flag if error
CLOSEFILE	ENDP

OPENFILE	PROC
;opens file 
; enter with: 	AH = file open function code
;		DS:DX pointing to unopened FCB
; exit with:	Z = 0  open was successful
;		Z = 1  file not found
; uses: AX
	MOV	DX, OFFSET FCB			;point to fcb
	MOV	AH, ZDOS$OPEN			;open function
	INT	BDOS				;call system
	INC	AL				;check
	RET
OPENFILE	ENDP

PARSEFILENAME	PROC
; parses filename and builds unopened fcb
; enter with:	DS:SI	pointing to filename string to parse
;		ES:DI	pointing to area to fill with fcb
;		AH	= filename parse function code 29H
;		AL	= flags to control parsing
; exits with:	Z = 0 then successful parse
;		Z = 1 then filename error
; uses: AX
	MOV	AH,ZDOS$PARSE			;parse filename function
	MOV	AL,00000000B			;may need to change flags
	INT	BDOS				;request the system
	INC	AL				;set non-zero until we know more
	RET
PARSEFILENAME	ENDP

READFILE	PROC	NEAR
; reads a new record into a buffer
; enter with:	DS:DX	  points to opened FCB
;		AH	= random read function
; returns with:	AL	= flag to show result
;			  00 = success
;			  01 = no more data available
;			  02 = not enough room in disc transfer segment
;			  03 = partial record returned filled with zeroes
; uses:	AX
	PUSH	DX			;save this
	MOV	DX,OFFSET FCB		;file to read
	MOV	AH,ZDOS$READSEQ		;read sequential function
	INT	BDOS			;do it
	TEST	AL,AL			;anything there?
	POP	DX
	RET				;zero = success
READFILE	ENDP

SETDTA		PROC	NEAR
; sets disc transfer address for file reads
; call with	DS:DX	pointing to location for disc transfers
; uses:	AX
	MOV	AH,ZDOS$SETDTA		;load function
	INT	BDOS			;do it
	RET
SETDTA		ENDP

	PAGE

LOAD_COM		PROC
	MOV	AX,START_SEGMENT		;transfer first record
	MOV	CX,128
	MOV	ES,AX
	XOR	DI,DI
	MOV	SI,OFFSET DTA
	REP	MOVSB
	MOV	DX,128				;set up for load module
LC$10:	MOV	AX,START_SEGMENT		;set up segment
	PUSH	DS				;save our segment
	MOV	DS,AX
	CALL	SETDTA				;set dta
	POP	DS				;restore our segment
	CALL	READFILE
	JNZ	LC$20				;end of file?
	ADD	DX,128				;bump dta pointer
	JMP	LC$10				;round until done
LC$20:	MOV	AX,START_SEGMENT
	MOV	YOUR_CS,AX			;set up registers
	MOV	YOUR_IP,0
	MOV	YOUR_DS,AX
	MOV	YOUR_ES,AX
	RET
LOAD_COM		ENDP

	PAGE

LOAD_EXE		PROC
	MOV	BX,OFFSET DTA			;point to transfer area
	MOV	AX,20[BX]			;calculate addresses
	MOV	YOUR_IP,AX			;users IP
	MOV	AX,22[BX]			;get CS offset
	ADD	AX,START_SEGMENT		;add base address
	MOV	YOUR_CS,AX			;code segment address
	MOV	AX,14[BX]			;get stack segment
	ADD	AX,START_SEGMENT		;add start segment
	MOV	YOUR_SS,AX			;save SS
	MOV	AX,16[BX]			;get SP
	MOV	YOUR_SP,AX			;save it
	MOV	AX,START_SEGMENT		;set ES,DS -> program header
	SUB	AX,010H				;start segment - 100h
	MOV	YOUR_ES,AX
	MOV	YOUR_DS,AX
	MOV	CX,8[BX]			;get paragraph count for header
	SHR	CX,1
	SHR	CX,1
	SHR	CX,1				;DIV 8 = 128 byte bufferloads
	DEC	CX				;already seen one
LE$10:	CALL	READFILE			;readfile through header
	LOOP	LE$10
	XOR	DX,DX				;set up for load module
LE$20:	MOV	AX,START_SEGMENT		;set up segment
	PUSH	DS				;save our segment
	MOV	DS,AX
	CALL	SETDTA				;set dta
	POP	DS				;restore our segment
	CALL	READFILE
	JNZ	LE$30				;end of file?
	ADD	DX,128				;bump dta pointer
	JMP	LE$20				;round until done
LE$30:	MOV	WORD PTR FCB+12,0		;reset file back to first rec.
	MOV	BYTE PTR FCB+32,0		;first block..
	MOV	DX,OFFSET DTA			;reset back to transfer area
	CALL	SETDTA
	CALL	READFILE			;read first record
	MOV	BX,OFFSET DTA			;point back at area
	MOV	CX,6[BX]			;get relocation counter
	MOV	SI,24[BX]			;relocation table start address
LE$40:	MOV	BX,WORD PTR DTA[SI]		;pick up offset
	MOV	AX,WORD PTR DTA[SI+2]		;and segment
	ADD	AX,START_SEGMENT		;add base address
	MOV	ES,AX				;use this segment
	MOV	AX,START_SEGMENT		;get start
	ADD	ES:[BX],AX			;relocate the address
	INC	SI				;add four to index
	INC	SI
	INC	SI
	INC	SI
	LOOP	LE$40				;do all table entries
	RET
LOAD_EXE		ENDP


CODESEG		ENDS

	END


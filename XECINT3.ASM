	PAGE	45,132


	TITLE Noddy88 debugger

 	SUBTTL Execution main routine

	.SALL

	.XLIST
	INCLUDE	FLAGDEF.ASM
	INCLUDE	MACLIB88.ASM
	INCLUDE	NOD88DEF.ASM
	.LIST

	PUBLIC	INTERRUPT_SERVICE
	PUBLIC	SSTEP
	PUBLIC	XECUTE

	EXTRN	ADDRESS_SEGS:WORD
	EXTRN	ADDRESS_OFFSETS:WORD
	EXTRN	BP_OPS:BYTE
	EXTRN	BP_SEGS:WORD
	EXTRN	BP_OFFSETS:WORD
	EXTRN	BYTE_COUNT:BYTE
	EXTRN	CLEAR_CMD:NEAR
	EXTRN	COMMAND:NEAR
	EXTRN	CURRENT_CS:WORD
	EXTRN	CURRENT_IP:WORD
	EXTRN	DECODE:NEAR
	EXTRN	DELETE_LINE:NEAR
	EXTRN	DISPLAY$FLAG:BYTE
	EXTRN	DUMP1:NEAR
	EXTRN	FLAGS:NEAR
	EXTRN	GET_CHAR:NEAR
	EXTRN	INPUT_CHAR:NEAR
	EXTRN	INS_CNT:BYTE
	EXTRN	LINE_CNT:BYTE
	EXTRN	MOVETO:NEAR
	EXTRN	M_COUNTER:BYTE
	EXTRN	MY_SS:WORD
	EXTRN	MY_SP:WORD
	EXTRN	POINTERS:NEAR
	EXTRN	QUIT:NEAR
	EXTRN	REGISTERS:NEAR
	EXTRN	S_COUNT:BYTE
	EXTRN	SS_FLAG:BYTE
	EXTRN	STACK_DISPLAY:NEAR
	EXTRN	BP_FLAGS:BYTE
	EXTRN	XS_FLAG:BYTE
	EXTRN	XF_FLAG:BYTE
	EXTRN	YOUR_AX:WORD
	EXTRN	YOUR_BX:WORD
	EXTRN	YOUR_CX:WORD
	EXTRN	YOUR_DX:WORD
	EXTRN	YOUR_DI:WORD
	EXTRN	YOUR_SI:WORD
	EXTRN	YOUR_SS:WORD
	EXTRN	YOUR_SP:WORD
	EXTRN	YOUR_BP:WORD
	EXTRN	YOUR_ES:WORD
	EXTRN	YOUR_DS:WORD
	EXTRN	YOUR_CS:WORD
	EXTRN	YOUR_IP:WORD
	EXTRN	YOUR_FLAGS:WORD

	PAGE

DATASEG		SEGMENT		PUBLIC

INT3_FLAG	DB	FALSE		;indicates a breakpoint reached

SYSTEM$BREAK	DB	FALSE		;to tell us if we set a break
SYSTEM$OPCODE	DB	0		;for saving users opcode

DATASEG		ENDS

	PAGE

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG,DS:DATASEG

; here to execute an instruction in the users code
 
XECUTE		PROC
	CALL	GET_CHAR		;get command qualifier
	JC	X_ERR			;error
	CMP	AL,'F'
	JNZ	X1
	JMP	X_FAST
X1:	CMP	AL,'S'
	JNZ	X_ERR
	JMP	X_SLOW
X_ERR:	STC				;error return
	RET

SSTEP:	MOV	SS_FLAG,TRUE		;set flag
	MOV	DISPLAY$FLAG,TRUE	;and display flag
X_CONT: CALL	CLEAR_CMD		;clear command line
	GOTO	25,1			;go to the 25th line
	CALL	DELETE_LINE		;clear anything there
	CALL	XBREAK_SET		;set the break points
	MOV	AX,ADDRESS_SEGS+4	;set their addresses to current
	MOV	YOUR_CS,AX		;values
	MOV	ES,AX			;time to check
	MOV	BX,ADDRESS_OFFSETS+4	;these must be set up on entry
	MOV	YOUR_IP,BX
	MOV	MY_SS,SS		;save our segments
	MOV	MY_SP,SP
	MOV	SS,YOUR_SS		;set to theirs
	MOV	SP,YOUR_SP
	CMP	BYTE PTR ES:[BX],0CDH	;this instruction an INT?
	JNZ	XC$1			;no
	CMP	BYTE PTR ES:[BX+1],20H	;an INT 20 instruction?
	JNZ	XC$3			;no so continue
	JMP	QUIT			;yes so tidy up and exit
XC$3:	CMP	BYTE PTR ES:[BX+1],21H	;an INT 21 in fact?
	JNZ	XC$1			;no
	MOV	SYSTEM$BREAK,TRUE	;set system break flag
	MOV	AL,ES:[BX+2]		;retrieve the next opcode
	MOV	SYSTEM$OPCODE,AL	;save it
	MOV	BYTE PTR ES:[BX+2],INT3	;replace with interrupt
	XOR	YOUR_FLAGS,TRAP
	JMP	XC$2
XC$1:	OR	YOUR_FLAGS,TRAP		;with trap set
XC$2:	PUSH	YOUR_FLAGS
	PUSH	YOUR_CS			;on their stack
	PUSH	YOUR_IP
	MOV	BX,YOUR_BX		;restore their registers
	MOV	CX,YOUR_CX
	MOV	DX,YOUR_DX
	MOV	SI,YOUR_SI
	MOV	DI,YOUR_DI
	MOV	BP,YOUR_BP
	MOV	ES,YOUR_ES
 	MOV	AX,YOUR_AX		;set ax
	MOV	DS,YOUR_DS		;now change data segment
 	IRET				;execute their instruction

	PAGE
 
X_FAST: MOV	XF_FLAG,TRUE		;set fast execution flag
	MOV	DISPLAY$FLAG,FALSE	;no display
	JMP	X_CONT
 
X_SLOW: MOV	XS_FLAG,TRUE		;set slow execution flag
	MOV	DISPLAY$FLAG,TRUE	;and display
	JMP	X_CONT			;execute slow
 
XECUTE		ENDP
  
 	PAGE
  
 
XBREAK_SET	PROC
; sets break points prior to executing users instruction
	TEST	BP_FLAGS,0FH		;any breakpoints set?
	JZ	XBS$30			;no
	MOV	AL,BP_FLAGS		;else get ready to set them
 	XOR	DI,DI			;clear pointers
 	XOR	BX,BX
 	CLC				;clear carry
 	MOV	CX,MAX_BP		;maximum breaks
XBS$10:	RCR	AL,1			;get a bit
 	JNC	XBS$20			;no carry = no break
 	PUSH	AX			;save copy of flag bits
 	MOV	ES,BP_SEGS[BX]		;get table entry
 	MOV	SI,BP_OFFSETS[BX]	;offset for break
 	MOV	AL,ES:[SI]		;get contents of location
 	MOV	BP_OPS[DI],AL		;save them in table
 	MOV	BYTE PTR ES:[SI],INT3	;replace with INT 3 instruction
 	POP	AX			;get flag bits back
XBS$20:	INC	DI			;bump pointers
 	INC	BX			;
 	INC	BX
 	LOOP	XBS$10			;round for all breaks
XBS$30:	RET
XBREAK_SET	ENDP
 
	SUBTTL

	PAGE	+

	SUBTTL Interrupt service routines

; here when an instruction has been executed in the users program

INTERRUPT_SERVICE	PROC
	PUSH	AX				;save their ax,es
	PUSH	ES
	MOV	AX,DATASEG			;set es=our data
	MOV	ES,AX
	MOV	ES:YOUR_BX,BX			;save their registers
	MOV	ES:YOUR_CX,CX
	MOV	ES:YOUR_DX,DX
	MOV	ES:YOUR_SS,SS
	MOV	ES:YOUR_DS,DS
	MOV	ES:YOUR_SI,SI
	MOV	ES:YOUR_DI,DI
	MOV	ES:YOUR_BP,BP
	POP	ES:YOUR_ES			;get their es
	POP	ES:YOUR_AX
	POP	ES:YOUR_IP			;get their new ip
	POP	ES:YOUR_CS			;and code segment
	POP	ES:YOUR_FLAGS			;flags
	MOV	DS,AX				;now restore our data segment
	CLD					;make string ops behave
	MOV	ES,ADDRESS_SEGS+4
	MOV	BX,ADDRESS_OFFSETS+4		;see if we can see an INT 3!
	TEST	SYSTEM$BREAK,TRUE		;did we just execute INT 21?
	JZ	X$2				;no
	MOV	SYSTEM$BREAK,FALSE		;reset flag
	MOV	AL,SYSTEM$OPCODE
	MOV	BYTE PTR ES:[BX+2],AL		;restore the users opcode
	DEC	YOUR_IP				;adjust his code segment
X$2:	CMP	BYTE PTR ES:[BX],0CCH		;interrupt?
	JNZ	XX$20				;no
	ADD	SP,6				;remove interrupt junk
	MOV	XF_FLAG,FALSE			;say we want to stop
	MOV	XS_FLAG,FALSE
	MOV	DISPLAY$FLAG,TRUE		;display the last thing found
	MOV	INT3_FLAG,TRUE			;say we were interrupted
XX$20:	CMP	YOUR_SP,SP			;anything done with stack?
	JZ	XX$10				;no
	MOV	AX,YOUR_SP
	CMP	SP,AX				;see which way we went
	JA	X$1				;popped
	SUB	AX,SP				;else we pushed
	SHR	AX,1				;divide difference by 2
	ADD	S_COUNT,AL			;add it to count
	JMP	XX$10				;finished here
X$1:	MOV	BX,SP				;here for a pop
 	SUB	BX,AX
	SHR	BX,1				;get difference * 2
	SUB	S_COUNT,BL			;put it in count
XX$10:	MOV	YOUR_SP,SP			;done with his sp now
	MOV	SS,MY_SS
	MOV	SP,MY_SP			;restore our SP
 	CALL	BREAK_RESET			;reset break points
	MOV	INS_CNT,0			;initialise counters
	MOV	LINE_CNT,0
	CALL	FIDDLE_ADDRESSES		;adjust address table + display
	TEST	XF_FLAG,TRUE
	JNZ	IS_50				;yes
	TEST	XS_FLAG,TRUE
	JZ	IS_60				;its neither so single step

; here for xs
 
IS_40:	CALL	REGISTERS
	CALL	POINTERS
	CALL	STACK_DISPLAY
	CALL	FLAGS
	CALL	DUMP1
	MOV	AL,5				;pause a bit
IS_41:	MOV	CX,0FFFFH
IS_42:	LOOP	IS_42
	DEC	AL
	JNZ	IS_41
	CALL	BREAK
	JZ	IS_61				;exit
	JMP	X_CONT

; here for checking break character
 
IS_50:	CALL	BREAK				;see if break charcter
	JZ	IS_60				;has to be this way
	JMP	X_CONT				;continue execution
 
; return to command

IS_60:	CALL	REGISTERS			;refresh screen
	CALL	POINTERS
	CALL	FLAGS
	CALL	STACK_DISPLAY
	CALL	DUMP1				;update memory as well
IS_61:	CALL	RESET_FLAGS			;reset all flags
	POP	AX				;raise stack
	JMP	COMMAND				;no error from execute

INTERRUPT_SERVICE	ENDP

	PAGE

BREAK_RESET	PROC  
; restores the opcodes back to memory
	XOR	AH,AH				;clear high byte
	MOV	AL,BP_FLAGS			;get break point flags
	TEST	AL,AL				;any set ?
	JZ	BR_30				;no so exit
	MOV	CX,MAX_BP			;max breakpoints
	XOR	SI,SI				;clear pointers
	XOR	BX,BX
	CLC					;clear carry flag
BR_10:	RCR	AL,1				;shift a bit
	JNC	BR_20				;nothing = no break point
	PUSH	AX				;save copy of flags
	MOV	ES,BP_SEGS[BX]			;get table entry
	MOV	DI,BP_OFFSETS[BX]		;set up offset
	MOV	AL,BP_OPS[SI]			;get opcode from table
	MOV	ES:[DI],AL			;replace it for user
	POP	AX
BR_20:	INC	SI				;bump pointers
	INC	BX
	INC	BX
	LOOP	BR_10
BR_30:	RET
BREAK_RESET	ENDP

	PAGE

FIDDLE_ADDRESSES	PROC

COMMENT	%
	main address handler

	algorithm is as follows:

	IF (int3_flag=true) THEN
	BEGIN
	{just executed an int 3 instruction}
	leave address table alone and force an exit
	END
	IF (instruction just executed=8EH) OR ( ins = SEG xS) THEN
	  BEGIN		{ it was mov segreg,XXX which is an exception case }
	  move top 4 addresses up two { or segment override }
	  calculate addresses 4-7
	  END
	ELSE
	  IF (current cs = next cs) AND (current ip=next ip) THEN
	    BEGIN		{sequential execution}
	    move all addresses up one entry
	    calculate next address 7
	    END
	  ELSE
	    BEGIN		{must have jumped}
	    move up top three addresses
	    set current address=jump address
	    calculate new addresses 4-7
	    END
%
	TEST	INT3_FLAG,TRUE			;hit a breakpoint?
	JNZ	AT_01				;yes-leave addresses alone
	MOV	ES,ADDRESS_SEGS+4		;see if mov segreg,...
	MOV	BX,ADDRESS_OFFSETS+4		;get ip
	CMP	BYTE PTR ES:[BX],8EH		;is it?
	JZ	FA_05				;yes continue
	MOV	AL,BYTE PTR ES:[BX]
	CMP	AL,000100110B			;try for segment override
	JZ	FA_05
	CMP	AL,000101110B
	JZ	FA_05
	CMP	AL,000110110B
	JZ	FA_05
	CMP	AL,000111110B
	JZ	FA_05
	JMP	FA_06
FA_05:	CALL	ADJUST_SKIP1			;we skipped an instruction
FA_06:	MOV	AX,YOUR_CS			;see if next CS=YOUR_CS
	CMP	ADDRESS_SEGS+6,AX		;are segments same?
	JNZ	FA_10				;no
	MOV	AX,YOUR_IP			;see if next IP=YOUR_IP
	CMP	ADDRESS_OFFSETS+6,AX
	JNZ	FA_10				;no
	CALL	ADJUST_TABLE			;move all addresses up
	JMP	FA_EXIT				;done
FA_10:	CALL	ADJUST_TOP3			;move top 3 entries only
FA_EXIT:
	RET
FIDDLE_ADDRESSES		ENDP

	PAGE

ADJUST_TABLE		PROC
	MOV	AX,DS				;point to our data
	MOV	ES,AX
	MOV	CX,6				;move all entries
	MOV	SI, OFFSET ADDRESS_SEGS+2	;get second entry
	MOV	DI, OFFSET ADDRESS_SEGS 	;first
	REP	MOVSW				;move string 
	MOV	CX,6				;offsets
	MOV	SI, OFFSET ADDRESS_OFFSETS+2	;
	MOV	DI, OFFSET ADDRESS_OFFSETS
	REP	MOVSW
AT_01:	XOR	BX,BX				;start with first entry
AT_10:	MOV	M_COUNTER,0
	MOV	AX,ADDRESS_SEGS[BX]		;get address from table
	MOV	CURRENT_CS,AX			;set up parameter block
	MOV	ES,AX				;es=code segment
	MOV	SI,ADDRESS_OFFSETS[BX]
	MOV	CURRENT_IP,SI
	CALL	DECODE				;decode and display
	INC	LINE_CNT			;bump line count
	INC	BX				;word table pointer
	INC	BX
	CMP	LINE_CNT,6			;next to last line?
	JNZ	AT_10				;not yet

	XOR	AH,AH				;else calc next ins address
	MOV	AL,BYTE_COUNT			;get instruction length
	ADD	AX,CURRENT_IP			;assume all intersegment****!
	MOV	ADDRESS_OFFSETS[BX],AX		;new ip
	MOV	SI,AX
	MOV	CURRENT_IP,AX

	MOV	AX,CURRENT_CS
	MOV	ADDRESS_SEGS[BX],AX		;keep old CS
	MOV	CURRENT_CS,AX			;set up parameter block
	MOV	ES,AX				;es=code segment

	MOV	M_COUNTER,0
	CALL	DECODE				;decode and display
	RET
ADJUST_TABLE	ENDP
 
	PAGE

ADJUST_TOP3		PROC
	MOV	AX,ADDRESS_SEGS+2		;shift two entries
	MOV	ADDRESS_SEGS,AX
	MOV	AX,ADDRESS_OFFSETS+2
	MOV	ADDRESS_OFFSETS,AX
	MOV	AX,ADDRESS_SEGS+4
	MOV	ADDRESS_SEGS+2,AX
	MOV	AX,ADDRESS_OFFSETS+4
	MOV	ADDRESS_OFFSETS+2,AX

	MOV	AX,YOUR_IP			;get real address
	MOV	ADDRESS_OFFSETS+4,AX		;set up as present address
	MOV	AX,YOUR_CS
	MOV	ADDRESS_SEGS+4,AX

	XOR	BX,BX				;start with first entry
AT3_10:	MOV	M_COUNTER,0			;keep the screen clean
	MOV	AX,ADDRESS_SEGS[BX]		;get address from table
	MOV	CURRENT_CS,AX			;set up parameter block
	MOV	ES,AX				;es=code segment
	MOV	SI,ADDRESS_OFFSETS[BX]
	MOV	CURRENT_IP,SI
	CALL	DECODE				;decode and display
	INC	LINE_CNT			;bump line count
	CMP	LINE_CNT,7			;end?
	JZ	AT3_EXIT			;yes
	INC	BX				;word table pointer
	INC	BX
	CMP	LINE_CNT,3			;third line ?
	JB	AT3_10				;not yet
	XOR	AH,AH				;else calc next ins address
	MOV	AL,BYTE_COUNT			;get instruction length
	ADD	AX,CURRENT_IP			;assume all intersegment****!
	MOV	ADDRESS_OFFSETS[BX],AX		;new ip
	MOV	AX,CURRENT_CS
	MOV	ADDRESS_SEGS[BX],AX		;keep old CS
	JMP	AT3_10				;round until done
AT3_EXIT:
	RET
ADJUST_TOP3		ENDP
 
	PAGE

ADJUST_SKIP1		PROC
	MOV	AL,DISPLAY$FLAG			;save display flag
	PUSH	AX
	MOV	DISPLAY$FLAG,FALSE
	MOV	AX,DS				;point to our data
	MOV	ES,AX
	MOV	CX,6				;move all entries
	MOV	SI, OFFSET ADDRESS_SEGS+2	;get second entry
	MOV	DI, OFFSET ADDRESS_SEGS 	;first
	REP	MOVSW				;move string 
	MOV	CX,6				;offsets
	MOV	SI, OFFSET ADDRESS_OFFSETS+2	;
	MOV	DI, OFFSET ADDRESS_OFFSETS
	REP	MOVSW

	MOV	BX,10				;index next to last
	MOV	AX,ADDRESS_SEGS[BX]		;get address from table
	MOV	CURRENT_CS,AX			;set up parameter block
	MOV	ES,AX				;es=code segment
	MOV	SI,ADDRESS_OFFSETS[BX]
	MOV	CURRENT_IP,SI
	MOV	M_COUNTER,0
	CALL	DECODE				;decode

	INC	BX				;point to last instruction
	INC	BX
	XOR	AH,AH				;else calc next ins address
	MOV	AL,BYTE_COUNT			;get instruction length
	ADD	AX,CURRENT_IP			;assume all intersegment****!
	MOV	ADDRESS_OFFSETS[BX],AX		;new ip
	MOV	AX,CURRENT_CS
	MOV	ADDRESS_SEGS[BX],AX		;keep old CS
	MOV	M_COUNTER,0			;clear buffer
	POP	AX				;restore display flag
	MOV	DISPLAY$FLAG,AL
	RET
ADJUST_SKIP1	ENDP

	PAGE

RESET_FLAGS	PROC
; reset execution flags
	MOV	DISPLAY$FLAG,FALSE
	MOV	LINE_CNT,FALSE
	MOV	SS_FLAG,FALSE
	MOV	XS_FLAG,FALSE
	MOV	XF_FLAG,FALSE
	MOV	INT3_FLAG,FALSE
	RET
RESET_FLAGS	ENDP

	PAGE

BREAK	PROC  
; check for break character
 	CALL	INPUT_CHAR			;get character
 	CMP	AL,'{'				;there?
 	RET					;zero = stop
BREAK	ENDP


CODESEG		ENDS

	END


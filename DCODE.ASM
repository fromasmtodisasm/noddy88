	PAGE	45,132

	TITLE Noddy88 debugger

	SUBTTL Main opcode decoding routines

	.SALL

	.XLIST
	INCLUDE	NOD88DEF.ASM
	.LIST

	EXTRN	ADDRESS_SEGS:WORD
	EXTRN	ADDRESS_OFFSETS:WORD
	EXTRN	BYTE_COUNT:BYTE
	EXTRN	CURRENT_CS:WORD
	EXTRN	CURRENT_IP:WORD
	EXTRN	CURRENT_OP:BYTE
	EXTRN	DEST$EA_SRC$REG:NEAR
	EXTRN	DEST$REG_SRC$EA:NEAR
	EXTRN	DISPLACEMENT_BYTE:NEAR
	EXTRN	DISPLACEMENT_WORD:NEAR
	EXTRN	DISPLAY:NEAR
	EXTRN	DISPLAY$FLAG:BYTE
	EXTRN	IMMEDIATE_BYTE:NEAR
	EXTRN	IMMEDIATE_WORD:NEAR
	EXTRN	INS_CNT:BYTE
	EXTRN	LINE_CNT:BYTE
	EXTRN	MOD_RM:NEAR
	EXTRN	OPCODES_8081:WORD
	EXTRN	OPCODES_8283:WORD
	EXTRN	OPCODES_C6C7:WORD
	EXTRN	OPCODES_D0D3:WORD
	EXTRN	OPCODES_F6F7:WORD
	EXTRN	OPCODES_FE:WORD
	EXTRN	OPCODES_FF:WORD
	EXTRN	OUTPUT_BUFFER:NEAR
	EXTRN	OUTPUT_LSQB:NEAR
	EXTRN	OUTPUT_MNEMONIC:NEAR
	EXTRN	OUTPUT_RSQB:NEAR
	EXTRN	REGISTER:NEAR
	EXTRN	REGISTER_PAIRS:BYTE
	EXTRN	ROUTINE_TABLE:WORD
	EXTRN	SEG_REGISTERS:BYTE
	EXTRN	SINGLE_REGISTERS:BYTE

	PAGE

	PUBLIC	DECODE
	PUBLIC	DECODE_01
	PUBLIC	DECODE_02
	PUBLIC	DECODE_03
	PUBLIC	DECODE_04
	PUBLIC	DECODE_05
	PUBLIC	DECODE_06
	PUBLIC	DECODE_07
	PUBLIC	DECODE_08
	PUBLIC	DECODE_09
	PUBLIC	DECODE_10
	PUBLIC	DECODE_11
	PUBLIC	DECODE_12
	PUBLIC	DECODE_13
	PUBLIC	DECODE_14
	PUBLIC	DECODE_15
	PUBLIC	DECODE_16
	PUBLIC	DECODE_17
	PUBLIC	DECODE_18
	PUBLIC	DECODE_19
	PUBLIC	DECODE_20
	PUBLIC	DECODE_21
	PUBLIC	DECODE_22
	PUBLIC	DECODE_23
	PUBLIC	DECODE_24
	PUBLIC	DECODE_25
	PUBLIC	DECODE_26
	PUBLIC	DECODE_27
	PUBLIC	DECODE_28
	PUBLIC	DECODE_29
	PUBLIC	DECODE_30
	PUBLIC	DECODE_31

	PAGE

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG
  
DECODE		PROC

COMMENT	%

 main opcode decode routine.
 
 Takes each instruction address in turn and builds
 new address for next instruction, displaying the
 line to screen if required.

%
	PUSH	BX				;save our index
	MOV	AL,ES:[SI]			;get opcode
	MOV	CURRENT_OP,AL
	XOR	AH,AH
	MOV	BX,AX				;get index
	SHL	BX,1				;word table so index * 2
	CALL	ROUTINE_TABLE[BX]		;off to routine
	TEST	DISPLAY$FLAG,TRUE		;do we show off?
	JZ	DC$10				;no
	CALL	DISPLAY 			;display line
DC$10:	POP	BX
	MOV	INS_CNT,0
	RET
DECODE		ENDP
  
	SUBTTL

	PAGE

 	SUBTTL Decode subroutines for specific instruction types

COMMENT	%

	the following routines cater for specific instruction types.
	they all work in a similar manner, placing an instruction mnemonics
	into the output buffer, then decoding the instruction further, if
	neccessary, and placing the details in the output buffer.
	the idea of the output buffer will stay in case future extensions
	try to place more info on a line, eg segment override. the initial
	idea was to to this but it is not implemented in the first version
	because, (a) release deadline is approaching, (b) the lines could
	get very long ( eg LOCK + seg override ) and space is limited.

	the buffer idea is useful in that it simplifies testing of the
	desire to display an instruction. the decoding and display can
	be performed as two seperate tasks.

	DECODE_01	: "??==" representing unknown opcode
	DECODE_02	: single byte instruction with <operand> only
	DECODE_03	: single byte instruction with <operand> <seg reg>
	DECODE_04	: single byte instruction with <operand> <reg>
	DECODE_05	: single byte with <operand> AX,<reg>
	DECODE_06	: two byte instruction with <operand> only
	DECODE_07	: two byte instruction with <operand> <displacement>
	DECODE_08	: two or three byte with <operand> AL or AX,<data>
	DECODE_09	: two or three byte with <operand> <reg>,<data>
	DECODE_10	: 3 bytes MOV AL or AX,<[address]>
	DECODE_11	: 3 bytes MOV <[address]>,AL or AX
	DECODE_12	: 2 bytes  IN AL or AX,<data>
	DECODE_13	: 2 bytes OUT <data>,AL or AX
	DECODE_14	: minimum 2 bytes with <op> mem/reg,mem/reg operands
	DECODE_15	: 2-4 byte ins <ESC> <mem/reg>
	DECODE_16	: opcodes 8CH and 8EH ( mov to or from segreg:mem/reg)
	DECODE_17	: opcodes 80H/81H
	DECODE_18	: opcodes 82H/83H
	DECODE_19	: opcodes D0H-D3H
	DECODE_20	: opcodes C6H/C7H
	DECODE_21	: opcodes F6H/F7H
	DECODE_22	: opcode FEH
	DECODE_23	: opcode FFH
	DECODE_24	: opcodes ECH/EDH
	DECODE_25	: opcodes EEH/EFH
	DECODE_26	: opcodes C2H/CAH	RET
	DECODE_27	: opcode CCH		INT 3
	DECODE_28	: opcode CDH		INT type
	DECODE_29	: opcodes E8H/E9H
	DECODE_30	: opcodes 9AH/EAH
	DECODE_31	: <op> reg,addr
%

	PAGE
 
DECODE_01		PROC
	CALL	OUTPUT_MNEMONIC 		; ??== sign for non-op
	MOV	BYTE_COUNT,1			;assume only one byte
	RET
DECODE_01		ENDP

	PAGE

DECODE_02		PROC
	CALL	OUTPUT_MNEMONIC 		;put mnemonic in buffer
	MOV	BYTE_COUNT,1			;only a one byte instruction
	RET
DECODE_02		ENDP

	PAGE

DECODE_03		PROC
	CALL	OUTPUT_MNEMONIC			;put mnemonic in buffer
	MOV	BYTE_COUNT,1			;one byte instruction
	MOV	BL,CURRENT_OP			;get opcode byte
	AND	BL,00011000B			;mask segment bits
	SHR	BL,1				;shift bits to bottom
	SHR	BL,1
	XOR	BH,BH				;clear index space
	MOV	AL, SEG_REGISTERS[BX]		;index segment register names
	CALL	OUTPUT_BUFFER			;place character
	MOV	AL, SEG_REGISTERS[BX+1]		;get the next letter
	CALL	OUTPUT_BUFFER			;place it
	RET
DECODE_03		ENDP

	PAGE

DECODE_04		PROC
	CALL	OUTPUT_MNEMONIC			;place mnemonic in buffer
	MOV	BYTE_COUNT,1			;one byte instruction
	MOV	BL,CURRENT_OP			;get opcode byte
	AND	BL,00000111B			;mask register bits
	SHL	BL,1				;word table
	XOR	BH,BH				;clear index space
	MOV	AL,REGISTER_PAIRS[BX]		;index segment register names
	CALL	OUTPUT_BUFFER			;place character
	MOV	AL,REGISTER_PAIRS[BX+1]		;get the next letter
	CALL	OUTPUT_BUFFER			;place it
	RET
DECODE_04		ENDP

	PAGE

DECODE_05		PROC
	CALL	OUTPUT_MNEMONIC			;place mnemonic
	MOV	BYTE_COUNT,1			;still only one byte
	MOV	AL,'A'				;put the accumulator in buffer
	CALL	OUTPUT_BUFFER
	MOV	AL,'X'
	CALL	OUTPUT_BUFFER
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	XOR	BH,BH				;clear space
	MOV	BL,CURRENT_OP			;now find a register
	AND	BL,00000111B			;index into registers
	SHL	BL,1				;word table
	MOV	AL,REGISTER_PAIRS[BX]		;first char
	CALL	OUTPUT_BUFFER
	MOV	AL,REGISTER_PAIRS[BX+1]
	CALL	OUTPUT_BUFFER
	RET
DECODE_05		ENDP

	PAGE

DECODE_06		PROC
	CALL	OUTPUT_MNEMONIC			;place mnemonics
	MOV	BYTE_COUNT,2			;two byte instruction
	RET
DECODE_06		ENDP

	PAGE

DECODE_07		PROC
	CALL	OUTPUT_MNEMONIC			;place mnemonic
	MOV	BYTE_COUNT,1			;one byte + displacement
	CALL	DISPLACEMENT_BYTE		;=instruction length
	RET
DECODE_07		ENDP

	PAGE

DECODE_08		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,1			;only one byte
	MOV	AL,'A'				;start off
	CALL	OUTPUT_BUFFER
	MOV	AL,CURRENT_OP			;get opcode byte
	TEST	AL,00000001B			;test word bit
	JNZ	DC_81				;bit set = word operation
	MOV	AL,'L'				;byte register
	CALL	OUTPUT_BUFFER
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	CALL	IMMEDIATE_BYTE			;immediate byte
	JMP	DC8_EXIT
DC_81:	MOV	AL,'X'				;word register
	CALL	OUTPUT_BUFFER
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	CALL	IMMEDIATE_WORD			;immediate word
DC8_EXIT:
	RET
DECODE_08		ENDP

	PAGE

DECODE_09		PROC
	CALL	OUTPUT_MNEMONIC			;place the mnemonic
	MOV	BYTE_COUNT,1			;minimum one byte
	XOR	BH,BH				;clear some space
	MOV	BL,CURRENT_OP			;get opcode byte
	TEST	BL,00001000B			;test word bit
	JNZ	DC_91				;bit set = word operation
	AND	BL,00000111B			;register index bits
	SHL	BX,1				;word table
	MOV	AL,SINGLE_REGISTERS[BX]		;get first
	CALL	OUTPUT_BUFFER
	MOV	AL,SINGLE_REGISTERS[BX+1]
	CALL	OUTPUT_BUFFER			;place second
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	CALL	IMMEDIATE_BYTE			;immediate byte
	JMP	DC9_EXIT
DC_91:	AND	BL,00000111B			;register index bits
	SHL	BX,1				;word table
	MOV	AL,REGISTER_PAIRS[BX]		;get first
	CALL	OUTPUT_BUFFER
	MOV	AL,REGISTER_PAIRS[BX+1]
	CALL	OUTPUT_BUFFER			;place second
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	CALL	IMMEDIATE_WORD			;immediate word
DC9_EXIT:
	RET
DECODE_09		ENDP
	
	PAGE

DECODE_10		PROC
	CALL	OUTPUT_MNEMONIC			;place the mnemonics
	MOV	BYTE_COUNT,1			;three byte instruction
	MOV	AL,'A'
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000001B		;byte or word?
	JNZ	DC_102				;word
	MOV	AL,'L'				;else byte
DC_101:	CALL	OUTPUT_BUFFER
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	CALL	OUTPUT_LSQB
	CALL	IMMEDIATE_WORD
	CALL	OUTPUT_RSQB
	JMP	DC10_EXIT
DC_102:	MOV	AL,'X'
	JMP	DC_101
DC10_EXIT:
	RET
DECODE_10		ENDP

	PAGE

DECODE_11		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,1
	CALL	OUTPUT_LSQB
	CALL	IMMEDIATE_WORD
	CALL	OUTPUT_RSQB
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	MOV	AL,'A'
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000001B			;byte or word?
	JNZ	DC_111					;word
	MOV	AL,'L'
	JMP	DC_112
DC_111:	MOV	AL,'X'
DC_112:	CALL	OUTPUT_BUFFER
DC11_EXIT:
	RET
DECODE_11		ENDP

	PAGE

DECODE_12		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,2
	MOV	AL,'A'
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000001B
	JNZ	DC_122					;byte or word?
	MOV	AL,'L'					;byte
DC_121:	CALL	OUTPUT_BUFFER
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	CALL	IMMEDIATE_BYTE
	JMP	DC12_EXIT
DC_122:	MOV	AL,'X'
	JMP	DC_121
DC12_EXIT:
	RET
DECODE_12		ENDP

	PAGE

DECODE_13		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,2
	CALL	IMMEDIATE_BYTE
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	MOV	AL,'A'
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000001B
	JNZ	DC_131
	MOV	AL,'L'
	JMP	DC13_EXIT
	MOV	AL,'X'
DC_131:	CALL	OUTPUT_BUFFER
DC13_EXIT:
	RET
DECODE_13		ENDP

	PAGE

DECODE_14		PROC
	CALL	OUTPUT_MNEMONIC				;place mnemonics
	MOV	BYTE_COUNT,2				;minimum 2 byte ins
	TEST	CURRENT_OP,00000010B			;test direction flag
	JNZ	DC_141					;its <op> reg,mem/reg
	CALL	DEST$EA_SRC$REG				;else mem/reg,reg
	JMP	DC14_EXIT
DC_141:	CALL	DEST$REG_SRC$EA
DC14_EXIT:
	RET
DECODE_14		ENDP

	PAGE

DECODE_15		PROC
	CALL	OUTPUT_MNEMONIC				;place mnemonic
	MOV	BYTE_COUNT,2				;minimum 2 bytes
	CALL	MOD_RM					;output the address
	RET
DECODE_15		ENDP

	PAGE

DECODE_16		PROC
	CALL	OUTPUT_MNEMONIC				;place mnemonic
	MOV	BYTE_COUNT,2
	TEST	CURRENT_OP,00000010B			;test for direction
	JNZ	DC_162					;mov seg,mem/reg
	CALL	MOD_RM					;else mov mem/reg,seg
	MOV	AL,','
	CALL	OUTPUT_BUFFER
DC_161:	MOV	BL,ES:[SI+1]				;get address byte
	AND	BL,00011000B				;mask segment register
	SHR	BL,1					;index to reg table
	SHR	BL,1
	XOR	BH,BH
	MOV	AL,SEG_REGISTERS[BX]			;pick up name
	CALL	OUTPUT_BUFFER
	MOV	AL,SEG_REGISTERS[BX+1]
	CALL	OUTPUT_BUFFER
	RET
DC_162:	CALL	DC_161					;decode seg register
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	CALL	MOD_RM
	RET
DECODE_16		ENDP

	PAGE

DECODE_17		PROC
	MOV	BYTE_COUNT,2
	MOV	AL,ES:[SI+1]
	AND	AL,00111000B				;pick up reg field
	SHR	AL,1
	SHR	AL,1					;set up as index
	XOR	BH,BH
	MOV	BL,AL
	MOV	BX,OPCODES_8081[BX]			;pick up real address
	MOV	CX,8					;char count
DC_171:	MOV	AL,[BX]					;get char
	CALL	OUTPUT_BUFFER				;deposit it
	INC	BX
	LOOP	DC_171					;keep going
	CALL	MOD_RM					;output mem/reg
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000001B
	JNZ	DC_172					;word of data
	CALL	IMMEDIATE_BYTE				;else byte
	JMP	DC17_EXIT
DC_172:	CALL	IMMEDIATE_WORD				;word
DC17_EXIT:
	RET
DECODE_17		ENDP

	PAGE

DECODE_18		PROC
	MOV	BYTE_COUNT,2
	MOV	AL,ES:[SI+1]
	AND	AL,00111000B				;pick up reg field
	SHR	AL,1
	SHR	AL,1					;set up as index
	XOR	BH,BH
	MOV	BL,AL
	MOV	BX,OPCODES_8283[BX]			;pick up real address
	MOV	CX,8					;char count
DC_181:	MOV	AL,[BX]					;get char
	CALL	OUTPUT_BUFFER				;deposit it
	INC	BX
	LOOP	DC_181					;keep going
	CALL	MOD_RM					;output mem/reg
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000001B
	JNZ	DC_182					;word of data
	CALL	IMMEDIATE_BYTE				;else byte
	JMP	DC18_EXIT
DC_182:	CALL	IMMEDIATE_BYTE				;word with sign extend
DC18_EXIT:
	RET
DECODE_18		ENDP

	PAGE
	
DECODE_19		PROC
	MOV	BYTE_COUNT,2
	MOV	AL,ES:[SI+1]
	AND	AL,00111000B				;pick up reg field
	SHR	AL,1
	SHR	AL,1					;set up as index
	XOR	BH,BH
	MOV	BL,AL
	MOV	BX,OPCODES_D0D3[BX]			;pick up real address
	MOV	CX,8					;char count
DC_191:	MOV	AL,[BX]					;get char
	CALL	OUTPUT_BUFFER				;deposit it
	INC	BX
	LOOP	DC_191					;keep going
	CALL	MOD_RM					;output mem/reg
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000010B			;see if 1 or CL
	JNZ	DC_192
	MOV	AL,'1'					;its single shift
	CALL	OUTPUT_BUFFER
	JMP	DC19_EXIT
DC_192:	MOV	AL,'C'					;its CL index
	CALL	OUTPUT_BUFFER
	MOV	AL,'L'
	CALL	OUTPUT_BUFFER
DC19_EXIT:
	RET
DECODE_19		ENDP

	PAGE

DECODE_20		PROC
	MOV	BYTE_COUNT,2
	MOV	AL,ES:[SI+1]
	AND	AL,00111000B				;pick up reg field
	SHR	AL,1
	SHR	AL,1					;set up as index
	XOR	BH,BH
	MOV	BL,AL
	MOV	BX,OPCODES_C6C7[BX]			;pick up real address
	MOV	CX,8					;char count
DC_201:	MOV	AL,[BX]					;get char
	CALL	OUTPUT_BUFFER				;deposit it
	INC	BX
	LOOP	DC_201					;keep going
	CALL	MOD_RM					;output mem/reg
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000001B
	JNZ	DC_202					;word of data
	CALL	IMMEDIATE_BYTE				;else byte
	JMP	DC20_EXIT
DC_202:	CALL	IMMEDIATE_WORD				;word with sign extend
DC20_EXIT:
	RET
DECODE_20		ENDP

	PAGE

DECODE_21		PROC

COMMENT	%

	this routine decodes F6H and F7H

	these opcodes decode using the address byte
	into the table:

	TEST	mem/reg,kk[jj]
	NON
	NOT
	NEG
	MUL
	IMUL
	DIV
	IDIV

	F6 = byte op
	F7 = word op
%
	MOV	BYTE_COUNT,2
	MOV	AL,ES:[SI+1]				;pick up address byte
	AND	AL,00111000B				;pick up reg field
	SHR	AL,1
	SHR	AL,1					;set up as index
	XOR	BH,BH
	MOV	BL,AL
	MOV	BX,OPCODES_F6F7[BX]			;pick up real address
	MOV	CX,8					;char count
DC_211:	MOV	AL,[BX]					;get char
	CALL	OUTPUT_BUFFER				;deposit it
	INC	BX
	LOOP	DC_211					;keep going
	CALL	MOD_RM					;output mem/reg
	TEST	BYTE PTR ES:[SI+1],00111000B		;test reg field
	JNZ	DC21_EXIT				;finish with routine
	MOV	AL,','
	CALL	OUTPUT_BUFFER				;seperator
	TEST	BYTE PTR ES:[SI],00000001B		;is it word?
	JNZ	DC_212					;word
	CALL	IMMEDIATE_BYTE
	JMP	DC21_EXIT
DC_212:	CALL	IMMEDIATE_WORD
DC21_EXIT:
	RET
DECODE_21		ENDP

	PAGE

DECODE_22		PROC
	MOV	BYTE_COUNT,2
	MOV	AL,ES:[SI+1]
	AND	AL,00111000B				;pick up reg field
	SHR	AL,1
	SHR	AL,1					;set up as index
	XOR	BH,BH
	MOV	BL,AL
	MOV	BX,OPCODES_FE[BX]			;pick up real address
	MOV	CX,8					;char count
DC_221:	MOV	AL,[BX]					;get char
	CALL	OUTPUT_BUFFER				;deposit it
	INC	BX
	LOOP	DC_221					;keep going
	CALL	MOD_RM					;output mem/reg
	RET
DECODE_22		ENDP

	PAGE

DECODE_23		PROC
	MOV	BYTE_COUNT,2
	MOV	AL,ES:[SI+1]
	AND	AL,00111000B				;pick up reg field
	SHR	AL,1
	SHR	AL,1					;set up as index
	XOR	BH,BH
	MOV	BL,AL
	MOV	BX,OPCODES_FF[BX]			;pick up real address
	MOV	CX,8					;char count
DC_231:	MOV	AL,[BX]					;get char
	CALL	OUTPUT_BUFFER				;deposit it
	INC	BX
	LOOP	DC_231					;keep going
	CALL	MOD_RM					;output mem/reg
	RET
DECODE_23		ENDP

	PAGE

DECODE_24		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,1
	MOV	AL,'A'					; IN Az,DX
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000001B			;byte or word?
	JNZ	DC_242					;word
	MOV	AL,'L'
DC_241:	CALL	OUTPUT_BUFFER
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	MOV	AL,'D'
	CALL	OUTPUT_BUFFER
	MOV	AL,'X'
	CALL	OUTPUT_BUFFER
	RET
DC_242:	MOV	AL,'X'
	JMP	DC_241
DECODE_24		ENDP

	PAGE

DECODE_25		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,1
	MOV	AL,'D'
	CALL	OUTPUT_BUFFER
	MOV	AL,'X'
	CALL	OUTPUT_BUFFER
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	MOV	AL,'A'					; IN Az,DX
	CALL	OUTPUT_BUFFER
	TEST	CURRENT_OP,00000001B			;byte or word?
	JNZ	DC_252					;word
	MOV	AL,'L'
DC_251:	CALL	OUTPUT_BUFFER
	RET
DC_252:	MOV	AL,'X'
	JMP	DC_251
DECODE_25		ENDP

	PAGE

DECODE_26		PROC
	CALL	OUTPUT_MNEMONIC				;output mnemonics
	MOV	BYTE_COUNT,1				;byte count
	CALL	IMMEDIATE_WORD				;output address
	RET
DECODE_26		ENDP

	PAGE

DECODE_27		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,1				;single byte INT
	MOV	AL,'3'					; INT 3
	CALL	OUTPUT_BUFFER
	RET
DECODE_27		ENDP

	PAGE

DECODE_28		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,1				;two byte interrupt
	CALL	IMMEDIATE_BYTE				;hex for now
	RET
DECODE_28		ENDP

	PAGE

DECODE_29		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,1
	CALL	IMMEDIATE_WORD				;16 bit unsigned disp.
	RET
DECODE_29		ENDP

	PAGE

DECODE_30		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,1
	CALL	IMMEDIATE_WORD				;output segment
	MOV	AL,':'					;seperator
	CALL	OUTPUT_BUFFER
	CALL	IMMEDIATE_WORD				;output offset
	RET
DECODE_30		ENDP

	PAGE

DECODE_31		PROC
	CALL	OUTPUT_MNEMONIC
	MOV	BYTE_COUNT,2
	CALL	REGISTER
	MOV	AL,','
	CALL	OUTPUT_BUFFER
	CALL	MOD_RM
	RET
DECODE_31		ENDP


CODESEG		ENDS

	END

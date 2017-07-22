	PAGE	45,132

	TITLE Noddy88 debugger

	SUBTTL	Enter command processor

COMMENT	%

	allows entry of values into memory and registers

	command line:

	EHB <seg reg OR address>:<offset> <byte>

	EHW <seg reg OR address>:<offset> <word>

	EAB <seg reg OR address>:<offset> <char>

	ERB <reg> <byte>
 	ERW <reg> <word>
 
 	where <seg reg> is one of CS, DS, ES, SS,
 	and <address> and <offset> are the segment
 	and offset addresses repectively, input as
 	four digit hexadecimal numbers. <byte> and
 	<word> are 2 and 4 digit hexadecimal numbers.
 	<char> is any ASCII character, and <reg> is
 	any of the registers either byte or word
 	depending on whether a byte or word fill is required.

%

	.SALL

	PAGE

	PUBLIC	ENTER

	EXTRN	BYTE2_BIN:NEAR
	EXTRN	DOUBLE_REG:NEAR
	EXTRN	DUMP1:NEAR
	EXTRN	GET_CHAR:NEAR
	EXTRN	GET_SEGMENT:NEAR
	EXTRN	POINTERS:NEAR
	EXTRN	REGISTERS:NEAR
	EXTRN	SINGLE_REG:NEAR
	EXTRN	WORD2_BIN:NEAR

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

ENTER		PROC
 	CALL	GET_CHAR			;get the qualifier
 	JC	ENTER_ERROR			;error
 	CMP	AL,'A'				;ascii?
 	JZ	ENTER_ASCII			;yes
 	CMP	AL,'H'				;hex?
 	JZ	ENTER_HEX			;yes
 	CMP	AL,'R'				;register then?
 	JZ	ENTER_REG			;yes
ENTER_ERROR:
 	STC					;none so error
 	RET					;carry=error
 
 	PAGE
 
ENTER_ASCII:
 	CALL	GET_CHAR			;get enter type
 	JC	ENTER_ERROR			;error
 	CMP	AL,'B'				;byte enter?
 	JNZ	ENTER_ERROR			;no so error
EAB:	CALL	GET_CHAR
	JC	ENTER_ERROR
	CMP	AL,' '
	JNZ	ENTER_ERROR
	CALL	GET_SEGMENT			;get the addresses
 	JC	ENTER_ERROR			;failed
 	MOV	ES,BX				;set up segment
	MOV	DI,DX				;and offset
 	CALL	GET_CHAR			;get character
 	JC	ENTER_ERROR			;done
 	MOV	ES:[DI],AL			;deposit character
 	JMP	ENTER_EXIT			;finish up
 
 	PAGE
 
ENTER_HEX:
 	CALL	GET_CHAR			;get qualifier
	JC	ENTER_ERROR			;wrong
	CMP	AL,'W'				;byte
	JZ	EHW				;enter hex word
	CMP	AL,'B'				;byte then?
	JNZ	ENTER_ERROR			;mistake
EHB:	CALL	GET_CHAR
	JC	ENTER_ERROR
	CMP	AL,' '
	JNZ	ENTER_ERROR
	CALL	GET_SEGMENT			;get the addresses
	JC	ENTER_ERROR			;failed
	MOV	ES,BX				;set up segment
	MOV	DI,DX				;and offset
 	CALL	BYTE2_BIN			;convert byte to binary
 	JC	ENTER_ERROR			;failed
 	MOV	ES:[DI],AL			;save the byte
 	JMP	ENTER_EXIT			;tidy up
EHW:	CALL	GET_CHAR
	JC	ENTER_ERROR
	CMP	AL,' '
	JNZ	ENTER_ERROR
	CALL	GET_SEGMENT			;get the addresses
	JC	ENTER_ERROR			;failed
	MOV	ES,BX				;set up addresses
	MOV	DI,DX
	CALL	WORD2_BIN			;convert word to binary
	JC	ENTER_ERROR			;no
	MOV	ES:[DI],DX			;save the word
	JMP	ENTER_EXIT			;tidy up

	PAGE

ENTER_REG:
 	CALL	GET_CHAR			;get characer
	JC	ENTER_ERROR			;error
	CMP	AL,'W'				;word?
 	JZ	ERW				;yes
 	CMP	AL,'B'				;byte?
 	JNZ	ENTER_ERROR
ERB:	CALL	GET_CHAR
	JNC	ERB$1
	JMP	ENTER_ERROR
ERB$1:	CMP	AL,' '				;space between parameters
	JZ	ERB$2
	JMP	ENTER_ERROR
ERB$2:	CALL	SINGLE_REG			;get name/value
	JNC	ERB$3				;mistake
	JMP	ENTER_ERROR
ERB$3:	CALL	GET_CHAR			;get space
	CMP	AL,' '				;should be space
	JZ	ERB$10				;wrong
	JMP	ENTER_ERROR
ERB$10:	CALL	BYTE2_BIN			;get value
	JNC	ERB$20				;wrong
	JMP	ENTER_ERROR
ERB$20:	MOV	[DI],AL				;put byte in table
	JMP	ENTER_EXIT

ERW:	CALL	GET_CHAR
	JNC	ERW$10
	JMP	ENTER_ERROR
ERW$10:	CMP	AL,' '
	JZ	ERW$15
	JMP	ENTER_ERROR
ERW$15:	CALL	DOUBLE_REG			;get name/value
	JNC	ERW$20
	JMP	ENTER_ERROR			;mistake
ERW$20:	CALL	GET_CHAR			;get space
	JNC	ERW$21
	JMP	ENTER_ERROR
ERW$21:	CMP	AL,' '				;should be space
 	JZ	ERW$30				;wrong
	JMP	ENTER_ERROR
ERW$30:	CALL	WORD2_BIN			;get word value
 	JNC	ERW$40				;wrong
	JMP	ENTER_ERROR
ERW$40:	MOV	[DI],DX				;place word in table
ENTER_EXIT:
	CALL	DUMP1
	CALL	REGISTERS			;refresh screen
	CALL	POINTERS
	CLC
	RET
 
ENTER		ENDP


CODESEG		ENDS

	END


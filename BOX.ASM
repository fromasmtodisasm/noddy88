	PAGE	45,132

	TITLE Noddy88 debugger

	SUBTTL Screen building routines

COMMENT	%

 The start of the screen building routines
 
 These routines move the cursor to specific locations
 and use the characters from the graphics character
 set in ALTCHAR.SYS to draw the screen
  
 This is a cumbersome method and will be tidied up
 in a later version, either to create the screen by
 direct memory access or by outputting the screen
 format as one long character string.
  
 The first method will be preferred as this should tie
 in with the paging routines that I hope to include
 as soon as I can find out how to do the paging with the
 6845 CRT-C.
  
 The reason this approach has been adopted for now is
 because it is a fairly straightforward copy from the
 8-bit version of this program.
 
%

	.SALL

	.XLIST
	INCLUDE	MACLIB88.ASM
	INCLUDE	NOD88DEF.ASM
	.LIST

	PAGE

	PUBLIC	SCREEN_BOXES
	PUBLIC	FIXED_CHARS

CODESEG		SEGMENT		PUBLIC

	ASSUME	CS:CODESEG

	EXTRN	LEFT_COMMAND:NEAR
	EXTRN	RIGHT_COMMAND:NEAR
	EXTRN	VERTICAL:NEAR
	EXTRN	HORIZONTAL:NEAR
	EXTRN	CROSS:NEAR
	EXTRN	TOP_LEFT:NEAR
	EXTRN	TOP_RIGHT:NEAR
	EXTRN	BOTTOM_LEFT:NEAR
	EXTRN	BOTTOM_RIGHT:NEAR
	EXTRN	TOP_DOWN:NEAR
	EXTRN	BOTTOM_UP:NEAR
	EXTRN	LEFT2_RIGHT:NEAR
	EXTRN	RIGHT2_LEFT:NEAR

	EXTRN	MOVETO:NEAR
	EXTRN	OUTPUT_CHAR:NEAR
	EXTRN	GRAPHICS_ON:NEAR
	EXTRN	GRAPHICS_OFF:NEAR
 
SCREEN_BOXES	PROC
  
; draws the screen outline
  
BOX:	GOTO	YORG,XORG		;start at the beginning
 	CALL	TOP_LEFT		;top left corner
 	MOV	CX,52			;count across the top
BOX_01: CALL	HORIZONTAL		;draw the horizontal character
 	LOOP	BOX_01			;until count=0
 	CALL	TOP_DOWN		;top edge branch down
 	MOV	CX,16			;continue top edge
BOX_02: CALL	HORIZONTAL		;draw the top edge
 	LOOP	BOX_02			;until counter=0
 	CALL	TOP_DOWN		;top edge branch down
 	MOV	CX,8			;last bit along the top
BOX_03: CALL	HORIZONTAL		;draw the top edge
 	LOOP	BOX_03			;until counter=0
 	CALL	TOP_RIGHT		;top right hand corner
  
; draw a few verticals around the command line
  
BOX_10: GOTO	YORG+1,XORG		;start of the linne
 	CALL	VERTICAL		;draw vertical line
	GOTO	YORG+1,XORG+53		;next location
 	CALL	VERTICAL		;draw this vertical
	GOTO	YORG+1,XORG+70		;and the next..
 
	CALL	VERTICAL		;draw it
 	GOTO	YORG+1,XORG+79		;the last on this line
 	CALL	VERTICAL		;done
  
; start of code to underline the command line
  
 	GOTO	YORG+2,XORG		;point to the start
 	CALL	LEFT2_RIGHT		;left edge branching right
 	MOV	CX,52			;count across
BOX_20: CALL	HORIZONTAL		;keep going
 	LOOP	BOX_20			;until count=0
 	CALL	CROSS			;intersection point
 	MOV	CX,16			;new count
BOX_21: CALL	HORIZONTAL		;keep going
 	LOOP	BOX_21			;until count=0
 	CALL	CROSS			;another intersection
 	MOV	CX,8			;last section
BOX_22: CALL	HORIZONTAL		;horizontal line
 	LOOP	BOX_22			;done when cx=0
 	CALL	RIGHT2_LEFT		;right edge branching left
  
; start of code for drawing the main verticals
  
 	MOV	DH,YORG+3		;move start locations here
 	MOV	DL,XORG			; line 5 column XORG
 	MOV	CX,7			;count
BOX_30: CALL	MOVETO			;go there
 	CALL	VERTICAL		;draw vertical line
	INC	DH			;increase the line number
	LOOP	BOX_30			;decrease count and round..
	MOV	DH,YORG+3		;go to next location along
	MOV	DL,XORG+53		; line 5 column 54
 	MOV	CX,7			;restore count
BOX_31: CALL	MOVETO			;go there
	CALL	VERTICAL		;draw the vertical line
	INC	DH			;increase the line count
	LOOP	BOX_31			;round until done
	GOTO	YORG+3,XORG+70		;go to edge of SP display
	CALL	VERTICAL		;output vertical line
	GOTO	YORG+3,XORG+79		;other side..
	CALL	VERTICAL		;output vertical
 	GOTO	YORG+4,XORG+70		;underline stack area
	CALL	LEFT2_RIGHT		;left to right branch
	MOV	CX,8			;get count
BOX_32: CALL	HORIZONTAL		;underline SP area
	LOOP	BOX_32			;until count=0
	CALL	RIGHT2_LEFT		;right edge branching left
	MOV	DH,YORG+5		;verticals under SP area
	MOV	DL,XORG+70		; line 7 coumn XORG+70
	MOV	CX,6			;count
BOX_33: CALL	MOVETO			;go to the location
	CALL	VERTICAL		;draw the vertical
	INC	DH			;increase the line number
	LOOP	BOX_33			;until count=0
	MOV	DH,YORG+5		;second vertical under SP

	MOV	DL,XORG+79		; line 7 column 80
	MOV	CX,12			;count
BOX_34: CALL	MOVETO			;go to the location
	CALL	VERTICAL		;draw the vertical
	INC	DH			;increase the line number
	LOOP	BOX_34			;round until count = 0
	GOTO	YORG+10,XORG		;draw main line across middle
	CALL	LEFT2_RIGHT		;left edge branching right
	MOV	CX,52			;get the counter set up
BOX_40: CALL	HORIZONTAL		;output the line
 	LOOP	BOX_40			;until count = 0
 	CALL	RIGHT2_LEFT		;right edge branching left
 	MOV	DH,YORG+11		;draw the verticals around
 	MOV	DL,XORG			;dump area
 	MOV	CX,6			;get count
BOX_41: CALL	MOVETO			;go there
 	CALL	VERTICAL		;put out the verticals
	INC	DH			;increase line number
 	LOOP	BOX_41			;until count=0
 	MOV	DH,YORG+11		;draw the other side
 	MOV	DL,XORG+53		;of the dump area
	MOV	CX,6			;get count
BOX_42: CALL	MOVETO			;go there
	CALL	VERTICAL		;put out the verticals
	INC	DH			;increase line number
	LOOP	BOX_42			;until count=0
 
; draw the box around the halt area
 
 	GOTO	YORG+11,XORG+63		;go to top left corner
	CALL	TOP_LEFT		;and give one
	MOV	CX,6			;get count
BOX_50: CALL	HORIZONTAL		;draw top edge
 	LOOP	BOX_50
 	CALL	RIGHT2_LEFT		;right edge branch left
 	MOV	DH,YORG+12		;draw left hand vertical
 	MOV	DL,XORG+63
 	MOV	CX,5			;get count
BOX_51: CALL	MOVETO			;go there
	CALL	VERTICAL		;draw the vertical
	INC	DH			;increase line number
	LOOP	BOX_51			;round until count=0
	MOV	DH,YORG+12		;draw right hand side
	MOV	DL,XORG+70
	MOV	CX,5			;get count
BOX_52: CALL	MOVETO			;go there
	CALL	VERTICAL		;draw the vertical
	INC	DH			;increase the line number
	LOOP	BOX_52			;round until count=0

; draw the bottom line
 
	GOTO	YORG+17,XORG		;move to start
	CALL	BOTTOM_LEFT		;bottom left hand corner
	MOV	CX,52			;count for bottom line

BOX_60: CALL	HORIZONTAL		;draw it
	LOOP	BOX_60			;until done
 	CALL	BOTTOM_UP		;bottom edge branch up
 	MOV	CX,9			;get count for next section
BOX_61: CALL	HORIZONTAL		;draw it
 	LOOP	BOX_61			;until done
 	CALL	BOTTOM_UP		;bottom edge branch up
	MOV	CX,6			;next bit
BOX_62: CALL	HORIZONTAL		;draw it
	LOOP	BOX_62			;until done
 	CALL	BOTTOM_UP		;bottom edge branch up
	MOV	CX,8			;count for next bit
BOX_63: CALL	HORIZONTAL		;draw it
 	LOOP	BOX_63			;
 	CALL	BOTTOM_RIGHT		;bottom right hand corner
  
SCREEN_BOXES	ENDP

	PAGE
  
; now for all the fixed characters on the screen
; starting with the command line
  
FIXED_CHARS	PROC
  
; inserts the register names and fixed characters on the screen
  
	GOTO	YORG+1,XORG+4		;put out the command delimiters
	CALL	GRAPHICS_ON		;turn graphics on
	CALL	LEFT_COMMAND		;left hand one
	CALL	RIGHT_COMMAND		;and a right one here
	CALL	GRAPHICS_OFF		;finished with graphics
	GOTO	YORG+1,XORG+55		;flag register name
	OUTPUT	F			;output flag register
	GOTO	YORG+1,XORG+71		;stack segment register
	OUTPUT	S
	OUTPUT	S
	GOTO	YORG+3,XORG+71		;stack pointer
	OUTPUT	S
	OUTPUT	P
	GOTO	YORG+3,XORG+55		;accumulator
 	OUTPUT	A
	OUTPUT	X
 	GOTO	YORG+4,XORG+55
 	OUTPUT	B			;base register
 	OUTPUT	X
 	GOTO	YORG+5,XORG+55		;counter
 	OUTPUT	C
 	OUTPUT	X
 	GOTO	YORG+6,XORG+55		;data register
 	OUTPUT	D
 	OUTPUT	X
 	GOTO	YORG+8,XORG+55		;base pointer
 	OUTPUT	B
 	OUTPUT	P
 	GOTO	YORG+9,XORG+55		;source index
 	OUTPUT	S
	OUTPUT	I
	GOTO	YORG+10,XORG+55		;destination index
 	OUTPUT	D
 	OUTPUT	I
	GOTO	YORG+12,XORG+55		;code segment
 	OUTPUT	C
 	OUTPUT	S
 	GOTO	YORG+13,XORG+55		;data segment
 	OUTPUT	D
 	OUTPUT	S
 	GOTO	YORG+14,XORG+55		;extra segment
 	OUTPUT	E
 	OUTPUT	S
  
; pointer brackets
	GOTO	YORG+4,XORG+63		; for BX only
	OUTPUT	(  

 	MOV	DH,YORG+8
 	MOV	DL,XORG+63		;bottom section left side
 	MOV	CX,3			;only three here
CF_20:	CALL	MOVETO			;go there
 	OUTPUT	(
 	INC	DH			;increase line number
 	LOOP	CF_20			;keep going

	GOTO	YORG+4,XORG+69
	OUTPUT	)

	MOV	DH,YORG+8		;bottom right section
 	MOV	DL,XORG+69
 	MOV	CX,3			;back to three
CF_40:	CALL	MOVETO			;go there
 	OUTPUT	)
 	INC	DH			;increase line count
 	LOOP	CF_40			;keep going
	RET
  
FIXED_CHARS	ENDP

CODESEG		ENDS

	END


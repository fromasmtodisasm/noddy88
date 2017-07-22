 	ZDOS$CONIO	EQU	06H	;direct CON: input/output
 	ZDOS$CONINPUT	EQU	07H	;direct CON: input missing ^C
	ZDOS$STRING	EQU	09H	;print string terminated with '$'
	ZDOS$FLUSH	EQU	0CH	;flush type ahead buffer
	ZDOS$OPEN	EQU	0FH	;open a file
	ZDOS$CLOSE	EQU	10H	;close a file
	ZDOS$FIRST	EQU	11H	;search for first entry
	ZDOS$NEXT	EQU	12H	;search for next entry
	ZDOS$DELETE	EQU	13H	;delete file
	ZDOS$READSEQ	EQU	14H	;sequential read
	ZDOS$WRITESEQ	EQU	15H	;sequential write
	ZDOS$CREATE	EQU	16H	;create file
	ZDOS$RENAME	EQU	17H	;rename file
	ZDOS$CURRENT	EQU	19H	;get current disc code
	ZDOS$SETDTA	EQU	1AH	;set disc transfer address
	ZDOS$READRN	EQU	21H	;random read
	ZDOS$WRITERN	EQU	22H	;random write
	ZDOS$SIZE	EQU	23H	;get file size
	ZDOS$VECTOR	EQU	25H	;set interrupt vector
	ZDOS$NEWSEG	EQU	26H	;create new program segment header
	ZDOS$PARSE	EQU	29H	;parse file name
	ZDOS$DATE	EQU	2AH	;gets date
	ZDOS$SETDATE	EQU	2BH	;sets date
	ZDOS$TIME	EQU	2CH	;gets time
	ZDOS$SETTIME	EQU	2DH	;sets time
; File control block definitions
 
	FCB_DRIVE	EQU	0			; drive number
	FCB_FNAME	EQU	FCB_DRIVE+1		; file name
	FCB_FEXT	EQU	FCB_FNAME+8		; extension to file name
	FCB_CURBLK	EQU	FCB_FEXT+3		; current block
	FCB_RECSIZ	EQU	FCB_CURBLK+2		; record size
	FCB_FILSIZ	EQU	FCB_RECSIZ+2		; file size
	FCB_DATE	EQU	FCB_FILSIZ+4		; date file modified
	FCB_TIME	EQU	FCB_DATE+2		; time file modified
	FCB_RES 	EQU	FCB_TIME+2		; reserved
	FCB_CURREC	EQU	FCB_RES+8		; current record in block
	FCB_RANREC	EQU	FCB_CURREC+1		; random record number
	FCB_SIZE	EQU	FCB_RANREC+4		; size of a FCB

    list    F=inhx8m, P=16F88, R=hex, N=0

#include p16f88.inc

    __config _CONFIG1, _FOSC_INTOSCCLCK & _WDT_OFF & _LVP_OFF & _CCP1_RB0
    __config _CONFIG2, _IESO_OFF & _FCMEN_OFF

    Errorlevel -302 ; switches off Message [302]: Register in operand not in bank 2

; Definitions ------------------------------------------------------------------
    
; RAM preserved ----------------------------------------------------------------

; Constants --------------------------------------------------------------------

; Program Memory ---------------------------------------------------------------
            ORG     0x0000
            GOTO    Init

; Interrupt Service Routine (ISR) ----------------------------------------------
            ORG     0x0004      ; Interrupt vector location

; Microcontroller initialization -----------------------------------------------
Init        ORG     0x0008

; Main program -----------------------------------------------------------------
Start
; **** YOUR CODE GOES HERE ****
	    MOVLW   H'40'
	    BANKSEL OSCCON
	    MOVWF OSCCON
	    
	    BANKSEL TRISB
	    MOVLW H'00'
	    MOVWF TRISB
	    BANKSEL PORTB
	    

	    
MainLoop
RiseStart
	    BSF PORTB, 0
	    GOTO DelayLoopMinor
RiseFin
FallStart
	    BCF PORTB, 0
	    GOTO DelayLoopMajor
	    
	    GOTO MainLoop
	    
	  
	    
DelayLoopMinor
MajorCount EQU H'FA' ; Equates are good for defining literals
MinorCount EQU H'4B'
	    CBLOCK  H'20' ; A CBLOCK defines a sequential region
		Major ; L1Var is in location H?20?
		Minor ; L2Var is in location H?21?
	    ENDC ; ENDC ends the definition block	    

; Begin Delay Loop
Delay	    MOVLW MajorCount ; Notice how above declarations
	    MOVWF Major ; are used here
Loop1	    MOVLW MinorCount
	    MOVWF Minor
Loop2	    DECFSZ Minor
	    GOTO Loop2
	    DECFSZ L1Var
	    GOTO Loop1
; End Delay Loop
	    
	    GOTO RiseFin
	    
	    
	    
DelayLoopMajor
MajorCount EQU H'FA' ; Equates are good for defining literals
MinorCount EQU H'AF'
	    CBLOCK  H'20' ; A CBLOCK defines a sequential region
		Major ; L1Var is in location H?20?
		Minor ; L2Var is in location H?21?
	    ENDC ; ENDC ends the definition block	    

; Begin Delay Loop
Delay	    MOVLW MajorCount ; Notice how above declarations
	    MOVWF Major ; are used here
Loop1	    MOVLW MinorCount
	    MOVWF Minor
Loop2	    DECFSZ Minor
	    GOTO Loop2
	    DECFSZ L1Var
	    GOTO Loop1
; End Delay Loop
	    
	    GOTO RiseFin
	    
Finish
            END     ; End of program




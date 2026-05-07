    list    F=inhx8m, P=16F88, R=hex, N=0

#include p16f88.inc

    __config _CONFIG1, _FOSC_INTOSCCLK & _WDT_OFF & _LVP_OFF & _CCP1_RB0
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
	    MOVLW   b'01010000'
	    BANKSEL OSCCON
	    MOVWF OSCCON
	    
	    BANKSEL TRISB
	    MOVLW H'00'
	    MOVWF TRISB
	    BANKSEL PORTB
	    

	    
MainLoop
RiseStart
	    BSF PORTB, RB0
	    GOTO DelayLoopMinor
RiseFin
FallStart
	    BCF PORTB, RB0
	    GOTO DelayLoopMajor
FallEnd	    
	    GOTO MainLoop
	    
	  
	    
DelayLoopMinor
;MajorCount EQU H'01' ; Equates are good for defining literals
MinorCount EQU H'32'
	    CBLOCK  H'20' ; A CBLOCK defines a sequential region
		Major ; L1Var is in location H?20?
		Minor ; L2Var is in location H?21?
	    ENDC ; ENDC ends the definition block	    

; Begin Delay Loop
Delay	    
	    MOVLW MinorCount
	    MOVWF Minor
Loop1	    DECFSZ Minor
	    GOTO Loop1
	    GOTO RiseFin
;Loop2	    DECFSZ Minor
;	    GOTO Loop2
;	    DECFSZ Major
;	    GOTO Loop1
; End Delay Loop
	    
;	    GOTO RiseFin
	    
	    
	    
DelayLoopMajor
MajorCountM EQU H'74' ; Equates are good for defining literals
;MinorCountM EQU H'32'
	    CBLOCK  H'23' ; A CBLOCK defines a sequential region
		MajorM ; L1Var is in location H?20?
;		MinorM ; L2Var is in location H?21?
	    ENDC ; ENDC ends the definition block	    
;DelayM
;
;Loop
	    
DelayM
	 MOVLW MajorCountM
	 MOVWF MajorM
Loop5	 DECFSZ MajorM
	 GOTO Loop5
	 GOTO MainLoop
	 

	    ; Begin Delay Loop
;DelayM	    MOVLW MajorCountM ; Notice how above declarations
;	    MOVWF MajorM ; are used here
;Loop1M	    MOVLW MinorCountM
;	    MOVWF MinorM
;Loop2M	    DECFSZ MinorM
;	    GOTO Loop2M
;	    DECFSZ MajorM
;	    GOTO Loop1M
;End Delay Loop
	    
;	    GOTO MainLoop
	    
Finish
            END     ; End of program




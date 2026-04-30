    list    F=inhx8m, P=16F88, R=hex, N=0

#include p16f88.inc

    __config _CONFIG1, _FOSC_INTOSCIO & _WDT_OFF & _LVP_OFF & _CCP1_RB0
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
	
	    BSF STATUS, RP0
	    MOVLW b'00000000'
	    MOVWF TRISB
	    BCF STATUS, RP0
	
Main	    MOVLW b'00000001'
	    MOVWF H'21'
	    MOVF H'21', PORTB
OnLED	    
;	    MOVF PORTB, H'21'
	    RLF H'21'
	    MOVF H'21', W
	    MOVWF PORTB
	    GOTO Delay
	
;SubLoop2    GOTO OnLED
;	    GOTO SubLoop2
;	    
;DelayArea
;	    GOTO Delay
;OffLEDarea
;	    GOTO OffLED
;	    GOTO MainLoop
;	   
	
;OnLED	    
;	    MOVWF H'21'
;	    MOVWF PORTB
;	    GOTO DelayArea
;	    
;OffLED	    MOVLW b'00000000'
;	    MOVWF PORTB
;	    GOTO MainLoop

; RANDOM DELAYLOOP NONSENSE	    
Delay	    MOVLW H'CF'
	    MOVWF H'30'
Loop	    MOVLW H'CF'
	    MOVWF H'31'
SubLoop	    DECFSZ H'31'
	    GOTO SubLoop
	    DECFSZ H'30'
;	    GOTO Loop
	    GOTO OnLED
	    
	    
	
Finish
            END     ; End of program




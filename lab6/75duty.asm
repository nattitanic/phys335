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
	
;	Set the internal Osccilator
	    MOVLW   b'01010000'
	    BANKSEL OSCCON
	    MOVWF OSCCON
	
;	Set trisb to be the output
	    BANKSEL TRISB
	    MOVLW H'00'
	    MOVWF TRISB
	    
;	Set PR2 to the correct value (Controls the freq)
	    BANKSEL PR2
	    MOVLW H'F9'
	    MOVWF PR2
	    
;	Turn on T2CON
	    BANKSEL T2CON
	    BSF T2CON, 2
	    
;	Set CCPR1 (LSB) and CP1CON (MSB) to control the Duty Cycle
	    BANKSEL CCPR1L
;	    MOVLW H'BD'
	    MOVLW b'10111011'
	    MOVWF CCPR1L
	    
	    BANKSEL CCP1CON
;	    MOVLW H'0C'
	    MOVLW b'00101100'
	    MOVWF CCP1CON
	    
	    
	    
	    BSF CCP1CON, 1
	    BSF CCP1CON, 2
	    
	    
;	    BANKSEL CCPR1L
	    
	    
Finish
            END     ; End of program




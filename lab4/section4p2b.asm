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
	    BSF STATUS, RP0 ; Go to bank 1
	    MOVLW b?00000000?
	    MOVWF TRISB ; Set Port B as Outputs
	    MOVWF ANSEL ; ANSEL = 0x00 --> inputs are digital
	    MOVLW b?11111111?
	    MOVWF TRISA ; Set Port A as input
	    BCF STATUS, RP0 ; Go to back to bank 0

MainLoop    BTFSS PORTA, 0 ; Look at PORTA<0>
	    GOTO PB1Pushed ; branch if lo, skip to next if hi
	    MOVLW b?00111101?
	    MOVWF PORTB ; Output a distinctive LED pattern
	    GOTO MainLoop ; loop back

PB1Pushed   MOVLW b?11000010?
	    MOVWF PORTB ; Output a contrasting pattern
	    GOTO MainLoop ; And go back to the Main Loop
	    
Finish
            END     ; End of program




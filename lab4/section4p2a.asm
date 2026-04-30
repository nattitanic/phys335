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
	    MOVLW b'00001111'
	    MOVWF H'20'
	    CLRF H'21'
	    MOVLW b'11001100'
	    MOVWF H'21'
LoopPoint   RRF H'20',F
	    INCF H'21',F
	    GOTO LoopPoint
Finish
            END     ; End of program




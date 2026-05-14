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
	
;	CONFIG
	
	; Set Vars
	
	CBLOCK  H'20' ; A CBLOCK defines a sequential region
	    PortTest ; L1Var is in location H?20?
	ENDC ; ENDC ends the definition block
	
	; Set Consts
	Thirty_Three EQU H'1C'
	Sixty_Six EQU H'72'
	Full_All EQU H'FF'

	    
;	Set the internal Osccilator
;	    MOVLW   b'01100000'
	    MOVLW b'01010000' ; 2mhz osc, 500khz clock
	    BANKSEL OSCCON
	    MOVWF OSCCON
	    BANKSEL CCP1CON

	    
;	Turn on T2CON
	    BANKSEL T2CON
	    BSF T2CON, 2
	    
;	Set Port A and B
	    BANKSEL TRISB
	    BCF TRISB, 0
;	    MOVLW H'00'
;	    MOVWF TRISB ; B as Output
	    
	    MOVWF ANSEL ; A as Digital
	    
	    MOVLW b'11111111' ; A as Input
	    MOVWF TRISA
	    BANKSEL PORTA
	    
;	Set PR2 to the correct value (Controls the freq)
	    BANKSEL PR2
	    MOVLW H'FF'
	    MOVWF PR2
	    
	    BANKSEL CCP1CON
	    BSF CCP1CON, 2
	    BSF CCP1CON, 3
	    
	
	MainLoop    
		    BANKSEL PORTA
		    MOVF PORTA, W
		    MOVWF PortTest
		    BTFSC PortTest, 1 ; Test MSB first, If set, got to MSBSet (SKIP IF CLEAR)
		    GOTO MSBSet
		    BTFSC PortTest, 0 ; Tests LSB set, if it is, 1/3
		    GOTO OneThird
		    GOTO OffLight

		    GOTO MainLoop



	; MSB Check
	MSBSet	    
		    BTFSS PortTest, 0 ; Check LSB
		    GOTO TwoThird ; If Not Set
		    GOTO FullBright ; If Set	    
		    GOTO MainLoop ; Fail Safe


	; Modes Avail
	OffLight    
		    BANKSEL CCPR1L
		    MOVLW H'00'
		    MOVWF CCPR1L		    
		    GOTO MainLoop


	OneThird    
		    BANKSEL CCPR1L
		    MOVLW Thirty_Three
		    MOVWF CCPR1L		    
		    GOTO MainLoop

	TwoThird    
		    BANKSEL CCPR1L
		    MOVLW Sixty_Six
		    MOVWF CCPR1L
		    GOTO MainLoop

	FullBright 
		    BANKSEL CCPR1L
		    MOVLW Full_All
		    MOVWF CCPR1L
		    GOTO MainLoop







	;	
	;;;	Set trisb to be the output
	;;	    BANKSEL TRISB
	;;	    MOVLW H'00'
	;;	    MOVWF TRISB
	;	    
	;;	Set PR2 to the correct value (Controls the freq)
	;	    BANKSEL PR2
	;	    MOVLW H'FF'
	;	    MOVWF PR2
	;	    

	;	    
	;;	Set CCPR1L (LSB) and CP1CON (MSB) to control the Duty Cycle
	;	    BANKSEL CCPR1L
	;	    MOVLW H'5D'
	;;	    MOVLW b'10111011'
	;	    MOVWF CCPR1L
	;	    
	;	    BANKSEL CCP1CON
	;	    MOVLW H'30'
	;;	    MOVLW b'00101100'
	;	    MOVWF CCP1CON
	;	    
	;	    
	;	    
	;	    BSF CCP1CON, 1
	;	    BSF CCP1CON, 2
;	
Finish
            END     ; End of program




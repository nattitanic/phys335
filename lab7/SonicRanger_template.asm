list       F=inhx8m, P=16F88, R=hex, N=0 ; File format, chip, and default radix

#include p16f88.inc ;   PIC 16f88 specific register definitions

 __config _CONFIG1, _MCLR_ON & _FOSC_INTOSCCLK & _WDT_OFF & _LVP_OFF & _PWRTE_OFF & _BODEN_ON & _LVP_OFF & _CPD_OFF & _WRT_PROTECT_OFF & _CCP1_RB0 & _CP_OFF
 __config _CONFIG2 , _IESO_OFF & _FCMEN_OFF

 Errorlevel -302 ; switches off msg [302]: Register in operand not in bank 0.

; Definitions -------------------------------------------------------------

; You may want to add other variables here
TimerCounts EQU     H'20'   ; Saving timer counts
bin         EQU     H'21'   ; used in bin2bcd
bcdH        EQU     H'22'   ; used in bin2bcd
bcdL        EQU     H'23'   ; used in bin2bcd
counter     EQU     H'24'   ; used in bin2bcd
temp        EQU     H'25'   ; used in bin2bcd

; RAM preserved -----------------------------------------------------------

; Constants --------------------------------------------------------------

; Program Memory ----------------------------------------------------------

            ORG     0x0000
            GOTO    Init

; Interrupt Service Routine -----------------------------------------------
            ORG     0x0004               ; ISR beginning
            
; -------------------------------------------------------------------------
; Microcontroller initialization
Init        ORG     0x0008

; Set Internal oscillator as you choose
SetOSC
	BANKSEL OSCCON
	MOVLW b'01100000' ; 4mhz osc, 1mhz clock
	MOVWF OSCCON
	BANKSEL CCP1CON

; Set up I/O on PORTA<0> Output, PORTA<1> input and PORTB<7:0> output
SetIO
;	PORT A AS INPUT
	BANKSEL TRISA
	MOVLW H'FF'
	MOVWF TRISA
	
;	PORTB AS OUTPUT
	BCF TRISB
	
	
;	ANSEL OFF, DIGITAL INPUT
	BCF ANSEL
	BANKSEL PORTA
	

; Set up Timer0, using OPTION_REG
SetTimer

; Main part of loop
MainLoop
 
; Make 10 microsecond pulse on PORTA<0>
Pulse
	BANKSEL PORTA
	BSF PORTA, 0
	CALL DELAY2
	BCF PORTA, 0
	
	
    ; ===== 15 ms TIME WASTER ====
	DELAY2

	DCounter3 EQU 0X0C
	DCounter4 EQU 0X0D


		MOVLW 0X78
		MOVWF DCounter3
		MOVLW 0X14
		MOVWF DCounter4
	LOOP2
		DECFSZ DCounter3, 1
		GOTO LOOP2
		DECFSZ DCounter4, 1
		GOTO LOOP2
		NOP
		RETURN
    ; ============================

; Wait until PORTA<1> Goes HI, then clear TMR0
EchoWait_and_Clear

; Wait until PORTA<1> Goes LOW, then read TMR0 into W
EndEcho_and_Read

; Save TMR0 and pass to BCD converter and then display

;            MOVWF   TimerCounts ; Save for debug comparison
;            MOVWF   bin         ; Save TMR0 to bin for Convertion
;
;            CALL    _bin2bcd
;
            CALL    UpdateDisplay

            CALL    Delay       ; Wait so we don't pulse too fast

            GOTO    MainLoop

; Time Waster Routine
Delay
	; First, the declarations
	DCounter1 EQU 0X0C
	DCounter2 EQU 0X0D
	
	; Now the loops
	DELAY
	    MOVLW 0Xe9
	    MOVWF DCounter1
	    MOVLW 0X4e
	    MOVWF DCounter2
	LOOP
	    DECFSZ DCounter1, 1
	    GOTO LOOP
	    
	    DECFSZ DCounter2, 1
	    GOTO LOOP
	    
	    NOP
	    NOP
	    
            RETURN
	    
	    
; Display output routine.  This checks to see if there is a digit above "99"
;   in "standard" mode or "39" in "debug" mode.  Note: RB6 and RB7 are used by
;   the debugger, so these bits cannot be used to display a digit.
;   If so, it outputs an overflow "OF" indication.
UpdateDisplay
;            MOVF    bcdH, W     ; Check if anything wound up in 100s column
;            BTFSS   STATUS, Z   ; if not, no overflow, so skip 'OF' display
;            GOTO    Overflow
;            MOVF    bcdL, W
;            ; Comment out next FOUR lines if using full '99' display
;            ANDLW   b'11000000' ; By ANDing with top 2 bits
;            BTFSS   STATUS, Z   ;    check to see if top nibble above '3'
;            GOTO    Overflow    ;    '39' is max value under Debug mode
;            MOVF    bcdL, W
;            MOVWF   PORTB       ; Otherwise copy BCD nibbles to PORTB
            RETURN

Overflow
;            MOVLW   H'0F'       ; Send OF to PORTB if we've overflowed
;            MOVWF   PORTB
;            RETURN

; Include the binary to BCD converter here
;#include bin2bcd.inc

Finish
            END                 ; end of program

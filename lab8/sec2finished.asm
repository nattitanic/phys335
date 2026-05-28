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
	
Index1	    EQU	    H'26'   ; Delay loop variables
Index2	    EQU	    H'27'   ; Cycles = 5*Count1*Count2 + 4*Count2 + 1

; PART 1 ==================================================================
 UnitCtr   EQU	    H'28'   ; counter to hold distance measurement
; -------------------------------------------------------------------------
	    
; PART 2 ==================================================================
 Latch	    EQU	    H'30'   ; Latch variable to hold state of button press
 Button    EQU	    H'31'   ; Button state variable (only use bit 0)
; -------------------------------------------------------------------------
	    
; Temporary storage for ISR needs to live in upper common area of RAM
W_TEMP	    EQU	    H'75'   ; Temporary storage for W and STATUS 
STATUS_TEMP EQU	    H'76'   ;    during interrupt

; RAM preserved -----------------------------------------------------------

; Constants ---------------------------------------------------------------
Count1	    EQU	    .199    ; 60 ms = 60,000 cycles
Count2	    EQU	    .60	    ; Nested loop executes for 59,941 cycles

; PART 1 ==================================================================
; You need to calculate these.
CM_period   EQU .58	    ; 1 cm equivalent for Timer2	    
IN_period   EQU .148	    ; 1 inch equivalent for Timer2
; -------------------------------------------------------------------------
	    
; Program Memory ----------------------------------------------------------

            ORG     0x0000
            GOTO    Init

; PART 1 ==================================================================
; Interrupt Service Routine -----------------------------------------------
            ORG     0x0004	    ; ISR beginning
            MOVWF   W_TEMP	    ; Save W
	    SWAPF   STATUS, W	    ; Save STATUS without affecting STATUS bits
	    MOVWF   STATUS_TEMP
	    
	    ; Your code for the ISR goes here 
	    ; Set Bank = 0
	    ; Increment the unit counter
	    ; Clear the interrupt flag for Timer2 (or whole PIR register)
	    
	    BANKSEL PORTA
;	    MOVLW .1
;	    ADDWF UnitCtr
	    INCF UnitCtr
	    BCF PIR1, TMR2IF
	    
	    
	    SWAPF   STATUS_TEMP, W
	    MOVWF   STATUS	    ; Restore STATUS
	    SWAPF   W_TEMP, F
	    SWAPF   W_TEMP, W	    ; Restore W without affecting STATUS
	    RETFIE		    ; Leave ISR (and enable interrupts)
; -------------------------------------------------------------------------

; Microcontroller initialization
Init        ORG     0x0020	    ; Note ORG must leave space for ISR

; PART 1 ==================================================================
; Disable interrupts
; YOU CODE THIS: Clear INTCON, PIE1 and PIE2  
;	    
	    BANKSEL INTCON
	    CLRF INTCON
	    CLRF PIE1
	    CLRF PIE2
	    BANKSEL PORTA
; -------------------------------------------------------------------------	   
	    
; Set Internal oscillator to 4 MHz clock
SetOSC
	    BANKSEL OSCCON  ; Select bits in OSCCON to use 4MHz clock
	    CLRF    OSCCON
	    BSF	    OSCCON, IRCF2
	    BSF	    OSCCON, IRCF1

; Set up I/O on PORTA<0> Output, PORTA<1> input and PORTB<7:0> output
SetIO
	    BANKSEL PORTA
	    CLRF    PORTA   ; Clear data latches
	    CLRF    PORTB   
	    BANKSEL TRISA
	    CLRF    ANSEL   ; All inputs are digital
	    CLRF    TRISB   ; Port B is all outputs
	    MOVLW   H'FF'
	    MOVWF   TRISA
	    BCF	    TRISA, RA0	; Port A is all inputs except for RA0

; -------------------------------------------------------------------------
; Set up Timer0 according to first Sonic Ranger lab
SetTimer
;	    BANKSEL OPTION_REG
;	    BCF	    OPTION_REG, T0CS	; select internal clock
;	    BCF	    OPTION_REG, PSA ; prescaler assigned to Timer0
;	    BSF	    OPTION_REG, PS2
;	    BCF	    OPTION_REG, PS1
;	    BSF	    OPTION_REG, PS0 ; select 1:64 pre-scaler PS<2:0> = 101
;	    BANKSEL TMR0	    ; Back to bank zero
; PART 1 ==================================================================
; Set up Timer2 which we use to generate an interrupt on PR2 match
; YOU CODE THIS:
;   First comment out code above that initializes Timer0 (we don't use it).
;   Use T2CON to select no prescaler and also turn Timer2 ON
;   Put a default value into PR2
	    
	    BANKSEL T2CON
	    CLRF T2CON ; Clears file
	    BSF T2CON, TMR2ON ; Sets turns on the timer
	    BANKSEL PR2
	    MOVLW IN_period
	    MOVWF PR2
	    
	   
; -------------------------------------------------------------------------

; PART 1 ==================================================================
; Enable interrupts
; YOU CODE THIS:
;   First Clear any interrupt flags in PIR1 and INTCON
;   Then set the bit in PIE1 to enable interrupt from Timer2 match
;   Then set the bits in INTCON to enable peripheral and global interrupts
	 BANKSEL PIR1
	 CLRF PIR1
	 
	 BANKSEL PIE1
	 BSF PIE1, TMR2IE
	 
	 
	 BANKSEL INTCON
	 CLRF INTCON
	 BSF INTCON, GIE
	 BSF INTCON, PEIE
	 
	 BANKSEL PORTA
	 
; -------------------------------------------------------------------------
	    

; PART 2 ==================================================================
; Initialize button control variables
; YOU CODE THIS:
;   Clear both button control variables
	    CLRF Latch
	    CLRF Button
; -------------------------------------------------------------------------

	    BCF	    STATUS, RP0
	    BCF	    STATUS, RP1	    ; All of the action is in Bank 0 now
MainLoop

;PollButton
;; Part 2 ==================================================================
;; Button Control
;; YOU CODE THIS	  
;; Section 1: software latch to save initial state
;;   Follow scheme in lab instructions:
;	    ; Test PORTA, RA2: if button is down
;	    ;	then jump to check the latch state
;	    ; Otherwise clear the latch
;	    ; Jump to Pulse
;	    
;	    BTFSS PORTA, RA2
;	    GOTO CheckLatch
;	    CLRF Latch
;	    GOTO Pulse
;	    
;	    ; 
;CheckLatch  ; Test the latch bit: if it is clear
;	    ;	then Call the routine to set the period register
;	    ; On return and otherwise, set the latch
;	    ; Jump to Pulse
;	    BTFSS Latch, 0
;	    CALL SetPeriod
;	    BSF Latch, 0
;	    GOTO Pulse
	    
	    
	    
	    
; Section 2: Routine to set the period register
;SetPeriod
;	    ; Complement the button state bit (0 --> 1, or 1 --> 0)
;	    ; Test the button state bit: if it is clear
;	    ;	GOTO Set_CM to load centimeter period
;	    ; Otherwise GOTO Set_IN
;	    
;	    BTFSS Button, 0
;	    GOTO Set_CM
;	    GOTO Set_IN
;	    
;	    
;	    
;Set_IN	    ; In either Set_CM or Set_IN, do two things:
;	    ;	1. Load W with the inch or cm period value
;	    MOVLW IN_period
;	    CALL SET_PR2
;	    GOTO Pulse
;	    
;Set_CM	    ;	2. GOTO Set_PR2
;	    MOVLW CM_period
;	    CALL SET_PR2
;	    GOTO Pulse
;	    
;SET_PR2	    ; In Set_PR2
;	    ;	Select the Bank for PR2
;	    ;	Copy W into PR2
;	    ;   Select Bank 0
;	    ; End SetPeriod with RETURN
;	    BANKSEL PR2
;	    MOVWF PR2
;	    BANKSEL PORTA
;	    RETURN
; -------------------------------------------------------------------------
	    
; Make 10 microsecond pulse on PORTA<0>
Pulse

; PART 1 ==================================================================
; Disable interrupts during pulse 
; YOU CODE THIS (one statement)
	    
	    BANKSEL INTCON
	    BCF INTCON, GIE
;--------------------------------------------------------------------------
	    BSF	    PORTA, RA0	; Set RA0 high
	    NOP			; Wait 10 instructions
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    BCF	    PORTA, RA0	; Set RA0 low
; PART 1 ==================================================================
; Re-enable interrupts 
; YOU CODE THIS (one statement)
	    BSF INTCON, GIE
;--------------------------------------------------------------------------
	    
; Wait until PORTA<1> Goes HI, then clear TMR0/UnitCtr
EchoWait_and_Clear
	    BTFSS   PORTA, RA1	    ; Keep checking until RA1 goes high
	    GOTO    EchoWait_and_Clear
; PART 1 ==================================================================
; Change TMR0 to UnitCtr 
;	    CLRF    TMR0	    ; When it does, clear unit counter
	    CLRF    UnitCtr	    ; When it does, clear unit counter
	    
; -------------------------------------------------------------------------
	    
; Wait until PORTA<1> Goes LOW, then read TMR0 into W
EndEcho_and_Read
	    BTFSC   PORTA, RA1	    ; Keep checking until RA0 goes low 
	    GOTO    EndEcho_and_Read
; PART 1 ==================================================================
; Change TMR0 to UnitCtr	    
	    MOVF    TMR0, W	    ; When it does, put TMR0/UnitCtr in W
	    MOVF    UnitCtr, W
; -------------------------------------------------------------------------	    
; Save counter value and pass to BCD converter and then display

            MOVWF   TimerCounts ; Save for debug comparison
            MOVWF   bin         ; Save TMR0 to bin for Convertion

            CALL    _bin2bcd	; Convert to BCD in bcdH, bcdL

            CALL    UpdateDisplay ; Only using bcdL

            CALL    Delay       ; Wait so we don't pulse too fast

            GOTO    MainLoop

; Time Waster Routine
Delay	    
	    MOVLW   Count2
	    MOVWF   Index2
Loop1	    MOVLW   Count1
	    MOVWF   Index1
Subloop1    NOP
	    NOP
	    DECFSZ  Index1,F
	    GOTO    Subloop1
	    DECFSZ  Index2,F
	    GOTO    Loop1
            RETURN
	    
; Display output routine.  This checks to see if there is a digit above "99"
;   in "standard" mode or "39" in "debug" mode.  Note: RB6 and RB7 are used by
;   the debugger, so these bits cannot be used to display a digit.
;   If so, it outputs an overflow "OF" indication.
UpdateDisplay
            MOVF    bcdH, W     ; Check if anything wound up in 100s column
            BTFSS   STATUS, Z   ; if not, no overflow, so skip 'OF' display
            GOTO    Overflow
            MOVF    bcdL, W
            ; Comment out next FOUR lines if using full '99' display
;            ANDLW   b'11000000' ; By ANDing with top 2 bits
;            BTFSS   STATUS, Z   ;    check to see if top nibble above '3'
;            GOTO    Overflow    ;    '39' is max value under Debug mode
;            MOVF    bcdL, W
            MOVWF   PORTB       ; Otherwise copy BCD nibbles to PORTB
            RETURN
Overflow
            MOVLW   H'0F'       ; Send OF to PORTB if we've overflowed
            MOVWF   PORTB
            RETURN

; Include the binary to BCD converter here
#include bin2bcd.inc

Finish
            END                 ; end of program

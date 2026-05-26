; 8-bit binary to BCD conversion
; pete griffiths 2007
; http://picprojects.org.uk/projects/pictips.htm
;
; These file register variables will
; need to be defined elsewhere.
; bin
; bcdH
; bcdL
; counter
; temp
;
; bin contains the binary value to convert.
; Conversion process destroys contents
; Result is in bcdH, bcdL on return.
; Call _bin2bcd to perform conversion.
;
; Executes in 86 instructions


_bin2bcd    movlw     d'5'
            movwf     counter
            clrf      bcdL
            clrf      bcdH
; we can save some execution time by not
; doing the 'test and add +3'code for the
; first two shifts
            rlf       bin,F
            rlf       bcdL,F
            rlf       bin,F
            rlf       bcdL,F
            rlf       bin,F
            rlf       bcdL,F

_repeat     movf      bcdL,W
            addlw     0x33
            movwf     temp
            movf      bcdL,W
            btfsc     temp,3
            addlw     0x03
            btfsc     temp,7
            addlw     0x30
            movwf     bcdL
; we only need to do the test and add +3 for
; the low bcd variable since the
; largest binary value is 0xFF which is 255
; decimal so the high bcd byte variable will
; never be greater than 2.
            rlf       bin,F
            rlf       bcdL,F
            rlf       bcdH,F

            decfsz    counter,F
            goto      _repeat
            return
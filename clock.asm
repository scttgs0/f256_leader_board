
;======================================
;
;======================================
DrawClock       .proc
                bra _2      ; HACK:

                lda CONSOL
                and #$01                ; SELECT pressed?
                bne _1                  ;   no

;   /// SELECT ///
                jsr PlayInputAction

                lda clockControl
                eor #$01
                sta clockControl
                and #$01
                bne _1

;   clear the clock display
                ldy #$07
_next1          lda #' '                ; space
                sta _clock,Y

                dey
                bpl _next1

                .frsTextXY 31,11,$70,DrawClock._clock

                ;lda #$08                ; duration
                ;ldx #$0D                ; timer 13
                ;jsr SetTimer

;   wait for timer
;_wait1          lda timerIsActive+13    ; timer 13 active?
;                bne _wait1              ;   yes

_1              jsr DoWind

                lda clockControl
                cmp #$81
                beq _2

                rts

; - - - - - - - - - - - - - - - - - - -
_2              and #$7F                ; clear hi-bit
                sta clockControl

;   hour (BCD)
                lda clockHour
                pha                     ; preserve

                lsr                     ; get upper-nibble
                lsr
                lsr
                lsr
                and #$0F
                ora #'0'
                sta _clock

                pla                     ; restore
                and #$0F                ; get lower-nibble
                ora #'0'
                sta _clock+1

                lda #':'                ; colon
                sta _clock+2

;   minutes (BCD)
                lda clockMins
                pha                     ; preserve

                lsr                     ; get upper-nibble
                lsr
                lsr
                lsr
                and #$0F
                ora #'0'
                sta _clock+3

                pla                     ; restore
                and #$0F                ; get lower-nibble
                ora #'0'
                sta _clock+4

                lda #':'                ; colon
                sta _clock+5

;   seconds (BCD)
                lda clockSecs
                pha                     ; preserve

                lsr                     ; get upper-nibble
                lsr
                lsr
                lsr
                and #$0F
                ora #'0'
                sta _clock+6

                pla                     ; restore
                and #$0F                ; get lower-nibble
                ora #'0'
                sta _clock+7

;   render the time
                .frsTextXY 31,11,$70,DrawClock._clock

                rts

;--------------------------------------

_clock          .null '00:00:00'

                .endproc


;--------------------------------------
;--------------------------------------

clockControl    .byte $01

clockSecs       .byte $00               ; BCD
clockMins       .byte $00               ; BCD
clockHour       .byte $00               ; BCD

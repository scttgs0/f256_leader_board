
;======================================
;
;--------------------------------------
; on entry:
;   A           multiplier
;   Y:X         value
; on exit:
;   Y:X:A       result:long
;====================================== ;[[V]]
MultiplyWordByByte .proc
_value          = physicsY
_multiplier     = dwordMath
_result         = dwordMath
;---

                sta _multiplier
                stz _multiplier+1       ; hi-byte unused

                stx _value
                sty _value+1

                jsr MultiplyWordByWord_ABS  ; long result in Y:X:A

                lda _result
                ldx _result+1
                ldy _result+2

                rts
                .endproc


;======================================
;
;--------------------------------------
;
;====================================== ;[[V]]
MultipleWordByPhysicsY .proc
                stz dwordMath+2
                stz dwordMath+3

                ldy #$10
_next1          lda dwordMath
                lsr
                bcc _1

                clc
                lda dwordMath+2
                adc physicsY
                sta dwordMath+2
                lda dwordMath+3
                adc physicsY+1
                sta dwordMath+3

_1              ror dwordMath+3
                ror dwordMath+2
                ror dwordMath+1
                ror dwordMath

                dey
                bne _next1

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   dwordMath   word value 1
;   physicsY    word value 2
; on exit:
;   dwordMath   dword result
;====================================== ;[[V]]
MultiplyWordByWord_ABS .proc
                lda physicsY+1
                eor dwordMath+1
                sta isResultNegative

                lda dwordMath+1
                bpl _1

;   negative value... convert to positive
                sec
                lda #<$0000
                sbc dwordMath
                sta dwordMath
                lda #>$0000
                sbc dwordMath+1
                sta dwordMath+1

_1              lda physicsY+1
                bpl _2

;   negative value... convert to positive
                sec
                lda #<$0000
                sbc physicsY
                sta physicsY
                lda #>$0000
                sbc physicsY+1
                sta physicsY+1

_2              jsr MultipleWordByPhysicsY

                lda isResultNegative
                bpl _XIT

                sec
                lda #<$0000
                sbc dwordMath
                sta dwordMath
                lda #>$0000
                sbc dwordMath+1
                sta dwordMath+1

                lda #<$0000
                sbc dwordMath+2
                sta dwordMath+2
                lda #>$0000
                sbc dwordMath+3
                sta dwordMath+3

_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[V]]
MultipleBy6     .proc
                stx dwordMath           ; idxActiveHole
                sty physicsY            ; always 6

                stz dwordMath+1         ; hi-byte unused
                stz physicsY+1

                jsr MultipleWordByPhysicsY

                lda dwordMath           ; word result
                ldx dwordMath+1

                rts
                .endproc


;======================================
;
;--------------------------------------
; preserved:    X,Y
; on entry:
;   A           power based on club
; on exit:
;   A           result_HI (dwordMath+1)
;   dwordMath   result_LO
;====================================== ;[[V]]
MultiplyByteBy42 .proc
_value          = dwordMath
_multiplier     = physicsY
_result         = dwordMath
;---

                sta _value

                txa                     ; preserve X,Y
                pha
                tya
                pha

                lda #>$002A
                sta _value+1            ; value_HI unused
                sta _multiplier+1       ; multiplier_HI unused
                lda #<$002A             ; multiplier (x42)
                sta _multiplier

                jsr MultipleWordByPhysicsY

                pla                     ; restore X,Y
                tay
                pla
                tax

                lda _result+1
                rts
                .endproc


;======================================
; divide wordB by wordA
;--------------------------------------
; on entry:
;   wordA       divisor
;   wordB       16-bit value
; on exit:
;   wordB       whole value
;   wordC       remainder
;--------------------------------------
; examples:
; wordA     $0024       ,$003C
; wordB     $3148->$015E,$090F->$0026
; wordC            $0010,       $0027
;====================================== ;[[V]]
DivideWordBbyWordA .proc
                stz wordC_3CC0
                stz wordC_3CC0+1

; - - - - - - - - - - - - - - - - - - -
_ENTRY1         lda wordA_3CBC
                ora wordA_3CBC+1        ; wordA=0?
                bne _1                  ;   no

                sec                     ;   yes
                rts

; - - - - - - - - - - - - - - - - - - -
_1              ldx #$10
_next1          rol wordB_3CBE          ; 32-bit ROL
                rol wordB_3CBE+1
                rol wordC_3CC0
                rol wordC_3CC0+1

                sec
                lda wordC_3CC0
                sbc wordA_3CBC
                tay
                lda wordC_3CC0+1
                sbc wordA_3CBC+1
                bcc _2

                sty wordC_3CC0
                sta wordC_3CC0+1

_2              dex
                bne _next1

                rol wordB_3CBE          ; 16-bit ROL
                rol wordB_3CBE+1

                clc
                rts
                .endproc


;======================================
; divide ABS(wordB) by ABS(wordA)
;--------------------------------------
; on entry:
;   wordA       divisor
;   wordB       16-bit value
; on exit:
;   wordB       whole value
;   wordC       remainder
;--------------------------------------
; examples:
;   wordA   $03E8->$02A0,$003C->$003C
;   wordB   $0000->$00A2,$02DA->$000C
;   wordC   $0007->$E220,$0000->$000A
;   wordD        ->$20ED,$0005->$0202
;====================================== ;[[V]]
DivideWordBbyWordA_ABS .proc
                lda wordB_3CBE+1
                eor wordA_3CBC+1
                sta wordD_3CC2

                lda wordB_3CBE+1
                sta wordD_3CC2+1

                lda wordA_3CBC+1
                bpl _1

;   negative, make positive
                lda #<$0000
                sec
                sbc wordA_3CBC
                sta wordA_3CBC
                lda #>$0000
                sbc wordA_3CBC+1
                sta wordA_3CBC+1

_1              lda wordB_3CBE+1
                bpl _2

;   negative, make positive
                lda #<$0000
                sbc wordB_3CBE
                sta wordB_3CBE
                lda #>$0000
                sbc wordB_3CBE+1
                sta wordB_3CBE+1

_2              jsr DivideWordBbyWordA  ; result in wordB+wordC[remainder]
_ENTRY1         bcs _4

                lda wordD_3CC2
                bpl _3

;   negative
                lda #<$0000
                sec
                sbc wordB_3CBE
                sta wordB_3CBE
                lda #>$0000
                sbc wordB_3CBE+1
                sta wordB_3CBE+1

_3              lda wordD_3CC2+1
                bpl _XIT

;   negative
                lda #<$0000
                sec
                sbc wordC_3CC0
                sta wordC_3CC0
                lda #>$0000
                sbc wordC_3CC0+1
                sta wordC_3CC0+1

                jmp _XIT

; - - - - - - - - - - - - - - - - - - -
_4              stz wordB_3CBE
                stz wordB_3CBE+1
                stz wordC_3CC0
                stz wordC_3CC0+1

                sec
                rts

; - - - - - - - - - - - - - - - - - - -
_XIT            clc
                rts
                .endproc


;======================================
;
;--------------------------------------
;
;====================================== ;[[V]]
DivideDWordCbySquareWordA .proc
                lda wordC_3CC0+1
                eor wordA_3CBC+1
                sta wordD_3CC2

                lda wordC_3CC0+1
                sta wordD_3CC2+1

                lda wordA_3CBC+1
                bpl _1

;   negative value... convert to positive
                lda #<$0000
                sec
                sbc wordA_3CBC
                sta wordA_3CBC
                lda #>$0000
                sbc wordA_3CBC+1
                sta wordA_3CBC+1

_1              lda wordC_3CC0+1
                bpl _2

;   negative value... convert to positive
                lda #<$0000
                sec
                sbc wordB_3CBE
                sta wordB_3CBE
                lda #>$0000
                sbc wordB_3CBE+1
                sta wordB_3CBE+1

                lda #<$0000
                sbc wordC_3CC0
                sta wordC_3CC0
                lda #>$0000
                sbc wordC_3CC0+1
                sta wordC_3CC0+1

;   calculate wordB / wordA^2
_2              jsr DivideWordBbyWordA._ENTRY1      ; result in wordB+wordC[remainder]
                jmp DivideWordBbyWordA_ABS._ENTRY1  ; result in wordB+wordC[remainder]

                .endproc


;======================================
;
;--------------------------------------
; on exit:
;   Y:X         result
;====================================== ;[[V]]
GetWordResult   .proc
                asl dwordMath+1         ; load CARRY

                bit dwordMath+3         ; are we decrementing?
                bmi _1                  ;   yes

; - - - - - - - - - - - - - - - - - - -
                lda dwordMath+2         ; increment
                adc #<$0000
                tax
                lda dwordMath+3
                adc #>$0000
                tay

                rts

; - - - - - - - - - - - - - - - - - - -
_1              lda dwordMath+2         ; decrement
                sbc #<$0000
                tax
                lda dwordMath+3
                sbc #>$0000
                tay

                rts
                .endproc


;======================================
;
;--------------------------------------
;
;====================================== ;[[V]]
Multiply_DividebySquare .proc
                lda distanceToPinFeet
                sta wordA_3CBC
                lda distanceToPinFeet+1
                sta wordA_3CBC+1

                stx dwordMath
                sty dwordMath+1

                lda wordA_course
                sta physicsY
                lda wordA_course+1
                sta physicsY+1

                jsr MultiplyWordByWord_ABS

                ldx #$03
_next1          lda dwordMath,X
                sta wordB_3CBE,X

                dex
                bpl _next1

                jsr DivideDWordCbySquareWordA

                ldx wordB_3CBE
                ldy wordB_3CBE+1

                rts
                .endproc


;======================================
; calculate Sqr(deltaX) + Sqr(deltaY).
;--------------------------------------
; Step One of the Pythagorean formula
;====================================== ;[[V]]
calcHypotenuseArea .proc
;   calculate deltaX^2
                lda wordA_course
                sec
                sbc polyVertX_LO
                sta dwordMath
                sta physicsY
                sta polyVertX_delta

                lda wordA_course+1
                sbc polyVertX_HI
                sta dwordMath+1
                sta physicsY+1
                sta polyVertX_delta+1

                jsr MultiplyWordByWord_ABS  ; = dwordMath * physicsY

                lda dwordMath
                sta distanceToPinFeet
                lda dwordMath+1
                sta distanceToPinFeet+1

                lda dwordMath+2
                sta distanceToPinNatural
                lda dwordMath+3
                sta distanceToPinNatural+1

; - - - - - - - - - - - - - - - - - - -
;   calculate deltaY^2
                lda wordB_course
                sec
                sbc polyVertY_LO
                sta dwordMath
                sta physicsY
                sta polyVertY_delta

                lda wordB_course+1
                sbc polyVertY_HI
                sta dwordMath+1
                sta physicsY+1
                sta polyVertY_delta+1

                jsr MultiplyWordByWord_ABS

                clc
                lda dwordMath
                adc distanceToPinFeet
                sta distanceToPinFeet
                sta distanceToPinFeet2
                lda dwordMath+1
                adc distanceToPinFeet+1
                sta distanceToPinFeet+1
                sta distanceToPinFeet2+1

                lda dwordMath+2
                adc distanceToPinNatural
                sta distanceToPinNatural
                sta distanceToPinNatural2
                lda dwordMath+3
                adc distanceToPinNatural+1
                sta distanceToPinNatural+1
                sta distanceToPinNatural2+1

                rts
                .endproc


;======================================
;
;--------------------------------------
; Step Two of the Pythagorean formula
;--------------------------------------
; given:
;   SQR($097CA440) = $3148
;--------------------------------------
; example:
;   $2294   $A440                     ->$A440 ...   ->$3148
;   $2296   $097C                     ->$097C       ->$097C
;   $2298   $A440->$7FFF              ->$497C       ->$3148
;   $229A   $097C->$0000              ->$0000       ->$0000
;   wordA          $7FFF       ->$7FFF
;   wordB          $A440->$12F9->$497C
;   wordC          $097C->$3739->$0000
;   wordD
;====================================== ;[[V]]
calcSquareRoot  .proc
                stz polyVertCount

;   find non-zero value
                ldx #$03                ; two words
_next1          lda distanceToPinFeet,X ; non-zero?
                bne _2                  ;   yes

                dex
                bne _next1

;   all values are zero
                lda distanceToPinFeet
                bne _1

                rts

; - - - - - - - - - - - - - - - - - - -
_1              cmp #$02                ; >=2 feet?
                bcs _2                  ;   yes

                lda #$01                ; distance is 1 foot

                rts

; - - - - - - - - - - - - - - - - - - -
_2              lda #>$7FFF             ; max value
                sta distanceToPinFeet2+1
                lda #<$7FFF
                sta distanceToPinFeet2

                stz distanceToPinNatural2
                stz distanceToPinNatural2+1

_next2          ldx #$03                ; two words
_next3          lda distanceToPinFeet,X ; get Feet & Natural
                sta wordB_3CBE,X        ; set wordB & wordC

                lda distanceToPinFeet2,X ; get Feet2 & Natural2
                sta wordA_3CBC,X        ; set wordA & wordB

                dex
                bpl _next3

;   input:
;   wordA = distanceToPinFeet2
;   wordB = distanceToPinNatural2
;   wordC = distanceToPinNatural
;   output:
;   wordB = distanceToPinNatural2 / distanceToPinFeet2
;   wordC = remainder
                jsr DivideWordBbyWordA._ENTRY1  ; result in wordB+wordC[remainder]

;   calculate wordB += distanceToPinFeet2
                ldy #$01
                ldx #$00
                clc
_next4          lda wordB_3CBE,X
                adc distanceToPinFeet2,X
                sta wordB_3CBE,X
                inx

                dey
                bpl _next4

                lsr wordB_3CBE+1        ; /2 (16-bit)
                ror wordB_3CBE

                lda #$00
                adc #$00
                sta tempC               ; preserve Carry-bit

                stz wordC_3CC0+1        ; clear remainder
                stz wordC_3CC0

                jsr CompareForEquality
                bcs _3

                ldx #$03                ; two word
_next5          lda wordB_3CBE,X        ; store result
                sta distanceToPinFeet2,X

                dex
                bpl _next5
                jmp _next2

; - - - - - - - - - - - - - - - - - - -
_3              lda wordB_3CBE          ; add the preserved Carry-bit
                clc
                adc tempC
                tax
                sta distanceToPinFeet   ; save result
                lda wordB_3CBE+1
                adc #$00
                tay
                sta distanceToPinFeet+1

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
ConvertToInches .proc
                stx dwordMath           ; polygon origin X_LO
                sta dwordMath+1         ; polygon origin X_HI

                tya                     ; preserve
                pha

                lda #<$000C
                sta physicsY
                lda #>$000C
                sta physicsY+1

                jsr MultiplyWordByWord_ABS

                pla                     ; restore
                tay

                lda dwordMath+1         ; result
                ldx dwordMath

                rts
                .endproc


;======================================
;
;--------------------------------------
; CARRY is cleared when NOT EQUAL
;====================================== ;[[V]]
CompareForEquality .proc
                ldx #$03                ; two words
_next1          lda wordB_3CBE,X
                cmp distanceToPinFeet2,X
                bne _XIT

                dex
                bpl _next1

_XIT            rts

;--------------------------------------

                .byte $00,$D3

                .endproc


;--------------------------------------
;--------------------------------------

dwordMath           .dword $0000
physicsY            .word $0000
isResultNegative    .byte $00

wordA_3CBC          .word $0000
wordB_3CBE          .word $0000
wordC_3CC0          .word $0000
wordD_3CC2          .word $0000

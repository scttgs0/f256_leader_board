
;======================================
;
;======================================
CourseTransformA .proc
                lda physicsX1_sign
                bmi _wait1

_next1          lda physicsY1
                sta physicsY
                lda physicsY1+1
                sta physicsY+1

                lda wordB_course
                sta dwordMath
                lda wordB_course+1
                sta dwordMath+1

                jsr MultiplyWordByWord_ABS

                rol dwordMath+1
                rol dwordMath+2
                rol dwordMath+3

                jsr GetWordResult       ; result in Y:X
                stx physics_delta
                sty physics_delta+1

                jmp CourseTransformB

; - - - - - - - - - - - - - - - - - - -
_wait1          lda physicsY1+1
                bpl _wait1

                dec physicsY1

                jmp _next1

                .endproc


;--------------------------------------
;
;--------------------------------------
CourseTransformB .proc
                lda physicsX0_sign
                bmi _1

_next1          lda physicsY0
                sta physicsY
                lda physicsY0+1
                sta physicsY+1

                lda wordA_course
                sta dwordMath
                lda wordA_course+1
                sta dwordMath+1

                jsr MultiplyWordByWord_ABS

                rol dwordMath+1
                rol dwordMath+2
                rol dwordMath+3

                jsr GetWordResult       ; result in Y:X
                txa

                jmp _3

; - - - - - - - - - - - - - - - - - - -
_1              lda physicsY0+1
                bpl _2

                dec physicsY0

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_2              lda wordA_course
                ldy wordA_course+1

_3              sec
                sbc physics_delta
                sta wordC_course
                tya
                sbc physics_delta+1
                sta wordC_course+1

                lda physicsX0_sign
                bmi _4

_next2          lda physicsY0
                sta physicsY
                lda physicsY0+1
                sta physicsY+1

                lda wordB_course
                sta dwordMath
                lda wordB_course+1
                sta dwordMath+1

                jsr MultiplyWordByWord_ABS

                rol dwordMath+1
                rol dwordMath+2
                rol dwordMath+3

                jsr GetWordResult       ; result in Y:X
                stx physics_delta
                sty physics_delta+1

                jmp _6

; - - - - - - - - - - - - - - - - - - -
_4              lda physicsY0+1
                bpl _5
                jmp _next2

; - - - - - - - - - - - - - - - - - - -
_5              lda wordB_course
                sta physics_delta
                lda wordB_course+1
                sta physics_delta+1

_6              lda physicsX1_sign
                bmi _7

_next3          lda physicsY1
                sta physicsY
                lda physicsY1+1
                sta physicsY+1

                lda wordA_course
                sta dwordMath
                lda wordA_course+1
                sta dwordMath+1

                jsr MultiplyWordByWord_ABS

                rol dwordMath+1
                rol dwordMath+2
                rol dwordMath+3

                jsr GetWordResult       ; result in Y:X

                txa
                jmp _9

; - - - - - - - - - - - - - - - - - - -
_7              lda physicsY1+1
                bpl _8
                jmp _next3

; - - - - - - - - - - - - - - - - - - -
_8              lda wordA_course
                ldy wordA_course+1
_9              clc
                adc physics_delta
                sta wordD_course
                tya
                adc physics_delta+1
                sta wordD_course+1

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A           playerWindDirection_LO
;   Y           playerWindDirection_HI
; on exit:
;   X           sign  (0=pos, -1=neg)
;======================================
PhysicsCosine_1E98 .proc
                sty savePhysicsY
                sta savePhysicsY+1

                ldx #$00                ; positive sign
                stx physicsSign_00_FF

                cmp #$C0                ; >=192? [75%]
                bcs _2                  ;   yes

                cmp #$80                ; >=128? [50%]
                bcs _3                  ;   yes

                cmp #$40                ; >=64?  [25%]
                bcs _4                  ;   yes

; - - - - - - - - - - - - - - - - - - -
;   <25%
_next1          ldy #$00
                sty physicsSign2_00_FF

_next2          lda savePhysicsY+1
                asl                     ; *2
                bne _1

                ldx #$FF                ; negative sign
                stx physicsSign_00_FF

_1              tax
                lda tblCosine,X
                tay

                inx
                lda tblCosine,X
                jmp _5

; - - - - - - - - - - - - - - - - - - -
;   75%+
_2              ;lda #$01
                ;lsr                    ; A=0
                lda #<$0000
                sec
                sbc savePhysicsY
                sta savePhysicsY
                lda #>$0000
                sbc savePhysicsY+1
                sta savePhysicsY+1

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
;   50%+
_3              sec
                sbc #$80
                sta savePhysicsY+1

_next3          ldy #$FF
                sty physicsSign2_00_FF

                jmp _next2

; - - - - - - - - - - - - - - - - - - -
;   25%+
_4              lda #<$8000
                sec
                sbc savePhysicsY
                sta savePhysicsY
                lda #>$8000
                sbc savePhysicsY+1
                sta savePhysicsY+1

                jmp _next3

; - - - - - - - - - - - - - - - - - - -
_5              cpx #$81
                beq _7

                sty physicsCosine
                sta physicsCosine+1

                inx
                tya

                sec
                sbc tblCosine,X         ; LO
                sta dwordMath
                lda physicsCosine+1
                inx
                sbc tblCosine,X         ; HI
                sta dwordMath+1

                lda savePhysicsY
                sta physicsY
                ;lda #$00
                stz physicsY+1          ; hi-byte unused

                jsr MultiplyWordByWord_ABS

                lda dwordMath
                clc
                bmi _6

                sec
_6              lda physicsCosine
                sbc dwordMath+1
                sta physicsCosine
                tay
                lda physicsCosine+1
                sbc dwordMath+2
                sta physicsCosine+1

_7              ldx physicsSign2_00_FF
                bpl _8

                ;lsr PORTA
                eor #$FF
                pha

                tya
                eor #$FF
                sec
                adc #$00
                tay
                pla
                adc #$00

_8              ldx physicsSign_00_FF
                rts
                .endproc


;--------------------------------------
;--------------------------------------

physicsSign_00_FF   .byte $00
                    .byte $00
physicsSign2_00_FF  .byte $00

savePhysicsY        .word $0000
physicsCosine       .word $0000


;======================================
;
;--------------------------------------
; on entry:
;   A           playerWindDirection_LO
;   Y           playerWindDirection_HI
; on exit:
;   A:Y         result
;   X           sign  (0=pos, -1=neg)
;======================================
PhysicsSubtract4000 .proc
                sty savePhysicsY
                sta savePhysicsY+1

                tya
                sec
                sbc #<$4000
                sta savePhysicsY
                tay
                lda savePhysicsY+1
                sbc #>$4000
                sta savePhysicsY+1

                jmp PhysicsCosine_1E98

                .endproc


;--------------------------------------
;--------------------------------------

tblCosine       .word $7FFF,$7FF6,$7FD8,$7FA7
                .word $7F62,$7F09,$7E9D,$7E1E
                .word $7D8A,$7CE4,$7C2A,$7B5D
                .word $7A7D,$798A,$7885,$776C
                .word $7642,$7504,$73B6,$7255
                .word $70E3,$6F5F,$6DCA,$6C24
                .word $6A6E,$68A7,$66CF,$64E9
                .word $62F2,$60EC,$5ED7,$5CB4
                .word $5A82,$5843,$55F6,$539B
                .word $5134,$4EC0,$4C40,$49B4
                .word $471D,$447B,$41CE,$3F17
                .word $3C57,$398D,$36BA,$33DF
                .word $30FC,$2E11,$2B1F,$2827
                .word $2528,$2224,$1F1A,$1C0C
                .word $18F9,$15E2,$12C8,$0FAB
                .word $0C8C,$096B,$0648,$0324
                .word $0000


;======================================
;
;--------------------------------------
; on entry:
;   A           playerWindDirection_LO
;               windDirThisHole_LO
;   Y           playerWindDirection_HI
;               windDirThisHole_HI
; on exit:
;   A:Y         value:word
;   X           sign
;======================================
PhysicsCosine_m4000 .proc
                sty _saveY              ; preserve
                sta _saveA

                jsr PhysicsCosine_1E98
                sty physicsY0
                sta physicsY0+1
                stx physicsX0_sign

                ldy _saveY              ; restore
                lda _saveA

                jsr PhysicsSubtract4000
                sty physicsY1
                sta physicsY1+1
                stx physicsX1_sign

                rts

;--------------------------------------

_saveY          .byte $00
_saveA          .byte $00

                .endproc


;--------------------------------------
;--------------------------------------

physicsX1_sign  .byte $00               ; 0=pos, -1=neg
physicsX0_sign  .byte $00               ; 0=pos, -1=neg

physicsY0       .word $0000
physicsY1       .word $0000

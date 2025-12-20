
;--------------------------------------
;
;--------------------------------------
;
;-------------------------------------- ;[[V]]
ProjectAimPosition .proc
                lda aimPosition
                sta polyVertX_LO_2
                lda aimPosition_HI
                sta polyVertX_HI_2

                lda #<$0018             ; surface (24 inches)
                sta polyVertZ_LO_2
                lda #>$0018
                sta polyVertZ_HI_2

                lda const_0x700
                sta polyVertY_LO_2
                lda const_0x700+1
                sta polyVertY_HI_2

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
; calculate:
;   wordC:wordD = vertZ * $0298
;   = wordD / vertY
;-------------------------------------- ;[[V]]
Project3DVertex .proc
;   wordC:wordB = (zCoord-zCenterline)*664
                lda polyVertZ_LO_2
                sec
                sbc #<$0150             ; 336 (zCoord centerline)
                sta dwordMath
                lda polyVertZ_HI_2
                sbc #>$0150
                sta dwordMath+1

                lda #<$0298             ; *664
                sta physicsY
                lda #>$0298
                sta physicsY+1

                jsr MultiplyWordByWord_ABS  ; result in dwordMath

                lda dwordMath           ; save result
                sta wordB_3CBE
                lda dwordMath+1
                sta wordB_3CBE+1
                lda dwordMath+2
                sta wordC_3CC0
                lda dwordMath+3
                sta wordC_3CC0+1

; - - - - - - - - - - - - - - - - - - -
;   wordB = wordC:wordB/yCoord^2... remainder wordC (ignored)
                lda polyVertY_LO_2
                sta wordA_3CBC
                lda polyVertY_HI_2
                sta wordA_3CBC+1

                jsr DivideDWordCbySquareWordA   ; result in wordB+wordC[remainder]

; - - - - - - - - - - - - - - - - - - -
                stz newClip_flags       ; clear clipping flags

; - - - - - - - - - - - - - - - - - - -
;   newVertZ = 20 - wordB
                lda #<$0014
                sec
                sbc wordB_3CBE
                sta newVertZ_LO
                lda #>$0014
                sbc wordB_3CBE+1
                sta newVertZ_HI
                bpl _1

                lda #$04                ; set bit-2 (newVertZ isOffScreenTop)
                ora newClip_flags
                sta newClip_flags

                jmp _3

; - - - - - - - - - - - - - - - - - - -
_1              bne _2

                lda newVertZ_LO
                cmp #$C8                ; off-screen?
                bcs _2                  ;   yes
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_2              lda #$08                ; set bit-3 (newVertZ isOffScreenBottom)
                ora newClip_flags
                sta newClip_flags

; - - - - - - - - - - - - - - - - - - -
;   wordC:wordB = (xCoord-xCenterline)*857
_3              lda polyVertX_LO_2
                sta dwordMath
                lda polyVertX_HI_2
                sec
                sbc #>$1800             ; course centerline (512 feet)
                sta dwordMath+1

                lda #<$0359             ; *857
                sta physicsY
                lda #>$0359
                sta physicsY+1

                jsr MultiplyWordByWord_ABS  ; result in dwordMath

                lda dwordMath           ; save result
                sta wordB_3CBE
                lda dwordMath+1
                sta wordB_3CBE+1
                lda dwordMath+2
                sta wordC_3CC0
                lda dwordMath+3
                sta wordC_3CC0+1

; - - - - - - - - - - - - - - - - - - -
;   wordB = wordC:wordB/yCoord^2... remainder wordC (ignored)
                lda polyVertY_LO_2
                sta wordA_3CBC
                lda polyVertY_HI_2
                sta wordA_3CBC+1

                jsr DivideDWordCbySquareWordA   ; result in wordB+wordC[remainder]

; - - - - - - - - - - - - - - - - - - -
;   newVertX = 120 + wordB
                lda #<$0078             ; 120, half of the screen width [240]
                clc
                adc wordB_3CBE
                sta newVertX_LO
                lda #>$0078
                adc wordB_3CBE+1
                sta newVertX_HI
                bpl _4

                lda #$02                ; set bit-1 (newVertX isOffScreenLeft)
                ora newClip_flags
                sta newClip_flags

                jmp _6

; - - - - - - - - - - - - - - - - - - -
_4              bne _5

                lda newVertX_LO
                cmp #$F0                ; off-screen?
                bcs _5                  ;   yes
                jmp _6

; - - - - - - - - - - - - - - - - - - -
_5              lda newClip_flags
                ora #$01                ; set bit-0 (newVertX isOffScreenRight)
                sta newClip_flags

; - - - - - - - - - - - - - - - - - - -
_6              ldx newVertX_LO
                ldy newVertZ_LO
                lda newClip_flags

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
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
;-------------------------------------- ;[[V]]
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
;   Y:X         word value
;====================================== ;[[V]]
CalcPolyVertXY_delta .proc
                stx wordA_course
                sty wordA_course+1

                ldy windDirThisHole_HI
                lda windDirThisHole_LO
                jsr PhysicsCosine_m4000 ; sets physicsY0,physicsX0_sign and physicsY1,physicsX1_sign

                lda physicsX1_sign
                bmi _1

; - - - - - - - - - - - - - - - - - - -
;   positive
_next1          lda physicsY1
                sta physicsY
                lda physicsY1+1
                sta physicsY+1

                lda wordA_course
                sta dwordMath
                lda wordA_course+1
                sta dwordMath+1

                jsr MultiplyWordByWord_ABS

                rol dwordMath+1         ; *2 (32-bit)
                rol dwordMath+2
                rol dwordMath+3

                jsr GetWordResult       ; result in Y:X

_next2          stx polyVertX_delta
                sty polyVertX_delta+1

                jmp _3

; - - - - - - - - - - - - - - - - - - -
;   negative
_1              lda physicsY1+1
                bpl _2

                dec physicsY1

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_2              ldx wordA_course
                ldy wordA_course+1

                jmp _next2

; - - - - - - - - - - - - - - - - - - -
_3              lda physicsX0_sign
                bmi _4

_next3          lda physicsY0
                sta physicsY
                lda physicsY0+1
                sta physicsY+1

                lda wordA_course
                sta dwordMath
                lda wordA_course+1
                sta dwordMath+1

                jsr MultiplyWordByWord_ABS

                rol dwordMath+1         ; *2 (32-bit)
                rol dwordMath+2
                rol dwordMath+3

                jsr GetWordResult       ; result in Y:X

_next4          stx polyVertY_delta
                sty polyVertY_delta+1

                rts

; - - - - - - - - - - - - - - - - - - -
_4              lda physicsY0+1
                bpl _5

                dec physicsY0

                jmp _next3

; - - - - - - - - - - - - - - - - - - -
_5              ldx wordA_course
                ldy wordA_course+1

                jmp _next4

                .endproc


;======================================
;
;--------------------------------------
;
;====================================== ;[[F]]
CalcProjectile  .proc
                ldx activePlayer
                lda playerDistUnit,X
                cmp #unitYARDS          ; yards or feet?
                bcc _1                  ;   feet

; - - - - - - - - - - - - - - - - - - -
;   yards
                jsr CalcTravelDistanceYards     ; example: 1Wood @ max power... val1=2522, val2=630
                jmp _2

; - - - - - - - - - - - - - - - - - - -
;   feet
_1              jsr CalcTravelDistanceFeet

_2              lda aimPosition
                sta wordA_course
                lda aimPosition_HI
                sta wordA_course+1

                lda const_0x700
                sta wordB_course
                lda const_0x700+1
                sta wordB_course+1

;   distance formula
                jsr calcHypotenuseArea  ; dword result
                jsr calcSquareRoot      ; word result

                ldx polyVertX_delta
                ldy polyVertX_delta+1

                lda temp9D35_puttY_LO
                sta wordA_course
                lda temp9D59_puttY_HI
                sta wordA_course+1

                jsr Multiply_DividebySquare
                stx temp9D33_puttX_LO
                stx puttX_LO
                sty temp9D57_puttX_HI
                sty puttX_HI

                ldx polyVertY_delta
                ldy polyVertY_delta+1

                jsr Multiply_DividebySquare
                stx temp9D35_puttY_LO
                stx puttY_LO
                sty temp9D59_puttY_HI
                sty puttY_HI

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
;====================================== ;[[F]]
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
_2              lda #<$0000
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
;====================================== ;[[F]]
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
;====================================== ;[[F]]
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


;======================================
;
;====================================== ;[[V]]
Divide_2040byWordA .proc
                lda #<$07F8             ; 2040 (7.9725)
                sta wordB_3CBE
                lda #>$07F8
                sta wordB_3CBE+1

                lda wordA_course
                sta wordA_3CBC
                lda wordA_course+1
                sta wordA_3CBC+1

                jsr DivideWordBbyWordA_ABS  ; result in wordB+wordC[remainder]

                lda wordB_3CBE
                sta temp9D29_delta

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
CalcTravelDistanceFeet .proc
                inc powerValue          ; remap [0:15] -> [1:16]
                lda powerValue
                sta dwordMath

                lda #$00
                sta physicsY
                sta dwordMath+1         ; hi-byte unused

                lda #>$0400
                sta physicsY+1

                jsr MultiplyWordByWord_ABS  ; =1024 * power

;   clear result
                ldx #$03
                lda #$00
_next1          sta distanceToPinFeet,X ; two words
                sta distanceToPinFeet2,X

                dex
                bpl _next1

;   store result
                lda dwordMath
                sta distanceToPinFeet
                sta distanceToPinFeet2
                lda dwordMath+1
                sta distanceToPinFeet+1
                sta distanceToPinFeet2+1

                lda dwordMath+2
                sta distanceToPinNatural
                sta distanceToPinNatural2

                jsr calcSquareRoot      ; word result
                stx temp9D35_puttY_LO
                stx puttY_LO
                sty temp9D59_puttY_HI
                sty puttY_HI

                lda #$00                ; clear yards
                sta distanceYards_LO
                sta distanceYards_HI

                rts
                .endproc

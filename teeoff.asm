
;======================================
;
;====================================== ;[[F]]
SetStage2_TeeOff .proc
                lda #stageTEEOFF
                sta nStage

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
DrawMarkers     .proc
                lda isTeeOffDone        ; at the tee box?
                beq _1                  ;   yes

                rts                     ;   no, don't draw the tee box markers

; - - - - - - - - - - - - - - - - - - -
_1              ldx #stageTEEOFF
                stx nStage

                ldy #$17                ; left marker [6,23]
                ldx #$06
                jsr CalcPixelAddr

                lda #$00                ; blue marker
                jsr PlotGlyph

                ldx #$17                ; right marker [23,23]
                ldy #$17
                jsr CalcPixelAddr

                lda #$00                ; blue marker
                jmp PlotGlyph

                .endproc


;======================================
;
;====================================== ;[[V]]
InitStroke      .proc
                ldx #$07                ; snap=mid-point, perfect, no penalty
                jsr CalcAccuracyPenalty
                jsr SetTimer6           ; duration: 10 ticks, activate: true
                jsr CalcProjectile

                lda #$00
                sta unused_9D28

                lda #$02
                sta unused_9D66

                lda #$80
                sta temp9D29

                lda #$18
                sta temp9D29_delta

                lda #$05
                sta timerDuration+7     ; timer 7 = 5 ticks
                sta timerRemaining+7

                lda #$06
                sta timerDuration+8     ; timer 8 = ??? ticks
                sta timerRemaining+8

                lda #$01
                sta isSwingAnimCounterActive
                sta swingAnimCounter

                jmp DoRTS3

                .endproc


;======================================
;
;====================================== ;[[F]]
ProcessStroke   .proc
                ldx activePlayer
                lda playerIsReady,X     ; ready?
                bne _1                  ;   yes

                lda #$00
                sta playerWindDirection_HI,X
                sta playerWindDirection_LO,X
                sta playerVertX_LO,X
                sta playerVertY_LO,X
                sta playerVertX_delta
                sta playerVertX_delta+1
                sta playerVertY_delta
                sta playerVertY_delta+1

                lda #>$1800
                sta playerVertX_HI,X

                lda #>$0500
                sta playerVertY_HI,X

                lda #FALSE
                sta isTeeOffDone

                jmp _2

; - - - - - - - - - - - - - - - - - - -
_1              jsr CalcPlayerPositionDelta

_2              ldx activePlayer
                lda playerDistUnit,X
                sta idxDistanceUnit

                jsr ClearSprites
                jsr PrepareCourse
                jsr RenderPlayfield     ; clear course
                jsr RenderHUD           ; course#, hole#, PAR, player summary

                jsr RenderCourse._OUTLINE   ; draw polygon outlines
                jsr RenderSodPatch          ; sod patch under the golfer
                jsr RenderFill              ; draw polygon fills

                jsr RenderCupOrPin
                jsr DrawMarkers

                lda idxDistanceUnit
                cmp #unitYARDS          ; yards?
                bcs _3                  ;   not putting

;   putting
                jsr DrawWindStreamer
                jsr PuttControl
                jmp _4

; - - - - - - - - - - - - - - - - - - -
_3              jsr MainLoop

; - - - - - - - - - - - - - - - - - - -
_4              jsr CalcTeeoff

                ldx activePlayer
                lda playerWindDirection_HI,X
                clc
                adc windDirThisHole_HI_2424
                tay
                lda playerWindDirection_LO,X
                adc windDirThisHole_LO_9D89

                jsr AdjustForWind

                lda playerVertX_LO,X
                sta polyVertX_LO

                lda playerVertX_HI,X
                sta polyVertX_HI

                lda playerVertY_LO,X
                sta polyVertY_LO

                lda playerVertY_HI,X
                sta polyVertY_HI

                lda xPosCup
                sta xPosCup_LO
                lda xPosCup+1
                sta xPosCup_HI

                lda yPosCup
                sta holeInfoPuttRadius_LO
                lda yPosCup+1
                sta holeInfoPuttRadius_HI

                jsr CalcDistanceToPuttGreen
                jsr DemoDistanceToPin   ; ensure demo player has a distance value

                ldx activePlayer
                lda idxDistanceUnit
                sta playerDistUnit,X

                lda hole_windDir_HI
                sta playerWindDirection_HI,X

                ldy hole_windDir_LO
                dey
                tya
                sta playerWindDirection_LO,X

                lda #TRUE
                sta playerIsReady,X

                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
CalcTeeoff      .proc
                lda #$00
                sta wordA_course
                sta wordB_course
                lda #>$1800
                sta wordA_course+1
                lda #>$0500
                sta wordB_course+1

;   distance formula (step one)
                jsr calcHypotenuseArea  ; dword result

                lda #<$0000
                sec
                sbc polyVertX_delta
                sta polyVertX_delta
                lda #>$0000
                sbc polyVertX_delta+1
                sta polyVertX_delta+1

                lda #<$0000
                sec
                sbc polyVertY_delta
                sta polyVertY_delta
                lda #>$0000
                sbc polyVertY_delta+1
                sta polyVertY_delta+1

;   distance formula (step two)
                jsr calcSquareRoot      ; word result
                stx distanceAdjusted
                sty distanceAdjusted+1

                jsr ApplyWindAffect

                lda windDirThisHole_HI
                sta windDirThisHole_HI_2424
                lda windDirThisHole_LO
                sta windDirThisHole_LO_9D89

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           snapValue
;====================================== ;[[F]]
CalcAccuracyPenalty .proc
                ldy activePlayer
                lda tblPlayerAbility,Y  ; skillNOVICE?
                bne _1                  ;   no

                ldx #$07
_1              cpx #$07                ; mid-point, perfect, no penalty
                beq _2

                lda _bySnapVal,X
                tay

                ldx activeClub
                lda #$00
_next1          clc
                adc _byClub,X

                dey
                bne _next1
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_2              lda #$00
_3              sta accuracyPenalty

                lda #$14
                sta timerDuration+5     ; timer 5 = 20 ticks
                sta timerRemaining+5

                rts

;--------------------------------------

; # of accuracy penalties
_bySnapVal      .byte $07,$06,$05,$04,$03
                .byte $02,$01,$00,$01,$02
                .byte $03,$04,$05,$06,$07

; value of each accuracy penalty
_byClub         .byte $10,$0D,$0A           ; woods
                .byte $07,$07,$06           ; irons
                .byte $06,$05,$05
                .byte $04,$04,$03
                .byte $03                   ; pitching wedge
                .byte $00,$00               ; unused

                .endproc


;======================================
;
;====================================== ;[[F]]
CalcTravelDistanceYards .proc
                lda powerValue          ; [0:15]
                clc
                ldx activeClub
                adc _deltaPower,X

                jsr MultiplyByteBy42    ; A=result_HI
                pha                     ; preserve result:word
                lda dwordMath
                pha

; - - - - - - - - - - - - - - - - - - -
                lda #$00
                sta physicsY+1          ; multiplier_HI unused

                ldx activeClub
                lda _data2_physicsY,X
                sta physicsY            ; multiplier

                jsr MultipleWordByPhysicsY

                lda dwordMath+1
                sta temp9D35_puttY_LO
                lda dwordMath+2
                sta temp9D59_puttY_HI

; - - - - - - - - - - - - - - - - - - -
                pla
                sta physicsY
                pla
                sta physicsY+1

                lda #$00
                sta dwordMath+1         ; hi-byte unused

                ldx activeClub
                lda _data3_physicsZ,X
                sta dwordMath

                jsr MultipleWordByPhysicsY

                lda dwordMath+1
                sta distanceYards_LO
                lda dwordMath+2
                sta distanceYards_HI

                rts

;--------------------------------------
;       min / max distance (per manual)
;   1W  154 / 269
;   1I  104 / 219
;   5I   61 / 180
;   PW   11 /  83

;--------------------------------------
; example at 15 power...
;   1W  15+47= 62*42= 2604*248= 645792 [$09DA.A0=2522] ,  62*2604= 161448 [$0276.A8=630]
;   1I  15+35= 50*42= 2100*243= 510300 [$07C9.5C=1993] ,  79*2100= 165900 [$0288.0C=648]
;   5I  15+21= 36*42= 1512*212= 320544 [$04E4.20=1252] , 143*1512= 216216 [$034C.98=844]
;   PW  15+9 = 24*42= 1008*150= 151200 [$024E.A0= 590] , 207*1008= 208656 [$032F.10=815]

_deltaPower     .byte $2F,$26,$20       ; woods
                .byte $23,$1E,$1B       ; irons
                .byte $17,$15,$13
                .byte $11,$0F,$0D
                .byte $09               ; pitching wedge
;               .byte 47,38,32
;               .byte 35,30,27
;               .byte 23,21,19
;               .byte 17,15,13
;               .byte  9

_data2_physicsY .byte $F8,$F3,$ED       ; woods (distance???)
                .byte $F3,$ED,$E6       ; irons
                .byte $DE,$D4,$CA
                .byte $BE,$B2,$A5
                .byte $96               ; pitching wedge
;               .byte 248,243,237
;               .byte 243,237,230
;               .byte 222,212,202
;               .byte 190,178,165
;               .byte 150

_data3_physicsZ .byte $3E,$4F,$60       ; woods (height???)
                .byte $4F,$60,$70       ; irons
                .byte $80,$8F,$9E
                .byte $AB,$B8,$C4
                .byte $CF               ; pitching wedge
;               .byte  62, 79, 96
;               .byte  79, 96,112
;               .byte 128,143,158
;               .byte 171,184,196
;               .byte 207

                .endproc


;======================================
;
;====================================== ;[[V]]
SetTimer6       .proc
                lda #$0A
                sta timerDuration+6     ; timer 6 = 10 ticks
                sta timerRemaining+6

                lda #$01
                sta timerIsActive+6     ; timer 6 is active

                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
Swing_math_326F .proc
                lda swingAnimCounter
                bne _1

                rts

; - - - - - - - - - - - - - - - - - - -
_1              lda polyVertZ_HI
                bne _2

                lda polyVertZ_LO
                cmp polyVertZ_delta
                bcc _3
                beq _3

_2              jmp _12

; - - - - - - - - - - - - - - - - - - -
_3              lda distanceYards_HI
                bne _4

                lda distanceYards_LO
                beq _next1

                lda distanceYards_HI
_4              bmi _5
                jmp _10

; - - - - - - - - - - - - - - - - - - -
_5              lda polyVertZ_delta
                sta polyVertZ_LO

                ldx distanceYards_LO    ; value:word
                ldy distanceYards_HI
                lda #$4C                ; multiplier (x76)
                jsr MultiplyWordByByte  ; long result in Y:X:A
                stx distanceYards_LO
                sty distanceYards_HI

                cpy #$FF
                bne _6

                cpx #$C0
                bcc _6

                jmp _11

; - - - - - - - - - - - - - - - - - - -
_6              lda distanceYards_LO
                eor #$FF
                sec
                adc #$00
                sta distanceYards_LO

                lda distanceYards_HI
                eor #$FF
                adc #$00
                sta distanceYards_HI

                ldx temp9D33_puttX_LO   ; value:word
                ldy temp9D57_puttX_HI
                lda temp9D29            ; multiplier
                jsr MultiplyWordByByte  ; long result in Y:X:A
                stx temp9D33_puttX_LO
                sty temp9D57_puttX_HI

                ldx temp9D35_puttY_LO   ; value:word
                ldy temp9D59_puttY_HI
                lda temp9D29            ; multiplier
                jsr MultiplyWordByByte  ; long result in Y:X:A
                stx temp9D35_puttY_LO
                sty temp9D59_puttY_HI

                clc
                bcc _10

_next1          lda timerIsActive+7     ; timer 7 active?
                bne _10                 ;   yes

                inc timerIsActive+7     ; no, make active

                ldx puttX_LO            ; value:word
                ldy puttX_HI
                lda temp9D29            ; multiplier
                jsr MultiplyWordByByte  ; long result in Y:X:A
                stx temp9D33_puttX_LO
                sty temp9D57_puttX_HI

                tya
                bpl _7

                inc temp9D33_puttX_LO
                bne _7

                inc temp9D57_puttX_HI

_7              ldx puttY_LO            ; value:word
                ldy puttY_HI
                lda temp9D29            ; multiplier
                jsr MultiplyWordByByte  ; long result in Y:X:A
                stx temp9D35_puttY_LO
                sty temp9D59_puttY_HI

                txa
                ora temp9D59_puttY_HI
                bne _8

                lda #$00
                sta temp9D33_puttX_LO
                sta temp9D57_puttX_HI

_8              lda temp9D29
                sec
                sbc temp9D29_delta
                bcs _9

                lda #$00
_9              sta temp9D29

;   place ball shadow
_10             lda xPosBall
                .frsSpriteSetX xPosBall,9

                lda temp9D33_puttX_LO
                ora temp9D57_puttX_HI
                ora distanceYards_LO
                ora distanceYards_HI
                ora temp9D35_puttY_LO
                ora temp9D59_puttY_HI
                bne _XIT1

                lda #$00                ; reset
                sta swingAnimCounter

                lda flagsBall_9D81
                and #$40                ; ball(bit-6) is visible?
                bne _XIT1

                lda #$01
                sta flags_9D76

_XIT1           rts

; - - - - - - - - - - - - - - - - - - -
_11             lda temp9D33_puttX_LO
                sta puttX_LO
                lda temp9D57_puttX_HI
                sta puttX_HI

                lda temp9D35_puttY_LO
                sta puttY_LO
                lda temp9D59_puttY_HI
                sta puttY_HI

                lda #$00
                sta distanceYards_LO
                sta distanceYards_HI

                clc
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_12             lda timerIsActive+5     ; timer 5 active?
                bne _14                 ;   yes

                inc timerIsActive+5     ;   no, make active

                lda distanceYards_LO
                ora distanceYards_HI
                beq _14

                ldx snapValue
                cpx #$07
                beq _14
                bcc _13

                lda temp9D33_puttX_LO
                clc
                adc accuracyPenalty
                sta temp9D33_puttX_LO
                lda temp9D57_puttX_HI
                adc #$00
                sta temp9D57_puttX_HI

                jmp _14

; - - - - - - - - - - - - - - - - - - -
_13             lda temp9D33_puttX_LO
                sec
                sbc accuracyPenalty
                sta temp9D33_puttX_LO
                lda temp9D57_puttX_HI
                sbc #$00
                sta temp9D57_puttX_HI

_14             lda timerIsActive+6     ; timer 6 active?
                bne _15                 ;   yes

                inc timerIsActive+6     ;   no, make active

                lda polyVertZ_LO
                cmp polyVertZ_delta
                beq _15

                lda temp9D33_puttX_LO
                clc
                adc windDeltaX
                sta temp9D33_puttX_LO
                lda temp9D57_puttX_HI
                adc windDeltaX+1
                sta temp9D57_puttX_HI

                lda temp9D35_puttY_LO
                clc
                adc windDeltaY
                sta temp9D35_puttY_LO
                lda temp9D59_puttY_HI
                adc windDeltaY+1
                sta temp9D59_puttY_HI

_15             lda timerIsActive+8     ; timer 8 active?
                beq _16                 ;   no

                rts

; - - - - - - - - - - - - - - - - - - -
_16             inc timerIsActive+8     ; make active

                lda distanceYards_LO
                sec
                sbc #<$0026
                sta distanceYards_LO
                lda distanceYards_HI
                sbc #>$0026
                sta distanceYards_HI

                rts
                .endproc


;--------------------------------------
;--------------------------------------

polyVertX_delta         .word $0000
polyVertY_delta         .word $0000

playerVertX_LO          .fill 4,$00
playerVertX_HI          .fill 4,$00

playerVertY_LO          .fill 4,$00
playerVertY_HI          .fill 4,$00

playerWindDirection_HI  .fill 4,$00
playerIsReady           .fill 4,$00

xPosCup                 .word $0000
yPosCup                 .word $0000

distanceToPinFeet       .word $0000     ; HI-byte=feet; LO-byte=inches
distanceToPinNatural    .word $0000     ; unit specified in idxDistanceUnit

distanceToPinFeet2      .word $0000     ; HI-byte=feet; LO-byte=inches
distanceToPinNatural2   .word $0000     ; unit specified in idxDistanceUnit


;======================================
;
;====================================== ;[[F]]
ApplyWindAffect .proc
                stx wordA_3CBC          ; distanceToPinFeet:word
                sty wordA_3CBC+1

                ldx polyVertX_delta
                ldy polyVertX_delta+1
                jsr Convert2Positive
                stx wordC_3CC0
                sty wordC_3CC0+1

                ldx #$00                ; clear wordB
                stx wordB_3CBE+1
                stx wordB_3CBE

                lsr wordC_3CC0+1        ; >> (32-bit)
                ror wordC_3CC0
                ror wordB_3CBE+1
                ror wordB_3CBE

                jsr DivideWordBbyWordA._ENTRY1  ; result in wordB+wordC[remainder]

                ldx #$80
_next1          lda wordB_3CBE+1
                bpl _1

                lda #$00
                sta windDirThisHole_HI
                sta windDirThisHole_LO

                jmp _4

; - - - - - - - - - - - - - - - - - - -
_1              cmp tblCosine+1,X
                bcc _3
                bne _2

                lda wordB_3CBE
                cmp tblCosine,X
                beq _3
                bcc _3

_2              dex
                dex
                bpl _next1

                inx
                inx

_3              lda tblCosine,X
                sec
                sbc tblCosine+2,X     ; next entry LO
                sta wordA_3CBC
                lda tblCosine+1,X
                sbc tblCosine+3,X     ; next entry HI
                sta wordA_3CBC+1

;   calculate cosine(x)-wordB
                lda tblCosine,X
                sec
                sbc wordB_3CBE
                tay

                lda tblCosine+1,X
                sbc wordB_3CBE+1
                sta wordC_3CC0
                sty wordB_3CBE+1

                lda #$00
                sta wordB_3CBE          ; lo-byte = 0
                sta wordC_3CC0+1        ; hi-byte = 0

                txa
                lsr
                sta windDirThisHole_LO

                jsr DivideWordBbyWordA._ENTRY1  ; result in wordB+wordC[remainder]

                lda wordB_3CBE
                sta windDirThisHole_HI

; - - - - - - - - - - - - - - - - - - -
;   negative, calculate $4000-(-value)
_4              lda #$01
                lsr                     ; A=0
                sbc windDirThisHole_HI
                sta windDirThisHole_HI
                lda #>$4000
                sbc windDirThisHole_LO
                sta windDirThisHole_LO

                lda polyVertX_delta+1
                bpl _6

                lda polyVertY_delta+1
                bpl _5

                lda #$80
                clc
                adc windDirThisHole_LO
_next2          sta windDirThisHole_LO

_next3          lda #TRUE
                sta isTeeOffDone

                rts

; - - - - - - - - - - - - - - - - - - -
_5              lda #>$0000
                sec
                sbc windDirThisHole_HI
                sta windDirThisHole_HI

                lda #<$0000
                sbc windDirThisHole_LO

                jmp _next2

; - - - - - - - - - - - - - - - - - - -
_6              lda polyVertY_delta+1
                bpl _next3

                lda #>$0080
                sec
                sbc windDirThisHole_HI
                sta windDirThisHole_HI

                lda #<$0080
                sbc windDirThisHole_LO

                jmp _next2

                .endproc


;--------------------------------------
;--------------------------------------

windDirThisHole_HI_2424 .byte $00
distanceAdjusted        .word $0000


;======================================
;
;====================================== ;[[F]]
AdjustForWind   .proc
                sta windDirThisHole_LO
                sty windDirThisHole_HI

                ldx distanceAdjusted    ; word value
                ldy distanceAdjusted+1
                jsr CalcPolyVertXY_delta

                ldx activePlayer
                lda playerVertX_LO,X
                clc
                adc polyVertX_delta
                sta playerVertX_LO,X
                lda playerVertX_HI,X
                adc polyVertX_delta+1
                sta playerVertX_HI,X

                lda playerVertY_LO,X
                clc
                adc polyVertY_delta
                sta playerVertY_LO,X
                lda playerVertY_HI,X
                adc polyVertY_delta+1
                sta playerVertY_HI,X

                rts
                .endproc

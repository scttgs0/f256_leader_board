
;======================================
;
;======================================
RenderHUD       .proc
                jsr RenderHUDCourse     ; draw course#
                jsr RenderHUDPAR        ; draw hole# and PAR
                jsr RenderHUDPlayers    ; draw player summary

                .frsTextXY 31, 1,$70,RenderHUD._scrnCourse
                .frsTextXY 38, 1,$10,RenderHUD._scrnCourseVal

                .frsTextXY 31, 2,$70,RenderHUD._scrnHole
                .frsTextXY 37, 2,$10,RenderHUD._scrnHoleVal

                .frsTextXY 31, 3,$70,RenderHUD._scrnPAR
                .frsTextXY 38, 3,$90,RenderHUD._scrnPARVal

                .frsTextXY 31,12,$70,RenderHUD._scrnWinds

                .frsTextXY 31,17,$30,RenderHUD._scrnClub
                .frsTextXY 37,17,$90,RenderHUD._scrnClubVal

                .frsTextXY 31,18,$30,RenderHUD._scrnYards
                .frsTextXY 37,18,$90,RenderHUD._scrnDistVal

                .frsTextXY 31,20,$70,RenderHUD._scrnPowerTop
                .frsTextXY 31,21,$70,RenderHUD._scrnPowerBot
                .frsTextXY 33,20,$80,RenderHUD._scrnPower
                .frsTextXY 30,22,$70,RenderHUD._scrnSnapLeft
                .frsTextXY 31,22,$70,RenderHUD._scrnSnapTop
                .frsTextXY 32,22,$70,RenderHUD._scrnSnapRight
                .frsTextXY 31,23,$70,RenderHUD._scrnSnapBot
                .frsTextXY 33,22,$30,RenderHUD._scrnSnap

                rts

;--------------------------------------

_scrnHole       .null "HOLE #"
_scrnHoleVal    .null "##"
_scrnPAR        .null "PAR"
_scrnPARVal     .null "#"
_scrnCourse     .null "COURSE"
_scrnCourseVal  .null "#"

_scrnWinds      .null "WINDS"

_scrnClub       .null "CLUB"
_scrnClubVal    .null "1W"

_scrnYards      .null "YARDS"
_scrnFeet       .null "FEET"
_scrnInches     .null "INCHES"
_scrnDistVal    .null "134"

_scrnPower      .null "POWER"
_scrnPowerTop   .null $C7
_scrnPowerBot   .null $C8

_scrnSnap       .null "SNAP"
_scrnSnapTop    .null $C7
_scrnSnapBot    .null $C8
_scrnSnapLeft   .null $C9
_scrnSnapRight  .null $CA

                .endproc


;======================================
;
;======================================
DrawDistanceToPin_m1 .proc
                ldx #stagePLAY
                stx nStage

                jsr CalcDistanceToPuttGreen

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
DrawDistanceToPin .proc
_remainder      = zpD0
;---

                jsr DrawDistUnit

                ldy zpD2                ; [37,$D2]... $D2=(17:yards|13:putt) set by DrawDistUnit
                ldx #$25
                jsr CalcPixelAddr

;--------------------------------------
;   hundreds-digit

                lda distanceToPinYards
                cmp #$C8                ; <200 yards?
                bcc _1                  ;   yes

                sbc #$C8                ; -200
                clc
                ldx #$02                ; X=hundreds-digit
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_1              cmp #$64                ; <100 yards?
                bcc _2                  ;   yes

                sbc #$64                ; -100
                clc
                ldx #$01                ; X=hundreds-digit
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_2              ldx #$00                ; X=hundreds-digit
_3              stx _hundredsDigit
                sta _remainder

;--------------------------------------
;   tens-digit

                ldx #$00                ; X=tens-digit
                lda _remainder
_next1          cmp #$0A                ; <10?
                bcc _4                  ;   yes

                sbc #$0A                ; -10

                inx                     ; ++X=tens-digit
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_4              stx _tensDigit
                sta _onesDigit

;--------------------------------------
;   distances >256 yards

; - - - - - - - - - - - - - - - - - - -
;   ones-digit
                ldx distanceToPinYards+1    ; [0:2] used as index
                lda _onesDigit
                clc
                adc _extendOnes,X
                cmp #$0A                ; <10?
                bcc _5                  ;   yes

                sbc #$0A                ; -10

_5              sta _onesDigit

; - - - - - - - - - - - - - - - - - - -
;   tens-digit

                lda _tensDigit
                adc _extendTens,X
                cmp #$0A                ; <10?
                bcc _6                  ;   yes

                sbc #$0A                ; -10

_6              sta _tensDigit

; - - - - - - - - - - - - - - - - - - -
;   hundreds-digit

                lda _hundredsDigit
                adc _extendHundreds,X
                sta _hundredsDigit

                lda #$80
                bit PORTA               ; security: unused
                sta glyphType

;--------------------------------------
;   draw distance to pin
                lda _hundredsDigit      ; is there a hundreds-digit?
                beq _7                  ;   no, skip

                dec glyphType
                ora #$10                ; convert to glyph #

_7              jsr PlotChar            ; render

                lda _tensDigit          ; is there a tens-digit?
                bne _8                  ;   yes

                bit glyphType           ;   no
                bmi _9

_8              ora #$10                ; convert to glyph #
_9              jsr PlotChar            ; render

                lda _onesDigit
                jmp PlotCharBCD         ; render

;--------------------------------------

_onesDigit      .byte $00
_tensDigit      .byte $00
_hundredsDigit  .byte $00

_extendOnes     .byte $00,$06,$02       ; 0,256,512
_extendTens     .byte $00,$05,$01
_extendHundreds .byte $00,$02,$05

                .endproc


;======================================
;
;======================================
DrawDistUnit    .proc
                ldx #stagePLAY
                stx nStage

                lda idxDistanceUnit
                clc                     ; *9 (length of each string)
                rol
                rol
                rol
                clc
                adc idxDistanceUnit
                sta zpD0                ; start index

;   calculate the end index
                clc
                adc #$09                ; length of each string
                sta _stopCond+1

                ldx activePlayer
                lda playerDistUnit,X
                cmp #unitYARDS
                bne _1

;   yards
                ldy #$11                ; yards (non-putt)
                .byte $2C               ; consume the following LDY operation
_1              ldy #$0D                ; feet/inches (putt)

                sty zpD2                ; [31,$D2]
                ldx #$1F
                jsr CalcPixelAddr

_next1          ldx zpD0
                lda _distUnit,X
                jsr PlotChar

                inc zpD0
                lda zpD0
_stopCond       cmp #$94                ; [smc] end reached?
                bne _next1              ;   no

                rts

;--------------------------------------


            .enc "atari-screen"
_distUnit       .text 'INCHES   '
                .text 'FEET     '
                .text 'YARDS    '
            .enc "none"

                .endproc


;--------------------------------------
; on entry:
;   glyphType   '0' or '0-bar' type
;--------------------------------------
PlotCharArray   .proc
_5digits        ldx #$00
                .byte $2C               ; consume the following LDX operation
_4digits        ldx #$01
                .byte $2C               ; consume
_3digits        ldx #$02
                .byte $2C               ; consume
_2digits        ldx #$03
                stx idxPolygonVertex

_next1          lda arr5Digits,X        ; fetch element value
                bit glyphType           ; <0?
                bmi _2                  ;   yes

; - - - - - - - - - - - - - - - - - - -
;   positive
                tay
                bne _1

                cpx #$04
                beq _2

                bit glyphType
                bvc _3

                lda #$4B                ; top separator bar
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_1              lda glyphType
                ora #$80                ; make negative
                sta glyphType

                tya

; - - - - - - - - - - - - - - - - - - -
;   negative
_2              cmp #$0A                ; >=10?
                bcs _3                  ;   yes

                ora glyphType
                and #$7F

;   render a single glyph
_3              jsr PlotChar

                inc idxPolygonVertex
                ldx idxPolygonVertex
                cpx #$05
                bcc _next1

                rts
                .endproc


;--------------------------------------
;--------------------------------------

glyphType       .byte $00


;======================================
;
;======================================
RenderHUDCourse .proc
                ldx #stagePLAY
                stx nStage

                ldx idxActiveCourse
                ldy tblCourseIndexes,X
                iny
                tya
                ora #$30
                sta RenderHUD._scrnCourseVal

                rts
                .endproc


;======================================
;
;======================================
RenderHUDPlayers .proc
                jsr RenderHUDActivePlayer  ; '>'-mark for the active player
                bra _hack    ; HACK:

                lda #stagePLAY
                sta nStage

                lda numPlayers
                sta idxPlayer

_nextplayer     ldx idxPlayer
                lda playerStrokeCount,X
                sta wordB_3CBE
                lda #$00                ; hi-byte unused
                sta wordB_3CBE+1

                ;;jsr Convert2Digits
                ;;jsr FindFirst5Digits

                lda #$05                ; line number [5:8]
                clc
                adc idxPlayer
                tay
                ldx #$21                ; [33,5+]
                jsr CalcPixelAddr

                lda #$10                ; '0'-glyph
                sta glyphType
                jsr PlotCharArray._2digits

                lda idxActiveCourse
                bne _1

                lda idxActiveHole       ; first hole?
                beq _2                  ;   yes, skip

_1              ;;jsr Render5Digits

_2              jsr DoNothing4

                dec idxPlayer
                bpl _nextplayer

;//////////////////////

_hack           .frsTextXY 31,5,$F0,RenderHUDPlayers._scrnName

                .frsTextXY 30,6,$F0,RenderHUDPlayers._scrnP1Active
                .frsTextXY 31,6,$10,RenderHUDPlayers._scrnP1
                .frsTextXY 34,6,$10,RenderHUDPlayers._scrnP1Strokes
                .frsTextXY 38,6,$30,RenderHUDPlayers._scrnP1Delta

                .frsTextXY 30,7,$F0,RenderHUDPlayers._scrnP2Active
                .frsTextXY 31,7,$F0,RenderHUDPlayers._scrnP2
                .frsTextXY 34,7,$10,RenderHUDPlayers._scrnP2Strokes
                .frsTextXY 38,7,$80,RenderHUDPlayers._scrnP2Delta

                .frsTextXY 30,8,$F0,RenderHUDPlayers._scrnP3Active
                .frsTextXY 31,8,$10,RenderHUDPlayers._scrnP3
                .frsTextXY 34,8,$10,RenderHUDPlayers._scrnP3Strokes
                .frsTextXY 38,8,$F0,RenderHUDPlayers._scrnP3Delta

                .frsTextXY 30,9,$F0,RenderHUDPlayers._scrnP4Active
                .frsTextXY 31,9,$10,RenderHUDPlayers._scrnP4
                .frsTextXY 34,9,$10,RenderHUDPlayers._scrnP4Strokes
                .frsTextXY 38,9,$10,RenderHUDPlayers._scrnP4Delta

                rts

;--------------------------------------

_scrnName       .null "ADAM    "

_scrnP1Active   .null " "
_scrnP1         .null "1"
_scrnP1Strokes  .null "1"
_scrnP1Delta    .null "-1"

_scrnP2Active   .null " "
_scrnP2         .null "2"
_scrnP2Strokes  .null "1"
_scrnP2Delta    .null " E"

_scrnP3Active   .null " "
_scrnP3         .null "3"
_scrnP3Strokes  .null "1"
_scrnP3Delta    .null "+1"

_scrnP4Active   .null " "
_scrnP4         .null "4"
_scrnP4Strokes  .null " "
_scrnP4Delta    .null "  "

                .endproc


;======================================
;
;======================================
RenderHUDActivePlayer .proc
_idxChar        = zpD0
_ptrName        = zpF9
_glyphCHEVRON   = $FA
;---

;   clear all active player markers
                lda #' '
                sta RenderHUDPlayers._scrnP1Active
                sta RenderHUDPlayers._scrnP2Active
                sta RenderHUDPlayers._scrnP3Active
                sta RenderHUDPlayers._scrnP4Active

                lda isDrivingRange      ; at driving range?
                beq _1                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
;   render active player name
_1              lda #stageCONFIG
                sta nStage

                ldx activePlayer
                jsr SetNameBufPtr       ; result _ptrName [$F9:FA]

                lda #<RenderHUDPlayers._scrnName
                sta zpDest
                lda #>RenderHUDPlayers._scrnName
                sta zpDest+1

                lda #$00
                sta _idxChar
_next1          tay
                lda (_ptrName),Y
                sta (zpDest),Y

                inc _idxChar
                lda _idxChar
                cmp #$08                ; rendered 8 chars?
                bne _next1              ;   no

; - - - - - - - - - - - - - - - - - - -
;   render active player chevron-mark
                ldx #_glyphCHEVRON
                lda activePlayer
                cmp #$00
                bne _2

                stx RenderHUDPlayers._scrnP1Active
                bra _XIT

_2              cmp #$01
                bne _3

                stx RenderHUDPlayers._scrnP2Active
                bra _XIT

_3              cmp #$02
                bne _4

                stx RenderHUDPlayers._scrnP3Active
                bra _XIT

_4              stx RenderHUDPlayers._scrnP4Active

_XIT            rts
                .endproc


;======================================
;
;======================================
DoNothing4      rts


;======================================
;
;======================================
RenderStrokeCount .proc
                ldx #stagePLAY
                stx nStage

                ldx activePlayer
                lda playerStrokeCount,X
                cmp #$20                ; >=32?
                bcs _1                  ;   yes, don't increase

                inc playerStrokeCount,X

_1              lda #$05                ; y-coordinate
                clc
                adc activePlayer
                tay
                ldx #$21                ; [33,5+]
                jsr CalcPixelAddr

                ldx activePlayer
                lda playerStrokeCount,X
                ldy #$00
_next1          cmp #$0A                ; <10?
                bcc _2                  ;   yes

                sbc #$0A                ; -10

                iny
                bne _next1

_2              pha

                tya
                beq _3

                ora #$10                ; convert to glyph #
_3              jsr PlotChar

                pla
                jmp PlotCharBCD

                .endproc


;======================================
;
;--------------------------------------
; examples:
;   $238D
;   wordA
;   wordB
;   wordC
;======================================
CalcValuem10_Div10_x3 .proc
                ldx activePlayer
                lda playerWindDirection_HI,X
                sec
                sbc #<$000A
                sta wordB_3CBE
                lda #>$000A
                sta wordB_3CBE+1

                sta wordA_3CBC+1
                lda #<$000A
                sta wordA_3CBC

                jsr DivideWordBbyWordA_ABS    ; result in wordB+wordC[remainder]

                lda wordC_3CC0
                asl
                clc
                adc wordC_3CC0

                rts
                .endproc


;======================================
;
;======================================
RenderHUDPAR    .proc
_tens_digit     = zpD0
;---

                lda #stagePLAY
                sta nStage

; - - - - - - - - - - - - - - - - - - -
;   draw Hole #
                ldx idxActiveHole
                inx                     ; convert to 1-based value

                txa
                cmp #$0A                ; >10?
                bcc _1                  ;   no

                sbc #$0A                ; get ones-digit

                ldx #'1'
                .byte $2C               ; consume the following LDX operation
_1              ldx #' '                ; space
                stx RenderHUD._scrnHoleVal   ; tens-digit
                ora #'0'
                sta RenderHUD._scrnHoleVal+1 ; ones-digit

; - - - - - - - - - - - - - - - - - - -
;   draw PAR value
                ldy #$01                ; [39,1]
                ldx #$27
                jsr CalcPixelAddr

                jsr GetPtrHolePAR
                stx _setAddrPAR+1
                sty _setAddrPAR+2

                ldx idxActiveHole
_setAddrPAR     lda $FFFF,X             ; [smc]
                ora #'0'
                sta RenderHUD._scrnPARVal

                rts
                .endproc


;--------------------------------------
;--------------------------------------

offsetByCourse          .byte $00,$48,$90,$D8   ; =0,72,144,216     (18*4=72)
yCoordinateByHonor      .byte $04,$08,$0C,$10   ; =4,8,12,16

playerStrokes           .fill 18,$00    ; Nora=7,6,3,4,4
                        .fill 18,$00    ; Adam=4,5,3,5,4
                        .fill 18,$00    ; Paul=5,4,3,4,4
                        .fill 18,$00

playerScoreA_LO         .fill 4,$00     ; =$18,$15,$14,0    score LO    [offset:+72]
playerScoreA_HI         .fill 4,$00     ; =0,0,0,0          score HI

playerScoreB_LO         .fill 4,$00     ; =0,0,0,0
playerScoreB_HI         .fill 4,$00     ; =0,0,0,0

;---

playerScoreRoundA_LO    .fill 4,$00     ; =$18,$15,$14,0    score LO
playerScoreRoundA_HI    .fill 4,$00     ; =0,0,0,0          score HI

playerScoreRoundB_LO    .fill 4,$00     ; =0,0,0,0
playerScoreRoundB_HI    .fill 4,$00     ; =0,0,0,0

playerScoreRoundC_LO    .fill 4,$00     ; =0,0,0,0
playerScoreRoundC_HI    .fill 4,$00     ; =0,0,0,0

playerScoreRoundD_LO    .fill 4,$00     ; =0,0,0,0
playerScoreRoundD_HI    .fill 4,$00     ; =0,0,0,0

playerScoreTotal_LO     .fill 4,$00     ; =$18,$15,$14,0    score LO
playerScoreTotal_HI     .fill 4,$00     ; =0,0,0,0          score HI

;---

playerHonorA            .fill 4,$00     ; =2,1,0,0          honor rank
playerHonorB            .fill 4,$00     ; =2,1,0,0          honor rank working copy
playerStrokeCount       .fill 4,$00     ; =4,4,4,0          strokes this hole
playerHonorPrior        .fill 4,$00     ; =1,2,0,0

courseOffset            .word $0000     ; =$0015
idxPlayer               .byte $00       ; =$FF
idxDigit                .byte $00       ; =4
tempB                   .byte $00       ; =3
playerNames             .fill 8,$00     ; =$2E,$2F,$32,$21 (NORA)
                        .fill 8,$00     ; =$21,$24,$21,$2D (ADAM)
                        .fill 8,$00     ; =$30,$21,$35,$2C (PAUL)
                        .fill 8,$00
playerNameMaxLen        .byte $08,$08,$08,$08
arr5Digits              .byte $00,$00,$00,$00,$00
glyphPlusMinus          .byte $00

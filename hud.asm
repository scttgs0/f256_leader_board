
;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[V]]
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

                .frsTextXY 33,20,$80,RenderHUD._scrnPower
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

_scrnYards      .null "YARDS    "
_scrnFeet       .null "FEET     "
_scrnInches     .null "INCHES   "
_scrnDistVal    .null "134"

_scrnPower      .null "POWER"
_scrnSnap       .null "SNAP"

                .endproc


;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[V]]
DrawDistanceToPin_m1 .proc
                ldx #stagePLAY
                stx nStage

                jsr CalcDistanceToPuttGreen

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
; X-Bank Procedure
;-------------------------------------- ;[[V]]
DrawDistanceToPin .proc
_remainder      = zpD0
;---

                jsr DrawDistUnit

;--------------------------------------
;   hundreds-digit

                lda distanceToPinYards
                cmp #$C8                ; <200 yards?
                bcc _1                  ;   yes

                ; carry is set
                sbc #$C8                ; -200
                clc

                ldx #$02                ; X=hundreds-digit
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_1              cmp #$64                ; <100 yards?
                bcc _2                  ;   yes

                ; carry is set
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

                ; carry is set
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

                ; carry is set
                sbc #$0A                ; -10

_5              sta _onesDigit

; - - - - - - - - - - - - - - - - - - -
;   tens-digit

                lda _tensDigit
                adc _extendTens,X
                cmp #$0A                ; <10?
                bcc _6                  ;   yes

                ; carry is set
                sbc #$0A                ; -10

_6              sta _tensDigit

; - - - - - - - - - - - - - - - - - - -
;   hundreds-digit

                lda _hundredsDigit
                adc _extendHundreds,X
                sta _hundredsDigit

;--------------------------------------
;   draw distance to pin

                lda #' '
                sta RenderHUD._scrnDistVal

                lda _hundredsDigit      ; is there a hundreds-digit?
                beq _7                  ;   no, skip

                ora #'0'                ; convert to ascii
                sta RenderHUD._scrnDistVal

_7              lda #' '
                sta RenderHUD._scrnDistVal+1

                lda _tensDigit          ; is there a tens-digit?
                beq _8                  ;   no, skip

                ora #'0'                ; convert to ascii
                sta RenderHUD._scrnDistVal+1

_8              lda _onesDigit
                ora #'0'                ; convert to ascii
                sta RenderHUD._scrnDistVal+2

                .frsTextXY 37,18,$90,RenderHUD._scrnDistVal

                rts

;--------------------------------------

_onesDigit      .byte $00
_tensDigit      .byte $00
_hundredsDigit  .byte $00

_extendOnes     .byte $00,$06,$02       ; +000,+256,+512
_extendTens     .byte $00,$05,$01
_extendHundreds .byte $00,$02,$05

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
DrawDistUnit    .proc
                ldx #stagePLAY
                stx nStage

                ldx activePlayer
                lda playerDistUnit,X
                cmp #unitYARDS
                bne _1

;   yards
                .frsTextXY 31,18,$30,RenderHUD._scrnYards
                bra _XIT

; - - - - - - - - - - - - - - - - - - -
_1              cmp #unitFEET
                bne _2

                .frsTextXY 31,18,$30,RenderHUD._scrnFeet
                bra _XIT

; - - - - - - - - - - - - - - - - - - -
_2              .frsTextXY 31,18,$30,RenderHUD._scrnInches

_XIT            rts
                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[V]]
RenderHUDCourse .proc
                ldx #stagePLAY
                stx nStage

                ldx idxActiveCourse
                ldy tblCourseIndexes,X
                iny
                tya
                ora #'0'
                sta RenderHUD._scrnCourseVal

                rts
                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[U]]+
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

                jsr XBPC_ConvertToArray
                jsr XBPC_FindFirstUsed  ; Y result is ignored

                lda #$05                ; line number [5:8]
                clc
                adc idxPlayer
                tay
                ldx #$21                ; [33,5+]
                jsr CalcPixelAddr

                lda #'0'                ; '0'-glyph
                sta glyphType
                jsr PlotCharArray._2digits

                lda idxActiveCourse
                bne _1

                lda idxActiveHole       ; first hole?
                beq _2                  ;   yes, skip

_1              jsr XBPC_RenderScoreDelta

_2              jsr DoNothing4

                dec idxPlayer
                bpl _nextplayer

                rts

;--------------------------------------
;//////////////////////

_hack           .frsTextXY 31,5,$F0,RenderHUDPlayers._scrnName

                .frsTextXY 30,6,$F0,RenderHUDPlayers._scrnP1Active
                .frsTextXY 31,6,$10,RenderHUDPlayers._scrnP1
                .frsTextXY 33,6,$10,RenderHUDPlayers._scrnP1Strokes
                .frsTextXY 37,6,$30,RenderHUDPlayers._scrnP1Delta

                .frsTextXY 30,7,$F0,RenderHUDPlayers._scrnP2Active
                .frsTextXY 31,7,$F0,RenderHUDPlayers._scrnP2
                .frsTextXY 33,7,$10,RenderHUDPlayers._scrnP2Strokes
                .frsTextXY 37,7,$80,RenderHUDPlayers._scrnP2Delta

                .frsTextXY 30,8,$F0,RenderHUDPlayers._scrnP3Active
                .frsTextXY 31,8,$10,RenderHUDPlayers._scrnP3
                .frsTextXY 33,8,$10,RenderHUDPlayers._scrnP3Strokes
                .frsTextXY 37,8,$F0,RenderHUDPlayers._scrnP3Delta

                .frsTextXY 30,9,$F0,RenderHUDPlayers._scrnP4Active
                .frsTextXY 31,9,$10,RenderHUDPlayers._scrnP4
                .frsTextXY 33,9,$10,RenderHUDPlayers._scrnP4Strokes
                .frsTextXY 37,9,$10,RenderHUDPlayers._scrnP4Delta

                rts

;--------------------------------------

_scrnName       .null "ADAM    "

_scrnP1Active   .null " "
_scrnP1         .null "1"
_scrnP1Strokes  .null "  0"
_scrnP1Delta    .null " -1"

_scrnP2Active   .null " "
_scrnP2         .null "2"
_scrnP2Strokes  .null "  0"
_scrnP2Delta    .null "  E"

_scrnP3Active   .null " "
_scrnP3         .null "3"
_scrnP3Strokes  .null "  0"
_scrnP3Delta    .null " +1"

_scrnP4Active   .null " "
_scrnP4         .null "4"
_scrnP4Strokes  .null "   "
_scrnP4Delta    .null "   "

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[V]]
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
                jsr XBPC_SetNameBufPtr  ; result _ptrName [$F9:FA]

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
;--------------------------------------
; Private Procedure
;====================================== ;[[V]]
DoNothing4      rts


;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[F]]
IncrementStrokeCount .proc
                ldx #stagePLAY
                stx nStage

                ldx activePlayer
                lda playerStrokeCount,X
                cmp #$20                ; >=32?
                bcs RenderStrokeCount   ;   yes, don't increase

                inc playerStrokeCount,X

                .endproc

                ;[fall-through]


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
RenderStrokeCount .proc
                ldx activePlayer
                lda playerStrokeCount,X
                ldy #$00
_next1          cmp #$0A                ; <10?
                bcc _2                  ;   yes

                ; carry is set
                sbc #$0A                ; -10

                iny
                bne _next1

_2              sty _tensDigit
                sta _onesDigit

; - - - - - - - - - - - - - - - - - - -
                lda activePlayer
                cmp #$00                ; player 1?
                bne _3                  ;   no

                lda #' '                ; clear the tens-digit placeholder
                sta RenderHUDPlayers._scrnP1Strokes

                lda _tensDigit          ; is there a tens-digit?
                beq _2A                 ;   no, skip

                ora #'0'                ; convert to ascii
                sta RenderHUDPlayers._scrnP1Strokes

_2A             lda _onesDigit
                ora #'0'                ; convert to ascii
                sta RenderHUDPlayers._scrnP1Strokes+1

                .frsTextXY 34,6,$10,RenderHUDPlayers._scrnP1Strokes

                jmp _XIT

; - - - - - - - - - - - - - - - - - - -
_3              cmp #$01                ; player 2?
                bne _4                  ;   no

                lda #' '                ; clear the tens-digit placeholder
                sta RenderHUDPlayers._scrnP2Strokes

                lda _tensDigit          ; is there a tens-digit?
                beq _3A                 ;   no, skip

                ora #'0'                ; convert to ascii
                sta RenderHUDPlayers._scrnP2Strokes

_3A             lda _onesDigit
                ora #'0'                ; convert to ascii
                sta RenderHUDPlayers._scrnP2Strokes+1

                .frsTextXY 34,7,$10,RenderHUDPlayers._scrnP2Strokes

                bra _XIT

; - - - - - - - - - - - - - - - - - - -
_4              cmp #$02                ; player 3?
                bne _5                  ;   no

                lda #' '                ; clear the tens-digit placeholder
                sta RenderHUDPlayers._scrnP3Strokes

                lda _tensDigit          ; is there a tens-digit?
                beq _4A                 ;   no, skip

                ora #'0'                ; convert to ascii
                sta RenderHUDPlayers._scrnP3Strokes

_4A             lda _onesDigit
                ora #'0'                ; convert to ascii
                sta RenderHUDPlayers._scrnP3Strokes+1

                .frsTextXY 34,8,$10,RenderHUDPlayers._scrnP3Strokes

                bra _XIT

; - - - - - - - - - - - - - - - - - - -
_5              lda #' '                ; clear the tens-digit placeholder
                sta RenderHUDPlayers._scrnP4Strokes

                lda _tensDigit          ; is there a tens-digit?
                beq _5A                 ;   no, skip

                ora #'0'                ; convert to ascii
                sta RenderHUDPlayers._scrnP4Strokes

_5A             lda _onesDigit
                ora #'0'                ; convert to ascii
                sta RenderHUDPlayers._scrnP4Strokes+1

                .frsTextXY 34,9,$10,RenderHUDPlayers._scrnP4Strokes

; - - - - - - - - - - - - - - - - - - -
_XIT            rts

;--------------------------------------

_onesDigit      .byte $00
_tensDigit      .byte $00

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;--------------------------------------
; examples:
;   $238D
;   wordA
;   wordB
;   wordC
;====================================== ;[[F]] <obsolete>???
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
;--------------------------------------
; Private Procedure
;====================================== ;[[V]]
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

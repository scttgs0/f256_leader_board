
;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[V]]
DrawScoreboard  .proc
;   fill the top with water and the bottom with grass
                jsr ResetScoreboard

; - - - - - - - - - - - - - - - - - - -
                ldx #40
                stx zpD0                ; number of cloud glyphs to render

                jsr DrawClouds._ENTRY1

; - - - - - - - - - - - - - - - - - - -
                ldx #40
                stx zpD0                ; number of mountain glyphs to render

                jsr DrawMountains._ENTRY1

; - - - - - - - - - - - - - - - - - - -

                jsr DrawScoreboardBackground

                .frsTextXY 3, 1,$10,DrawScoreboard._scoreboard0
                .frsTextXY 3, 2,$10,DrawScoreboard._scoreboard1
                .frsTextXY 3, 3,$10,DrawScoreboard._scoreboard2

                .frsTextXY 3, 4,$10,DrawScoreboard._scoreboard2
                .frsTextXY 3, 5,$10,DrawScoreboard._scoreboard3
                .frsTextXY 3, 6,$10,DrawScoreboard._scoreboard3
                .frsTextXY 3, 7,$10,DrawScoreboard._scoreboard4

                .frsTextXY 3, 8,$10,DrawScoreboard._scoreboard2
                .frsTextXY 3, 9,$10,DrawScoreboard._scoreboard3
                .frsTextXY 3,10,$10,DrawScoreboard._scoreboard3
                .frsTextXY 3,11,$10,DrawScoreboard._scoreboard4

                .frsTextXY 3,12,$10,DrawScoreboard._scoreboard2
                .frsTextXY 3,13,$10,DrawScoreboard._scoreboard3
                .frsTextXY 3,14,$10,DrawScoreboard._scoreboard3
                .frsTextXY 3,15,$10,DrawScoreboard._scoreboard4

                .frsTextXY 3,16,$10,DrawScoreboard._scoreboard2
                .frsTextXY 3,17,$10,DrawScoreboard._scoreboard3
                .frsTextXY 3,18,$10,DrawScoreboard._scoreboard3
                .frsTextXY 3,19,$10,DrawScoreboard._scoreboard4

                rts

;--------------------------------------

            .enc "custom-ascii"
                .cdef " Z",$20
                .tdef "j",$E0
                .tdef "k",$E1
                .tdef "l",$E2
                .tdef "m",$E3
                .tdef "n",$E4

_scoreboard0    .null 'jkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk'
_scoreboard1    .null 'l COURSE                  ROUND l'
_scoreboard2    .null 'lkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkm'
                .null 'lkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkm'
_scoreboard3    .null 'lkkmkkmkkmkkmkkmkkmkkmkkmkkmkkkkm'
                .null 'lkkmkkmkkmkkmkkmkkmkkmkkmkkmkkkkm'
_scoreboard4    .null 'l                         nkkkkkm'
                .null 'lkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkm'
                .null 'lkkmkkmkkmkkmkkmkkmkkmkkmkkmkkkkm'
                .null 'lkkmkkmkkmkkmkkmkkmkkmkkmkkmkkkkm'
                .null 'l                         nkkkkkm'
                .null 'lkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkm'
                .null 'lkkmkkmkkmkkmkkmkkmkkmkkmkkmkkkkm'
                .null 'lkkmkkmkkmkkmkkmkkmkkmkkmkkmkkkkm'
                .null 'l                         nkkkkkm'
                .null 'lkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkm'
                .null 'lkkmkkmkkmkkmkkmkkmkkmkkmkkmkkkkm'
                .null 'lkkmkkmkkmkkmkkmkkmkkmkkmkkmkkkkm'
                .null 'l                         nkkkkkm'
            .enc "none"

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[V]]
DrawScoreboardBackground .proc
_dest           = zpCD
_width          = zpD0
_height         = zpD1
_src            = zpD4
_layerOffset    = zpCF
_scrnBackground = screen16K+320*16+32
;---

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda #$10                ; [8000:9FFF]->[2_0000:2_1FFF]
                sta zpMMU
                sta MMU_Block4
                inc A                   ; [A000:BFFF]->[2_2000:2_3FFF]
                sta MMU_Block5

; - - - - - - - - - - - - - - - - - - -
                lda #<_scrnBackground
                sta _dest
                lda #>_scrnBackground
                sta _dest+1

                ldx #18
                stx _height             ; number of rows to render

_nextRow        ldx #32
                stx _width              ; number of glyphs to render

;   render a single glyph line (1 of 16 lines)
_nextColumn     ldx #$07

_next3          ldy #$00
                tya
                sta (_dest),Y
                iny
                sta (_dest),Y
                iny
                sta (_dest),Y
                iny
                sta (_dest),Y
                iny
                sta (_dest),Y
                iny
                sta (_dest),Y
                iny
                sta (_dest),Y
                iny
                sta (_dest),Y

;   advance to the next scanline
                lda _dest
                clc
                adc #<$0140             ; +320
                sta _dest
                lda _dest+1
                adc #>$0140
                sta _dest+1

                dex
                bpl _next3

;   back up 8 scanlines to prepare for the next glyph
                lda _dest
                sec
                sbc #<$09F8             ; -2552 (320*8-8)
                sta _dest
                lda _dest+1
                sbc #>$09F8
                sta _dest+1

;   advance to the next glyph
                dec _width              ; completed all the columns?
                bne _nextColumn         ;   no

;   advance to the next row
                lda _dest
                clc
                adc #<$0900             ; +2304 (320*7+8*8)
                sta _dest
                lda _dest+1
                adc #>$0900
                sta _dest+1

;   determine whether to adjust the MMU
                cmp #>$A000
                bcc _1

                lda _dest
                sec
                sbc #<$2000
                sta _dest
                lda _dest+1
                sbc #>$2000
                sta _dest+1

                lda zpMMU
                inc A
                sta zpMMU
                sta MMU_Block4
                inc A
                sta MMU_Block5

_1              dec _height             ; completed all the rows?
                bne _nextRow            ;   no

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                rts
                .endproc


;======================================
;
;--------------------------------------
;  80 bytes black [$F0:13F]
; 240 bytes blue  [$00:EF]
;--------------------------------------
; Private Procedure
;====================================== ;[[V]]
ResetScoreboard .proc
_zpFillQty      = zpD0
;---

                pha
                phx
                phy

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                lda #$10                ; [8000:9FFF]->[2_0000:2_1FFF]
                sta zpMMU
                sta MMU_Block4
                inc A                   ; [A000:BFFF]->[2_2000:2_3FFF]
                sta MMU_Block5

; - - - - - - - - - - - - - - - - - - -
                lda #<screen16K         ; Set the destination address ($8000)
                sta zpDest
                lda #>screen16K
                sta zpDest+1

                lda #$08                ; WATER
                sta _setColor1+1
                sta _setColor2+1

                lda #$08                ; quantity of buffer fills (8k/iteration)
                sta _zpFillQty

_nextBlock      ldx #$1A                ; 26 lines (26*320=$2080)

_nextLine
_setColor1      lda #$08                ; [smc] WATER or GRASS
                ldy #$EF
_nextWater      sta (zpDest),Y

                dey
                bne _nextWater

                sta (zpDest),Y

                lda zpDest
                clc
                adc #<240
                sta zpDest
                lda zpDest+1
                adc #>240
                sta zpDest+1

_setColor2      lda #$08                ; [smc] WATER or GRASS
                ldy #$4F
_nextHUD        sta (zpDest),Y

                dey
                bpl _nextHUD

                lda zpDest
                clc
                adc #<80
                sta zpDest
                lda zpDest+1
                adc #>80
                sta zpDest+1

                dex
                bne _nextLine

                ldx _zpFillQty
                dex
                cpx #$04
                bne _1

                lda #$0D                ; GRASS
                sta _setColor1+1
                sta _setColor2+1

_1              dec _zpFillQty
                beq _XIT

                inc zpMMU
                inc MMU_Block4          ; +$2000
                inc MMU_Block5          ; +$2000

;   reset to the top of the screen buffer
                lda zpDest
                sec
                sbc #<$2000
                sta zpDest
                lda zpDest+1
                sbc #>$2000
                sta zpDest+1

                bra _nextBlock

_XIT
; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                ply
                plx
                pla
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
; X-Bank Procedure
;-------------------------------------- ;[[F]]+
DoScoreboard    .proc
                jsr ClearAllPlayers
                jsr ClearMissiles
                jsr ClearSwingGauge

                lda #stageCONFIG
                sta nStage

                jsr DrawScoreboard
                jsr RenderCourseNbr
                jsr UpdateScore

                lda numPlayers
                sta idxPlayer

_next1          jsr RenderPlayerName
                jsr RenderScoreDelta
                jsr Render4Digits
                jsr Render2or3Digits
                jsr Render2or3Digits_2
                jsr DoNothing3

                dec idxPlayer
                bpl _next1

                rts
                .endproc


;======================================
; Print Course and Round numbers
;--------------------------------------
; Private Procedure
;====================================== ;[[V]]
RenderCourseNbr .proc
;   render Course #
                ldy #$03                ; [7,3]
                ldx #$07
                jsr CalcPixelAddr

                ldy idxActiveCourse
                ldx tblCourseIndexes,Y
                inx
                txa
                jsr PlotCharBCD

;   render Round #
                ldy #$03                ; [32,3]
                ldx #$20
                jsr CalcPixelAddr

                ldx idxActiveCourse
                inx
                txa
                jmp PlotCharBCD

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[U]]
UpdateScore     .proc
                jsr SaveStrokes

                stz courseOffset+1

                ldx idxActiveCourse
                lda offsetByCourse,X
                sta courseOffset

                jsr GetPtrHolePAR
                stx _setAddrPAR+1
                sty _setAddrPAR+2

                ldx idxActiveHole
                lda courseOffset
_next1          clc
_setAddrPAR     adc $FFFF,X             ; [smc]
                tay

                lda courseOffset+1
                adc #$00
                sta courseOffset+1

                tya
                dex
                bpl _next1

                sta courseOffset

                ldx numPlayers
                stx idxPlayer

_next2          ldx idxPlayer
                jsr SetStrokesPtr

                ldy idxActiveHole
_next3          lda #$00
                sta tempB

_next4          clc
                adc (zpF9),Y

                jsr Add0_HI_469C

                dey
                cpy #$08
                bne _1

                ldx idxPlayer
                sta playerScoreB_LO,X
                lda tempB
                sta playerScoreB_HI,X

                jmp _next3

; - - - - - - - - - - - - - - - - - - -
_1              cpy #$FF
                bne _next4

                ldx idxPlayer
                sta playerScoreA_LO,X
                lda tempB
                sta playerScoreA_HI,X

                lda playerScoreB_LO,X
                clc
                adc playerScoreA_LO,X
                pha

                lda playerScoreB_HI,X
                adc playerScoreA_HI,X

                ldx idxActiveCourse
                jsr CalcPlayerScoreIndex    ; result in X
                sta playerScoreRoundA_HI,X
                pla
                sta playerScoreRoundA_LO,X

                stz tempB

                ldx idxPlayer
                lda playerScoreRoundA_LO,X
                clc
                adc playerScoreRoundB_LO,X

                jsr Add0_HI_469C

                clc
                adc playerScoreRoundC_LO,X

                jsr Add0_HI_469C

                clc
                adc playerScoreRoundD_LO,X

                jsr Add0_HI_469C
                sta playerScoreTotal_LO,X

                lda tempB
                clc
                adc playerScoreRoundA_HI,X
                adc playerScoreRoundB_HI,X
                adc playerScoreRoundC_HI,X
                adc playerScoreRoundD_HI,X
                sta playerScoreTotal_HI,X

                dec idxPlayer
                bmi _2
                jmp _next2

; - - - - - - - - - - - - - - - - - - -
                ;!!ldx PORTA
                ;!!cpx PORTA
                ;!!bvs _next6

_2              stz playerHonorA
                stz playerHonorA+1
                stz playerHonorA+2
                stz playerHonorA+3

;   calculate players' honor rank
                ldy numPlayers
_next5          ldx numPlayers
_next6          lda playerScoreTotal_HI,Y
                cmp playerScoreTotal_HI,X
                beq _3
                bcc _4
                bcs _5                  ; [unc]

; - - - - - - - - - - - - - - - - - - -
_3              lda playerScoreTotal_LO,Y
                cmp playerScoreTotal_LO,X
                beq _5
                bcs _5

_4              inc playerHonorA,X

_5              dex
                bpl _next6

                dey
                bpl _next5

                jmp EnsureUniqueHonorRanking

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== [[F]]
RenderPlayerName .proc
_ptrName        = zpF9
;---

                jsr GetYByHonorRank
                ldx #$05                ; [5,???]
                jsr CalcPixelAddr

                ldx idxPlayer
                jsr SetNameBufPtr       ; result _ptrName [$F9:FA]

                ldy #$00
                sty idxPlayerName

_next1          ldy idxPlayerName
                lda (_ptrName),Y
                beq _XIT

                jsr PlotChar

                inc idxPlayerName

                ldx idxPlayer
                lda idxPlayerName
                cmp playerNameMaxLen,X  ; at max length?
                bne _next1              ;   no, continue

_XIT            rts
                .endproc


;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[V]]
CalcScoreDelta  .proc
;   clear array
                ldx #$04
                lda #$00
_next1          sta arr5Digits,X

                dex
                bpl _next1

                ldx idxPlayer
                lda playerScoreTotal_HI,X
                cmp courseOffset+1
                bcc _2
                bne _1

;   value is greater
                lda playerScoreTotal_LO,X
                cmp courseOffset
                beq _3
                bcc _2

;   value is greater
_1              lda playerScoreTotal_LO,X
                sec
                sbc courseOffset
                sta wordB_3CBE
                lda playerScoreTotal_HI,X
                sbc courseOffset+1
                sta wordB_3CBE+1

                lda #'+'
                sta glyphPlusMinus

                jmp _4

; - - - - - - - - - - - - - - - - - - -
;   value is less
_2              lda courseOffset
                sec
                sbc playerScoreTotal_LO,X
                sta wordB_3CBE
                lda courseOffset+1
                sbc playerScoreTotal_HI,X
                sta wordB_3CBE+1

                lda #'-'
                sta glyphPlusMinus

                jmp _4

; - - - - - - - - - - - - - - - - - - -
;   value is equal
_3              lda #'E'
                sta arr5Digits+4

                jmp _XIT

; - - - - - - - - - - - - - - - - - - -
_4              jsr ConvertToArray
                jsr FindFirstUsed

                lda glyphPlusMinus
                sta arr5Digits,Y

_XIT            rts
                .endproc


;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[V]]
RenderScoreDelta .proc
                jsr CalcScoreDelta

                lda nStage
                cmp #stageCONFIG
                bne _6

; - - - - - - - - - - - - - - - - - - -
;   nStage is stageCONFIG
                jsr GetYByHonorRank

                ldx #$0D                ; [13,Y]
                jsr CalcPixelAddr

                lda #'0'
                sta glyphType
                jmp PlotCharArray._5digits

; - - - - - - - - - - - - - - - - - - -
;   nStage is not stageCONFIG
_6              lda #$05
                clc
                adc idxPlayer
                tay

                ldx #$23                ; [35,5+]
                jsr CalcPixelAddr

                lda #'0'
                sta glyphType
                jmp PlotCharArray._5digits

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
Render4Digits   .proc
                lda idxActiveCourse
                bne _1

                rts

; - - - - - - - - - - - - - - - - - - -
_1              jsr GetYByHonorRank
                ldx #$13                ; [19,???]
                jsr CalcPixelAddr

                ldx #$00
                stx tempC

_next1          ldx tempC
                jsr CalcPlayerScoreIndex    ; result in X

                lda playerScoreRoundA_LO,X
                sta wordB_3CBE
                lda playerScoreRoundA_HI,X
                sta wordB_3CBE+1

                jsr ConvertToArray
                jsr FindFirstUsed

                lda #'0'
                sta glyphType
                jsr PlotCharArray._4digits

                inc tempC
                lda tempC
                cmp idxActiveCourse
                bne _next1

                rts
                .endproc


;======================================
; Render stroke count for the top row
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
Render2or3Digits .proc
                jsr GetYByHonorRank

                iny
                ldx #$04                ; [4,Y]
                jsr CalcPixelAddr

                ldx idxPlayer
                jsr SetStrokesPtr

                ldy #$00
                sty idxDigit

_next1          ldy idxDigit
                lda (zpF9),Y
                sta wordB_3CBE
                stz wordB_3CBE+1

                jsr ConvertToArray
                jsr FindFirstUsed

                lda #'0'
                sta glyphType
                jsr PlotCharArray._2digits

                lda #' '                ; separator bar
                jsr PlotChar

                lda idxDigit
                cmp #$08
                beq _1

                cmp idxActiveHole       ; first hole?
                beq _XIT                ;   yes

                inc idxDigit

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_1              ldx idxPlayer
                lda playerScoreA_LO,X
                sta wordB_3CBE
                lda playerScoreA_HI,X
                sta wordB_3CBE+1

                jsr ConvertToArray
                jsr FindFirstUsed

                lda #'0'
                sta glyphType
                jsr PlotCharArray._3digits

_XIT            rts
                .endproc


;======================================
; Render stroke count for the bottom row
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
Render2or3Digits_2 .proc
                lda idxActiveHole
                cmp #$09                ; back-nine holes?
                bcs _1                  ;   yes

                rts

; - - - - - - - - - - - - - - - - - - -
_1              jsr GetYByHonorRank
                iny
                iny
                ldx #$04                ; [4,Y]
                jsr CalcPixelAddr

                ldx idxPlayer
                jsr SetStrokesPtr

                ldy #$09
                sty idxDigit

_next1          ldy idxDigit
                lda (zpF9),Y
                sta wordB_3CBE
                stz wordB_3CBE+1

                jsr ConvertToArray
                jsr FindFirstUsed

                lda #'0'
                sta glyphType
                jsr PlotCharArray._2digits

                lda #' '                ; separator bar
                jsr PlotChar

                lda idxDigit
                cmp #$11
                beq _3

                cmp idxActiveHole       ; first hole?
                bne _2                  ;   no

                rts

; - - - - - - - - - - - - - - - - - - -
_2              inc idxDigit

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_3              ldx idxPlayer
                lda playerScoreB_LO,X
                sta wordB_3CBE
                lda playerScoreB_HI,X
                sta wordB_3CBE+1

                jsr ConvertToArray
                jsr FindFirstUsed
                jsr PlotCharArray._3digits

                jsr GetYByHonorRank
                iny
                iny
                iny
                ldx #$20                ; [32,Y]
                jsr CalcPixelAddr

                ldx idxActiveCourse
                jsr CalcPlayerScoreIndex    ; result in X

                lda playerScoreRoundA_LO,X
                sta wordB_3CBE
                lda playerScoreRoundA_HI,X
                sta wordB_3CBE+1

                jsr ConvertToArray
                jsr FindFirstUsed
                jmp PlotCharArray._3digits

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[V]]
DoNothing3      rts


;--------------------------------------
;
;--------------------------------------
; Private Procedure
;-------------------------------------- ;[[F]]
EnsureUniqueHonorRanking .proc
_nextHonorRank  = tempB
_targetHonor    = tempC
;---

                stz _targetHonor
                stz _nextHonorRank

_next1          ldx #$00
_next2          lda playerHonorA,X
                cmp _targetHonor        ; this player's honor = target honor?
                bne _1                  ;   no, skip

                lda _nextHonorRank      ; match found, update rank
                sta playerHonorB,X

                inc _nextHonorRank      ; advance to next rank

_1              cpx numPlayers          ; all players processed?
                beq _2                  ;   yes

                inx                     ;   no, continue the search

                jmp _next2

; - - - - - - - - - - - - - - - - - - -
_2              lda _targetHonor
                cmp numPlayers
                beq _3                  ; when all valid ranks were checked
                bcs _4                  ; when valid ranks exhausted

_3              inc _targetHonor

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
;   make the new rank assignments active
_4              ldx numPlayers
_next3          lda playerHonorB,X
                sta playerHonorA,X

                dex
                bpl _next3

                rts
                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
SaveStrokes     .proc
                ldx #$03
                stx idxPlayer

_next1          ldx idxPlayer
                jsr SetStrokesPtr

                ldx idxPlayer
                ldy idxActiveHole
                lda playerStrokeCount,X
                sta (zpF9),Y

                dec idxPlayer
                bpl _next1

                rts
                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
Add0_HI_469C    .proc
                pha

                lda tempB
                adc #$00
                sta tempB

                pla
                rts
                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
GetYByHonorRank .proc
                ldy idxPlayer
                ldx playerHonorA,Y
                ldy yCoordinateByHonor,X

                rts
                .endproc


;======================================
;
;--------------------------------------
; on exit:
;   Y           index of first non-zero
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[F]]
FindFirstUsed   .proc
                ldx #$00
                stx arr5Digits

;   check for used slot (check elements [1:3])
                ldy #$00
_next1          lda arr5Digits+1,Y      ; =0?
                bne _XIT                ;   no

                iny
                cpy #$03
                bne _next1

_XIT            rts
                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
SetStrokesPtr   .proc
                pha

                lda #>playerStrokes
                sta zpF9+1
                lda #<playerStrokes

                ldy #$12
                sty _setLength+1

; - - - - - - - - - - - - - - - - - - -
;   entry point for a different buffer and entry length
_ENTRY1         cpx #$00                ; player index = 0?
                beq _1                  ;   yes

                clc
_setLength      adc #$12                ; [smc] length per entry... bufferLO+(8|18)
                pha                     ; preserve accum

                lda zpF9+1
                adc #$00
                sta zpF9+1

                pla                     ; restore accum

                dex
                jmp _ENTRY1

; - - - - - - - - - - - - - - - - - - -
_1              sta zpF9

                pla
                rts
                .endproc


;======================================
;
;--------------------------------------
; X-Bank Procedure
;--------------------------------------
; on exit:
;   zpF9:FA     pointer
;====================================== ;[[F]]
SetNameBufPtr   .proc
                pha                     ; =$0C (enter), needed due to bypass of SetStrokePtr

                lda #>playerNames
                sta zpFA
                lda #<playerNames

;   set zpF9 to point to playerNames table
                ldy #$08                ; max length
                sty SetStrokesPtr._setLength+1
                jmp SetStrokesPtr._ENTRY1

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;--------------------------------------
; preserved:    A
; on entry:
;   X
; on exit:
;   X
;====================================== ;[[F]]
CalcPlayerScoreIndex .proc
                pha

                lda #$00
_next1          cpx #$00
                beq _1

                clc
                adc #$08

                dex
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_1              clc
                adc idxPlayer
                tax

                pla
                rts
                .endproc


;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[F]]
ConvertToArray  .proc
; - - - - - - - - - - - - - - - - - - -
;   thousands digit
                lda #<1000
                sta wordA_3CBC
                lda #>1000
                sta wordA_3CBC+1

                jsr DivideWordBbyWordA_ABS  ; result in wordB+wordC[remainder]

                lda wordB_3CBE
                sta arr5Digits+1

                lda wordC_3CC0          ; remainder is the new value
                sta wordB_3CBE
                lda wordC_3CC0+1
                sta wordB_3CBE+1

; - - - - - - - - - - - - - - - - - - -
;   hundreds digit
                lda #<100
                sta wordA_3CBC
                lda #>100
                sta wordA_3CBC+1

                jsr DivideWordBbyWordA_ABS  ; result in wordB+wordC[remainder]

                lda wordB_3CBE
                sta arr5Digits+2

                lda wordC_3CC0          ; remainder is the new value
                sta wordB_3CBE
                lda wordC_3CC0+1
                sta wordB_3CBE+1

; - - - - - - - - - - - - - - - - - - -
;   tens digit
                lda #<10
                sta wordA_3CBC
                lda #>10
                sta wordA_3CBC+1

                jsr DivideWordBbyWordA_ABS  ; result in wordB+wordC[remainder]

                lda wordB_3CBE
                sta arr5Digits+3

; - - - - - - - - - - - - - - - - - - -
;   ones digit
                lda wordC_3CC0          ; remainder is the ones digit
                sta arr5Digits+4

                rts
                .endproc

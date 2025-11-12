
;======================================
;
;======================================
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
;======================================
DrawScoreboardBackground .proc
_dest           = zpCD
_width          = zpD0
_height         = zpD1
_MMU            = zpD2
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

;   ensure edit mode
                lda MMU_CTRL
                pha                     ; preserve
                ora #mmuEditMode
                sta MMU_CTRL

                lda #$10                ; [8000:9FFF]->[2_0000:2_1FFF]
                sta _MMU
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

                lda _MMU
                inc A
                sta _MMU
                sta MMU_Block4
                inc A
                sta MMU_Block5

_1              dec _height             ; completed all the rows?
                bne _nextRow            ;   no

; - - - - - - - - - - - - - - - - - - -
;   restore MMU control
                pla
                sta MMU_CTRL

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
;======================================
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

;   ensure edit mode
                lda MMU_CTRL
                pha                     ; preserve
                ora #mmuEditMode
                sta MMU_CTRL

                lda #$10                ; [8000:9FFF]->[2_0000:2_1FFF]
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
;   restore MMU control
                pla
                sta MMU_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                ply
                plx
                pla
                rts
                .endproc

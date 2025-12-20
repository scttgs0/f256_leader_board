
;======================================
;
;--------------------------------------
; rendered at (10,23)
;       = (80,184) = 320*184+80
;       = +$E650
;       = screen16K [block:23] + $0650
;====================================== ;[[V]]
RenderSodPatch  .proc
_composite      = zpCD
_scrnSod        = screen16K
;---

_dest           = zpCD
_width          = zpD0
_src            = zpD4
_scrnSodPatch   = screen16K+$0790
;---

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

                lda #$17                ; [8000:9FFF]->[2_E000:2_FFFF]
                sta zpMMU
                sta MMU_Block4
                inc A                   ; [A000:BFFF]->[3_0000:3_1FFF]
                sta MMU_Block5

                ldx #$06
                stx _width              ; number of glyphs to render

                ldx #<glyphSodPatch
                stx _src
                ldx #>glyphSodPatch
                stx _src+1

                lda #<_scrnSodPatch
                sta _dest
                lda #>_scrnSodPatch
                sta _dest+1

;   render a single glyph line (1 of 14 lines)
_next2          ldx #$0D

_next3          ldy #$00
                lda (_src),Y
                beq _1a
                sta (_dest),Y
_1a             iny
                lda (_src),Y
                beq _1b
                sta (_dest),Y
_1b             iny
                lda (_src),Y
                beq _1c
                sta (_dest),Y
_1c             iny
                lda (_src),Y
                beq _1d
                sta (_dest),Y
_1d             iny
                lda (_src),Y
                beq _1e
                sta (_dest),Y
_1e             iny
                lda (_src),Y
                beq _1f
                sta (_dest),Y
_1f             iny
                lda (_src),Y
                beq _1g
                sta (_dest),Y
_1g             iny
                lda (_src),Y
                beq _2
                sta (_dest),Y

;   advance to the next line of the glyph
_2              lda _src
                clc
                adc #$08
                sta _src
                lda _src+1
                adc #$00
                sta _src+1

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

;   back up 16 scanlines to prepare for the next glyph
                lda _dest
                sec
                sbc #<$1178             ; -4472 (320*14-8)
                sta _dest
                lda _dest+1
                sbc #>$1178
                sta _dest+1

                dec _width              ; completed all the glyphs?
                bne _next2              ;   no

;   restore MMU control
                pla
                sta MMU_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                rts
                .endproc

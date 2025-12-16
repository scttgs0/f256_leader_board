
;======================================
;
;--------------------------------------
; on entry:
;   X           glyph #
;======================================
GetGlyph        .proc
_src            = zp3D
;---

                lda #<fontGlyphs
                sta _src
                lda #>fontGlyphs
                sta _src+1

                txa                     ; using glyph #0?
                beq _XIT                ;   yes, skip adjustment

;   adjust address to point to the proper glyph #
_next1          lda _src
                clc
                adc #$40                ; advance one glyph
                sta _src
                bcc _1

                inc _src+1

_1              dex
                bne _next1

_XIT            rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   zp3D/3E     addr of source glyph
;   zp3F/40     addr of destination
;======================================
DrawGlyph       .proc
_src            = zp3D
_dest           = zp3F
_idxLine        = zpCF
;---

                lda #$00
                sta _idxLine            ; active scanline

;   render a single glyph line (1 of 8 lines)
_nextRow        ldy #$00
                lda (_src),Y
                sta (_dest),Y
                iny
                lda (_src),Y
                sta (_dest),Y
                iny
                lda (_src),Y
                sta (_dest),Y
                iny
                lda (_src),Y
                sta (_dest),Y
                iny
                lda (_src),Y
                sta (_dest),Y
                iny
                lda (_src),Y
                sta (_dest),Y
                iny
                lda (_src),Y
                sta (_dest),Y
                iny
                lda (_src),Y
                sta (_dest),Y

;   advance to the next glyph line
                lda _src
                clc
                adc #<$0008             ; +8
                sta _src
                lda _src+1
                adc #>$0008
                sta _src+1

;   advance to the next scanline
                lda _dest
                clc
                adc #<$0140             ; +320
                sta _dest
                lda _dest+1
                adc #>$0140
                sta _dest+1

;   next source line
                inc _idxLine
                lda _idxLine
                cmp #$08                ; completed 8 scanlines?
                bcc _nextRow            ;   no

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           x-coordinate
;   Y           y-coordinate
;======================================
CalcPixelAddr   .proc
_dest           = zp3F
;---

                txa                     ; x-coordinate
                asl                     ; *8
                asl
                asl
                clc
                adc #<scrnTop           ; +$A010
                sta _dest
                lda #>scrnTop
                adc #$00
                sta _dest+1

;   set MMU
                lda #$10                ; [8000:9FFF]->[2_0000:2_1FFF]
                sta zpMMU               ; [A000:BFFF]->[2_2000:2_3FFF]

                tya                     ; y-coordinate =0?
                beq _apply              ;   yes, skip adjustment

;   adjust address to point to the proper scanline
_next1          lda _dest
                clc
                adc #<$0A00             ; +320*8
                sta _dest
                lda _dest+1
                adc #>$0A00
                sta _dest+1

;   determine whether to adjust the MMU
                cmp #>$A000
                bcc _cont

                lda _dest
                sec
                sbc #<$2000
                sta _dest
                lda _dest+1
                sbc #>$2000
                sta _dest+1

                inc zpMMU

_cont           dey
                bne _next1

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
_apply          lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

;   ensure edit mode
                lda MMU_CTRL
                pha                     ; preserve
                ora #mmuEditMode
                sta MMU_CTRL

; - - - - - - - - - - - - - - - - - - -
;   set the MMU
                lda zpMMU
                sta MMU_Block4
                inc A
                sta MMU_Block5

; - - - - - - - - - - - - - - - - - - -
;   restore MMU control
                pla
                sta MMU_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A           single BCD-digit
;======================================
PlotCharBCD     ora '0'

                ;[fall-through]


;======================================
;
;--------------------------------------
; on entry:
;   A           glyph #
;======================================
PlotChar        .proc
_dest           = zp3F
;---

                tax                     ; glyph #
                jsr GetGlyph
                jsr DrawGlyph

;   restore DEST pointer
                lda _dest
                sec
                sbc #<$09FF             ; -2559 (8 scanlines * 320 bytes/line)
                sta _dest
                lda _dest+1
                sbc #>$09FF
                sta _dest+1

                rts
                .endproc

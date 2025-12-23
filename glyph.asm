
;======================================
;
;--------------------------------------
; on entry:
;   X           glyph #
;   zp3D/3E     addr of source glyph
;====================================== ;[[V]]
GetGlyph        .proc
_src            = zp3D
;---

                lda #<gfxGlyph
                sta _src
                lda #>gfxGlyph
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
;   X           glyph #
; on exit:
;   glyphData   8x8 glyph data
;====================================== ;[[V]]
GetFontGlyph    .proc
_src            = zpSource
_dest           = zpDest
;---

                lda #<FONT_MEMORY_BANK0
                sta _src
                lda #>FONT_MEMORY_BANK0
                sta _src+1

                lda #<glyphData
                sta _dest
                lda #>glyphData
                sta _dest+1

                txa                     ; using glyph #0?
                bne _next1

                lda #' '

;   adjust address to point to the proper glyph #
_next1          lda _src
                clc
                adc #$08                ; advance one glyph
                sta _src
                bcc _1

                inc _src+1

_1              dex
                bne _next1

; - - - - - - - - - - - - - - - - - - -
_extract        ldy #$00
                sty _idxLine

_nextLine       ldy _idxLine
                lda (_src),Y

                ldy #$00
_nextPixel      clc
                rol
                pha                     ; preserve remainder

                bcs _one

                lda #$00                ; background
                .byte $2C
_one            lda #$16                ; foreground
                sta (_dest),Y
                iny

                pla                     ; restore remainder

                cpy #$08
                bne _nextPixel

                lda _dest
                clc
                adc #<$0008
                sta _dest
                lda _dest+1
                adc #>$0008
                sta _dest+1

                ldy _idxLine
                iny
                sty _idxLine

                cpy #$08
                bne _nextLine

                rts

;--------------------------------------

_idxLine        .byte $00

                .endproc


;--------------------------------------
;--------------------------------------

glyphData       .fill 64,$00


;======================================
;
;--------------------------------------
; on entry:
;   zp3D/3E     addr of source glyph
;   zp3F/40     addr of destination
;====================================== ;[[V]]
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
; on exit
;   zp3F/40     address
;====================================== ;[[V]]
CalcPixelAddr   .proc
_dest           = zp3F
;---

                stz _dest+1

                txa                     ; x-coordinate
                asl                     ; *8
                asl
                asl
                bcc _1

                inc _dest+1

_1              clc
                adc #<scrnTop           ; +$A010
                sta _dest
                lda _dest+1
                adc #>scrnTop
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
;====================================== ;[[V]]
PlotCharBCD     ora #'0'

                ;[fall-through]


;======================================
; plot a 1x8 character glyph
;--------------------------------------
; on entry:
;   A           glyph #
;   zp3F/40     screen address
;====================================== ;[[V]]
PlotChar        .proc
_src            = zp3D
_dest           = zp3F
;---

                sta zpCharToPlot

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to charset map
                lda #iopPage1
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                lda zpCharToPlot
                tax                     ; glyph #
                jsr GetFontGlyph

                lda #<glyphData
                sta _src
                lda #>glyphData
                sta _src+1

                jsr DrawGlyph

;   restore DEST pointer
                lda _dest
                sec
                sbc #<$09F8             ; -2552 (320*8-8)
                sta _dest
                lda _dest+1
                sbc #>$09F8
                sta _dest+1

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                rts
                .endproc


;======================================
; plot an 8x8 gfx glyph
;--------------------------------------
; on entry:
;   A           glyph #
;====================================== ;[[V]]
PlotGlyph       .proc
_dest           = zp3F
;---

                tax                     ; glyph #
                jsr GetGlyph
                jsr DrawGlyph

;   restore DEST pointer
                lda _dest
                sec
                sbc #<$09F8             ; -2552 (320*8-8)
                sta _dest
                lda _dest+1
                sbc #>$09F8
                sta _dest+1

                rts
                .endproc


;======================================
;
;--------------------------------------
;  80 bytes black [$F0:13F]
; 240 bytes blue  [$00:EF]
;====================================== ;[[V]]
ResetPlayfield  .proc
zpIndex1        = zpD0
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
                sta zpMMU
                sta MMU_Block4
                inc A                   ; [A000:BFFF]->[2_2000:2_3FFF]
                sta MMU_Block5

; - - - - - - - - - - - - - - - - - - -
                lda #<screen16K         ; Set the destination address ($8000)
                sta zpDest
                lda #>screen16K
                sta zpDest+1

                lda #$08                ; quantity of buffer fills (8k/iteration)
                sta zpIndex1

_nextBlock      ldx #$1A                ; 26 lines (26*320=$2080)

_nextLine       lda #$08                ; WATER
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

                lda #$00                ; BLACK (HUD)
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

                dec zpIndex1
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


;======================================
;
;====================================== ;[[F]]
AdvNextScanline .proc
_ptr            = zpFD
;---

                pha                     ; preserve

                lda _ptr
                clc
                adc #<$0140             ; +320
                sta _ptr
                lda _ptr+1
                adc #>$0140
                sta _ptr+1

                pla                     ; restore
                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
BackSwingAnim   .proc
                lda isBackSwingAnim     ; back swing in progress?
                bne _1                  ;   yes

                rts

; - - - - - - - - - - - - - - - - - - -
_1              lda timerIsActive       ; timer 0 active?
                beq _2                  ;   no

                rts

; - - - - - - - - - - - - - - - - - - -
_2              ;!!jsr DrawGolferPutt

                inc golferSwingFrame
                ldx golferSwingFrame
                cpx #$0A                ; max back swing?
                bne _3                  ;   no

                lda #FALSE              ;   yes, done
                sta isBackSwingAnim

                rts

; - - - - - - - - - - - - - - - - - - -
_3              lda puttAnimTimer,X     ; duration
                ldx #$00                ; timer 0
                jsr SetTimer

                ldx golferSwingFrame
                cpx #$06
                bne _4

                jsr InitPutt_2521

_4              lda golferSwingFrame
                cmp #$07
                bne _XIT

                lda #$00                ; silence
                ;!!sta AUDC4
                ;!!sta AUDF4

_XIT            rts
                .endproc


;--------------------------------------
;--------------------------------------

puttAnimTimer   .byte $05,$05,$05,$0C,$05
                .byte $05,$05,$05,$05,$05
puttAnimIndex   .byte $00,$01,$02,$03,$02
                .byte $01,$00,$04,$05,$06


;======================================
;
;====================================== ;[[V]]
RenderPlayfield .proc
                jsr ResetPlayfield      ; fill playfield with water
                jsr DrawClouds          ; render clouds
                jsr DrawMountains       ; render mountains

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
DrawClouds      .proc
_dest           = zpCD
_width          = zpD0
_src            = zpD4
_layerOffset    = zpCF
_scrnCloud      = screen16K
;---

                ldx #30
                stx _width              ; number of cloud glyphs to render

; - - - - - - - - - - - - - - - - - - -
;   entry point for the scoreboard view... which expands to the full screen width
_ENTRY1
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
                sta zpMMU
                sta MMU_Block4
                lda #CLOUD_CHUNK         ; [A000:BFFF]->[CLOUD_CHUNK]
                sta MMU_Block5

; - - - - - - - - - - - - - - - - - - -
                .frsRandomByte
                and #$1F
                cmp #30                 ; >=30 (width of playfield)?... and also the cloud stamps
                bcs _ENTRY1             ;   yes... try again

                sta _layerOffset        ; cloud layer offset

                ldx #<glyphClouds
                stx _src
                ldx #>glyphClouds
                stx _src+1

                tax                     ; offset=0?
                beq _1                  ;   yes, skip

;   advance to the next glyph
_next1          lda _src
                clc
                adc #<$0040             ; +64 (bytes/lines/glyph)
                sta _src
                lda _src+1
                adc #>$0040
                sta _src+1

                dex
                bne _next1

_1              lda #<_scrnCloud
                sta _dest
                lda #>_scrnCloud
                sta _dest+1

;   render a single cloud glyph line (1 of 8 lines)
_next2          ldx #$07

_next3          ldy #$00
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

;   advance to the next line of the glyph
                lda _src
                clc
                adc #$08
                sta _src
                lda _src+1
                adc #$00
                sta _src+1

;   advance to the next scanline
_2              lda _dest
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

;   advance to the next cloud glyph
                inc _layerOffset
                lda _layerOffset
                cmp #30                 ; <30?
                bcc _3                  ;   yes

;   end of cloud layer reached... wrap around to the beginning
                lda #$00
                sta _layerOffset

                lda #<glyphClouds       ; wrap back to the left-edge of the cloud layer
                sta _src
                lda #>glyphClouds
                sta _src+1

_3              dec _width              ; completed all the cloud glyphs?
                bne _next2              ;   no

; - - - - - - - - - - - - - - - - - - -
;   restore MMU
                lda zpMMU
                inc A
                sta MMU_Block5

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
;====================================== ;[[V]]
DrawMountains   .proc
_dest           = zpCD
_layerOffset    = zpCF
_width          = zpD0
_src            = zpD4
_scrnMountain   = screen16K+320*8
;---

                ldx #30
                stx _width              ; number of mountain glyphs to render

; - - - - - - - - - - - - - - - - - - -
;   entry point for the scoreboard view... which expands to the full screen width
_ENTRY1
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
                sta zpMMU
                sta MMU_Block4
                lda #CLOUD_CHUNK         ; [A000:BFFF]->[CLOUD_CHUNK]
                sta MMU_Block5

; - - - - - - - - - - - - - - - - - - -
                .frsRandomByte
                and #$1F
                cmp #30                 ; >=30 (width of playfield)?... and also the mountain stamps
                bcs _ENTRY1             ;   yes... try again

                sta _layerOffset        ; mountain layer offset

                ldx #<glyphMountains
                stx _src
                ldx #>glyphMountains
                stx _src+1

                tax                     ; offset=0?
                beq _1                  ;   yes, skip

;   advance to the next glyph
_next1          lda _src
                clc
                adc #<$0080             ; +128 (bytes/lines/glyph)
                sta _src
                lda _src+1
                adc #>$0080
                sta _src+1

                dex
                bne _next1

_1              lda #<_scrnMountain
                sta _dest
                lda #>_scrnMountain
                sta _dest+1

;   render a single mountain glyph line (1 of 16 lines)
_next2          ldx #$0F

_next3          ldy #$00
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

;   advance to the next line of the glyph
                lda _src
                clc
                adc #$08
                sta _src
                lda _src+1
                adc #$00
                sta _src+1

;   advance to the next scanline
_2              lda _dest
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
                sbc #<$13F8             ; -5112 (320*16-8)
                sta _dest
                lda _dest+1
                sbc #>$13F8
                sta _dest+1

;   advance to the next mountain glyph
                inc _layerOffset
                lda _layerOffset
                cmp #30                 ; <30?
                bcc _3                  ;   yes

;   end of mountain layer reached... wrap around to the beginning
                lda #$00
                sta _layerOffset

                lda #<glyphMountains   ; wrap back to the left-edge of the mountain layer
                sta _src
                lda #>glyphMountains
                sta _src+1

_3              dec _width              ; completed all the mountain glyphs?
                bne _next2              ;   no

; - - - - - - - - - - - - - - - - - - -
;   restore MMU
                lda zpMMU
                inc A
                sta MMU_Block5

;   restore MMU control
                pla
                sta MMU_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                rts
                .endproc

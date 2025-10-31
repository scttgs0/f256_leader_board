
                .include "equates/system_f256.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

                .include "macros/f256_graphic.mac"
                .include "macros/f256_mouse.mac"
                .include "macros/f256_random.mac"
                .include "macros/f256_text.mac"


;--------------------------------------
;--------------------------------------
                * = $1FE0
;--------------------------------------

.if PGZ=0
                .byte $F2,$56           ; signature
                .byte $01               ; block count
                .byte $01               ; start at block1
                .addr BOOT              ; execute address
                .word $0001             ; version
                .word $0000             ; kernel
                .null 'Leader Board'    ; binary name
.endif


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

;--------------------------------------
;
;--------------------------------------
BOOT            ldx #$FF
                txs

                stz IOPAGE_CTRL

                stz BACKGROUND_COLOR_R
                stz BACKGROUND_COLOR_G
                stz BACKGROUND_COLOR_B

                jsr INIT
                jmp START


;--------------------------------------
;--------------------------------------

                .include "hud.asm"


;--------------------------------------
;--------------------------------------
; Start of Code
;--------------------------------------
;--------------------------------------
START           .proc
                jsr RenderHUD

_endless        bra _endless
                .endproc


;--------------------------------------
;--------------------------------------

                .include "platform_f256.asm"
                .include "interrupts.asm"


;======================================
;
;======================================
INIT            .proc
                sei

                jsr InitCPUVectors
                jsr InitMMU
                jsr InitIRQs

                cli

                jsr RandomSeedQuick

                .frsGraphics mcSpriteOn|mcBitmapOn|mcGraphicsOn|mcOverlayOn|mcTextOn,mcVideoMode200|mcTextDoubleX|mcTextDoubleY
                .frsMouse_off
                .frsCursor FALSE
                .frsBorder_off

                stz BITMAP0_CTRL        ; disable all bitmaps
                stz BITMAP1_CTRL
                stz BITMAP2_CTRL
                stz LAYER_ORDER_CTRL_0
                stz LAYER_ORDER_CTRL_1

                jsr InitTextPalette
                jsr ClearScreen

                rts
                .endproc

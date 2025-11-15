
                .include "equates/system_f256.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

                .include "macros/f256_graphic.mac"
                .include "macros/f256_mouse.mac"
                .include "macros/f256_random.mac"
                .include "macros/f256_sprite.mac"
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

                .include "glyph.asm"
                .include "sprites.asm"
                .include "input.asm"
                .include "clock.asm"
                .include "audio.asm"

                .include "main.asm"
                .include "aim.asm"
                .include "clubs.asm"
                .include "gauge.asm"

                .include "hud.asm"
                .include "hud_mock.asm"
                .include "playfield.asm"
                .include "sodpatch.asm"
                .include "render.asm"

                .include "course.asm"
                .include "physics.asm"
                .include "math.asm"

                .include "ball.asm"
                .include "wind.asm"

                .include "swinganimation.asm"
                .include "teeoff.asm"
                .include "putt.asm"

                .include "scoreboard.asm"

                .include "gameconfig.asm"

                .include "mock.asm"


;--------------------------------------
;--------------------------------------
; Start of Code
;--------------------------------------
;--------------------------------------
START           .proc
                jsr ClearGameState

                ;jsr DoConfig

                jsr RenderHUD
                jsr RenderPlayfield
                jsr RenderSodPatch

_endless        bra _endless
                .endproc


;--------------------------------------
;--------------------------------------

                .align $0100
palette         .include "data/PALETTE.inc"
end_palette

                .align $0100
gameFont        .include "data/FONT.inc"
end_gameFont

                .include "data/CLOUDS.inc"
                .include "data/MOUNTAINS.inc"
                .include "data/STATIC.inc"
                .include "data/GAMESTATE.inc"
                .include "data/SODPATCH.inc"

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

                jsr SetFont
                jsr InitTextPalette
                jsr ClearScreen

                jsr InitGfxPalette
                jsr InitBitmap
                jsr InitSprites

                .frsSpriteSetX $86,0    ; club
                .frsSpriteSetY $D2,0

                .frsSpriteSetX $70,1    ; player top
                .frsSpriteSetY $B6,1
                .frsSpriteSetX $70,2    ; player bottom
                .frsSpriteSetY $D6,2

                rts
                .endproc


;--------------------------------------
;--------------------------------------

                .include "data/ANIM0_DRIVER_32.inc"
                .include "data/ANIM0_CLUB_24.inc"

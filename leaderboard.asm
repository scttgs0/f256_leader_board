
                .include "equates/system_f256.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

                .include "macros/f256_graphic.mac"
                .include "macros/f256_mouse.mac"
                .include "macros/f256_random.mac"
                .include "macros/f256_sprite.mac"
                .include "macros/f256_text.mac"

;--------------------------------------
;   f256        atari8
;   sprint 0                club
;   sprint 1                golfer top      (driving)
;   sprint 2                golfer bottom   (driving)
;   sprint 4                golfer top      (putting)
;   sprint 5                golfer bottom   (putting)
;   sprint 8                ball
;   sprint 9                ball shadow
;   sprint 10               aim target
;   sprite 11               gauge
;
;               sprint 0/1  Golfer left-half (0=front, 1=back)
;               sprite 2/3  Golfer right-half (2=front, 3=back)
;               missile 0   Aim target (top,bottom,middle-right) / Ball Shadow
;               missile 1   Ball (right-side)
;               missile 2   Aim target (middle-left)
;               missile 3   Ball (left-side)

;--------------------------------------
;   timers
;   0   = swing animation, cursor flash
;   1   = change clubs
;   5   = snap
;   6   = ball movement
;   7   = swing animation
;   8   = subtract distance
;   9   = aim target movement
;   11  = audio 4
;   12  = audio 3
;   13  = audio 3

;--------------------------------------
;   right-hand rule  *** assumed for this project ***
;
;   +Z  +Y
;   |  /
;   | /
;   |/
;   |______ +X

;--------------------------------------
;   keycodes (raw/ascii)
;   esc             $92/$08     [crap] same as backspc, use RUNSTOP instead
;   run/stop        $BC/$03
;   up-arrow        $B6/$10
;   down-arrow      $B7/$0E
;   left-arrow      $B8/$02
;   right-arrow     $B9/$06
;   right-alt       $05/--
;   F2              $81/--
;   return          $94/$0D
;   delete          $92/$08
;   oem [K]         $06/--
;   a-z             [$61:$7A]/[$61:$7A]
;   A-Z             [$61:$7A]/[$41:$5A]
;   1-4             [$31:$34]/[$31:$34]
;   Shft,1-4        [$31:$34]/[$21,$40,$23,$24]


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
                .include "playfield.asm"
                .include "sodpatch.asm"
                .include "render.asm"
                .include "clipping.asm"

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

;   zero all player names
                ldx #$1F
                lda #$00
_next1          sta playerNames,X

                dex
                bpl _next1

;   initialize all skill levels
                ldx #$03
                lda #skillPRO           ; professional
_next2          sta tblPlayerAbility,X

                dex
                bpl _next2

                jmp NewGame

                ;jsr DoConfig

                ;jsr ProcessStroke

;_endless        jsr ProcessEvents
;                bra _endless
                .endproc


;--------------------------------------
;--------------------------------------

                .include "data/GAMESTATE.inc"
                .include "data/SODPATCH.inc"
                .include "data/GAUGE.inc"

                .include "platform_f256.asm"
                .include "kernel/facade.asm"


;======================================
;
;======================================
INIT            .proc
                jsr InitKernel

; - - - - - - - - - - - - - - - - - - -
                sei                     ; disable interrupts

                jsr InitMMU
                jsr InitCPUVectors
                jsr InitIRQs

                cli                     ; enable interrupts
; - - - - - - - - - - - - - - - - - - -

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

                jsr Stage

                rts
                .endproc


;======================================
;
;======================================
Stage           .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------
                * = $0800
;--------------------------------------

                .include "data/COURSES.inc"

                .align $100
                .include "interrupts.asm"
                .include "data/GLYPHS.inc"
                .include "data/STATIC.inc"


;--------------------------------------
;--------------------------------------
                * = $8000
;--------------------------------------

palette         .include "data/PALETTE.inc"

                .align $0100
gameFont        .include "data/FONT.inc"


;--------------------------------------
;--------------------------------------

                .include "data/ANIM0_DRIVER.inc"
                .include "data/ANIM0_CLUB.inc"
                .include "data/ANIM1_PUTT.inc"


;--------------------------------------
;--------------------------------------
                .align $2000
CLOUD_CHUNK     = (* / $2000)

                .logical $A000
;--------------------------------------

                .include "data/CLOUDS.inc"
                .include "data/MOUNTAINS.inc"

;--------------------------------------
;--------------------------------------
                .endlogical
;--------------------------------------

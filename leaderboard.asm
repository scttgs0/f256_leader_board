
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
;   sprite 12               splash
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
;   < ,             $2C
;   > .             $2E


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
BOOT            ldx #$FF                ; reset the stack
                txs

                stz IOPAGE_CTRL         ; switch to the Primary I/O page

                lda #mmuPage3|mmuEditPage3|mmuEditMode
                sta MMU_CTRL            ; ensure Page3 w/Edit

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

                .include "data/HUD.inc"
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

                .endproc


;--------------------------------------
;--------------------------------------

                .include "data/GAMESTATE.inc"


;======================================
;
;======================================
INIT            .proc
                jsr InitKernel

; - - - - - - - - - - - - - - - - - - -
                sei                     ; disable interrupts

                jsr InitMMU
                lda #CONFIG_CHUNK       ; default to the gameconfig chunk
                sta MMU_Block3

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


;======================================
;
;====================================== ;[[V]]
XBPC_DrawScoreboard .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #SCORE_CHUNK
                sta MMU_Block3

                jsr DrawScoreboard

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_DoScoreboard .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #SCORE_CHUNK
                sta MMU_Block3

                jsr DoScoreboard

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_RenderScoreDelta .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #SCORE_CHUNK
                sta MMU_Block3

                jsr RenderScoreDelta

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_FindFirstUsed .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #SCORE_CHUNK
                sta MMU_Block3

                jsr FindFirstUsed

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_SetNameBufPtr .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #SCORE_CHUNK
                sta MMU_Block3

                jsr SetNameBufPtr

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_ConvertToArray .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #SCORE_CHUNK
                sta MMU_Block3

                jsr ConvertToArray

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_InitPutt_2521 .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #PUTT_CHUNK
                sta MMU_Block3

                jsr InitPutt_2521

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_DrawGolferPutt .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #PUTT_CHUNK
                sta MMU_Block3

                jsr DrawGolferPutt

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_PuttControl .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #PUTT_CHUNK
                sta MMU_Block3

                jsr PuttControl

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_Swing_3E71 .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #PUTT_CHUNK
                sta MMU_Block3

                jsr Swing_3E71

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_RenderHUD .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #HUD_CHUNK
                sta MMU_Block3

                jsr RenderHUD

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_RenderHUD_ENTRY1 .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #HUD_CHUNK
                sta MMU_Block3

                jsr RenderHUD._ENTRY1

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_DrawDistanceToPin_m1 .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #HUD_CHUNK
                sta MMU_Block3

                jsr DrawDistanceToPin_m1

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_DrawDistanceToPin .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #HUD_CHUNK
                sta MMU_Block3

                jsr DrawDistanceToPin

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;======================================
;
;======================================
XBPC_IncrementStrokeCount .proc
                lda MMU_Block3          ; preserve
                sta zpMMU_XBPC

                lda #HUD_CHUNK
                sta MMU_Block3

                jsr IncrementStrokeCount

                lda zpMMU_XBPC          ; restore
                sta MMU_Block3

                rts
                .endproc


;--------------------------------------
;--------------------------------------
                * = $0300
;--------------------------------------

                .include "platform_f256.asm"


;--------------------------------------
;--------------------------------------
                * = $0800
;--------------------------------------

                .include "data/COURSES.inc"

                .align $100
                .include "interrupts.asm"

                .include "data/STATIC.inc"
                .include "kernel/facade.asm"


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
                .include "data/ANIM2_CLUB.inc"
                .include "data/ANIM1_PUTT.inc"
                .include "data/ANIM3_SPLASH.inc"


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


;--------------------------------------
;--------------------------------------
                * = $5_0000
CONFIG_CHUNK    = (* / $2000)

                .logical $6000
;--------------------------------------

                .include "gameconfig.asm"
                .include "data/SODPATCH.inc"
                .include "data/GLYPHS.inc"
                .include "data/GAUGE.inc"
                .include "mock.asm"


;--------------------------------------
;--------------------------------------
                .endlogical

                * = $5_2000
SCORE_CHUNK     = (* / $2000)

                .logical $6000
;--------------------------------------

                .include "scoreboard.asm"


;--------------------------------------
;--------------------------------------
                .endlogical

                * = $5_4000
PUTT_CHUNK      = (* / $2000)

                .logical $6000
;--------------------------------------

                .include "putt.asm"


;--------------------------------------
;--------------------------------------
                .endlogical

                * = $5_8000
HUD_CHUNK       = (* / $2000)

                .logical $6000
;--------------------------------------

                .include "hud.asm"


;--------------------------------------
;--------------------------------------
                .endlogical
;--------------------------------------

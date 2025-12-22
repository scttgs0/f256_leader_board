
;======================================
;
;====================================== ;[[V]]
DoWind          .proc
_retainPixel    = zpCD
_SCREEN         = zpD4
_scrnCloud      = screen16K
;---

                lda windFactor          ; already set?
                beq _1                  ;   no

_XIT1           rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_1              lda windVelocity        ; is there any wind?
                beq _XIT1               ;   no

                asl                     ; =wind_vel*4-68... [-$40|-$3C|-$38|-$34|-$30|-$2C|-$28]
                asl                     ;                   [ $C0| $C4| $C8| $CC| $D0| $D4| $D8]
                sec
                sbc #$44
                sta windFactor

                ldy activePlayer
                lda tblPlayerAbility,Y
                cmp #skillPRO           ; professional?
                bne _XIT1               ;   no

; - - - - - - - - - - - - - - - - - - -
;   executed for Professional only

                lda #$00                        ; result is ignored
                sec                             ; only purpose is to set the CARRY flag
                sbc playerWindDirection_HI,Y    ;

                lda #$00
                sbc playerWindDirection_LO,Y
                clc
                adc windDirection
                sta windDirClouds

                lda windDirClouds
                bpl _2

                eor #$FF                ; 2-compliment
                adc #$01

_2              cmp #$10                ; <16?
                bcc _XIT1               ;   yes

                cmp #$F0                ; >=240?
                bcs _XIT1               ;   yes

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
;   move clouds
                lda #<_scrnCloud
                sta _SCREEN
                lda #>_scrnCloud
                sta _SCREEN+1

                ldx #$08
                bit windDirClouds
                bmi _moveLeft

; - - - - - - - - - - - - - - - - - - -
;   positive - move clouds right
_moveRight      ldy #$EF                ; right-most cloud pixel
                lda (_SCREEN),Y
                sta _retainPixel        ; preserve the right-pixel

                ldy #$EE
_next2          lda (_SCREEN),Y
                iny
                sta (_SCREEN),Y
                dey

                dey
                cpy #$FF
                bne _next2

                lda _retainPixel        ; right-most pixel becomes left-most pixel
                ldy #$00
                sta (_SCREEN),Y

                jsr AdvNextScanline_D4  ; move down one line

                dex
                bne _moveRight
                bra _XIT

; - - - - - - - - - - - - - - - - - - -
;   negative - move clouds left
_moveLeft       ldy #$00                ; left-most cloud pixel
                lda (_SCREEN),Y
                sta _retainPixel        ; preserve the left-pixel

                ldy #$01
_next4          lda (_SCREEN),Y
                dey
                sta (_SCREEN),Y
                iny

                iny
                cpy #$F0
                bne _next4

                lda _retainPixel        ; left-most pixel becomes right-most pixel
                ldy #$EF
                sta (_SCREEN),Y

                jsr AdvNextScanline_D4  ; move down one line

                dex
                bne _moveLeft

; - - - - - - - - - - - - - - - - - - -
_XIT
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
;====================================== ;[[F]]
SetWindRandom   .proc
                .frsRandomByte
                sta windDirection

                .frsRandomByte
                and #$07
                sta windVelocity

                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
DoWindStreamer  .proc
                ldx activePlayer
                lda #$00
                sec
                sbc playerWindDirection_HI,X
                sta windDirThisHole_HI

                lda #$00
                sbc playerWindDirection_LO,X
                clc
                adc windDirection
                sta windDirThisHole_LO
                sta windDirClouds

                lda #$50                ; +80
                sta deltaWind_m40_p80

                lda #$32                ; +50
                sta deltaWind_p00_p50

                ldy windVelocity
                ldx activePlayer
                lda tblPlayerAbility,X
                cmp #skillPRO           ; professional?
                beq _1                  ;   yes

                ldy #$00                ; ignore wind
_1              sty windVelThisHole

                ;;lda #>$0140             ; [override] xMax [320]
                ;;sta ProcessLine._setMaxX_HI+1
                ;;lda #<$0140
                ;;sta ProcessLine._setMaxX_LO+1
                lda #$40                ; [override] xMax [320; hi-byte ignored]
                sta ProcessLine._setMaxX+1

                lda #$03                ; [override] color=dark gray
                sta DrawWindStreamer._setColor1+1

                jsr DrawWindStreamer._ENTRY1

                ;;lda #>$00F0             ; [default] xMax [240]
                ;;sta ProcessLine._setMaxX_HI+1
                ;;lda #<$00F0
                ;;sta ProcessLine._setMaxX_LO+1
                lda #$F0                ; [default] xMax [120]
                sta ProcessLine._setMaxX+1

                lda #$00                ; [default] color=black
                sta DrawWindStreamer._setColor1+1

                rts
                .endproc


;======================================
;
;--------------------------------------
; also utilized to render the slope
;====================================== ;[[F]]
DrawWindStreamer .proc
_srcWIND_DIR    = zpFB
_srcWIND_VEL    = zpFD
;---

                ldx activePlayer
                lda #$00
                sec
                sbc playerWindDirection_HI,X
                sta windDirThisHole_HI

                lda #$00
                sbc playerWindDirection_LO,X
                pha

                jsr GetPtrHoleWindDirection
                stx _srcWIND_DIR
                sty _srcWIND_DIR+1

                jsr GetPtrHoleWindVelocity
                stx _srcWIND_VEL
                sty _srcWIND_VEL+1

                pla                     ; -wind direction
                ldy idxActiveHole
                clc
                adc (_srcWIND_DIR),Y    ; + wind direction
                sta windDirThisHole_LO

                lda (_srcWIND_VEL),Y
                sta windVelThisHole

                lda #$D8                ; -40
                sta deltaWind_m40_p80

                lda #$00                ; +0
                sta deltaWind_p00_p50

; - - - - - - - - - - - - - - - - - - -
_ENTRY1         lda #<$0018             ; surface (24 inches)
                sta polyVertZ_LO
                lda #>$0018
                sta polyVertZ_HI

                lda #<$1800
                sta polyVertX_LO
                lda #>$1800
                sta polyVertX_HI

                lda #<$0600
                sta polyVertY_LO
                lda #>$0600
                sta polyVertY_HI

                ldx #xformNORMAL
                jsr VertexTransform
                stx lineNode0_VertX_LO
                sty lineNode0_VertZ_LO

                ldx #<$0032             ; value (50)
                ldy #>$0032
                sty nodeOperation       ; operPIXEL
                jsr CalcPolyVertXY_delta

                lda #<$1800
                clc
                adc polyVertX_delta
                sta polyVertX_LO
                lda #>$1800
                adc polyVertX_delta+1
                sta polyVertX_HI

                lda #<$0600
                clc
                adc polyVertY_delta
                sta polyVertY_LO
                lda #>$0600
                adc polyVertY_delta+1
                sta polyVertY_HI

                ldx #xformNORMAL
                jsr VertexTransform
                stx lineNode1_VertX_LO
                sty lineNode1_VertZ_LO

                jsr SwapLineNodes

; - - - - - - - - - - - - - - - - - - -
_setColor1      lda #COLOR_BLACK        ; (wind velocity pole)
                sta pixelColor

                lsr lineNode0_VertX_LO
                lsr lineNode1_VertX_LO

                lda lineNode0_VertX_LO
                clc
                adc deltaWind_m40_p80
                sta lineNode0_VertX_LO

                lda lineNode1_VertX_LO
                clc
                adc deltaWind_m40_p80
                sta lineNode1_VertX_LO

                lda lineNode0_VertZ_LO
                sec
                sbc deltaWind_p00_p50
                sta lineNode0_VertZ_LO

                lda lineNode1_VertZ_LO
                sec
                sbc deltaWind_p00_p50
                sta lineNode1_VertZ_LO

                jsr ProcessLine._ENTRY_WIND

; - - - - - - - - - - - - - - - - - - -
                lda lineNode0_VertZ_LO
                sec
                sbc windVelThisHole
                sta lineNode1_VertZ_LO

                lda #COLOR_BLUE         ; (wind direction streamer)
                sta pixelColor

                jsr ProcessLine._ENTRY_WIND

; - - - - - - - - - - - - - - - - - - -
                lda windVelThisHole
                tax
                ldy #$00                ; hi-byte unused
                jsr CalcPolyVertXY_delta

                lda polyVertX_delta
                sta windDeltaX
                lda polyVertX_delta+1
                sta windDeltaX+1

                lda polyVertY_delta
                sta windDeltaY
                lda polyVertY_delta+1
                sta windDeltaY+1

                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
PuttSlope_54CF  .proc
                lda idxDistanceUnit
                cmp #unitYARDS          ; inches or feet?
                bcc _1                  ;   yes

_XIT1           rts

; - - - - - - - - - - - - - - - - - - -
_1              lda timerIsActive+6     ; timer 6 active?
                bne _XIT1               ;   yes

                inc timerIsActive+6     ;   no, make active

                lda puttX_LO
                clc
                adc windDeltaX
                sta puttX_LO
                lda puttX_HI
                adc windDeltaX+1
                sta puttX_HI

                lda puttY_LO
                clc
                adc windDeltaY
                sta puttY_LO
                lda puttY_HI
                adc windDeltaY+1
                sta puttY_HI

                rts
                .endproc


;--------------------------------------
;--------------------------------------

windDeltaX      .word $0000
windDeltaY      .word $0000

windDirClouds   .byte $00
windFactor      .byte $00               ; [-$40:-$28]

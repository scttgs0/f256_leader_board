
;======================================
;
;====================================== ;[[V]]
SpriteInit      .proc
                jsr ClearAllPlayers

                lda #$00
                sta golferSwingFrame
                sta golferSwingFrameMax

                jsr DrawGolfer
                jmp ProcessClubSwingAnim    ; render club

                .endproc


;======================================
;
;====================================== ;[[V]]
ClearMissiles   .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                .frsSpriteClear 8       ; ball
                .frsSpriteHide 8
                .frsSpriteClear 9       ; ball shadow
                .frsSpriteHide 9

                .frsSpriteClear 10      ; aim target
                .frsSpriteHide 10

                ;;.frsSpriteClear 11      ; swing gauge
                ;;.frsSpriteHide 11

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
ClearAllPlayers .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                .frsSpriteClear 0       ; club
                .frsSpriteHide 0

                .frsSpriteClear 1       ; player
                .frsSpriteHide 1
                .frsSpriteClear 2       ; player
                .frsSpriteHide 2

                .frsSpriteClear 4       ; putter
                .frsSpriteHide 4
                .frsSpriteClear 5       ; putter
                .frsSpriteHide 5

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                .endproc


;======================================
;
;====================================== ;[[F]]
ClearBallShadow .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                .frsSpriteClear 9       ; ball shadow
                .frsSpriteHide 9

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
ClearAimTarget  .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                .frsSpriteClear 10      ; aim target
                .frsSpriteHide 10

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[V]]
ShowSwingGauge  .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                .frsSpriteShow 11       ; swing gauge
                .frsSpriteSetX $114,11
                .frsSpriteSetY $C0,11

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
ClearSwingGauge .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                .frsSpriteClear 11      ; swing gauge
                .frsSpriteHide 11

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc

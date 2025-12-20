
;======================================
;
;====================================== ;[[U]]
SpriteInit      .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A           player # to clear [0:3]
;======================================; [[U]]
ClearPlayer_n   .proc
                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
ClearMissiles   .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                .frsSpriteClear 8       ; ball
                .frsSpriteHide 8
                ;.frsSpriteClear 9       ; ball shadow
                ;.frsSpriteHide 9
                ;.frsSpriteClear 10      ; aim target
                ;.frsSpriteHide 10

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
ClearAllPlayers .proc
                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
ClearBallShadow .proc
;ClearMissile0   .proc
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
;-------------------------------------- ;[[U]]
ClearAimTarget  .proc
;ClearMissile2   .proc
                pha

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

                ;.frsSpriteClear 10      ; aim target
                ;.frsSpriteHide 10

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                pla
                rts
                .endproc

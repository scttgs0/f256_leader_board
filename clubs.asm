
;======================================
;
;====================================== ;[[V]]
GetUserInput    .proc
                stz joystick            ; no input
                jsr ReadJoystick

                lda #joyButton0         ; button pushed?
                bit joystick
                beq _XIT                ;   no

                ldx #xformDELTA_Z
                jsr VertexTransform

                txa
                clc
                adc xPosDeltaBall
                sta xPosBallShadow

                tya
                clc
                adc yPosDeltaBall
                sta yPosBallShadow

                lda #TRUE
                sta isSwingInProgress

                ;;jsr ClearMissile0       ; clear the aim target
                jmp ClearAimTarget

; - - - - - - - - - - - - - - - - - - -
_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[V]]
ChangeClub      .proc
;   check delay timer
                lda timerIsActive+1     ; timer 1 active?
                beq _1                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_1              sta joystick            ; reset
                jsr ReadJoystick

                lda #joyUP              ; up deflection?
                bit joystick
                beq _2                  ;   no

;   /// UP ///
                dec activeClub
                bpl _4                  ; no overflow

                lda #$0C                ; overflow, wrap around to the pitching wedge
                sta activeClub

                bra _4

; - - - - - - - - - - - - - - - - - - -
_2              lda #joyDOWN            ; down deflection?
                bit joystick
                bne _3                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
;   /// DOWN ///
_3              inc activeClub
                lda activeClub
                cmp #$0D                ; too far?
                bne _4                  ;   no, we're good

                stz activeClub          ; wrap around to the 1-wood

_4              jsr DrawClub

;   set delay timer to introduce a pause before allowing further club changes
                lda #$18                ; duration
                ldx #$01                ; timer 1
                jsr SetTimer

;   record the club change
                ldx activePlayer
                lda activeClub
                sta playerClub,X

;   play sound
                jmp PlaySoundInputAction

                .endproc


;======================================
;
;====================================== ;[[V]]
DrawClub        .proc
                ldx #stagePLAY
                stx nStage

;   clone the active club text into _activeClub
                lda activeClub
                asl                     ; *2
                pha                     ; preserve

                tax
                lda _golfclub,X         ; first character
                sta _activeClub

                pla                     ; restore
                tax

                lda _golfclub+1,X       ; second character
                sta _activeClub+1

;   render the text
                .frsTextXY 37,17,$90,DrawClub._activeClub

                rts

;--------------------------------------

_activeClub     .null '1W'

_golfclub       .text '1W'              ; [0]
                .text '3W'              ; [1]
                .text '5W'              ; [2]
                .text '1I'              ; [3]
                .text '2I'              ; [4]
                .text '3I'              ; [5]
                .text '4I'              ; [6]
                .text '5I'              ; [7]
                .text '6I'              ; [8]
                .text '7I'              ; [9]
                .text '8I'              ; [A]
                .text '9I'              ; [B]
                .text 'PW'              ; [C]

                .endproc


;======================================
;
;====================================== ;[[F]]
AudioSwingControl .proc
                lda isSwingInProgress   ; swing anim in progress?
                bne _1                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              lda timerIsActive       ; timer 0 active?
                beq _2                  ;   no

                rts

; - - - - - - - - - - - - - - - - - - -
_2              inc golferSwingFrame
                ldx golferSwingFrame
                cpx #$20                ; =32?
                bne _3                  ;   no

                lda #FALSE              ; stop swing animation
                sta isSwingInProgress

                lda #$FF
                sta golferSwingFrame

                rts

; - - - - - - - - - - - - - - - - - - -
_3              lda tblDuration,X       ; duration
                ldx #$00                ; timer #0
                jsr SetTimer

                ldx golferSwingFrame
                cpx #$01
                bne _4
                jmp SetAudSwingPwr

; - - - - - - - - - - - - - - - - - - -
_4              cpx #$0A                ; max backswing
                bne _5
                jmp SetAudSwingEnd

; - - - - - - - - - - - - - - - - - - -
_5              cpx #$0B
                bne _6
                jmp SetAudSwingTmg

; - - - - - - - - - - - - - - - - - - -
_6              cpx #$10
                bne _7
                jmp SetAudSwingEnd

; - - - - - - - - - - - - - - - - - - -
_7              cpx #$11
                bne _8
                jmp SetAudSwingSnap

; - - - - - - - - - - - - - - - - - - -
_8              cpx #$16
                bne _XIT
                jmp SetAudSwingEnd

; - - - - - - - - - - - - - - - - - - -
_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[F]]
SetAudSwing     .proc
                sei

                jsr DisableTimer2

                jsr PlayClubSwing

                lda #gaugeINACTIVE
                sta gaugeStage

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SetAudSwingPwr  .proc
                sei

                jsr DisableTimer2

                lda #$00
                sta gaugeValue          ; reset

                jsr PlayClubSwing

                lda #gaugeASCENDING
                sta gaugeStage          ; = Power Increasing

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SetAudSwingTmg  .proc
                sei

                jsr DisableTimer2

                lda #$10
                sta gaugeValue          ; = peak power

                jsr PlayClubSwing

                lda #gaugeDESCENDING
                sta gaugeStage          ; = Power Decreasing

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SetAudSwingSnap .proc
                sei

                jsr DisableTimer2

                lda #$20
                sta gaugeValue          ; beginning of snap

                jsr PlayClubSwing

                lda #gaugeSNAP
                sta gaugeStage

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SetAudSwingEnd  .proc
                sei

                jsr DisableTimer2

                ldx gaugeStage
                dex                     ; clamp to range[0:2]

                lda gaugeValue
                sta cacheGaugeValue,X

                cpx #$02                ; =snap?
                bne _1                  ;   no

                jsr SetAudSwing

_1              cli
                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
DisableTimer2   .proc
                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
PlayClubSwing   .proc
                rts
                .endproc

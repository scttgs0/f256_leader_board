
;======================================
;
;======================================
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
                adc xPosDeltaMissile0
                sta xPosBallShadow

                tya
                clc
                adc yPosDeltaMissile0
                sta yPosBallShadow

                lda #TRUE
                sta isSwingInProgress

                jsr ClearMissile0
                jmp ClearMissile2

; - - - - - - - - - - - - - - - - - - -
_XIT            rts
                .endproc


;======================================
;
;======================================
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
                ;lda #$18                ; duration
                lda #$01                ; duration
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
;======================================
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
;======================================
AudioSwingControl .proc
                rts
                .endproc


;======================================
;
;======================================
SetAudSwing     .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
SetAudSwingPwr  .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
SetAudSwingTmg  .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
SetAudSwingSnap .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
SetAudSwingEnd  .proc
                rts
                .endproc


;======================================
;
;======================================
DisableTimer2   .proc
                rts
                .endproc


;======================================
;
;======================================
PlayClubSwing   .proc
                rts
                .endproc

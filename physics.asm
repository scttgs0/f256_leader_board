
;======================================
;
;======================================
CourseTransformA .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
CourseTransformB .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A           playerWindDirection_LO
;   Y           playerWindDirection_HI
; on exit:
;   X           sign  (0=pos, -1=neg)
;======================================
PhysicsCosine_1E98 .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

physicsSign_00_FF   .byte $00
                    .byte $00
physicsSign2_00_FF  .byte $00

savePhysicsY        .word $0000
physicsCosine       .word $0000


;======================================
;
;--------------------------------------
; on entry:
;   A           playerWindDirection_LO
;   Y           playerWindDirection_HI
; on exit:
;   A:Y         result
;   X           sign  (0=pos, -1=neg)
;======================================
PhysicsSubtract4000 .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

tblCosine       .word $7FFF,$7FF6,$7FD8,$7FA7
                .word $7F62,$7F09,$7E9D,$7E1E
                .word $7D8A,$7CE4,$7C2A,$7B5D
                .word $7A7D,$798A,$7885,$776C
                .word $7642,$7504,$73B6,$7255
                .word $70E3,$6F5F,$6DCA,$6C24
                .word $6A6E,$68A7,$66CF,$64E9
                .word $62F2,$60EC,$5ED7,$5CB4
                .word $5A82,$5843,$55F6,$539B
                .word $5134,$4EC0,$4C40,$49B4
                .word $471D,$447B,$41CE,$3F17
                .word $3C57,$398D,$36BA,$33DF
                .word $30FC,$2E11,$2B1F,$2827
                .word $2528,$2224,$1F1A,$1C0C
                .word $18F9,$15E2,$12C8,$0FAB
                .word $0C8C,$096B,$0648,$0324
                .word $0000


;======================================
;
;--------------------------------------
; on entry:
;   A           playerWindDirection_LO
;               windDirThisHole_LO
;   Y           playerWindDirection_HI
;               windDirThisHole_HI
; on exit:
;   A:Y         value:word
;   X           sign
;======================================
PhysicsCosine_m4000 .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

physicsX1_sign  .byte $00               ; 0=pos, -1=neg
physicsX0_sign  .byte $00               ; 0=pos, -1=neg

physicsY0       .word $0000
physicsY1       .word $0000

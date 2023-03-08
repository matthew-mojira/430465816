;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ERROR HANDLER
;; prints error and terminates machine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

error:
    PHP

    SEP #$20    ; 8-bit A

    LDA #$65
    STA !tilemap+$52
    LDA #$72
    STA !tilemap+$54
    STA !tilemap+$56 ; ascii "err"

    LDA #$80
    STA !INIDISP; begin F-blank

    JSL dma_tilemap  ; force display

    LDA #$0F
    STA !INIDISP; end F-blank

    PLP
    RTL

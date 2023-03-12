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

    ; palette
    STZ !CGADD
    ; pal transfer (no DMA, hardcoded few colors)
    STZ !CGDATA
    STZ !CGDATA
    LDA #%11111111
    STA !CGDATA
    LDA #%00011100
    STA !CGDATA

    JSL dma_tilemap  ; force display

    LDA #$0F
    STA !INIDISP; end F-blank

    PLP
    RTL

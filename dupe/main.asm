;;    START OF RUNTIME SYSTEM
ORG $C10000


main:
    PHP
    REP #$30  ; 16-bit AXY

    ; clear tilemap

    LDA #$0080
    LDX #$0800
-   STA $7E2000,X
    DEX #2
    BNE -
    STA $7E2000

    ; CALL THE COMPILED CODE!!
    JSL entry

    ;; New for Dupe: First we must check the types...
    BIT.W #%1   ; get just the last bit (0 =int, 1 = bool)
    BEQ .convert_integer

.convert_boolean:
    CMP.W #%11    ; false
    SEP #$20      ; 8-bit A
    BNE +

    ; false
    LDA #$0F      ; character F
    STA $7E2042
    BRA .display

+   ; true
    LDA #$1D      ; character T
    STA $7E2042
    BRA .display

.convert_integer:
    ; Hex2Dec routine
    ; assuming numbers are unsigned right now...
    ; and storing them in the tilemap area
    LSR           ; bit shift right 1 for integers
    LDX.W #10

-   STA !WRDIVL   ; store in dividend
    SEP #$20      ; 8-bit A
    LDA #10
    STA !WRDIVB   ; store in divisor, also starts process
    NOP #8        ; need to wait 16 cycles
    LDA !RDMPYL   ; remainder of the division by 10
    STA $7E2042,X ; store in digit
    REP #$20      ; 16-bit A
    LDA !RDDIVL   ; result of the division

    DEX #2
    BNE -

.display:
    JSL DrawTilemap

    PLP
    RTL


DrawTilemap:
    ; display stuff now!
    ; DMA tilemap
    PHP

    SEP #$20
    REP #$10

    LDA #$80
    STA !INIDISP  ; begin F-blank

    STA !VMAIN
    LDX.W #$1000
    STX !VMADDL

    LDA.B #$7E
    STA $4304
    LDX.W #$2000
    STX $4302
    LDA #$18
    STA $4301
    LDY #$0800
    STY $4305
    LDA #$01
    STA $4300
    LDA #$01
    STA $420B

    LDA #$0F
    STA !INIDISP  ; end F-blank

    PLP
    RTL


initialize:
    PHP
    SEP #$20
    REP #$10

    LDA #$80
    STA !INIDISP    ; begin F-blank

    LDA #$10
    STA.W !BG1SC
    LDA #$14
    STA.W !BG2SC
    LDA #$18
    STA.W !BG3SC

    STZ.W !BG12NBA
    LDA #$01
    STA.W !BG34NBA

    JSL UploadGraphics

    STZ !BG1VOFS
    STZ !BG1VOFS
    ; more background scroll?

    ; set background mode
    LDA #1
    STA !BGMODE
    LDA #1
    STA !TM ; enable BG1 main screen

    LDA #$81
    STA $4200
    LDA #$0F
    STA !INIDISP    ; end F-blank

    PLP
    RTL

UploadGraphics:
    PHP
    SEP #$20
    REP #$10

    ; gfx

    LDA #$80
    STA !VMAIN
    LDX.W #$0000
    STX !VMADDL

    ; gfx dma

    LDA.B #$D0
    STA $4304
    LDX.W #$0000
    STX $4302
    LDA #$18
    STA $4301
    LDY.W #$2800
    STY $4305
    LDA #$01
    STA $4300
    STA $420B   ; DMA enable

    ; palette

    STZ $2121

    ; pal dma

    LDA.B #$D1
    STA $4304
    LDX.W #$0000
    STX $4302
    LDA #$22
    STA $4301
    LDY #$0200
    STY $4305
    STZ $4300
    LDA #$01
    STA $420B   ; DMA enable

    PLP
    RTL

vblank:
    RTL

ORG $D00000
incbin "gfx.bin"

ORG $D10000
incbin "pal.pal"

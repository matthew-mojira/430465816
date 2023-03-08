;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN ENTRY LOOP
;; runs compiled code and prints result
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
    PHP
    JSL initialize    ; note: this code is only called once here, so it could
                      ; be inlined for efficiency. but not doing it yet

    REP #$30  ; 16-bit AXY

    ; CALL THE COMPILED CODE!!
+   JSL entry

    ;; New for Dupe: First we must check the types...
    BIT.W #%01   ; get just the last bit (0 =int, 1 = bool)
    BEQ .convert_integer
    BIT.W #%10  ; get the second-to-last bit
    BEQ .convert_character

    CMP.W #!val_false
    BEQ .print_false
    CMP.W #!val_true
    BEQ .print_true
    CMP.W #!val_void
    BEQ .print_void
    CMP.W #!val_eof
    BEQ .print_eof

.print_eof:
    SEP #$20      ; 8-bit A
    LDA #$85      ; character (EOF)
    STA !tilemap+$42
    BRA .done

.print_void:
    SEP #$20      ; 8-bit A
    LDA #$84      ; character (V)
    STA !tilemap+$42
    BRA .done

.print_false:
    SEP #$20      ; 8-bit A
    LDA #$82      ; character (F)
    STA !tilemap+$42
    BRA .done

.print_true:
    SEP #$20      ; 8-bit A
    LDA #$83      ; character (T)
    STA !tilemap+$42
    BRA .done

.convert_character:
    LSR #!char_shift
    SEP #$20
    STA !tilemap+$44
    BRA .done

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
    ADC #$30      ; convert to ASCII
    STA !tilemap+$42,X ; store in digit
    REP #$20      ; 16-bit A
    LDA !RDDIVL   ; result of the division

    DEX #2
    BNE -

.done:
    SEP #$20      ; 8-bit A

    LDA #$80
    STA !INIDISP  ; begin F-blank

    JSL dma_tilemap

    LDA #$0F
    STA !INIDISP  ; end F-blank

    PLP
    RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INITIALIZATION SEQUENCE
;; prepares graphics/PPU registers for display
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

initialize:
    PHP

    SEP #$20
    REP #$10

    LDA #$01
    STA !NMITIMEN   ; disable NMI interrupt (we're running main game loop)

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

    JSL upload_graphics

    STZ !BG1VOFS
    STZ !BG1VOFS
    ; more background scroll?

    ; set background mode
    LDA #1
    STA !BGMODE
    LDA #1
    STA !TM ; enable BG1 main screen

    ; clear tilemap
    REP #$30

    LDA #$0080
    LDX #$0800
-   STA !tilemap,X
    DEX #2
    BNE -
    STA !tilemap

    ; import tilemap from file
    SEP #$20      ; 8-bit A

    LDX.W #TilemapData
    STX $4302
    LDA.B #<:TilemapData
    STA $4304
    LDX #!TilemapSize
    STX $4305
    LDX.W #!tilemap
    STX $2181
    LDA.B #<:!tilemap
    STA $2183
    LDA #$80
    STA $4301
    STZ $4300
    LDA #$01
    STA $420B

    LDA #$81
    STA $4200
    LDA #$0F
    STA !INIDISP    ; end F-blank

    ; set up pointer for drawing text to screen
    LDA.B #<:!tilemap
    LDX.W #!tilemap+$C2
    STA !draw_pointer+2
    STX !draw_pointer

    LDX #$2682
    STA !read_pointer+2
    STX !read_pointer

    PLP
    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UPLOAD GRAPHICS ROUTINE
;; uploads the ASCII graphics and the palette to VRAM/CGRAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

upload_graphics:
    PHP
    SEP #$20
    REP #$10

    ; gfx

    LDA #$80
    STA !VMAIN
    LDX.W #$0000
    STX !VMADDL

    ; gfx dma

    LDA.B #<:GraphicsData
    STA $4304
    LDX.W #GraphicsData
    STX $4302
    LDA #$18
    STA $4301
    LDY.W #!GraphicsSize
    STY $4305
    LDA #$01
    STA $4300
    STA $420B   ; DMA enable

    ; palette

    STZ $2121

    ; pal dma

    LDA.B #<:CGData
    STA $4304
    LDX.W #CGData
    STX $4302
    LDA #$22
    STA $4301
    LDY.W #!CGSize
    STY $4305
    STZ $4300
    LDA #$01
    STA $420B   ; DMA enable

    PLP
    RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TILEMAP UPLOAD ROUTINE
;; uploads tilemap from copy in RAM to VRAM
;; F-Blank is not enabled here, so you will have to do it yourself
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dma_tilemap:
    ; display stuff now!
    ; DMA tilemap
    PHP

    SEP #$20      ; A 8-bit
    REP #$10      ; XY 16-bit

    LDA #$80
    STA !VMAIN
    LDX.W #$1000
    STX !VMADDL

    LDA.B #<:!tilemap
    STA $4304
    LDX.W #!tilemap
    STX $4302
    LDA #$18
    STA $4301
    LDY #$0800
    STY $4305
    LDA #$01
    STA $4300
    LDA #$01
    STA $420B

    PLP
    RTL

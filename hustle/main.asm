;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN ENTRY LOOP
;; runs compiled code and prints result
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
    PHP
    JSL initialize    ; note: this code is only called once here, so it could
                      ; be inlined for efficiency. but not doing it yet

    REP #$10  ; 16-bit XY
    SEP #$20  ; 8-bit A

    LDA #$7E
    LDX #$8000

    STA !HEAP+2     ; set up heap pointer
    STX !HEAP
    STA !DEREF+2    ; set up dereferencing area

    REP #$30  ; 16-bit AXY

    ; CALL THE COMPILED CODE!!
+   JSL entry

    ;; PRINT RESULT VALUE
    LDX.W #$42     ; offset into tilemap kept in registers (sigh...)

    JSR print_value

    SEP #$20      ; 8-bit A

    LDA #$80
    STA !INIDISP  ; begin F-blank

    ; palette
    STZ !CGADD
    ; pal transfer (no DMA, hardcoded few colors)
    STZ !CGDATA
    STZ !CGDATA
    LDA #%11100111
    STA !CGDATA
    LDA #%00011111
    STA !CGDATA

    JSL dma_tilemap

    LDA #$0F
    STA !INIDISP  ; end F-blank

    PLP
    RTL

; Note to self: in the hustle language we modified this greatly, making the
; result expression window a true printable area instead of hardcoding types to
; be printed in this area, except err :(

print_value:

macro deref()
    ; convert pointer
    REP #$20      ; 16-bit A
    STY !DEREF
    SEC
    ROR !DEREF
    LSR !DEREF
    ASL !DEREF
    ; dereference
    LDA [!DEREF]   ; dereference
endmacro

macro put_tilemap(imm)
    SEP #$20      ; 8-bit A
    LDA.B <imm>
    STA !tilemap,X
    INX #2
endmacro

    ; check immediates: get the last 2 bits
-   BIT.W #%11
    BEQ .convert_immediate

    TAY
    AND.W #!ptr_type_mask
    CMP.W #!box_type_tag
    BEQ .convert_box
    CMP.W #!cons_type_tag
    BEQ .convert_cons

    BRK #$00    ; type error

.convert_box:
    %put_tilemap(#$87)
    %deref()

    JMP print_value   ; wow! tail recursion!

.convert_cons:
    %deref()
    PHY
    JSR print_value
    PLY

    %put_tilemap(#$90)

    INY #2
    %deref()

    JMP print_value   ; wow! tail recursion!

.convert_immediate:
    BIT.W #%100
    BEQ .convert_integer

    CMP.W #!val_false
    BEQ .print_false
    CMP.W #!val_true
    BEQ .print_true
    CMP.W #!val_void
    BEQ .print_void
    CMP.W #!val_eof
    BEQ .print_eof
    CMP.W #!val_empty
    BEQ .print_empty

    BRA .convert_character

    ; TODO invalid character

.print_eof:
    %put_tilemap(#$85)
    RTS

.print_void:
    %put_tilemap(#$84)
    RTS

.print_false:
    %put_tilemap(#$82)
    RTS

.print_true:
    %put_tilemap(#$83)
    RTS

.print_empty:
    %put_tilemap(#$91)
    RTS

.print_invalid:
    %put_tilemap(#$81)
    RTS

.convert_character:
    LSR #!char_shift    ; the actual character
    CMP.W #$80
    BCS .print_invalid

    PHA         ; preseve char
    %put_tilemap(#$86)

    REP #$20
    PLA
    SEP #$20
    STA !tilemap,X
    INX #2
    RTS

.convert_integer:
    ; Hex2Dec routine
    ; assuming numbers are unsigned right now...
    ; and storing them in the tilemap area
    LSR #!int_shift
    BEQ .zero
    LDY.W #10

-   STA !WRDIVL   ; store in dividend
    SEP #$20      ; 8-bit A
    LDA #10
    STA !WRDIVB   ; store in divisor, also starts process
    NOP #8        ; need to wait 16 cycles
    LDA !RDMPYL   ; remainder of the division by 10
    ADC #$30      ; convert to ASCII
    STA.W $00,Y   ; store in SCRATCH!
    REP #$20      ; 16-bit A
    LDA !RDDIVL   ; result of the division

    DEY #2
    BNE -

    ; move scratch to tilemap
    LDY.W #0
    ; get rid of trailing zeros
-   LDA.W $02,Y
    CMP.W #$0030
    BNE +
    INY #2
    BRA -
+
-   LDA.W $02,Y
    STA !tilemap,X
    INX #2
    INY #2
    CPY.W #$0A
    BNE -

    RTS

.zero:
    %put_tilemap(#$30)
    RTS

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
    STZ !CGADD

    ; pal transfer (no DMA, hardcoded few colors)
    STZ !CGDATA
    STZ !CGDATA
    LDA #%11101100
    STA !CGDATA
    LDA #%01111101
    STA !CGDATA

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

incsrc "types.asm"
incsrc "ram.asm"

;;    START OF RUNTIME SYSTEM
ORG $C10000


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN ENTRY LOOP
;; runs compiled code and prints result
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
    PHP
    REP #$30  ; 16-bit AXY

;    LDA !con1ff
;    AND.W #$10            ; Z
;    BEQ +
;    LDX.W #$0065          ;char e
;    JSL putchar
;+
;    LDA !con1ff
;    AND.W #$20            ; A
;    BEQ +
;    JSL getchar
;+
    LDA !main_already_run   ; just make it 16bit lol
    BEQ +     ; do not run entry if already run once before

    PLP
    RTL       ; if already done before, let's not do this again
      ; (later in Evildoer we will be refactoring this entirely)

    ; CALL THE COMPILED CODE!!
+   JSL entry
    INC !main_already_run

    ;; New for Dupe: First we must check the types...
    BIT.W #%01   ; get just the last bit (0 =int, 1 = bool)
    BEQ .convert_integer
    BIT.W #%10  ; get the second-to-last bit
    BEQ .convert_character
    ;BRA .convert_boolean

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
    STA $7E2042
    BRA .done

.print_void:
    SEP #$20      ; 8-bit A
    LDA #$84      ; character (V)
    STA $7E2042
    BRA .done

.print_false:
    SEP #$20      ; 8-bit A
    LDA #$82      ; character (F)
    STA $7E2042
    BRA .done

.print_true:
    SEP #$20      ; 8-bit A
    LDA #$83      ; character (T)
    STA $7E2042
    BRA .done

.convert_character:
    LSR #!char_shift
    SEP #$20
    STA $7E2044
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
    ADC #$30      ; convert ot ASCII
    STA $7E2042,X ; store in digit
    REP #$20      ; 16-bit A
    LDA !RDDIVL   ; result of the division

    DEX #2
    BNE -

.done:
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

    ; clear tilemap
    REP #$30

    LDA #$0080
    LDX #$0800
-   STA $7E2000,X
    DEX #2
    BNE -
    STA $7E2000
    ; import tilemap from file

    SEP #$20

    LDX #$0000
    STX $4302
    LDA #$D2
    STA $4304
    LDX #$0700
    STX $4305
    LDX #$2000
    STX $2181
    LDA #$7E
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
    LDA #$7E
    LDX #$20C2
    STA !draw_pointer+2
    STX !draw_pointer

    LDX #$2682
    STA !read_pointer+2
    STX !read_pointer

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
    PHP
    SEP #$20    ; 8-bit A

    LDA #$80
    STA !INIDISP  ; begin F-blank
    NOP #30       ; don't check polling finished before polling even begins

-   LDA !HVBJOY ; auto-joypad status (on at start of V-blank, clear if done)
    AND #%00000001
    BNE -       ; wait if not complete

    ; get first frame controller information
    ; L = axlr0000
    ; H = byetUDLR

    REP #$30      ; 16-bit AXY

    LDA !JOY1L    ; controller 1
    TAX
    STA !con1ff
    LDA !con1
    TRB !con1ff
    STX !con1

    LDA !JOY2L    ; controller 2  (5)
    TAX
    STA !con2ff
    LDA !con2
    TRB !con2ff
    STX !con2

    LDA !JOY3L    ; controller 3  (2)
    TAX
    STA !con3ff
    LDA !con3
    TRB !con3ff
    STX !con3

    LDA !JOY4L    ; controller 4  (6)
    TAX
    STA !con4ff
    LDA !con4
    TRB !con4ff
    STX !con4

    ; keyboard needs 13 + 13 + 12 + 11 (no RShift) = 49 (one too many!)

    ; send over tilemap
    JSL DMATilemap

    SEP #$20

    LDA #$0F
    STA !INIDISP  ; end F-blank

    PLP
    RTL


DMATilemap:
    ; display stuff now!
    ; DMA tilemap
    PHP

    SEP #$20
    REP #$10

    LDA #$80
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

    PLP
    RTL


incsrc "io.asm"


ORG $D00000
incbin "ascii.bin"    ; GFX is now ASCII

ORG $D10000
incbin "pal.pal"

ORG $D20000
incbin "tilemap.bin"

; Places a character on the screen
; A - the character to be put on the screen
write_byte:
    PHP
    SEP #$20    ; 8 bit A
    REP #$30    ; 16bit AXY

    LSR #!int_shift
    TAX   ; A -> X

    CPX.W #$10    ; newline character
    BNE +

    ; newline move the draw pointer
    LDA !draw_pointer
    AND #$FFC0
    ADC.W #$0041
    STA !draw_pointer
    BRA .ret

    ; draw the character
+   TXA
    STA [!draw_pointer]   ;put on tilemap
    INC !draw_pointer     ; \
    INC !draw_pointer     ; / advance tilemap

    ; check if we need to wrap to next line
    LDA !draw_pointer
    AND.W #$3F
    CMP.W #$3E
    BNE .ret
    rep 4 : INC !draw_pointer

.ret:
    ; return void
    LDA.W #!val_void
    PLP
    RTL


read_byte:
!REFRESH_LENGTH = #100
    PHP

    SEP #$20    ; 8bit A
    REP #$10    ; 16bit XY

    ; check if the buffer already has a character
    LDA $7E2682 ; magic!
    CMP #$80  ; empty tile
    BNE .break  ; buffer is nonempty, so go get the character

    ; buffer empty, prompt user for typein
    LDA #$81        ; enable NMI
    STA !NMITIMEN   ; enable NMI interrupt and autojoypad

    LDA !REFRESH_LENGTH/2+4   ; init cursor timer
    STA !cursor_timer

    ; reset read pointer to front
    LDX #$2682
    LDA #$7E
    STX !read_pointer
    STA !read_pointer+2

    REP #$30    ; 16bit A

    ; loop
-   JSR .controller2ascii
    BIT #$1000
    BNE .break

    ; cursor
    SEP #$20
    DEC !cursor_timer
    BNE +
    LDA !REFRESH_LENGTH
    STA !cursor_timer
    LDA #$80
    STA [!read_pointer]

+   LDA !cursor_timer
    CMP !REFRESH_LENGTH/2
    BNE +
    LDA #$81
    STA [!read_pointer]
+   REP #$20

    WAI
    BRA -

.break:
    SEP #$20    ; 8 bit A
    LDA #$01        ; disable NMI
    STA !NMITIMEN   ; disable NMI interrupt

    ; get character
    REP #$30    ; 16bit AXY
    LDA $7E2682 ; magic!
    PHA         ; store result

    ; move everything up
    PHB       ; store data Bank register
    LDX #$2684  ; src
    LDY #$2682  ; dest
    LDA.W #57   ; number of bytes -1
    MVN $7E,$7E
    PLB       ; retrieve data Bank register

    ; flush a new empty character in at the back
    LDA.W #$0080
    STA $7E2682+58

    ; retrieve stored result and return
    PLA     ; result
    ASL #!int_shift  ; convert to TYPES
    PLP
    RTL

.controller2ascii:
!CONTROLLER_B = #1<<15
!CONTROLLER_Y = #1<<14
!CONTROLLER_SELECT = #1<<13
!CONTROLLER_START = #1<<12
!CONTROLLER_UP = #1<<11
!CONTROLLER_DOWN = #1<<10
!CONTROLLER_LEFT = #1<<9
!CONTROLLER_RIGHT = #1<<8
!CONTROLLER_A = #1<<7
!CONTROLLER_X = #1<<6
!CONTROLLER_LT = #1<<5
!CONTROLLER_RT = #1<<4
!ASCII_A = #$41
!ASCII_C = #$43
!ASCII_X = #$58
!ASCII_a = #$61
!ASCII_c = #$63
!ASCII_x = #$78
!ASCII_NEWLINE = #$10
macro checkinput(input, char, shift)  ; todo SHIFT
    BIT.W <input>
    BEQ +
    LDX.W <char>
    JSR .putchar_prompt
+
endmacro
    LDA !con1ff
    %checkinput(!CONTROLLER_B, !ASCII_c, !ASCII_C)
    %checkinput(!CONTROLLER_Y, !ASCII_x, !ASCII_X)
    %checkinput(!CONTROLLER_START, !ASCII_NEWLINE, !ASCII_NEWLINE)
    STZ !con1ff
    RTS

; this routine preserves A
.putchar_prompt:
    PHA
+   TXA
    STA [!read_pointer]   ;put on tilemap
    LDA !read_pointer     ; lower 16 bits
    CMP #$26BC
    BEQ +                 ;if at end of line, don't advance pointer (oof)
    INC !read_pointer     ; \
    INC !read_pointer     ; / advance tilemap
+
    SEP #$20
    LDA !REFRESH_LENGTH/2+6
    STA !cursor_timer
    REP #$20
    PLA
    RTS

peek_byte:
    PHP
    REP #$20    ; 16bit A

    ; check if the buffer already has a character
    LDA $7E2682 ; magic!
    AND.W #$00FF  ; get lower 8 only (we need to rethink this; it should never)
    CMP.W #$0080 ; EOF
    BNE +
    LDA.W #!val_eof
    PLP
    RTL

+   ASL #!int_shift
    PLP
    RTL

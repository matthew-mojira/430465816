incsrc "ascii.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; WRITE BYTE
;; Places a character on the screen
;; A - the character to be put on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


write_byte:
    PHP
    SEP #$20    ; 8 bit A
    REP #$30    ; 16bit AXY

    LSR #!int_shift
    TAX   ; A -> X

    CPX.W !ASCII_NEWLINE    ; newline character
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; READ BYTE
;; does stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read_byte:
!REFRESH_LENGTH = #100
!FRONT_BUFFER #= !tilemap+$682
    PHP

    SEP #$20    ; 8bit A
    REP #$10    ; 16bit XY

    ; check if the buffer already has a character
    LDA !FRONT_BUFFER ; magic!
    CMP #$80  ; empty tile
    BNE .break  ; buffer is nonempty, so go get the character

    ; buffer empty, prompt user for typein
    LDA #$81        ; enable NMI
    STA !NMITIMEN   ; enable NMI interrupt and autojoypad

    LDA !REFRESH_LENGTH/2+4   ; init cursor timer
    STA !cursor_timer

    ; reset read pointer to front
    LDX.W #!FRONT_BUFFER
    LDA.B #<:!FRONT_BUFFER
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
    LDA !FRONT_BUFFER ; magic!
    PHA         ; store result

    ; move everything up
    PHB       ; store data Bank register
    LDX.W #!FRONT_BUFFER+2  ; src
    LDY.W #!FRONT_BUFFER  ; dest
    LDA.W #57   ; number of bytes -1
    MVN <:!FRONT_BUFFER,<:!FRONT_BUFFER
    PLB       ; retrieve data Bank register

    ; flush a new empty character in at the back
    LDA.W #$0080
    STA.W !FRONT_BUFFER+58

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
    %checkinput(!CONTROLLER_A, !ASCII_d, !ASCII_D)
    %checkinput(!CONTROLLER_X, !ASCII_s, !ASCII_S)
    %checkinput(!CONTROLLER_LT, !ASCII_a, !ASCII_A)
    %checkinput(!CONTROLLER_RT, !ASCII_z, !ASCII_Z)
    %checkinput(!CONTROLLER_START, !ASCII_NEWLINE, !ASCII_NEWLINE)
    STZ !con1ff
    RTS

; this routine preserves A
.putchar_prompt:
    PHA
+   TXA
    STA [!read_pointer]   ;put on tilemap
    LDA !read_pointer     ; lower 16 bits
    CMP.W #!FRONT_BUFFER+$3A
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PEEK BYTE
;; does stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

peek_byte:
    PHP
    REP #$20    ; 16bit A

    ; check if the buffer already has a character
    LDA !FRONT_BUFFER ; magic!
    AND.W #$00FF  ; get lower 8 only (we need to rethink this; it should never)
    CMP.W #$0080 ; EOF
    BNE +
    LDA.W #!val_eof
    PLP
    RTL

+   ASL #!int_shift
    PLP
    RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VBLANK ROUTINE
;; does stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    JSL dma_tilemap

    SEP #$20

    LDA #$0F
    STA !INIDISP  ; end F-blank

    PLP
    RTL


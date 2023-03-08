fastrom
hirom

;;    OTHER IMPORTANT FILES

incsrc "defines.asm"
incsrc "main.asm"
incsrc "comp.asm"

;;    ROM HEADER INFORMATION

ORG $00FFB0
    db    "  "        ; MAKER CODE (2 Bytes)
    db    "MGL "      ; GAME CODE (4 Bytes)
    db    $00, $00, $00, $00, $00, $00, $00    ; hardcoded
    db    $00         ; EXPANSION RAM SIZE
    db    $00         ; SPECIAL VERSION (normally $00)
    db    $00         ; CARTRIDGE SUB-NUMBER (normally $00)
    db    "CMSC 430 DUPE        "    ; GAME TITLE (21 Bytes)
          ;|-------------------|;
    db    $31         ; MAP MODE (fastrom, hirom)
    db    $00         ; CARTRIDGE TYPE (ROM only)
    db    $0C         ; ROM SIZE (2^7 KB = 128KB) -- corresponds to bank C0-C1
    db    $00         ; RAM SIZE (0 means 0KB)
    db    $01         ; DESTINATION CODE (north america)
    db    $33         ; hardcoded
    db    $00         ; MASK ROM VERSION (Ver 1.0)

;;    INTERRUPT VECTOR INFORMATION

ORG $00FFE0
    ;;  N/A    N/A    COP    BRK   ABORT   NMI    RESET    IRQ
    dw $0000, $0000, $0000, $0000, $0000, I_NMI, I_RESET, I_IRQ      ; NATIVE
    dw $0000, $0000, $0000, $0000, $0000, I_NMI, I_RESET, I_IRQ      ; EMULATION

;;    INITIALIZATION ROUTINES

ORG $C08000     ; hirom bank starts at $C00000
I_RESET:
    CLC         ; clear carry flag
    XCE         ; exchange carry and emulation (this turns off emulation mode)
    ROL !MEMSEL ; rotate left cycle speed designation (3.58MHz => 2.68MHz?)
                ; Technically this seems to be overwritten by ClearRegs
    JML F_RESET
F_RESET:
    REP #$30    ; accumulator 16-bit
    LDX #$1FFF
    TXS         ; initialize stack pointer
    JSL ClearRegs
    JSL ClearMemory
    SEP #$20    ; accumulator 8-bit
    LDA #$C0    ; automatic read of the SNES read the first pair of JoyPads
    STA !WRIO   ; IO Port Write Register
    LDA #$01
    STA !MEMSEL ; sets FastROM (but we do it above?)

    JSL initialize

    ; main game loop

-   LDA #$01
    STA !NMITIMEN   ; disable NMI interrupt (we're running main game loop)

    JSL main

    LDA #$01        ; TEMP KEEP DISABLING NMI
    STA !NMITIMEN   ; enable NMI interrupt and autojoypad
;   ADC $2137   ; latches current scaline (to determine time)

    WAI         ; WAit for Interrupt
    BRA -       ; infinite loop to end code
I_NMI:
    JSL vblank
    LDA !RDNMI  ; read for NMI done
    RTI         ; ReTurn from Interrupt
I_IRQ:
    RTI         ; ReTurn from Interrupt
I_BRK:
-   BRA -

ClearRegs:
    PHP         ; push processor status register

    SEP #$20    ; accumulator 8-bit
    LDA #$80

    ; A = %10000000

    STA $2100   ; screen display register
                ; (a---bbbb: a = disable screen, b = brightness)
    STZ $2101   ; OAM size and data area designation
                ; (aaabbccc: a = size, b = name selection, c = base selection)
    STZ $2102   ; address for accessing OAM
    STZ $2103   ; address for accesting OAM
    STZ $2104   ; OAM data write
    STZ $2105   ;
    STZ $2106
    STZ $2107
    STZ $2108
    STZ $2109
    STZ $210A
    STZ $210B
    STZ $210C
    STZ $210D
    STZ $210D
    STZ $210E
    STZ $210E
    STZ $210F
    STZ $210F
    STZ $2110
    STZ $2110
    STZ $2111
    STZ $2111
    STZ $2112
    STZ $2112
    STZ $2113
    STZ $2113
    STZ $2114
    STZ $2114
    STA $2115
    STZ $2116
    STZ $2117
    STZ $211A
    LDA #$01
    STZ $211B
    STA $211B
    STZ $211C
    STZ $211C
    STZ $211D
    STZ $211D
    STZ $211E
    STA $211E
    STZ $211F
    STZ $211F
    STZ $2120
    STZ $2120
    STZ $2121
    STZ $2123
    STZ $2124
    STZ $2125
    STZ $2126
    STZ $2127
    STZ $2128
    STZ $2129
    STZ $212A
    STZ $212B
    STZ $212C
    STZ $212D
    STZ $212E
    LDA #$30
    STA $2130
    STZ $2131
    LDA #$E0
    STA $2132
    STZ $2133
    STZ $4200
    STZ $4202
    STZ $4203
    STZ $4204
    STZ $4205
    STZ $4206
    STZ $4207
    STZ $4208
    STZ $4209
    STZ $420A
    STZ $420B
    STZ $420C
;   STZ $420D

    PLP
    RTL

ClearMemory:
    PHP
    PHB
    ;    this line causes crashes PEA $0000
    PHK
    PLB
    SEP #$20
    REP #$10

    STZ $00
    STZ $2115
    LDX.W #0
    STX $2116
    STX $2102
    STZ $2121
    STX $4302
    STX $4312
    STX $4322
    LDA #$7E
    STA $4304
    STA $4314
    STA $4324

    STX $4305
    LDX #$200
    STX $4315
    LDX #$220
    STX $4325

    LDA #$18
    STA $4301
    LDA #$22
    STA $4311
    LDA #$04
    STA $4321

    LDA #$09
    STA $4300
    LDA #$9A
    STA $4310
    STA $4320

    LDA #7
    STA $420B

    ; clear WRAM

    REP #$30
    LDA #$0000
    LDX #$0FFE
-   STA.L $7E0000,X
    STA.L $7E1000-4,X
    STA.L $7E2000,X
    STA.L $7E3000,X
    STA.L $7E4000,X
    STA.L $7E5000,X
    STA.L $7E6000,X
    STA.L $7E7000,X
    STA.L $7E8000,X
    STA.L $7E9000,X
    STA.L $7EA000,X
    STA.L $7EB000,X
    STA.L $7EC000,X
    STA.L $7ED000,X
    STA.L $7EE000,X
    STA.L $7EF000,X
    STA.L $7F0000,X
    STA.L $7F1000,X
    STA.L $7F2000,X
    STA.L $7F3000,X
    STA.L $7F4000,X
    STA.L $7F5000,X
    STA.L $7F6000,X
    STA.L $7F7000,X
    STA.L $7F8000,X
    STA.L $7F9000,X
    STA.L $7FA000,X
    STA.L $7FB000,X
    STA.L $7FC000,X
    STA.L $7FD000,X
    STA.L $7FE000,X
    STA.L $7FF000,X
    DEX #2
    BMI +
    BRL -

+   PLB
    PLP
    RTL

ORG $FFFFFF   ; force full 4KB filesize to prevent emulator issues
  db  $FF

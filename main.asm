;; START OF RUNTIME SYSTEM
ORG $C10000

main:
  PHP
  REP #$30  ; 16-bit AXY

  ; clear tilemap

  LDA #$0010
  LDX #$0800
- STA $7E2000,X
  DEX #2
  BNE -

  ; CALL THE COMPILED CODE!!
  JSL entry

  ; set the tilemaps accordingly to ret value in A
  STA $00
  AND.W #$000F
  STA $7E204A
  LDA $00
  AND.W #$00F0
  LSR #4
  STA $7E2048
  LDA $00
  AND.W #$0F00
  LSR #8
  STA $7E2046
  LDA $00
  AND.W #$F000
  LSR #12
  STA $7E2044

  ; display stuff now!
  ; DMA tilemap
  
  SEP #$20
  REP #$10
  
  LDA #$80
  STA !INIDISP  ; begin F-blank

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
  
  JSL .transfer_graphics

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

.transfer_graphics:
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

  LDA #$01
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

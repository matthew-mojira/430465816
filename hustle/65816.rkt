#lang racket

(provide (all-defined-out))

(define (sequence . xs)
  (foldr (λ (x xs) (if (list? x) (append x xs) (cons x xs))) '() xs))

(struct Label (lbl) #:prefab)
(struct Comment (str) #:prefab)
(struct Org (add) #:prefab)
(struct Rtl () #:prefab)
(struct Lda (imm) #:prefab) ; immediate!
(struct Inc () #:prefab)
(struct Dec () #:prefab)
(struct Cmp (imm) #:prefab)
(struct Beq (lbl) #:prefab)
(struct Bne (lbl) #:prefab)
(struct Bra (lbl) #:prefab)
(struct Bcc (lbl) #:prefab)
(struct Bcs (lbl) #:prefab)
(struct Bit (mask) #:prefab)
(struct And (mask) #:prefab)
(struct Eor (mask) #:prefab)
(struct Ora (mask) #:prefab)
(struct Asl (num) #:prefab)
(struct Lsr (num) #:prefab)
(struct Jsl (lbl) #:prefab)
(struct Tax () #:prefab)
(struct Brk () #:prefab)
(struct Pha () #:prefab) ; for pushing to stk
(struct Ply () #:prefab) ; for pulling from stk
(struct Pla () #:prefab) ; for pulling from stk
(struct Sec () #:prefab) ; go dawgs
(struct Clc () #:prefab) ; avoid bullshit
(struct LdaStk (offset) #:prefab)
(struct AdcStk (offset) #:prefab)
(struct SbcStk (offset) #:prefab)
(struct CmpStk (offset) #:prefab)
(struct StaDir (zp) #:prefab)
(struct StaDirY (zp) #:prefab)
(struct LdaDir (zp) #:prefab)
(struct LdaDirY (zp) #:prefab)
(struct LdaAddr (a) #:prefab)
(struct IncAddr (a) #:prefab)
(struct Rol (num) #:prefab)
(struct Ror (num) #:prefab)
(struct StaZp (addr) #:prefab)
(struct LdxImm (imm) #:prefab)
(struct StxZp (addr) #:prefab)
(struct LdyImm (imm) #:prefab)

(define (instr->string ins)
  (match ins
    [(Org a) (string-append "ORG " a)]
    [(Label l) (string-append l ":")]
    [(Comment s) (string-append ";" s)]
    [(Rtl) "    RTL"]
    [(Lda n) (string-append "    LDA.W #" n)]
    [(Inc) "    INC"]
    [(Dec) "    DEC"]
    [(Tax) "    TAX"]
    [(Cmp i) (string-append "    CMP.W " i)]
    [(Beq l) (string-append "    BEQ " l)]
    [(Bne l) (string-append "    BNE " l)]
    [(Bcc l) (string-append "    BCC " l)]
    [(Bcs l) (string-append "    BCS " l)]
    [(Bra l) (string-append "    BRA " l)]
    [(Jsl l) (string-append "    JSL " l)]
    [(Bit l) (string-append "    BIT.W " l)]
    [(And l) (string-append "    AND.W " l)]
    [(Eor l) (string-append "    EOR.W " l)]
    [(Ora l) (string-append "    ORA.W " l)]
    [(Asl n) (string-append "    ASL #" n)]
    [(Lsr n) (string-append "    LSR #" n)]
    [(Jsl l) (string-append "    JSL " l)]
    [(Brk) (string-append "    BRK #$00")]
    [(Pha) "    PHA"]
    [(Pla) "    PLA"]
    [(Ply) "    PLY"]
    [(Sec) "    SEC"]
    [(Clc) "    CLC"]
    [(LdaStk o) (string-append "    LDA " o ",S")]
    [(AdcStk o) (string-append "    ADC " o ",S")]
    [(SbcStk o) (string-append "    SBC " o ",S")]
    [(CmpStk o) (string-append "    CMP " o ",S")]
    [(StaDir z) (string-append "    STA [" z "]")]
    [(StaDirY z) (string-append "    STA [" z "],Y")]
    [(LdaDir z) (string-append "    LDA [" z "]")]
    [(LdaDirY z) (string-append "    LDA [" z "],Y")]
    [(LdaAddr a) (string-append "    LDA " a)]
    [(IncAddr a) (string-append "    INC " a)]
    [(Rol n) (string-append "    ROL #" n)]
    [(Ror n) (string-append "    ROR #" n)]
    [(StaZp a) (string-append "    STA.B " a)]
    [(LdxImm a) (string-append "    LDX.W #" a)]
    [(LdyImm a) (string-append "    LDY.W #" a)]
    [(StxZp a) (string-append "    STX.B " a)]))

(define (comp->string lst)
  (foldr (lambda (ins rst) (string-append (instr->string ins) "\n" rst))
         ""
         lst))

(define (printer lst)
  (display (comp->string lst)))

(define (genstr s)
  (symbol->string (gensym s)))

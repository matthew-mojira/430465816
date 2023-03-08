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
(struct Bra (lbl) #:prefab)
(struct Bit (mask) #:prefab)
(struct And (mask) #:prefab)
(struct Eor (mask) #:prefab)
(struct Asl (num) #:prefab)
(struct Lsr (num) #:prefab)

(define (instr->string ins)
  (match ins
    [(Org a) (string-append "ORG " a)]
    [(Label l) (string-append l ":")]
    [(Comment s) (string-append ";" s)]
    [(Rtl) "    RTL"]
    [(Lda n) (string-append "    LDA.W #" n)]
    [(Inc) "    INC"]
    [(Dec) "    DEC"]
    [(Cmp i) (string-append "    CMP.W " i)]
    [(Beq l) (string-append "    BEQ " l)]
    [(Bra l) (string-append "    BRA " l)]
    [(Bit l) (string-append "    BIT.W " l)]
    [(And l) (string-append "    AND.W " l)]
    [(Eor l) (string-append "    EOR.W " l)]
    [(Asl n) (string-append "    ASL #" n)]
    [(Lsr n) (string-append "    LSR #" n)]))

(define (comp->string lst)
  (foldr (lambda (ins rst) (string-append (instr->string ins) "\n" rst))
         ""
         lst))

(define (printer lst)
  (display (comp->string lst)))

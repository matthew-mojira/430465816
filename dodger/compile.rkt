#lang racket
(provide (all-defined-out))
(require "ast.rkt"
         "65816.rkt")

;; Expr -> Asm
(define (compile e)
  (sequence (Org "$C20000") (Label "entry") (compile-e e) (Rtl)))

;; Expr -> Asm
(define (compile-e e)
  (match e
    [(Prim1 p e) (compile-prim1 p e)]
    [(Int i) (compile-int i)]
    [(Char c) (compile-char c)]
    [(Bool b) (compile-bool b)]
    [(If e1 e2 e3) (compile-if e1 e2 e3)]))

;; Integer -> Asm
(define (compile-int i)
  (Lda (string-append (~v i) "<<!int_shift")))
(define (compile-char c)
  (Lda (string-append "(("
                      (~v (char->integer c))
                      "<<!char_shift)|!char_type_tag)")))
(define (compile-bool b)
  (if b (Lda "!val_true") (Lda "!val_false")))

;; Expr Expr Expr -> Asm
(define (compile-if e1 e2 e3)
  (let ([false (symbol->string (gensym "iftrue"))]
        [endif (symbol->string (gensym "endif"))])
    (sequence (compile-e e1)
              (Cmp "#!val_false")
              (Beq false)
              (compile-e e2) ; true case
              (Bra endif)
              (Label false) ; false case
              (compile-e e3)
              (Label endif))))
; beware! what if the branch is too long?

;; Op1 Expr -> Asm
(define (compile-prim1 p e)
  (sequence (compile-e e) (compile-op1 p)))

;; Op1 -> Asm
(define (compile-op1 p)
  (match p
    ['add1 (sequence (Inc) (Inc))]
    ['sub1 (sequence (Dec) (Dec))]
    ['zero?
     (let ([true (symbol->string (gensym "iftrue"))]
           [endif (symbol->string (gensym "endif"))])
       (sequence (Cmp "#0")
                 (Beq true)
                 (Lda "!val_false")
                 (Bra endif)
                 (Label true) ; true case
                 (Lda "!val_true")
                 (Label endif)))]

    ['char?
     (let ([true (symbol->string (gensym "iftrue"))]
           [endif (symbol->string (gensym "endif"))])
       (sequence (And "#!char_type_mask")
                 (Cmp "#!char_type_tag")
                 (Beq true)
                 (Lda "!val_false")
                 (Bra endif)
                 (Label true) ; true case
                 (Lda "!val_true")
                 (Label endif)))]
    ['char->integer (sequence (Lsr "!char_shift") (Asl "!int_shift"))]
    ['integer->char
     (sequence (Lsr "!int_shift")
               (Asl "!char_shift")
               (Eor "#!char_type_tag"))]))

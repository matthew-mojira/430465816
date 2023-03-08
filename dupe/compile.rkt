#lang racket
(provide (all-defined-out))
(require "ast.rkt"
         "65816.rkt"
         "types.rkt")

;; Expr -> Asm
(define (compile e)
  (sequence (Org "$C20000") (Label "entry") (compile-e e) (Rtl)))

;; Expr -> Asm
(define (compile-e e)
  (match e
    [(Prim1 p e) (compile-prim1 p e)]
    [(Int i) (compile-value i)]
    [(Bool b) (compile-value b)]
    [(If e1 e2 e3) (compile-if e1 e2 e3)]))

;; Integer -> Asm
(define (compile-value i)
  (Lda (string-append "#" (~v (value->bits i)))))

;; Expr Expr Expr -> Asm
(define (compile-if e1 e2 e3)
  (let ([false (symbol->string (gensym "iftrue"))]
        [endif (symbol->string (gensym "endif"))])
    (sequence (compile-e e1)
              (Cmp (string-append "#" (~v val-false)))
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
                 (Lda (string-append "#" (~v val-false)))
                 (Bra endif)
                 (Label true) ; true case
                 (Lda (string-append "#" (~v val-true)))
                 (Label endif)))]))

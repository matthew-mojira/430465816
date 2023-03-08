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
    [(Int i) (compile-integer i)]
    [(IfZero e1 e2 e3) (compile-ifzero e1 e2 e3)]))

;; Op Expr -> Asm
(define (compile-prim1 p e)
  (sequence (compile-e e)
            (match p
              ['add1 (Inc)]
              ['sub1 (Dec)])))

;; Integer -> Asm
(define (compile-integer i)
  (Lda (string-append "#" (~v i))))

;; Expr Expr Expr -> Asm
(define (compile-ifzero e1 e2 e3)
  (let ([true (symbol->string (gensym "iftrue"))]
        [endif (symbol->string (gensym "endif"))])
    (sequence (compile-e e1)
              (Cmp "#0") ; not necessarily necessary... but think about it!
              (Beq true)
              (compile-e e3) ; else case
              (Bra endif)
              (Label true) ; true case
              (compile-e e2)
              (Label endif))))
; beware! what if the branch is too long?

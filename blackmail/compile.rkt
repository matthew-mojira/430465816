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
    [(Int i) (compile-integer i)]))

;; Op Expr -> Asm
(define (compile-prim1 p e)
  (sequence (compile-e e)
            (match p
              ['add1 (Inc)]
              ['sub1 (Dec)])))

;; Integer -> Asm
(define (compile-integer i)
  (Lda (string-append "#" (~v i))))

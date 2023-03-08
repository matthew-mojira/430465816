#lang racket
(provide interp)
(require "ast.rkt")

;; Expr -> Integer
(define (interp e)
  (match e
    [(Int i) i]
    [(Prim1 p e) (interp-prim1 p (interp e))]
    [(IfZero e1 e2 e3) (interp-ifzero e1 e2 e3)]))

;; Op Integer -> Integer
(define (interp-prim1 op i)
  (match op
    ['add1 (add1 i)]
    ['sub1 (sub1 i)]))

(define (intero-ifzero e1 e2 e3)
  (if (zero? (interp e1)) (interp e2) (interp e3)))

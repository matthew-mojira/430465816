#lang racket
(provide parse)
(require "ast.rkt")

;; S-Expr -> Expr
(define (parse s)
  (match s
    ['eof (Eof)]
    [(? exact-integer?) (Int s)]
    [(? boolean?) (Bool s)]
    [(? char?) (Char s)]
    [(list (? op0? o)) (Prim0 o)]
    [(list (? op1? o) e) (Prim1 o (parse e))]
    [(list 'begin e1 e2) (Begin (parse e1) (parse e2))]
    [(list 'if e1 e2 e3) (If (parse e1) (parse e2) (parse e3))]
    [(list 'let (list (list (? symbol? x) e1)) e2)
     (Let x (parse e1) (parse e2))]
    [(? symbol? s) (Var s)]
    [(list (? op2? o) e1 e2) (Prim2 o (parse e1) (parse e2))]
    [(list 'quote (list)) (Empty)]
    [_ (error "Parse error")]))

;; Any -> Boolean
(define (op0? x)
  (memq x '(read-byte peek-byte void)))
(define (op1? x)
  (memq x
        '(add1 sub1
               zero?
               char?
               integer->char
               char->integer
               write-byte
               eof-object?
               box
               unbox
               empty?
               cons?
               box?
               car
               cdr)))
(define (op2? x)
  (memq x '(+ - < = cons eq?)))

#lang racket
(provide (all-defined-out))
(require "ast.rkt"
         "65816.rkt"
         "compile-ops.rkt")

;; Expr -> Asm
(define (compile e)
  (seq (Label "entry") (compile-e e '()) (Rtl)))

;; Expr -> Asm
(define (compile-e e cenv)
  (match e
    [(Int i) (compile-int i)]
    [(Char c) (compile-char c)]
    [(Bool b) (compile-bool b)]
    [(Eof) (compile-eof)]
    [(Empty) (compile-empty)]
    [(Prim0 p) (compile-prim0 p cenv)]
    [(Prim1 p e) (compile-prim1 p e cenv)]
    [(If e1 e2 e3) (compile-if e1 e2 e3 cenv)]
    [(Begin e1 e2) (compile-begin e1 e2 cenv)]
    [(Let x e1 e2) (compile-let x e1 e2 cenv)]
    [(Var x) (compile-variable x cenv)]
    [(Prim2 p e1 e2) (compile-prim2 p e1 e2 cenv)]))

;; Integer -> Asm
(define (compile-int i)
  (Lda (Imm (string-append (~v i) "<<!int_shift"))))
(define (compile-char c)
  (Lda (Imm (string-append "(("
                           (~v (char->integer c))
                           "<<!char_shift)|!char_type_tag)"))))
(define (compile-bool b)
  (if b (Lda (Imm "!val_true")) (Lda (Imm "!val_false"))))
(define (compile-eof)
  (Lda (Imm "!val_eof")))
(define (compile-empty)
  (Lda (Imm "!val_empty")))

(define (compile-prim0 p cenv)
  (compile-op0 p))

;; Expr Expr Expr -> Asm
(define (compile-if e1 e2 e3 cenv)
  (let ([false (genstr "iftrue")] [endif (genstr "endif")])
    (seq (compile-e e1 cenv)
         (Cmp (Imm "!val_false"))
         (Beq false)
         (compile-e e2 cenv) ; true case
         (Bra endif)
         (Label false) ; false case
         (compile-e e3 cenv)
         (Label endif))))
; beware! what if the branch is too long?

;; Op1 Expr -> Asm
(define (compile-prim1 p e cenv)
  (seq (compile-e e cenv) (compile-op1 p)))

(define (compile-begin e1 e2 cenv)
  (seq (compile-e e1 cenv) (compile-e e2 cenv)))

(define (compile-let x e1 e2 cenv)
  (seq (compile-e e1 cenv)
       (Pha)
       (compile-e e2 (cons x cenv)) ; add to env
       (Ply)))

;; Id CEnv -> Integer
(define (lookup x cenv)
  (match cenv
    ['() (error "undefined variable:" x)]
    [(cons y rest)
     (match (eq? x y)
       [#t 1] ; 1???
       [#f (+ 2 (lookup x rest))])]))

;; Id CEnv -> Asm
(define (compile-variable x cenv)
  (let ([i (lookup x cenv)]) (seq (Lda (Stk (~v i))))))

;; Op2 Expr Expr CEnv -> Asm
(define (compile-prim2 p e1 e2 cenv)
  (case p
    [(+ - < =) ; special integer instructions
     (seq (compile-e e2 cenv) ; HUGE! expressions evaluated right-to-left
          (assert-integer) ; big note, we're doing this here, as long as
          (Pha) ; our prim2 constructs all expect integers
          (compile-e e1 (cons #f cenv))
          (assert-integer) ; assert arg2 integer
          (compile-op2 p)
          (Ply))]
    [else
     (seq (compile-e e2 cenv) ; expressions evaluated right-to-left
          (Pha)
          (compile-e e1 (cons #f cenv))
          (compile-op2 p))])) ;careful, stack not pulled!

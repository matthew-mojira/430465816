#lang racket
(provide (all-defined-out))
(require "ast.rkt"
         "65816.rkt")

;; Expr -> Asm
(define (compile e)
  (sequence (Org "$C20000") (Label "entry") (compile-e e '()) (Rtl)))

;; Expr -> Asm
(define (compile-e e cenv)
  (match e
    [(Int i) (compile-int i)]
    [(Char c) (compile-char c)]
    [(Bool b) (compile-bool b)]
    [(Eof) (compile-eof)]
    [(Prim0 p) (compile-prim0 p cenv)]
    [(Prim1 p e) (compile-prim1 p e cenv)]
    [(If e1 e2 e3) (compile-if e1 e2 e3 cenv)]
    [(Begin e1 e2) (compile-begin e1 e2 cenv)]
    [(Let x e1 e2) (compile-let x e1 e2 cenv)]
    [(Var x) (compile-variable x cenv)]
    [(Prim2 p e1 e2) (compile-prim2 p e1 e2 cenv)]))

;; Integer -> Asm
(define (compile-int i)
  (Lda (string-append (~v i) "<<!int_shift")))
(define (compile-char c)
  (Lda (string-append "(("
                      (~v (char->integer c))
                      "<<!char_shift)|!char_type_tag)")))
(define (compile-bool b)
  (if b (Lda "!val_true") (Lda "!val_false")))
(define (compile-eof)
  (Lda "!val_eof"))

(define (compile-prim0 p cenv)
  (compile-op0 p))
(define (compile-op0 p)
  (match p
    ['void (Lda "!val_void")]
    ['eof (Lda "!val_eof")]
    ['read-byte (Jsl "read_byte")]
    ['peek-byte (Jsl "peek_byte")]))

;; Expr Expr Expr -> Asm
(define (compile-if e1 e2 e3 cenv)
  (let ([false (genstr "iftrue")] [endif (genstr "endif")])
    (sequence (compile-e e1 cenv)
              (Cmp "#!val_false")
              (Beq false)
              (compile-e e2 cenv) ; true case
              (Bra endif)
              (Label false) ; false case
              (compile-e e3 cenv)
              (Label endif))))
; beware! what if the branch is too long?

;; Op1 Expr -> Asm
(define (compile-prim1 p e cenv)
  (sequence (compile-e e cenv) (compile-op1 p)))
;; Op1 -> Asm
(define (compile-op1 p)
  (match p
    ['add1 (sequence (assert-integer) (Inc) (Inc))]
    ['sub1 (sequence (assert-integer) (Dec) (Dec))]
    ['zero? (sequence (assert-integer) (Cmp "#0") (if-equal))]
    ['char?
     (sequence (And "#!char_type_mask") (Cmp "#!char_type_tag") (if-equal))]
    ['char->integer
     (sequence (assert-char) (Lsr "!char_shift") (Asl "!int_shift"))]
    ['integer->char
     (sequence (assert-ascii)
               (Lsr "!int_shift")
               (Asl "!char_shift")
               (Eor "#!char_type_tag"))]
    ['eof-object? (sequence (Cmp "#!val_eof") (if-equal))]
    ['write-byte (sequence (assert-byte) (Jsl "write_byte"))]))

(define (if-equal)
  (let ([true (genstr "iftrue")] [endif (genstr "endif")])
    (sequence (Beq true)
              (Lda "!val_false")
              (Bra endif)
              (Label true) ; true case
              (Lda "!val_true")
              (Label endif))))

(define (compile-begin e1 e2 cenv)
  (sequence (compile-e e1 cenv) (compile-e e2 cenv)))

;hardcoded approach
(define (assert-integer)
  (let ([ok (genstr "assert_int")])
    (sequence (Bit "#!int_type_mask")
              (Beq ok)
              (Brk) ; err
              (Label ok))))

(define (assert-char)
  (let ([ok1 (genstr "assert_char")] [ok2 (genstr "assert_char")])
    (sequence (Bit "#%01")
              (Bne ok1)
              (Brk)
              (Label ok1)
              (Bit "#%10")
              (Beq ok2)
              (Brk)
              (Label ok2))))

; CMP, CPX, and CPY clear the c flag if the register was less than the data,
; and set the c flag if the register was greater than or equal to the data.
(define (assert-ascii)
  (let ([ok (genstr "assert_ascii")])
    (sequence (assert-integer)
              (Cmp "#255") ; magic num
              (Bcc ok)
              (Brk) ; err
              (Label ok))))
; want A < 256

(define (assert-byte) ; this is kinda unnecessary. word size is OK
  (let ([ok (genstr "assert_byte")])
    (sequence (assert-integer)
              (Cmp "#511") ;magic num
              (Bcc ok)
              (Brk) ; err
              (Label ok))))

(define (compile-let x e1 e2 cenv)
  (sequence (compile-e e1 cenv)
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
  (let ([i (lookup x cenv)]) (sequence (LdaStk (~v i)))))

;; Op2 Expr Expr CEnv -> Asm
(define (compile-prim2 p e1 e2 cenv)
  (sequence (compile-e e2 cenv) ; HUGE! expressions evaluated right-to-left
            (assert-integer) ; big note, we're doing this here, as long as
            (Pha) ; our prim2 constructs all expect integers
            (compile-e e1 (cons #f cenv))
            (assert-integer) ; assert arg2 integer
            (compile-op2 p)
            (Ply)))
;; Op2 -> Asm
(define (compile-op2 p)
  (match p
    ['+ (sequence (Clc) (AdcStk "1"))]
    ['- (sequence (Sec) (SbcStk "1"))]
    ['<
     (let ([false (genstr "lefalse")] [done (genstr "ledone")])
       (sequence (CmpStk "1")
                 (Bcs false)
                 (Lda "!val_true")
                 (Bra done)
                 (Label false)
                 (Lda "!val_false")
                 (Label done)))]
    ['= (sequence (CmpStk "1") (if-equal))]))

(define (genstr s)
  (symbol->string (gensym s)))

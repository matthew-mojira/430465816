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
    [(Eof) (compile-eof)]
    [(Prim0 p) (compile-prim0 p)]
    [(Char c) (compile-char c)]
    [(Bool b) (compile-bool b)]
    [(If e1 e2 e3) (compile-if e1 e2 e3)]
    [(Begin e1 e2) (compile-begin e1 e2)]))

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

(define (compile-prim0 p)
  (compile-op0 p))
(define (compile-op0 p)
  (match p
    ['void (Lda "!val_void")]
    ['eof (Lda "!val_eof")]
    ['read-byte (Jsl "read_byte")]
    ['peek-byte (Jsl "peek_byte")]))

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
  (let ([true (symbol->string (gensym "iftrue"))]
        [endif (symbol->string (gensym "endif"))])
    (sequence (Beq true)
              (Lda "!val_false")
              (Bra endif)
              (Label true) ; true case
              (Lda "!val_true")
              (Label endif))))

(define (compile-begin e1 e2)
  (sequence (compile-e e1) (compile-e e2)))

;hardcoded approach
(define (assert-integer)
  (let ([ok (symbol->string (gensym "assert_int"))])
    (sequence (Bit "#!int_type_mask")
              (Beq ok)
              (Brk) ; err
              (Label ok))))

(define (assert-char)
  (let ([ok1 (symbol->string (gensym "assert_char"))]
        [ok2 (symbol->string (gensym "assert_char"))])
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
  (let ([ok (symbol->string (gensym "assert_ascii"))])
    (sequence (assert-integer)
              (Cmp "#255")
              (Bcc ok)
              (Brk) ;err
              (Label ok))))
; want A < 256

(define (assert-byte) ; this is kinda unnecessary. word size is OK
  (let ([ok (symbol->string (gensym "assert_byte"))])
    (sequence (assert-integer) (Cmp "#511") (Bcc ok) (Brk) (Label ok))))

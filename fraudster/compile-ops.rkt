#lang racket
(provide (all-defined-out))
(require "ast.rkt" "65816.rkt")

(define (compile-op0 p)
  (match p
    ['void (Lda "!val_void")]
    ['eof (Lda "!val_eof")]
    ['read-byte (Jsl "read_byte")]
    ['peek-byte (Jsl "peek_byte")]))


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


(define (if-equal)
  (let ([true (genstr "iftrue")] [endif (genstr "endif")])
    (sequence (Beq true)
              (Lda "!val_false")
              (Bra endif)
              (Label true) ; true case
              (Lda "!val_true")
              (Label endif))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ASSERTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

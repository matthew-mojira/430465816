#lang racket
(provide (all-defined-out))
(require "ast.rkt"
         "65816.rkt")

(define (compile-op0 p)
  (match p
    ['void (Lda (Imm "!val_void"))]
    ['eof (Lda (Imm "!val_eof"))]
    ['read-byte (Jsl "read_byte")]
    ['peek-byte (Jsl "peek_byte")]))

;; Op1 -> Asm
(define (compile-op1 p)
  (match p
    ['add1 (seq (assert-integer) (Inc (Acc "2")))]
    ['sub1 (seq (assert-integer) (Dec (Acc "2")))]
    ['zero?
     (seq (assert-integer)
          (Cmp (Imm "0")) ; think this is unnecessary
          (equal-check))]
    ['char?
     (seq (And (Imm "!char_type_mask"))
          (Cmp (Imm "!char_type_tag"))
          (equal-check))]
    ['char->integer
     (seq (assert-char) (Lsr (Acc "!char_shift")) (Asl (Acc "!int_shift")))]
    ['integer->char
     (seq (assert-ascii)
          (Lsr (Acc "!int_shift"))
          (Asl (Acc "!char_shift"))
          (Eor (Imm "!char_type_tag")))]
    ['eof-object? (seq (Cmp (Imm "!val_eof")) (equal-check))]
    ['write-byte (seq (assert-byte) (Jsl "write_byte"))]
    ['box
     (seq (Sta (ZpInd "!HEAP"))
          (Lda (Zp "!HEAP"))
          (Asl (Acc "1"))
          (Ora (Imm "!box_type_tag"))
          (Inc (Zp "!HEAP"))
          (Inc (Zp "!HEAP")))]
    ['unbox
     (seq (assert-box)
          (convert-ptr) ;
          (Sta (Zp "!DEREF"))
          (Lda (ZpInd "!DEREF")))]
    ['box?
     (seq (And (Imm "!ptr_type_mask"))
          (Cmp (Imm "!box_type_tag"))
          (equal-check))]
    ['cons?
     (seq (And (Imm "!ptr_type_mask"))
          (Cmp (Imm "!cons_type_tag"))
          (equal-check))]
    ['empty? (seq (Cmp (Imm "!val_empty")) (equal-check))]
    ['car
     (seq (assert-cons)
          (convert-ptr)
          (Sta (Zp "!DEREF"))
          (Lda (ZpInd "!DEREF")))]
    ['cdr
     (seq (assert-cons)
          (convert-ptr)
          (Sta (Zp "!DEREF"))
          (Ldy (Imm "2"))
          (Lda (ZpIndY "!DEREF")))]))

;; Op2 -> Asm
(define (compile-op2 p)
  (match p
    ['+
     (seq (Clc) ; clear carry
          (Adc (Stk "1")))]
    ['-
     (seq (Sec) ; set carry (because subtraction is weird)
          (Sbc (Stk "1")))]
    ['<
     (let ([false (genstr "lefalse")] [done (genstr "ledone")])
       (seq (Cmp (Stk "1"))
            (Bcs false)
            (Lda (Imm "!val_true"))
            (Bra done)
            (Label false)
            (Lda (Imm "!val_false"))
            (Label done)))]
    ['= (seq (Cmp (Stk "1")) (equal-check))]
    ['cons
     (seq (Sta (ZpInd "!HEAP"))
          (Pla) ; pull from stack
          (Ldy (Imm "2"))
          (Sta (ZpIndY "!HEAP"))
          (Lda (Zp "!HEAP"))
          (Asl (Acc "1"))
          (Ora (Imm "!cons_type_tag"))
          (Inc (Zp "!HEAP"))
          (Inc (Zp "!HEAP"))
          (Inc (Zp "!HEAP"))
          (Inc (Zp "!HEAP")))]

    ; this is the same as = but compile-prim2 is diff
    ['eq? (seq (Cmp (Stk "1")) (equal-check) (Ply))]))

(define (equal-check)
  (let ([true (genstr "iftrue")] [endif (genstr "endif")])
    (seq (Beq true)
         (Lda (Imm "!val_false"))
         (Bra endif)
         (Label true) ; true case
         (Lda (Imm "!val_true"))
         (Label endif))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ASSERTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;hardcoded approach
(define (assert-integer)
  (let ([ok (genstr "assert_int")])
    (seq (Bit (Imm "!int_type_mask"))
         (Beq ok)
         (Brk (Imm8 "0")) ; err
         (Label ok))))

(define (assert-char)
  (let ([ok1 (genstr "assert_char")] [ok2 (genstr "assert_char")])
    (seq (Bit (Imm "%1011"))
         (Beq ok1)
         (Brk (Imm8 "0"))
         (Label ok1)
         (Bit (Imm "%0100"))
         (Bne ok2)
         (Brk (Imm8 "0"))
         (Label ok2))))

; CMP, CPX, and CPY clear the c flag if the register was less than the data,
; and set the c flag if the register was greater than or equal to the data.
(define (assert-ascii)
  (let ([ok (genstr "assert_ascii")])
    (seq (assert-integer)
         (Cmp (Imm "1023")) ; magic num
         (Bcc ok)
         (Brk (Imm8 "0")) ; err
         (Label ok))))
; want A < 256

(define (assert-byte) ; this is kinda unnecessary. word size is OK
  (let ([ok (genstr "assert_byte")])
    (seq (assert-integer)
         (Cmp (Imm "2047")) ;magic num
         (Bcc ok)
         (Brk (Imm8 "0")) ; err
         (Label ok))))

(define (assert-box)
  (let ([ok1 (genstr "assert_box")] [ok2 (genstr "assert_box")])
    (seq (Bit (Imm "%10"))
         (Beq ok1)
         (Brk (Imm8 "0"))
         (Label ok1)
         (Bit (Imm "%01"))
         (Bne ok2)
         (Brk (Imm8 "0"))
         (Label ok2))))

(define (assert-cons)
  (let ([ok1 (genstr "assert_box")] [ok2 (genstr "assert_box")])
    (seq (Bit (Imm "%10"))
         (Bne ok1)
         (Brk (Imm8 "0"))
         (Label ok1)
         (Bit (Imm "%01"))
         (Beq ok2)
         (Brk (Imm8 "0"))
         (Label ok2))))

(define (convert-ptr)
  (seq (Sec)
       (Ror (Acc "!imm_shift")) ; this approach
       (Asl (Acc "!imm_shift-1"))))

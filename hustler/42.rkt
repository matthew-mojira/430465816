#lang racket

;(let ([x (read-byte)])
;  (let ([y (read-byte)])
;    (if (= x y)
;        (begin
;          (write-byte x)
;          (write-byte y))
;        (add1 (peek-byte)))))

;(unbox (box 42))
;(cons 10 20)
;(let ((x (cons 1 2))) (cons (car x) (cdr x)))
;(cons 4 (cons 3 (cons 2 '())))
;(cons 42 (cons (box 84) (cons 0 #\f)))
;(char->integer #\a)
;(begin (write-byte 126) (integer->char 126))

;(let ([x 1])
;  (begin
;    (write-byte 97)
;    1))

;(let ([x 1])
;  (let ([y 2])
;    (begin
;      (write-byte 97)
;      1)))

;(let ([x (cons 1 2)])
;  (begin
;    (write-byte 97)
;    (car x)))

(cons #\e
      (cons (cons (+ 20 2) (unbox (box 42)))
            (cons (peek-byte)
                  (cons (write-byte 107)
                        (cons (box (= 5 5))
                              (cons (zero? 69)
                                    (cons (cdr (cons 10 20)) '())))))))

;(unbox (box 42))
;(box 42)

;(+ 1 2)

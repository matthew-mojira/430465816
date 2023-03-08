#lang racket

;(let ((x 77)) (let ((y (add1 x))) (write-byte y)))
;(let ((x 4)) (+ (let ((y 32)) (- y 20)) x))
;(< 41 40)
;  ^STK ^A
;  C set if A >= STK
;  C clear if A < STK
;  want A > STK
(let ([x (+ 1 2)]) (let ([z (- 4 x)]) (+ (+ x x) z)))
;(+ (write-byte 97) (write-byte 98))

|---------|
|         |
|---------|
|         |
|---------|
|         | <-- empty-stack
|---------| <-- not an address
|  stack  | <-- full-stack
|---------|
|  stack  |
|---------|
|  stack  |
|---------|


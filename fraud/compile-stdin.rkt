#lang racket
(provide main)
(require "parse.rkt" "compile.rkt" "65816.rkt")

;; -> Void
;; Compile contents of stdin,
;; emit asm code on stdout
(define (main)
  (read-line) ; ignore #lang racket line
  (printer (compile (parse (read)))))

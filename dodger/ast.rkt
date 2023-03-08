#lang racket
(provide Int
         Bool
         Prim1
         If
         Char)

;; type Expr =
;; | (Int Integer)
;; | (Prim1 Op Expr)
;; type Op = 'add1 | 'sub1
(struct Int (i) #:prefab)
(struct Bool (b) #:prefab)
(struct Char (c) #:prefab)
(struct Prim1 (p e) #:prefab)
(struct If (e1 e2 e3) #:prefab)

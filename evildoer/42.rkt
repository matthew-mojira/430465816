#lang racket

;(begin
;  (write-byte 97)
;  (begin
;    (read-byte)
;    (write-byte (add1 97))))
(begin
  (write-byte (char->integer #\l))
  (begin
    (write-byte (char->integer #\m))
    (begin
      (write-byte (char->integer #\n))
      (begin
        (write-byte (char->integer #\o))
        (begin
          (write-byte (char->integer #\p))
          (begin
            (write-byte (char->integer #\q))
            (begin
              (write-byte (char->integer #\r))
              (begin
                (write-byte (char->integer #\s))
                (begin
                  (write-byte (char->integer #\t))
                  (begin
                    (write-byte (char->integer #\u))
                    (write-byte (char->integer #\v))))))))))))

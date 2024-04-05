

(import scheme)
(import simple-exceptions)
(import (chicken repl))
(import (chicken string))
(import (chicken pretty-print))
(import (chicken io))
(import (chicken format))
(import (chicken bitwise))
(import (chicken sort))
(import (chicken file))
(import (chicken process-context))
;; (change-directory "day17")
;; (get-current-directory)
(import procedural-macros)
(import regex)
(import simple-md5)
(import simple-loops)
(import srfi-13) ;; string-pad
(import srfi-69)
;; hash-table-ref  hash key thunk
;; hash-table-set! hash key val
;; sudo chicken-install srfi-178
(import srfi-178)
;; srfi-178 provides bit-vectors
;; (import-for-syntax
;;   (only checks <<)
;;   (only bindings bind bind-case)
;;   (only procedural-macros macro-rules with-renamed-symbols once-only))
(import sequences)
(import srfi-1)
(import matchable)
(define pp pretty-print)

;; ----------------------------------------------

;; macros
#|
make an array from 0 to 255 inclusive 256 elements

|#

(define (make-circular-vector size)
  (assert (and (integer? size) (> size 0)))
  (let ((vec (make-vector size)))
    (letrec ((foo (lambda (n)
		(cond
		 ((>= n size) #f)
		 (#t (vector-set! vec n n)
		     (foo (+ n 1)))))))
      (foo 0))
    (lambda (op . args)
      (cond
       ((eq? op 'read) (let ((n (car args)))
			 (vector-ref vec (modulo n size))))
       ((eq? op 'write) (let ((n (car args))
			      (k (cadr args)))
			  (vector-set! vec (modulo n size) k)))
       ((eq? op 'size) size)
       ((eq? op 'vec) vec)
       (#t (error "circular vector"))))))



(define (circ-reverse circ index len)
  (letrec ((bar (lambda (n acc)
		  (cond
		   ((null? acc) #f)		   
		   (#t		    
		    (circ 'write n (car acc))
		    (bar (+ n 1) (cdr acc))))))
	   (foo (lambda (n ct acc)
		  (cond
		   ((= ct 0) (bar index acc))
		   (#t (foo (+ n 1) (- ct 1) (cons (circ 'read n) acc))))))
	   )
    (let ((acc '())
	  (count len)
	  (index index))
      (foo index count acc))))


(define (act-64 circ pos skip lengths)
  (define (recur pos skip xs run)
    (format #t "run ~a : pos = ~a : skip = ~a ~%" run pos skip)
    (cond
     ((null? xs)
      (cond
       ((>= run 64) pos)
       (#t (recur pos skip lengths (+ 1 run)))))
     (#t (let ((len (car xs)))
	   (circ-reverse circ pos len)
	   (recur (modulo (+ pos len skip) (circ 'size)) (+ skip 1) (cdr xs) run)))))
  ;; entry
  (recur pos skip lengths 1))



(define (circ-show circ pos)
  (let ((size (circ 'size)))
    (letrec ((foo (lambda (n)
		    (cond
		     ((> n (- size 1)) #f)
		     (#t
		      ;; insert newline
		      (cond
		       ((zero? (modulo n 20)) (format #t "~%")))
		      ;; put squares around where POS is in circular array
		      (cond
		       ((= n pos)
			(format #t "[~a] " (circ 'read n)))
		       (#t
			(format #t "~a " (circ 'read n))))
		      (foo (+ n 1)))))))
      (foo 0)
      (format #t "~%"))))


#|

input 1,2,3 is no longer numbers but to be thought of as a string of bytes 0-255 ascii
"1,2,3"

append standard suffix lengths
 '(17 31 73 47 23)

|#

;; string to ascii values
(define (string->ascii s)
  (map char->integer (string->list s)))

(define (front-door s)
  (assert (string? s))
  (let ((standard-suffix  '(17 31 73 47 23)))
    (append (string->ascii s) standard-suffix)))


(define (example)
  (let ((circ (make-circular-vector 5))
	(lengths (front-door "3,4,1,5"))
	(pos 0)
	(skip 0))
    (let ((final-pos (act-64 circ pos skip lengths)))
      (circ-show circ final-pos)
      (circ 'vec))))

;; chicken bitwise
;;65 ^ 27 ^ 9 ^ 1 ^ 4 ^ 3 ^ 40 ^ 50 ^ 91 ^ 7 ^ 6 ^ 0 ^ 2 ^ 5 ^ 68 ^ 22 => 64
;;(bitwise-xor 65   27   9   1   4   3   40   50   91   7   6   0   2   5   68  22)
;;64

;; convert circ to a list
;; take 16 , drop 16
(define (split-16 xs)
  (define (recur xs)
    (cond
     ((null? xs) xs)
     (#t (cons (take xs 16) (recur (drop xs 16))))))
  (cond
   ((vector? xs) (recur (vector->list xs)))
   (#t (recur xs))))


(define (output xs)
  (let ((result (apply string-append
		 (map (lambda (n)
			(string-pad (format #f "~X" n) 2 #\0))
		      (map (lambda (x)(apply bitwise-xor x))
			   (split-16 xs))))))
    result))


(define (entry)
  (let ((circ (make-circular-vector 256))
	(lengths (front-door "212,254,178,237,2,0,1,54,167,92,117,125,255,61,159,164"))
	(pos 0)
	(skip 0))
    (let ((final-pos (act-64 circ pos skip lengths)))
      (format #t "final pos = ~a ~%" final-pos)      
      (circ-show circ final-pos)
      (output (circ 'vec)))))


(define (explore lengths)
  (let ((circ (make-circular-vector 256))
	(pos 0)
	(skip 0))
    (act-64 circ pos skip lengths)
    (output (circ 'vec))))

(define (example-empty-string)
  (explore (front-door "")))

(define (example-aoc-2017)
  (explore (front-door "AoC 2017")))

(define (example-1-2-3)
  (explore (front-door "1,2,3")))

(define (example-1-2-4)
  (explore (front-door "1,2,4")))

(define (puzzle)
  (explore (front-door "212,254,178,237,2,0,1,54,167,92,117,125,255,61,159,164")))


#|

> (puzzle)

96de9657665675b51cd03f0b3528ba26

|#



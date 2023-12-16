


(import scheme)
(import (chicken pretty-print))
(define pp pretty-print)

(import (chicken format))
(import (chicken sort))
(import (chicken file))
(import (chicken process-context))
;; (change-directory "../day4")
;; (current-directory)


(import procedural-macros)
(import regex)

(import simple-md5)
(import simple-loops)

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


;;------------------------- code -----------------------------------

;; change input file ! 
(define (get-input) (call-with-input-file "input"
		      (lambda (port)
			(read port))))

(define input (get-input))

(set! input
  (map (lambda (x)
	 (string->number (format #f "~a" x)))
       (string->list input)))


(define (1+ x) (+ x 1))
(define (1- x) (- x 1))

(define (10+ x) (+ x 10))
(define (10- x) (- x 10))

;; ------------------------------------------------------------------------

(define (fs xs ys)
  (cond
   ((null? (cdr xs)) (if (= (car xs) (car ys)) (car xs) 0))
   ((= (car xs) (car (cdr xs))) (+ (car xs) (fs (cdr xs) ys)))
   (#t (fs (cdr xs) ys))))

(define (fs2 xs)
  (fs xs xs))

(list 
 (fs2 '(1 1 1 1)) 
 (fs2 '(1 1 2 2))
 (fs2 '(1 2 3 4))
 (fs2 '(9 1 2 1 2 1 2 9)))

(fs2 input)

1393






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

#|

circular data structures are trickier than a simple append

    1212 produces 6: the list contains 4 items, and all four digits match the digit 2 items ahead.
    1221 produces 0, because every comparison is between a 1 and a 2.
    123425 produces 4, because both 2s match each other, but no other digit has a match.
    123123 produces 12.
    12131415 produces 4.


|#


#|

|#
(define (rs xs ys n)
  (cond
   ((null? xs) 0)
   (#t (let ((a (car xs))
	     (b (car (drop ys n))))
	 (format #t "comparing ~a with ~a ~%" a b )
	 (cond
	  ((= a b) (+ a (rs (cdr xs) (cdr ys) n)))
	  (#t (rs (cdr xs) (cdr ys) n)))))))



(define (rs2 xs)
  (format #t "~%")
  (rs xs (append xs xs xs) (/(length xs)2)))



(list
(rs2 '(1 2 1 2))
(rs2 '(1 2 2 1))
(rs2 '(1 2 3 4 2 5))
(rs2 '(1 2 3 1 2 3))
(rs2 '(1 2 1 3 1 4 1 5 )))

(rs2 input)

"part 2 "
1292


#|
1 2 1 2
*   ^
1 2 1 2 1 2 1 2 1 2 1 2 
  *   *
    *   *
      *   *
        *   *
|#






















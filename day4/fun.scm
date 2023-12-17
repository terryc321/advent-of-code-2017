#|

day 4


           

|#


(import scheme)
(import (chicken pretty-print))
(define pp pretty-print)

(import (chicken format))
(import (chicken string))
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

(define input (string-split (get-input) "\n"))


#|
(set! input
  (map (lambda (x)
	 (string->number (format #f "~a" x)))
       (string->list input)))
|#

(define (1+ x) (+ x 1))
(define (1- x) (- x 1))

(define (10+ x) (+ x 10))
(define (10- x) (- x 10))

;; ------------------------------------------------------------------------

(define examples '(
    "aa bb cc dd ee" ;; is valid.
    "aa bb cc dd aa" ;; is not valid - the word aa appears more than once.
    "aa bb cc dd aaa" ;; is valid - aa and aaa count as different words.
    ))


(define (f s)
  (let ((words (string-split s " ")))
    (all-unique words)))

(define (all-unique xs)
  (cond
   ((null? xs) #t)
   ((member (car xs) (cdr xs) string=?) (values #f (car xs)))
   (#t (all-unique (cdr xs)))))

(map f examples)

(define (part-1)
  (length (filter (lambda (x) (if x x #f)) (map f input))))




















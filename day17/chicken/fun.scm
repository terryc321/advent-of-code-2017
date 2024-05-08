

(import scheme)
(import simple-exceptions)
(import (chicken repl))
(import (chicken string))
(import (chicken pretty-print))
(import (chicken io))
(import (chicken format))
(import (chicken sort))
(import (chicken file))
(import (chicken process-context))
;; (change-directory "day17")
;; (get-current-directory)
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
(define pp pretty-print)


#|
;; ---------------------------------------------------------------------------------

             [ 0 -> ] 

50000000

|#

(define (make-item x n)
  (let ((vec (make-vector 2)))
    (vector-set! vec 0 x)
    (vector-set! vec 1 n)
    vec))

(define (next v)
  (vector-ref v 1))

(define (init)
  (let ((v (make-item 0 0)))
    (vector-set! v 1 v)
    v))

(define (insert x v k)
  (cond
   ((> k 0) (insert x (next v) (- k 1)))
   (#t 
    (let ((new (make-item x 0))
	  (old-next (vector-ref v 1)))    
      (vector-set! v 1 new)
      (vector-set! new 1 old-next)
      new))))

(define p (init))
(define n 1)
(define cur p)

(define (reset)
  (set! p (init))
  (set! cur p)
  (set! n 1))

(define (go)
  (set! cur (insert n cur 3))
  (set! n (+ n 1))
  p)

(define (go2)
  (set! cur (insert n cur 303))
  (set! n (+ n 1))
  p)


(define (ffind)
  (letrec ((foo (lambda (r)
		  (cond
		   ((> n 2017) #t)
		   (#t (go2)
		       (foo (+ r 1)))))))
    (foo 1)))


(define (show)
  (letrec ((foo (lambda (v r)
		  (cond
		   ((and (> r 0) (= (vector-ref v 0) 0)) #f)
		   (#t (format #t "~a " (vector-ref v 0))
		       (foo (next v) (+ r 1)))))))
    (foo p 0)))


(define (show-10)
  (letrec ((foo (lambda (v r)
		  (cond
		   ((or (> r 10) (and (> r 0) (= (vector-ref v 0) 0))) #f)
		   (#t (format #t "~a " (vector-ref v 0))
		       (foo (next v) (+ r 1)))))))
    (foo p 0)))


#|

repeatedly do this 50 - million times
if n > 50 - million then it has been inserted already 
|#
(define (ffind2)
  (letrec ((foo (lambda (r)
		  (cond
		   ((= (modulo n 1000000) 0)
		    (format #t "n = ~a ~%" n )))
		  (cond
		   ((> n 50000000) #t)
		   (#t (go2)
		       (foo (+ r 1)))))))
    (foo 1)))


(ffind2)
(show-10)


#|

n = 49000000 
n = 50000000 
0 17202899 32278554 10221408 48728547 37934195 31751138 34025879 5611473 23603333 17720674

17202899

ANSWER ACCEPTED ! 


|#

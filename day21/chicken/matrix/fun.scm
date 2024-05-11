

#|
matrix in lisp
hash table then use key (1 1) say

if matrix width is divisble by 2
2 4 6 8 10 12 ...
break matrix up into 2 x 2 squares converted to 3x3 squares
think of 2 x 2 squares being already in place
insert blank rows and blank columns every nth row ,

keep track of largest element set so far ?
or do we just do a copy of matrix (a hash) and leave blank spaces #f falsies
in place

show matrix facility row 1 , col 1 .. N
... ron N , col 1 ... N
matrices are always square

if we do check and replace 2x2 by 3x3 when matrix has been expanded ( post expansion )
then the 3x3 matrix can then be slotted in place
|#

(import scheme)
(import expand-full)
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
(import srfi-69) ;; hash tables

;; ------------ macros ---------------------------------------
;; dolist
(define-macro (dolist varlist . body)
  (let ((var (car varlist))
	(ls (cadr varlist))
	(fn (gensym "fn")))	
    `(begin
       (letrec
	   ((,fn (lambda (xs)
		   (cond
		    ((null? xs) #f)
		    (#t (let ((,var (car xs)))
			  ,@body
			  (,fn (cdr xs))))))))
	 (,fn ,ls)))))

;; dofor
;; cannot handle decreasing steps ?
(define-macro (for v . body)
  (let ((var (car v))
	(init (cadr v))
	(lim (caddr v))
	(step (cadddr v))	      
	(foo (gensym "foo"))
	(v-i (gensym "i"))
	(v-step (gensym "step"))
	(v-lim (gensym "lim")))
    `(begin
       (letrec ;; want to capture var
	   ((,foo (lambda (,var ,v-step ,v-lim)
		    (cond
		     ((> ,var ,v-lim) #f)
		     (#t
		      ,@body
		      (,foo (+ ,var ,v-step) ,v-step ,v-lim))))))
	 (,foo ,init ,step ,lim)))))

;;(pp (expand* '(for (i 1 10 1) (format #t "i = ~A ~%" i))))
;; (for (i 1 10 1) (format #t "i = ~A ~%" i))
;; (for (i 10 1 -1) (format #t "i = ~A ~%" i))

;; ---------------------------------------------------------------------------


(define input-map
  '((#(0 0 0 0) #(0 0 0 1 0 1 0 0 0))
    (#(1 0 0 0) #(0 0 1 0 0 1 1 0 0))
    (#(1 1 0 0) #(0 0 0 1 0 0 0 0 1))
    (#(0 1 1 0) #(1 0 0 0 0 0 0 0 0))
    (#(1 1 1 0) #(1 0 1 0 1 0 1 0 0))
    (#(1 1 1 1) #(0 0 1 1 0 1 0 0 1))
    (#(0 0 0 0 0 0 0 0 0) #(0 1 0 0 1 0 0 1 1 0 0 0 0 1 0 0))
    (#(1 0 0 0 0 0 0 0 0) #(0 0 1 1 0 0 1 1 0 1 0 1 0 0 0 0))
    (#(0 1 0 0 0 0 0 0 0) #(0 0 1 1 0 0 1 1 0 1 1 1 1 1 0 0))
    (#(1 1 0 0 0 0 0 0 0) #(0 0 0 0 0 1 1 0 1 0 1 1 0 0 1 0))
    (#(1 0 1 0 0 0 0 0 0) #(1 1 1 1 1 0 1 1 1 0 1 1 1 0 1 0))
    (#(1 1 1 0 0 0 0 0 0) #(1 0 0 1 0 0 1 0 0 0 0 0 1 1 0 1))
    (#(0 1 0 1 0 0 0 0 0) #(0 0 1 0 0 1 0 0 0 0 0 1 1 0 1 1))
    (#(1 1 0 1 0 0 0 0 0) #(0 0 0 0 1 0 1 1 1 0 0 1 0 1 0 0))
    (#(0 0 1 1 0 0 0 0 0) #(1 1 0 1 1 1 1 1 1 1 1 0 1 1 1 0))
    (#(1 0 1 1 0 0 0 0 0) #(0 0 0 0 1 0 1 1 0 1 1 1 1 0 1 0))
    (#(0 1 1 1 0 0 0 0 0) #(0 0 1 0 1 1 0 1 1 1 1 1 0 0 1 1))
    (#(1 1 1 1 0 0 0 0 0) #(0 0 1 0 0 1 1 0 0 0 0 1 0 0 1 0))
    (#(0 0 0 0 1 0 0 0 0) #(0 1 1 1 1 0 0 0 0 1 0 0 1 1 1 1))
    (#(1 0 0 0 1 0 0 0 0) #(1 1 1 0 0 1 0 1 1 0 1 1 1 1 0 1))
    (#(0 1 0 0 1 0 0 0 0) #(0 0 1 1 0 0 1 0 1 1 1 0 0 0 1 0))
    (#(1 1 0 0 1 0 0 0 0) #(1 0 0 1 0 0 1 0 1 1 1 0 0 0 0 1))
    (#(1 0 1 0 1 0 0 0 0) #(1 0 0 0 1 1 0 1 1 0 1 1 1 0 0 1))
    (#(1 1 1 0 1 0 0 0 0) #(0 0 0 1 1 0 0 1 1 1 1 1 1 1 0 1))
    (#(0 1 0 1 1 0 0 0 0) #(1 0 1 1 1 0 1 1 0 0 0 0 1 0 1 0))
    (#(1 1 0 1 1 0 0 0 0) #(0 0 1 1 1 1 1 0 0 0 1 0 1 1 1 1))
    (#(0 0 1 1 1 0 0 0 0) #(0 0 0 0 1 1 0 0 1 1 0 1 0 1 1 0))
    (#(1 0 1 1 1 0 0 0 0) #(1 1 0 0 1 1 1 1 1 1 1 1 0 1 0 1))
    (#(0 1 1 1 1 0 0 0 0) #(0 0 0 0 1 1 0 1 0 1 1 1 1 1 0 0))
    (#(1 1 1 1 1 0 0 0 0) #(0 1 0 0 1 0 1 0 0 1 0 0 0 0 1 1))
    (#(0 0 0 1 0 1 0 0 0) #(1 1 1 1 1 0 1 0 0 0 1 1 1 0 0 1))
    (#(1 0 0 1 0 1 0 0 0) #(0 1 0 0 0 1 0 0 1 0 0 1 0 0 0 0))
    (#(0 1 0 1 0 1 0 0 0) #(0 0 1 1 0 1 1 0 1 1 1 1 1 0 1 0))
    (#(1 1 0 1 0 1 0 0 0) #(0 0 1 0 1 1 1 0 0 1 0 0 0 0 0 0))
    (#(1 0 1 1 0 1 0 0 0) #(0 0 1 0 0 0 1 0 0 0 0 1 1 0 0 0))
    (#(1 1 1 1 0 1 0 0 0) #(1 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1))
    (#(0 0 0 1 1 1 0 0 0) #(1 0 1 1 1 1 1 1 1 1 1 1 0 0 1 1))
    (#(1 0 0 1 1 1 0 0 0) #(0 1 0 1 0 0 0 1 1 1 1 0 0 0 0 1))
    (#(0 1 0 1 1 1 0 0 0) #(0 0 0 0 0 1 0 1 0 1 0 0 0 0 0 0))
    (#(1 1 0 1 1 1 0 0 0) #(0 0 0 1 0 1 1 1 0 0 0 0 0 1 1 0))
    (#(1 0 1 1 1 1 0 0 0) #(0 0 1 1 1 1 1 0 0 1 0 0 1 0 0 1))
    (#(1 1 1 1 1 1 0 0 0) #(0 1 1 1 0 0 1 0 0 0 1 0 0 1 1 1))
    (#(0 0 1 0 0 0 1 0 0) #(0 1 1 0 1 1 1 0 1 1 1 1 1 0 1 0))
    (#(1 0 1 0 0 0 1 0 0) #(1 1 1 1 1 0 0 0 1 0 0 0 0 0 1 1))
    (#(0 1 1 0 0 0 1 0 0) #(1 1 1 0 1 0 0 1 0 0 1 0 0 1 0 0))
    (#(1 1 1 0 0 0 1 0 0) #(0 1 1 1 0 1 1 0 1 0 1 0 0 1 1 1))
    (#(0 1 1 1 0 0 1 0 0) #(1 1 0 1 0 0 0 1 0 1 0 1 0 0 0 1))
    (#(1 1 1 1 0 0 1 0 0) #(1 0 1 1 0 0 1 0 0 0 0 0 1 0 0 1))
    (#(0 0 1 0 1 0 1 0 0) #(1 0 0 1 1 1 0 1 0 1 1 0 1 1 1 1))
    (#(1 0 1 0 1 0 1 0 0) #(1 1 1 0 0 0 1 1 1 0 0 1 1 0 0 1))
    (#(0 1 1 0 1 0 1 0 0) #(0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 1))
    (#(1 1 1 0 1 0 1 0 0) #(0 1 0 0 1 1 0 0 0 1 1 1 0 0 1 0))
    (#(0 1 1 1 1 0 1 0 0) #(1 1 0 0 0 0 1 1 1 1 0 0 1 1 0 1))
    (#(1 1 1 1 1 0 1 0 0) #(1 0 1 1 1 0 0 1 0 1 1 1 1 1 1 1))
    (#(1 0 0 0 0 1 1 0 0) #(1 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1))
    (#(0 1 0 0 0 1 1 0 0) #(1 0 0 1 0 0 0 0 0 0 0 0 1 1 1 0))
    (#(1 1 0 0 0 1 1 0 0) #(1 0 0 1 1 1 0 1 1 1 0 1 1 0 1 0))
    (#(1 0 1 0 0 1 1 0 0) #(0 1 1 1 1 1 0 1 1 1 1 1 1 0 0 0))
    (#(0 1 1 0 0 1 1 0 0) #(1 1 1 1 0 1 1 0 0 0 0 1 1 0 0 1))
    (#(1 1 1 0 0 1 1 0 0) #(0 1 0 1 1 1 1 1 1 1 0 1 0 0 0 1))
    (#(1 0 0 1 0 1 1 0 0) #(0 0 1 1 0 1 1 0 0 0 1 1 1 1 0 0))
    (#(0 1 0 1 0 1 1 0 0) #(1 0 0 0 1 1 0 0 0 0 1 1 0 0 1 0))
    (#(1 1 0 1 0 1 1 0 0) #(0 0 0 1 1 1 0 1 1 0 0 1 0 1 0 0))
    (#(0 0 1 1 0 1 1 0 0) #(1 0 1 0 1 1 0 0 1 0 1 1 1 1 1 0))
    (#(1 0 1 1 0 1 1 0 0) #(1 1 0 0 1 1 0 1 1 0 1 0 0 0 0 0))
    (#(0 1 1 1 0 1 1 0 0) #(1 1 1 1 0 0 0 1 1 1 1 1 0 1 0 0))
    (#(1 1 1 1 0 1 1 0 0) #(0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0))
    (#(1 0 0 0 1 1 1 0 0) #(0 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1))
    (#(0 1 0 0 1 1 1 0 0) #(1 0 0 0 0 1 0 1 0 1 1 1 0 1 1 0))
    (#(1 1 0 0 1 1 1 0 0) #(1 0 1 0 1 0 1 0 0 1 0 0 1 1 1 0))
    (#(1 0 1 0 1 1 1 0 0) #(1 1 1 1 1 1 0 0 0 1 1 0 1 1 1 1))
    (#(0 1 1 0 1 1 1 0 0) #(1 0 0 0 1 0 1 0 1 0 1 1 1 1 1 0))
    (#(1 1 1 0 1 1 1 0 0) #(1 1 1 1 1 1 1 1 0 0 0 0 1 1 1 1))
    (#(1 0 0 1 1 1 1 0 0) #(1 1 1 1 0 1 1 0 0 0 0 1 1 1 0 1))
    (#(0 1 0 1 1 1 1 0 0) #(0 1 0 0 1 0 1 1 1 0 0 1 0 0 1 1))
    (#(1 1 0 1 1 1 1 0 0) #(1 0 1 0 0 0 1 1 1 0 0 0 0 0 1 1))
    (#(0 0 1 1 1 1 1 0 0) #(1 0 1 1 0 1 1 1 1 0 1 0 1 1 1 0))
    (#(1 0 1 1 1 1 1 0 0) #(1 0 1 1 1 0 1 1 0 0 0 0 1 0 0 1))
    (#(0 1 1 1 1 1 1 0 0) #(0 1 1 0 1 0 1 0 0 0 1 1 1 1 1 1))
    (#(1 1 1 1 1 1 1 0 0) #(0 1 1 0 1 0 0 1 1 0 0 0 1 1 1 0))
    (#(0 1 0 1 0 1 0 1 0) #(1 0 1 0 1 0 0 1 1 0 0 1 1 1 0 1))
    (#(1 1 0 1 0 1 0 1 0) #(0 0 0 1 1 0 1 0 1 1 0 1 1 1 1 0))
    (#(1 0 1 1 0 1 0 1 0) #(1 1 0 1 0 0 1 1 1 1 0 1 1 0 1 1))
    (#(1 1 1 1 0 1 0 1 0) #(0 1 0 1 0 0 1 0 1 1 0 0 0 1 1 0))
    (#(0 1 0 1 1 1 0 1 0) #(1 0 0 1 0 0 1 0 0 0 1 1 1 0 0 0))
    (#(1 1 0 1 1 1 0 1 0) #(1 1 1 1 0 1 0 1 1 1 1 1 0 0 1 0))
    (#(1 0 1 1 1 1 0 1 0) #(1 0 1 0 0 0 1 1 1 1 0 0 1 0 0 1))
    (#(1 1 1 1 1 1 0 1 0) #(0 0 0 1 0 0 0 0 0 0 0 0 1 0 1 0))
    (#(1 0 1 0 0 1 1 1 0) #(0 0 1 0 0 1 1 0 1 1 1 0 0 1 0 1))
    (#(1 1 1 0 0 1 1 1 0) #(1 0 0 0 1 1 1 0 0 0 0 1 1 1 1 1))
    (#(0 1 1 1 0 1 1 1 0) #(0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0))
    (#(1 1 1 1 0 1 1 1 0) #(1 1 0 0 0 0 0 0 1 0 1 0 0 1 1 0))
    (#(1 0 1 0 1 1 1 1 0) #(0 1 0 1 1 1 0 0 0 0 1 1 1 0 1 0))
    (#(1 1 1 0 1 1 1 1 0) #(1 1 1 0 1 1 1 1 0 0 0 1 0 1 0 0))
    (#(0 1 1 1 1 1 1 1 0) #(0 0 1 1 1 0 0 0 0 0 1 1 0 1 0 1))
    (#(1 1 1 1 1 1 1 1 0) #(0 0 1 1 0 0 0 1 0 1 1 1 0 1 0 0))
    (#(1 0 1 0 0 0 1 0 1) #(0 0 1 1 1 0 0 0 1 1 0 1 0 0 0 0))
    (#(1 1 1 0 0 0 1 0 1) #(1 0 1 1 1 0 0 1 0 0 0 0 1 1 0 0))
    (#(1 1 1 1 0 0 1 0 1) #(1 0 0 0 0 0 0 0 1 1 0 1 0 0 1 0))
    (#(1 0 1 0 1 0 1 0 1) #(1 1 1 0 0 0 1 1 0 1 0 0 0 1 1 0))
    (#(1 1 1 0 1 0 1 0 1) #(0 0 0 0 1 0 0 1 0 1 1 1 1 0 0 1))
    (#(1 1 1 1 1 0 1 0 1) #(0 1 0 1 1 1 1 0 1 1 0 1 0 1 1 1))
    (#(1 0 1 1 0 1 1 0 1) #(0 0 0 0 0 0 0 0 0 1 1 0 1 0 0 1))
    (#(1 1 1 1 0 1 1 0 1) #(0 1 1 1 0 1 0 1 0 0 0 1 0 1 1 1))
    (#(1 0 1 1 1 1 1 0 1) #(0 1 0 1 1 1 0 0 0 1 0 0 0 1 0 0))
    (#(1 1 1 1 1 1 1 0 1) #(0 1 0 1 0 1 1 0 1 0 1 1 0 0 0 0))
    (#(1 1 1 1 0 1 1 1 1) #(0 0 1 0 0 0 1 0 0 0 1 0 0 0 1 1))
    (#(1 1 1 1 1 1 1 1 1) #(1 1 0 1 0 0 1 1 0 1 0 1 0 0 0 0))))




#|
;; old dev code - translate string representation to lists ....

(define (test)
(let ((test-map (let ((fn (lambda (ch) (cond ((char=? ch #\1) 1)(#t 0)))))
(map (lambda (pr) (list (map fn (string->list (car pr)))
(map fn (string->list (cadr pr)))))
some-map))))
test-map))



|#


;; (map (lambda (pr) (match pr ((a b) (list (list->vector a) (list->vector b)))))
;;      input-map)



;; --------------------------------------------------------------------------

#|

take a pattern pat : list of 0 and 1 s :
length 4  : represent 2 x 2 matrix 
length 9 : represent 3 x 3 matrix 

|#
(define (lookup pat)
  (when (not (vector? pat))
    (error (format #f "lookup : pat must be a vector! ~a " pat)))
  (call/cc (lambda (exit)
	     (let ((perms (rotate-flip-permute pat)))
	       (dolist (in-out input-map)
		       (let* ((in (car in-out))
			      (out (cadr in-out)))
			 (dolist (perm perms)
				 (cond
				  ((equal? perm in) (exit out))))))))))



;; ----------------------------------------------------------------------------



;; ------ rotate --------------------

#|


rotate.scm

2 x 2 routines

rotation 
0 1    2 0
2 3    3 1 

reflect horizontally
0 1     1 0
2 3     3 2 

reflect vertical
0 1     2 3
2 3     0 1

|#


(define (rot2d-1 xs)
  (list->vector
   (map (lambda (i) (vector-ref xs i)) '(2 0 3 1))))


(define (rot2d-2 xs) (rot2d-1 (rot2d-1 xs)))

(define (rot2d-3 xs) (rot2d-1 (rot2d-1 (rot2d-1 xs))))

(define (rot2d-4 xs) (rot2d-1 (rot2d-1 (rot2d-1 (rot2d-1 xs)))))

(define (ref2d-1 xs)
  (list->vector
   (map (lambda (i) (vector-ref xs i)) '(1 0 3 2))))

(define (ref2d-2 xs)
  (list->vector
   (map (lambda (i) (vector-ref xs i)) '(2 3 0 1))))



#|

3 x 3 routines

rotation 
0 1 2          6  3  0
3 4 5          7  4  1
6 7 8          8  5  2

reflect horiz
0 1 2          6 7 8 
3 4 5          3 4 5
6 7 8          0 1 2

reflect vert
0 1 2          2 1 0
3 4 5          5 4 3
6 7 8          8 7 6


|#



(define (rot3d-1 xs)
  (list->vector
   (map (lambda (i) (vector-ref xs i)) '(  6 3 0
					   7 4 1
					   8 5 2))))

(define (rot3d-2 xs) (rot3d-1 (rot3d-1 xs)))

(define (rot3d-3 xs) (rot3d-1 (rot3d-1 (rot3d-1 xs))))

(define (rot3d-4 xs) (rot3d-1 (rot3d-1 (rot3d-1 (rot3d-1 xs)))))

(define (ref3d-1 xs)
  (list->vector
   (map (lambda (i) (vector-ref xs i)) '(  6 7 8
					   3 4 5
					   0 1 2))))

(define (ref3d-2 xs)
  (list->vector
   (map (lambda (i) (vector-ref xs i)) '(  2 1 0
					   5 4 3
					   8 7 6))))




;; permute2 maps changes to 2x2 with 3x3 together
(define (rotate-flip-permute2 from)
  (let ((known '()))
    (letrec ((foo (lambda (a)
		    (cond
		     ((member a  known) #f)
		     (#t (set! known (cons a known))
			 (foo (rot2d-1 a))
			 (foo (rot2d-2 a))
			 (foo (rot2d-3 a))
			 (foo (ref2d-1 a))
			 (foo (ref2d-2 a))
			 )))))
      (foo from)
      known)))


(define (rotate-flip-permute3 from)
  (let ((known '()))
    (letrec ((foo (lambda (a)
		    (cond
		     ((member a known) #f)
		     (#t (set! known (cons a known))
			 (foo (rot3d-1 a))
			 (foo (rot3d-2 a))
			 (foo (rot3d-3 a))
			 (foo (ref3d-1 a))
			 (foo (ref3d-2 a))
			 )))))
      (foo from)
      known)))


(define (rotate-flip-permute from)
  (when (not (vector? from))
    (error (format #f "rot-flip-permute : from must be a vector ! ~a " from)))
  (cond
   ((= (vector-length from) 4) (rotate-flip-permute2 from))
   ((= (vector-length from) 9) (rotate-flip-permute3 from))
   (#t (error "rotate-flip-permute"))))






;; -----------------------------------

;; (define (make-matrix)
;;   (let ((hash (make-hash-table)))
;;     (hash-table-set! hash 'max-x 0)
;;     (hash-table-set! hash 'max-y 0)
;;     (hash-table-set! hash 'size 0)
;;     hash
;;     ))

;; (define (matrix-set! m x y z)
;;   (format #t " z = ~A ~% " z)
;;   (when (not (integer? z))
;;     (error (format #f "matrix-set! : error z not integer!")))
;;   (when (not (or (= z 0)(= z 1)))
;;     (error (format #f "matrix-set! error : z not integer or 0 or 1 : ~a " z)))
;;   (let ((max-x (hash-table-ref m 'max-x))
;; 	(max-y (hash-table-ref m 'max-y)))
;;     (hash-table-set! m (list x y) z)
;;     (when (> x max-x)
;;       (hash-table-set! m 'max-x x))
;;     (when (> y max-y)
;;       (hash-table-set! m 'max-y y))
;;     ))


;; (define (matrix-ref m x y)
;;   (hash-table-ref/default m (list x y) #f))

;; (define (matrix-show m)
;;   ;;(format #t "m = ~a ~%" m )
;;   (format #t "~%")  
;;   (let ((x 0)
;; 	(y 0)
;; 	(max-x (hash-table-ref m 'max-x))
;; 	(max-y (hash-table-ref m 'max-y))
;; 	)
;;     (letrec ((foo (lambda (x y)
;; 		    (cond
;; 		     ((> y max-y) #f)
;; 		     ((> x max-x)
;; 		      (format #t "~%")
;; 		      (foo 1 (+ y 1)))
;; 		     (#t (let ((val (matrix-ref m x y)))
;; 			   (format #t "~a " val)
;; 			   (foo (+ 1 x) y)))))))
;;       (foo 1 1))))


;; (define (matrix-size m)
;;   (hash-table-ref m 'max-x))


;; -------------------------------------------------------------------------
#|

et ((p (make-matrix)))
(matrix-set! p 1 1 0)
(matrix-set! p 2 1 1)
(matrix-set! p 3 1 0)	       
(matrix-set! p 1 2 0)
(matrix-set! p 2 2 0)
(matrix-set! p 3 2 1)	       
(matrix-set! p 1 3 1)
(matrix-set! p 2 3 1)
(matrix-set! p 3 3 1)
p))

(matrix-show init)
|#

;; --------------------------------------------------------------------------


#|

for a matrix of size [size] 

a flat vector to 

formula is just
(+ x (* y size))

(define (f2d)
(dolist (size (iota 10 1))
(let ((i 0))
(for (y 0 (- size 1) 1)
(for (x 0 (- size 1) 1)
(let ((guess (+ x (* size y))))
(format #t "size = ~a : x = ~a : y = ~a : " size x y)
(cond
((= guess i)	  (format #t "... ok~%"))
(#t (format #t "....bad : out ~a ~%" (- guess i))))
(set! i (+ i 1))))))))



|#





;; v is a flat vector ?? 
(define (v-split v)
  (let ((size (sqrt (vector-length v))))
    (assert (integer? size))
    (cond
     ((zero? (modulo size 2)) (v-split2 v size))
     ((zero? (modulo size 3)) (v-split3 v size))
     (#t (error "v-split")))))


;; split a matrix into a set of 2 x 2 matrices or vec4 #(v1 v2 v3 v4)
#|

matrix size 4 : split into 2 s  2 wide x 2 high
matrix size 6 : split into 2 s  3 wide x 3 high
matrix size 8 : split into 2 s  4 wide x 4 high : 16 - 2x2s

|#
(define (v-split2-stage-1 v size)
  (let* ((n2 (/ size 2))
	 (res (make-vector (* n2 n2) 0))
	 (i 0)
	 (j 0)
	 (sz 2));; sz making 2 x 2 matrices sz = 2 
    (for (y 0 (- n2 1) 1)
	 (for (x 0 (- n2 1) 1)
	      (let ((tmp (make-vector 4 0)))
		
		;; vector-set! 0 1 2 3 .... for ... 
		(vector-set! tmp (+ 0 (* 0 sz)) (vector-ref v (+ i (* j size))))  
		(vector-set! tmp (+ 1 (* 0 sz)) (vector-ref v (+ (+ i 1) (* j size))))		
		(vector-set! tmp (+ 0 (* 1 sz)) (vector-ref v (+ i (* (+ j 1) size))))
		(vector-set! tmp (+ 1 (* 1 sz)) (vector-ref v (+ (+ i 1) (* (+ j 1) size))))

		(vector-set! res (+ x (* y n2)) tmp)
		
		(set! i (+ i 2))
		(when (>= i size)
		  (set! i 0)
		  (set! j (+ j 2)))		
		
		;;
		)))
    res))



;; this is just vector-map . with function lookup
(define (v-split2-lookup v)
  (let* ((size (sqrt (vector-length v)))
	 (res (make-vector (* size size) 0)))
    (for (y 0 (- size 1) 1)
	 (for (x 0 (- size 1) 1)
	      (let ((pat (vector-ref v (+ x (* y size)))))
		(vector-set! res (+ x (* y size)) (lookup pat))
		)))
    res))


;; know only going to be dealing with 3 x 3 matrices
;; have 2 x 2 matrix containing all 3 x 3 matrices
;; length v = 4
;; vsize 2
;; need 3 vsize columns
;; need 3 vsize rows
;; total of (* (* 3 vsize)(* 3 vsize))
;; may 9 size^2 but we cant express this here ...
;; need to iterate over first row , know all 3 x 3 matrices
;; y ... x ... iterate over outer matrix ?
;; inner ... row 0 ... row 1 ... row 2 

(define (v-split2-flat v)
  (let* ((vsize (sqrt (vector-length v)))
	 (rsize (* vsize 3))
	 (res (make-vector (* rsize rsize) 0))
	 (by3 3)
	 (tn 0)
	 )
    (for (y 0 (- vsize 1) 1)	 
	 (for (x 0 (- vsize 1) 1)

	      ;; (format #t "~%")
	      ;; vec is a 3 x 3 matrix
	      (let* ((vec (vector-ref v (+ x (* y vsize)))))
		(for (iy 0 (- by3 1) 1)
		     (for (ix 0 (- by3 1) 1)
			  (let ((val (vector-ref vec (+ ix (* iy by3))))
				(tx (+ ix (* x by3)))
				(ty (+ iy (* y by3))))
			    ;;(format #t "setting ~a , ~a  <-  ~a ~%" tx ty val)
			    (vector-set! res (+ tx (* ty rsize)) val )
			    ;;(vector-set! res (+ ix (* x by3) (* (+ y (* iy by3)) rsize)) val)
			    ;;(format #t "read ~a from ~a ~a ~%" val ix iy)
			    ;;#t
			    ))))))
    res))




(define (v-split2 v size)
  (let* ((v2 (v-split2-stage-1 v size))
	 (v3 (v-split2-lookup v2))
	 (v4 (v-split2-flat v3))
	 )
    ;; (format #t "debug ~%")
    ;; (show-matrix v2)
    ;; (format #t "lookup'ed ~%")
    ;; (show-matrix v3)
    ;; (format #t "flattened ~%")
    ;; (show-matrix v4)
    v4
    ))



;; --------------- v-split3  -----------------------------------------



#|

matrix size 9 : split into 3 x 3 s

|#
(define (v-split3-stage-1 v size)
  (let* ((n3 (/ size 3))
	 (res (make-vector (* n3 n3) 0))
	 (i 0)
	 (j 0)
	 (sz 3)) ;; sz making 3 x 3 matrices sz = 3 
    (for (y 0 (- n3 1) 1)
	 (for (x 0 (- n3 1) 1)
	      ;; 3 x 3 need 9 element long vector , initial value 0 
	      (let ((tmp (make-vector 9 0))) 		
		;; vector-set! 0 1 2 - 3 4 5 - 6 7 8 .... for ... 3 x 3 matrix
		;; make tmp vector
		;; row 0
		(vector-set! tmp (+ 0 (* 0 sz)) (vector-ref v (+ (+ i 0) (* (+ j 0) size))))
		(vector-set! tmp (+ 1 (* 0 sz)) (vector-ref v (+ (+ i 1) (* (+ j 0) size))))
		(vector-set! tmp (+ 2 (* 0 sz)) (vector-ref v (+ (+ i 2) (* (+ j 0) size))))
		;; row 1
		(vector-set! tmp (+ 0 (* 1 sz)) (vector-ref v (+ (+ i 0) (* (+ j 1) size))))
		(vector-set! tmp (+ 1 (* 1 sz)) (vector-ref v (+ (+ i 1) (* (+ j 1) size))))
		(vector-set! tmp (+ 2 (* 1 sz)) (vector-ref v (+ (+ i 2) (* (+ j 1) size))))
		;; row 2
		(vector-set! tmp (+ 0 (* 2 sz)) (vector-ref v (+ (+ i 0) (* (+ j 2) size))))
		(vector-set! tmp (+ 1 (* 2 sz)) (vector-ref v (+ (+ i 1) (* (+ j 2) size))))
		(vector-set! tmp (+ 2 (* 2 sz)) (vector-ref v (+ (+ i 2) (* (+ j 2) size))))
		;; assign tmp to overall result
		(vector-set! res (+ x (* y n3)) tmp)
		;; 
		(set! i (+ i 3))
		(when (>= i size)
		  (set! i 0)
		  (set! j (+ j 3)))		
		)))
    res))



;; this is just vector-map . with function lookup
(define (v-split3-lookup v)
  (let* ((size (sqrt (vector-length v)))
	 (res (make-vector (* size size) 0)))
    (for (y 0 (- size 1) 1)
	 (for (x 0 (- size 1) 1)
	      (let ((pat (vector-ref v (+ x (* y size)))))
		(vector-set! res (+ x (* y size)) (lookup pat))
		)))
    res))




;; each element of v expands from 4 x 4 so 4 times bigger each way
(define (v-split3-flat v)
  (let* ((vsize (sqrt (vector-length v)))
	 (rsize (* vsize 4)) 
	 (res (make-vector (* rsize rsize) 0))
	 (by4 4)
	 (tn 0)
	 )
    (for (y 0 (- vsize 1) 1)	 
	 (for (x 0 (- vsize 1) 1)

	      ;; (format #t "~%")
	      ;; vec is a 4 x 4 matrix
	      (let* ((vec (vector-ref v (+ x (* y vsize)))))
		(for (iy 0 (- by4 1) 1)
		     (for (ix 0 (- by4 1) 1)
			  (let ((val (vector-ref vec (+ ix (* iy by4))))
				(tx (+ ix (* x by4)))
				(ty (+ iy (* y by4))))
			    ;;(format #t "setting ~a , ~a  <-  ~a ~%" tx ty val)
			    (vector-set! res (+ tx (* ty rsize)) val )
			    ;;(vector-set! res (+ ix (* x by3) (* (+ y (* iy by3)) rsize)) val)
			    ;;(format #t "read ~a from ~a ~a ~%" val ix iy)
			    ;;#t
			    ))))))
    res))






(define (v-split3 v size)
  (let* ((v3 (v-split3-stage-1 v size))
	 (v4 (v-split3-lookup v3))
	 (v5 (v-split3-flat v4))
	 )
    ;; (format #t "debug ~%")
    ;; (show-matrix v3)
    ;; (format #t "lookup'ed ~%")
    ;; (show-matrix v4)
    ;; (format #t " --- done lookup ---  ~%")
    ;; (format #t "flattened ~%")
    ;; (show-matrix v5)
    ;; (format #t " -- done flattened -- ~%")
    v5
    ))





;; -----------------------------------------------------------------------



(define (show-matrix v)
  (let ((n (sqrt (vector-length v))))
    (assert (integer? n))
    (for (y 0 (- n 1) 1)
	 (format #t "~%")
	 (for (x 0 (- n 1) 1)
	      (let ((val (vector-ref v (+ x (* y n)))))
		(format #t "~a " val)
		)))
    (format #t "~%")))


(define (matrix-size v)
  (sqrt (vector-length v)))


(define (count-matrix-ones v)
  (let* ((size (sqrt (vector-length v)))
	 (tot 0))
    (for (y 0 (- size 1) 1)
	 (for (x 0 (- size 1) 1)
	      (let ((val (vector-ref v (+ x (* y size)))))
		(cond
		 ((= val 1) (set! tot (+ tot 1)))))))
    tot))


;; -----------------------------------------------------

#|

.#.
..#
###

|#

(define (e0) #(  0 1 0
		 0 0 1
		 1 1 1 ))


;; e1 is 4 x 4  here list of 16 values
(define (e1) (lookup (e0)))

;; two split + lookups to 3 x 3 + new matrix + flatten ?
(define (e2) (v-split (e1)))
(define (e3) (v-split (e2)))
(define (e4) (v-split (e3)))
(define (e5) (v-split (e4)))


(define (e-iter n)
  (cond
   ((= n 0) (e0))
   ((= n 1) (e1))
   (#t ;; bootstrapped so can iteratively call v-split
    (let ((result (e1)))
      (for (i 2 n 1)
	   (set! result (v-split result))
	   )
      result))))


(define (size-chart lim) 
  (format #t "~%---------------- matrix size chart --------------- ~%")
  (format #t "e Nth : size  :  count ones ~%")
  (format #t "e~a : ~a  :  ~a ~%" 0 (matrix-size (e0)) (count-matrix-ones (e0)))
  ;; (format #t "e~a : ~a ~%" 1 (matrix-size (e1)))
  (let ((result (e1)))
    (for (i 1 lim 1)
	 (format #t "e~a : ~a  : ~a ~%" i (matrix-size result) (count-matrix-ones result))
	 (set! result (v-split result))
	 )
    #t))




(size-chart 18)




#|

---------------- matrix size chart ---------------

e Nth : size  :  count ones
----------------------------
e0 : 3  :  5 
e1 : 4  : 7 
e2 : 6  : 8 
e3 : 9  : 24 
e4 : 12  : 75 
e5 : 18  : 110  <<-------- ACCEPTED 
e6 : 27  : 194 
e7 : 36  : 630 
e8 : 54  : 961 
e9 : 81  : 1736 
e10 : 108  : 5948 
e11 : 162  : 8807 
e12 : 243  : 15832 
e13 : 324  : 53257 
e14 : 486  : 78898 
e15 : 729  : 141882 
e16 : 972  : 479341 
e17 : 1458  : 710858 
e18 : 2187  : 1277716  <<------ ACCEPTED

for 5th iteration 110 was ACCEPTED answer .

for 18th iteration 1277716 was ACCEPTED answer .

|#











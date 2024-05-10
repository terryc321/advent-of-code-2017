
(import scheme)
(import simple-exceptions)
(import expand-full)
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

;; ------------------------------- macros -------------------------------

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


#|      
;; loop template 
(letrec ((foo (lambda (i step lim)
		      (cond
		       ((> i lim) #f)
		       (#t
			(format #t " i = ~a ~%" i )
			(foo (+ i step) step lim))))))
	(foo 1 1 10))
|#

;; template
;; (for i 1 10 1 ...)

;; (define (macro/for v . body)
;;   (let ((var (car v))
;; 	(init (cadr v))
;; 	(step (caddr v))
;; 	(by (cadddr v))	      
;; 	(foo (gensym "foo"))
;; 	(v-i (gensym "i"))
;; 	(v-step (gensym "step"))
;; 	(v-lim (gensym "lim")))
;;     `(begin
;;        (letrec ;; want to capture var
;; 	   ((,foo (lambda (,var ,v-step ,v-lim)
;; 		   (cond
;; 		    ((> ,var ,v-lim) #f)
;; 		    (#t
;; 		     ,@body
;; 		     (,foo (+ ,var ,v-step) ,v-step ,v-lim))))))
;; 	 (,foo ,init ,step ,by)))))

;; (pp (macro/for '(i 1 10 2) '(format #t "i = ~a ~%")))
;; (define-macro (for v . body)
;;   (macro/for v @body))
;; (for (i 1 10 1) (format #t "i = ~A ~%" i))

#|
simplest for loop macro my brain can manage at quick notice
defmacro , no hygiene ,,,
|#
(define-macro (for v . body)
  (let ((var (car v))
	(init (cadr v))
	(step (caddr v))
	(by (cadddr v))	      
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
	 (,foo ,init ,step ,by)))))

;;(pp (expand* '(for (i 1 10 1) (format #t "i = ~A ~%" i))))


(define (tests)
  (for (i 1 1 10) (format #t " i = ~a ~%" i ))
  (for (i 1 1 10)
       (for (j 1 1 10)
	    (format #t "  i= ~a : j = ~a ~%" i j))))




;; ---------------------------------------------------------------------------


#|

p1 : problem 1

four matrices 
a : ((1 2)(3 4))
b : ((5 6)(7 89))
c : ((9 10)(11 12))
d : ((13 14)(15 16))

into one matrix
m : ((a b)(c d))

flattern matrix so returns result

((1 2 3 4)(5 6 7 8)(9 10 11 12)(13 14 15 16))


|#




;; iterate over each row in matrix m  - a dolist will suffice -- wont get results ? maybe map ?
;;(dolist (v p1)(format #t "v = ~A ~%" v))
;;(map f p1) ... what is f
;;
;;  suppose v : (((1 2) (3 4)) ((5 6) (7 8))) 
;;  ((1 2) (5 6)) take all 1st elements  = (map car v) 
;;                                         (map (lambda (z) (list-ref z 0)) v)   ;; 
;;
;;
;;  ((3 4) (7 8))  take all 2nd elements = (map cadr v)
;;                                         (map (lambda (z) (list-ref z 1)) v)
;;
;;  (length (car v)) : 2
;;
;;  in general case (car v) is L
;;   ............ take all i-th elements = (map (lambda (z) (list-ref z i)) v)

;; ---------- GOLD -------- GOLD ---------- GOLD -----------------
;; 1 ) apply f to every row of matrix m and append the results together.
;; 2 ) f given a row , computes length of first column
;; 3 ) for every column take the i-th element of that list and append all the results together
;; 4 ) iota size , eg size = 3  iota = list ( 0 1 2 ) 
(define (flat m)
  (let ((f (lambda (c)
	     (let ((size (length (car c))))
	       (map (lambda (i)
		      (apply append (map (lambda (z) (list-ref z i)) c)))
		    (iota size))))))
    (apply append (map f m))))
;; ----------- GOLD ------- GOLD --------- GOLD ---------------------


;; matrix contains one sub-matrix a , a is a 3x3 matrix
(define p0
  (let ((a '((1 2 3)(4 5 6)(7 8 9))))
    `((,a))))

(define p00
  (let ((a '((1 2 3)(4 5 6)(7 8 9))))
    `((,a ,a)
      (,a ,a))))





;; ;; 
;;        ( ((1 2)(3 4))    ((5 6)(7 8))     )
;;        ( ((9 10)(11 12)) ((13 14)(15 16)) )	  

(define p1
  (let ((a '((1 2)(3 4)))
	(b '((5 6)(7 8)))
	(c '((9 10)(11 12)))
	(d '((13 14)(15 16)))
	)
    `((,a ,b)(,c ,d))))


#|
#;3947> p1
((((1 2) (3 4)) ((5 6) (7 8))) (((9 10) (11 12)) ((13 14) (15 16))))
#;3949> (flat p1)
((1 2 5 6) (3 4 7 8) (9 10 13 14) (11 12 15 16))
|#

;; p2 is 2 x 2 matrix containing four 3 x 3 matrices
;; matrix a b are on same row
;; matrix c d are on same row
;; we like to be able to flatten matrix 
(define p2
  (let ((a '((1 2 3)(4 5 6)(7 8 9)))
	(b '((10 11 12)(13 14 15)(16 17 18)))
	(c '((19 20 21)(22 23 24)(25 26 27)))
	(d '((28 29 30)(31 32 33)(34 35 36)))
	)
    `((,a ,b)(,c ,d))))
#|
#;4453> (pp p2)
((((1 2 3) (4 5 6) (7 8 9)) ((10 11 12) (13 14 15) (16 17 18))) ;; < - two 3 x 3 matrices 
 (((19 20 21) (22 23 24) (25 26 27)) ((28 29 30) (31 32 33) (34 35 36)))) ; < two 3 x 3 matrices

#;4324> (pp (flat p2)) ;; correctly flattened as required
((1 2 3 10 11 12)
 (4 5 6 13 14 15)
 (7 8 9 16 17 18)
 (19 20 21 28 29 30)
 (22 23 24 31 32 33)
 (25 26 27 34 35 36))

|#

#|

divisible by 2 then makes 2 x 2 matrices -> enhance to 3x3 matrices
divisible by 3 then makes 3 x 3 matrices -> enhance to 4x4 matrices
    3 , 6 , 9 , 12 



task to flatten 3 x 3 matrices which are all square
task to flatten 4 x 4 matrices 

                 a b
                 c d

how can we get some basic colour syntax highlight in edwin scheme mit-scheme ??

|#


     
;; auto generate test case code ...
;;---
;; a b c
;; d e f
;; g h i
(define p3
  (let ((a '((1 2 3)(4 5 6)(7 8 9)))
	(b '((10 11 12)(13 14 15)(16 17 18)))
	(c '((19 20 21)(22 23 24)(25 26 27)))
	(d '((28 29 30)(31 32 33)(34 35 36)))	
	)
    `((,a ,b)(,c ,d))))


;; 1 to 9 increment by 1 and split into 3 groups
;; assume positive for now 
(define (sseq count start n)
  (letrec ((foo (lambda (xs ys)
		  (cond
		   ((null? xs) (reverse ys))
		   (#t (foo (drop xs n) (cons (take xs n) ys)))))))
    (foo (iota count start) '())))







;; val (list-ref (list-ref (list-ref (list-ref m y) x) d) c)))
;; ;; flatten matrix m 
;; (define (flat m) ; given some matrix in lisp format row 1 , row 2 ... ron N 
;;   (let ((size (- 2 1))) ;; zero based indexing - one less than size of matrix
;;     (for (y 0 1 size) ; row in matrix
;; 	 (for (d 0 1 1) ; depth in sub-matrix
;; 	      (for (x 0 1 size) ; col in matrix
;; 		   (for (c 0 1 1) ; col in sub-matrix
;; 			(let* ((ly (list-ref m y))
;; 			       (lx (list-ref ly x))
;; 			       (ld (list-ref lx d))
;; 			       (lc (list-ref ld c))
;; 			       (val lc)
;; 			       )
;; 			  (format #t "ly = ~a : lx ~a : ld ~a  : lc ~a : VAL ~a ~%" ly lx ld lc val)
;; 			  )))))))
;;  FAIL  ...
;; ly = (((1 2) (3 4)) ((5 6) (7 8))) : lx ((1 2) (3 4)) : ld (1 2)  : lc 1 : VAL 1  < ok
;; ly = (((1 2) (3 4)) ((5 6) (7 8))) : lx ((1 2) (3 4)) : ld (1 2)  : lc 2 : VAL 2  < ok
;; ly = (((1 2) (3 4)) ((5 6) (7 8))) : lx ((5 6) (7 8)) : ld (5 6)  : lc 5 : VAL 5 <<-- wrong order
;; ly = (((1 2) (3 4)) ((5 6) (7 8))) : lx ((5 6) (7 8)) : ld (5 6)  : lc 6 : VAL 6  < no no no 
;; ly = (((1 2) (3 4)) ((5 6) (7 8))) : lx ((1 2) (3 4)) : ld (3 4)  : lc 3 : VAL 3  << wanted after 2
;; ly = (((1 2) (3 4)) ((5 6) (7 8))) : lx ((1 2) (3 4)) : ld (3 4)  : lc 4 : VAL 4  < 
;; ly = (((1 2) (3 4)) ((5 6) (7 8))) : lx ((5 6) (7 8)) : ld (7 8)  : lc 7 : VAL 7 
;; ly = (((1 2) (3 4)) ((5 6) (7 8))) : lx ((5 6) (7 8)) : ld (7 8)  : lc 8 : VAL 8 
;; ly = (((9 10) (11 12)) ((13 14) (15 16))) : lx ((9 10) (11 12)) : ld (9 10)  : lc 9 : VAL 9 
;; ly = (((9 10) (11 12)) ((13 14) (15 16))) : lx ((9 10) (11 12)) : ld (9 10)  : lc 10 : VAL 10 
;; ly = (((9 10) (11 12)) ((13 14) (15 16))) : lx ((13 14) (15 16)) : ld (13 14)  : lc 13 : VAL 13 
;; ly = (((9 10) (11 12)) ((13 14) (15 16))) : lx ((13 14) (15 16)) : ld (13 14)  : lc 14 : VAL 14 
;; ly = (((9 10) (11 12)) ((13 14) (15 16))) : lx ((9 10) (11 12)) : ld (11 12)  : lc 11 : VAL 11 
;; ly = (((9 10) (11 12)) ((13 14) (15 16))) : lx ((9 10) (11 12)) : ld (11 12)  : lc 12 : VAL 12 
;; ly = (((9 10) (11 12)) ((13 14) (15 16))) : lx ((13 14) (15 16)) : ld (15 16)  : lc 15 : VAL 15 
;; ly = (((9 10) (11 12)) ((13 14) (15 16))) : lx ((13 14) (15 16)) : ld (15 16)  : lc 16 : VAL 16 





  



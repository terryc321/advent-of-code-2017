

#|
scanner puzzle

depth 2
1 2 1
0 1 2
anything mod 2 

depth 3 
1 2 3 2 1
0 1 2 3 4 
anything mod 4

depth 4
1 2 3 4 3 2 1
0 1 2 3 4 5 6 
mod 6

depth 5
1 2 3 4 5 4 3 2 1
0 1 2 3 4 5 6 7 8
mod 8

hmmm , can we model this ?? tired.
     

|#



(define input '(
		(0  3)
		(1  2)
		(2  5)
		(4  4)
		(6  4)
		(8  6)
		(10  6)
		(12  6)
		(14  8)
		(16  6)
		(18  8)
		(20  8)
		(22  8)
		(24  12)
		(26  8)
		(28  12)
		(30  8)
		(32  12)
		(34  12)
		(36  14)
		(38  10)
		(40  12)
		(42  14)
		(44  10)
		(46  14)
		(48  12)
		(50  14)
		(52  12)
		(54  9)
		(56  14)
		(58  12)
		(60  12)
		(64  14)
		(66  12)
		(70  14)
		(76  20)
		(78  17)
		(80  14)
		(84  14)
		(86  14)
		(88  18)
		(90  20)
		(92  14)
		(98  18)
		))


;; example 
(define example '(
		  (0  3)
		  (1  2)
		  (4  4)
		  (6  4)
		  ))


;; build a scanner from a number initially at 1 .. 2 ... 3 ... 2 .. .1


;; --- simpler version ---
;;(define (up-down k)

#|

(up-down 1 1 'up)

this is a badly written incorrect version 
  (lambda 
  (format #t "n = ~a : k = ~a : dir = ~a ~%" n k dir)
  (cond
   ((eq? dir 'up) 
    (let ((n2 (+ n 1))
	  (n3 (- n 1)))
      (cond
       ((> n2 k) (cond
		  ((< n3 1) (up-down 1 k 'up))
		  (#t (up-down n3 k 'down))))
       (#t (up-down n2 k 'up)))))
   (#t
    (let ((n2 (+ n 1))
	  (n3 (- n 1)))
      (cond
       ((< n3 1) (cond
		  ((> n2 k) (up-down 1 k 'down))
       		  (#t (up-down n2 k 'up))))
       (#t (up-down n3 k 'down)))))))

X = 1 2 3
    Y = X ++ ( cdr (reverse (cdr X )))
Y =  1 2 3 2
then keep repeating Y 

|#


(define (my-iota n)
  (cond
   ((< n 1) '())
   (#t 
    (letrec ((foo (lambda (i xs)
		    (cond
		     ((>= i n) (reverse xs))
		     (#t (foo (+ i 1) (cons i xs)))))))
      (foo 0 '())))))

(define iota my-iota)
;; (import (chicken format))



(define (make-fn k x2)
  (cond
   ((< k 1) (lambda (op)
	      (cond
	       ((eq? op 'depth) 0)
	       ((eq? op 'x) x2)	       
	       (#t -1)))) ;; -1 we never reach here 
   ((= k 1) (lambda (op)
	      (cond
	       ((eq? op 'depth) 1)
	       ((eq? op 'x) x2)	       
	       (#t 1)))) ;; return constant values never next anyway
   (#t
    (let* ((X (cdr (iota (+ k 1))))
	   (Y (append X (cdr (reverse (cdr X)))))
	   (xs Y))
      (lambda (op)
	(cond
	 ((eq? op 'x) x2)	       
	 ((eq? op 'next)
	  (let ((n (car xs)))
	    (set! xs (cdr xs))
	    (when (null? xs) (set! xs Y))
	    n))
	 ((eq? op 'val)
	  (car xs))
	 ((eq? op 'depth)
	  k)
	 (#t (error (format #f "op unknown")))))))))




(define a (make-fn 1 0))
(define b (make-fn 2 0))
(define c (make-fn 3 0))

;; input not defined for all values
(define (find-last db)
  (apply max (map car db)))


(define (entries db)
  (let* ((n (find-last db))
	 (sparse (iota (+ n 1)))
	 (in 0))
    (letrec ((foo (lambda (xs ys zs in)
		    (cond
		     ((null? xs) (reverse zs))
		     (#t (let* ((ab (car ys))
				(a (car ab))
				(b (cadr ab))
				(x (car xs)))
			   ;;(format #t "x = ~a : ab = ~a ~%" x ab)
			   (cond
			    ((= x a) ;;(format #t "making proc depth ~a ~%" b)
			     (foo (cdr xs)(cdr ys) (cons (make-fn b in)
							 zs)
				  (+ in 1)))
			    (#t
			     ;;(format #t "making proc depth zero 0 ~%")
			     (foo (cdr xs) ys (cons (make-fn 0 in) zs) (+ in 1))))))))))
      (foo sparse db '() in))))




#|
;; items with zero depth return -1 as height , we are only ever at height 1 so no collision occurs

traverse over all functions and call them with no arguments
side effect of moving each object one step


|#
(define (solve in)
  (let ((i -1)
	(i-lim (find-last in))
	(db (entries in))
	(cost 0))
    (letrec ((foo (lambda ()
		    (set! i (+ i 1))
		    (cond
		     ((null? db) 'done)
		     (#t
		      ;; check if we hit
		      (let* ((fn (car db))
			     (n (fn 'val))
			     (dep (fn 'depth)))
			(cond
			 ((= n 1) (format #t "caught at index ~a ~%" i)
			  (set! cost (+ cost (* i dep))))
			 (#t (format #t "miss at index ~a ~%" i )))
			(map (lambda (fn) (fn 'next)) db)
			(set! db (cdr db))
			(foo)))))))
      (foo)
      (format #t "total cost ~a ~%" cost)
      cost)))



(define (wait in w)
  (let ((i -1)
	(i-lim (find-last in))
	(db (entries in))
	(wait w))
    (letrec ((foo (lambda (exit)
		    (cond
		     ((> wait 0) (set! wait (- wait 1)))
		     (#t (set! i (+ i 1))))
		    (cond
		     ((null? db) 'done)
		     (#t
		      ;; check if we hit only if i >= 0
		      (let* ((fn (car db))
			     (n (fn 'val))
			     (dep (fn 'depth)))

			(when (>= i 0)		      
			  (cond
			   ((= n 1)
			    (exit #f)
			    ;;(format #t "caught at index ~a ~%" i)
			    ;;(set! cost (+ cost (* i dep))))
			    )
			   (#t
			    ;;(format #t "miss at index ~a ~%" i )
			    )))
			
			(map (lambda (fn) (fn 'next)) db)
			(set! db (cdr db))
			(foo exit)))))))      
      (call/cc (lambda (exit)
		 (foo exit)
		 )))))



(define (solve-wait in)
  (let ((n 0))
    (letrec ((foo (lambda (exit)
		    (let ((result (wait in n)))
		      (when (eq? result 'done)
			(exit n)))
		    (set! n (+ n 1))
		    (foo exit))))
      (call/cc (lambda (exit)
		 (foo exit))))))


;;(defmacro ...)
(define-macro (repeat n . body)
  (let ((foo (gensym "g")))  
    `(letrec ((,foo (lambda (i)
		    (cond
		     ((> i 0) ,@body
		      (,foo (- i 1)))
		     (#t #f)))))
       (,foo ,n))))

(repeat 3 "hello world!")

(macroexpand '(repeat 3 "hello world!"))

#|

at depth 3 , when does get caught ? 




|#

(define (for-depth n i w)
  (let* ((i 0)
	 (fn (make-fn n i))
	 (x 0)
	 (t 0))
    (repeat w
	    (let ((at (fn 'val)))
	      (format #t "time ~a : at ~a : ~%" t at)	    
	      (fn 'next)
	      (set! x (+ x 1))
	      (set! t (+ t 1))))
	    	    
    (repeat (* 3 n)
	    (let ((dep (fn 'val)))
	      (format #t "time ~a : x = ~a : fx ~a , ~a: " t x (fn 'x) dep)
	      (cond
	       ((and (= (fn 'val) 1) (= x (fn 'x)))
		(format #t "--- caught ! ~%"))
	       (#t
		(format #t "~%")))
	      (fn 'next)
	      (set! x (+ x 1))
	      (set! t (+ t 1))))))




	    
;;(for-depth 3)

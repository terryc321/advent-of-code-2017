
#|

advent of code 2017
day 13

|#

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

(define example '(
		     (0  3)
		     (1  2)
		     (4  4)
		     (6  4)
		     ))


#|
difficulty defining list ref without clobbering original list-ref
(define old-list-ref list-ref)
(define (list-ref xs n)
  (
|#

(define (my/list-ref xs n)
  (list-ref xs (- n 1)))

    
  

#|
model the security scanner all start at top initially

scanner = example ?? 

depth = how far across scanner
range = how far up / down scanner is 

      <----- depth -------------->
      0   1   2   3   4   5   6
r
a  0 [S] [S] ... ... [S] ... [S]
n  1 [ ] [ ]         [ ]     [ ]
g  2 [ ]             [ ]     [ ]
e  3                 [ ]     [ ]
 

|#

#|
increment procedure - given a limit , returns a counter
when reaches counter - it resets back to zero
own mutable state
|#
(define true-counter
  (lambda (upper)    
    (let* ((lower 1)
	   (direction 1)
	   (index lower))
      (lambda (op)
	(cond
	 ((eq? op 'val) index)
	 ((eq? op 'fake) #f)
	 ((eq? op 'rng) upper)
	 ((eq? op 'inc)
	  (set! index (+ index direction))
	  (cond
	   ((positive? direction)
	    (cond
	     ((> index upper)
	     ;; negate direction
	     (set! direction (- direction)) 
	     (set! index (+ index direction))
	     (set! index (+ index direction))
	     )))
	   ((negative? direction) 
	    (cond
	     ((< index lower)
	      ;; negate direction
	      (set! direction (- direction)) 
	      (set! index (+ index direction))
	      (set! index (+ index direction))
	      )))))
	 (#t (error "counter")))))))




(define (test-counter)
  (do-for (limit 0 10)
	  (let ((p (true-counter limit)))
	    (format #t "~%*************** testing a counter with limit of ~a ******** ~%" limit)
	    (do-for (i 0 (* limit 3))
		    (format #t "p = ~a : next => ~a ~%" (p 'val) (begin (p 'inc) (p 'val)))))))


(define fake-counter
  (lambda ()
  (let ((i -1))
    (lambda (op)
      (cond
       ((eq? op 'val) i) ;; give a fake unreachable range value of negative one 
       ((eq? op 'fake) #t) ;; report i am a fake
       ((eq? op 'inc) #f) ;; ignore message
       ((eq? op 'rng) -1) ;; fake range value
       (#t (error "counter")))))))


#|

  (define example '(
		     (0  3)
		     (1  2)
		     (4  4)
		     (6  4)
		     ))

|#
(define (encode-scanner scanner)
  (let ((max-depth (apply max (map first scanner))))
    (letrec ((foo (lambda (xs n ys)
		    (cond
		     ((null? xs) ys)
		     (#t (let ((pair (car xs)))
			   (let ((i (first pair))
				 (range (second pair)))
			     (cond
			      ((= i n)
			       (foo (cdr xs) (+ n 1) (cons (true-counter range) ys)))
			      (#t
			       (foo xs (+ n 1) (cons (fake-counter) ys)))))))))))
      (let ((n 0))
	(reverse (foo scanner n '()))))))

#|

;; maybe same as object approach above - still require mutation so not any different here...
(define (extend scanner)
  (letrec ((foo (lambda (pair)
		  (append pair '(0)))))
(map foo scanner)))
|#

;; passing message to object is equivalent to
;; calling a function that will pass procedure argument (message) that mutates some state


;; graphical depiction of state
(define (depict state)
  (let ((max-rng (apply max (map (lambda (f) (f 'rng)) state)))
	(max-dep (length state)))
    ;; (format #t "max-rng = ~a ~%" max-rng)
    ;; (format #t "max-dep = ~a ~%" max-dep)    
    (format #t "~%*********** state *********** ~%")
    (do-for (r 1 (+ 1 max-rng))
	    (format #t "~%")
	    (do-for (d 1 (+ 1 max-dep))
		    (let ((proc (my/list-ref state d)))
		      (cond
		       ((proc 'fake) (cond
				      ((= r 0) (format #t      "... "))
				      (#t (format #t      "    "))))		       
		       ((= (proc 'val) r) (format #t "[S] "))
		       ((> r (proc 'rng)) (format #t "    "))
		       (#t (format #t "[ ] "))))))
    (format #t "~%")))



(define (model scanner)
  (let ((state (encode-scanner scanner))
	(step 0)
	(total-cost 0))    
    (do-for (depth 1 (+ 1 (length state)))
	    (format #t "~%")
	    (depict state)
	    ;; get state counter at depth [depth]
	    (let ((proc (my/list-ref state depth)))
	      (cond
	       ((= (proc 'val) 1)
		(format #t "***caught*** at depth ~a : puzzle depth ~a ~%" depth (- depth 1))
		(let* ((the-range (proc 'rng))
		       (the-depth (- depth 1))
		       (the-cost (* the-range the-depth)))
		  (format #t "*** the range [~a] : the depth [~a] : the cost [~a] ~%"
			  the-range
			  the-depth
			  the-cost)
		  (set! total-cost (+ total-cost the-cost))))))
		      
	    ;;(format #t "depth ~a : state ~%~a~%" depth (map (lambda (f) (f 'val)) state))
	    ;;(format #t "range ~a ~%" (map (lambda (f) (f 'rng)) state))
	    (map (lambda (f) (f 'inc)) state))
    total-cost))



#|

      my model caught at depth 1 and 7
in zero based puzzle caught at 0 and 6

(model input)
......
=> 2508

|#

  


























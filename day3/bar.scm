#|


spiral of numbers


start with 1 at some coordinate (x,y)
move right 1 label that 2
move up 1 label that 3

move left 2
move down 2

move right 3
move left 3

move down 4
move right 4

move up 5
move left 5

right -> up -> left -> down -> ... right
 1       1      2       2      3  3      4 4   5  5 
           

|#


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

(define input 277678)
;;(define input (get-input))


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

(define hash #f)

(define hash2 #f)


(define (reset)
  (set! hash (make-hash-table))
  (set! hash2 (make-hash-table))
  (hash-table-set! hash2 (list 0 0) 1)
  )


#|
n counter from 1 ...
x position
y position
d direction
s steps
c count 
|#


(define (iter n x y d s c escape)
  (let ((x2 x)
	(y2 y)
	(n2 n))
    ;;(format #t "~a : at ~a , ~a  ~%" n2 x2 y2)
    
    (when (= n input)
      (format #t "~a : at ~a , ~a  ~%" n2 x2 y2))
    
    (cond
     ((< c 1) (iter n x y d (+ s 1) 2 escape)) ;; arg
     ;;((> n input) 'done)
     (#t 
      (letrec ((lookup (lambda (x3 y3)
			 (let ((n3 (hash-table-ref/default hash2 (list x3 y3) 0)))
			   (format #t "lookup ~a ~a => ~a ~%" x3 y3 n3)
			   n3)))
	       (record (lambda ()
			 ;;(format #t "~a : at ~a , ~a  ~%" n2 x2 y2)
			 (hash-table-set! hash (list x2 y2) n2)
			 (let ((val (+ (lookup (- x2 1) (- y2 1))
				       (lookup (+ x2 1) (- y2 1))
				       (lookup x2 (- y2 1))
				       (lookup (- x2 1) y2)
				       (lookup (+ x2 1) y2)
				       (lookup (- x2 1) (+ y2 1))
				       (lookup (+ x2 1) (+ y2 1))
				       (lookup x2 (+ y2 1)))))
			   (when
			       (and (= x2 0)(= y2 0))
			     (set! val 1))
			    
			   (hash-table-set! hash2 (list x2 y2) val)
			   (format #t "~a : at ~a , ~a : val => ~a ~%" n2 x2 y2 val)
			   (cond
			    ((> val input)
			     (format #t "first values written ~a ~%" val)
			     (escape val))))))
	       (right (lambda ()  (record) (set! n2 (+ n2 1))  (set! x2 (+ x2 1))))
	       (left (lambda ()  (record)  (set! n2 (+ n2 1)) (set! x2 (- x2 1))))
	       (up (lambda ()  (record)   (set! n2 (+ n2 1)) (set! y2 (- y2 1))))
	       (down (lambda ()  (record)  (set! n2 (+ n2 1))  (set! y2 (+ y2 1))))
	       (next-dir (lambda (d)
			   (cond
			    ((eq? d 'right) 'up)
			    ((eq? d 'left) 'down)
			    ((eq? d 'down) 'right)
			    ((eq? d 'up) 'left)
			    (#t (error "next-dir")))))
	       )	   
	(do-for i (1 (+ s 1) 1)	    
		(cond
		 ((eq? d 'right) (right))
		 ((eq? d 'left) (left))
		 ((eq? d 'down) (down))
		 ((eq? d 'up) (up))
		 (#t (error "dir"))))
	(iter n2  x2 y2 (next-dir d) s (- c 1) escape))))))
        ;;(iter n x  y      d        s      c  escape)
    
(reset)


(define (run)
  (let ((n 1)(x 0)(y 0)(dir 'right)(steps 1)(count 2))
    (call/cc (lambda (escape)
    (iter n x y dir steps count escape)))))


(define (leftpad s n)
  (let ((slen (string-length s)))
  (cond
   ((> n slen) (leftpad (string-append " " s) n))
   (#t s))))



(define (viz w)
  (let ((lo (- w))
	(hi (+ w)))
    (format #t "~%")    
    (do-for y ((- w) (+ w 1) 1)
	    (do-for x ((- w) (+ w 1) 1)
		    (let ((n (hash-table-ref hash (list x y))))
		      (format #t "~a " (leftpad (format #f "~a" n) 8))
		      ))
	    (format #t "~%"))))




(define (viz2 w)
  (let ((lo (- w))
	(hi (+ w)))
    (format #t "~%")    
    (do-for y ((- w) (+ w 1) 1)
	    (do-for x ((- w) (+ w 1) 1)
		    (let ((n (hash-table-ref/default hash2 (list x y) 0)))
		      (format #t "~a " (leftpad (format #f "~a" n) 8))
		      ))
	    (format #t "~%"))))




#|

1 at 0 ,0

277678 : at 212 , 263  

manhattan 212 + 263
(+ 212 263)
475

first values written 279138 
279138


       0        0        0        0        0        0   279138   266330   130654 
       0     6591     6444     6155     5733     5336     5022     2450   128204 
       0    13486      147      142      133      122       59     2391   123363 
       0    14267      304        5        4        2       57     2275   116247 
       0    15252      330       10        1        1       54     2105   109476 
       0    16295      351       11       23       25       26     1968   103128 
       0    17008      362      747      806      880      931      957    98098 
       0    17370    35487    37402    39835    42452    45220    47108    48065 
       0        0        0        0        0        0        0        0        0 
#;369> 

|#
	    
	








   
		    



  





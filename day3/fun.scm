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

(define (reset)
  (set! hash (make-hash-table)))

#|
n counter from 1 ...
x position
y position
d direction
s steps
c count 
|#


(define (iter n x y d s c)
  (let ((x2 x)
	(y2 y)
	(n2 n))
    ;;(format #t "~a : at ~a , ~a  ~%" n2 x2 y2)
    
    (when (= n input)
      (format #t "~a : at ~a , ~a  ~%" n2 x2 y2))
    
  (cond
   ((< c 1) (iter n x y d (+ s 1) 2))
   ((> n input) 'done)
   (#t 
    (letrec ((record (lambda ()
		       (format #t "~a : at ~a , ~a  ~%" n2 x2 y2)
		       (hash-table-set! hash (list x2 y2) n2)
		       #t
		       ))
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
      (iter n2 x2 y2 (next-dir d) s (- c 1)))))))

    
(reset)

(define (run)
  (let ((n 1)(x 0)(y 0)(dir 'right)(steps 1)(count 2))
    (iter n x y dir steps count)))


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



#|

1 at 0 ,0

277678 : at 212 , 263  

manhattan 212 + 263
(+ 212 263)
475



|#
	    
	








   
		    



  





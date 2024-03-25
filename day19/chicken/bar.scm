
#|

advent of code 2017
day 19

|#

(import scheme)
(import simple-exceptions)
(import (chicken bitwise)) ;; --- bit operations

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
series of tubes

example = small
input = larger network

start position ??
continue on path until can no longer must change direction

(change-directory "../")
(change-directory "day19/chicken")

input = list of strings of length 201
example = list of strings of length

space            --- empty 
characters + - | ---
other letters    ---

|#

(define (tag x y)
  (cons x y))

(define (type-of x)
  (car x))

(define (untag x)
  (cdr x))

(define (grid? x)
  (and (pair? x) (eq? (car x) 'grid)))

;; convert a list of strings to a two dimensional grid
;; up to user to supply correct input for the puzzle
;; we do no checking here
(define (convert-to-grid xs)
  (let ((hash (make-hash-table))
	(slen (string-length (car xs)))
	(x 1)
	(y 1)
	(letters '()))
    (do-list (str xs)
	     (do-for (i 0 slen)
		     (let ((x (+ i 1))
			   (ch (string-ref str i)))
		       (cond
			((char=? #\space ch) #f)
			((char=? #\+ ch) (hash-table-set! hash (list x y) 'cross))
			((char=? #\- ch) (hash-table-set! hash (list x y) 'horz))
			((char=? #\| ch) (hash-table-set! hash (list x y) 'vert))
			(#t (hash-table-set! hash (list x y) (list 'letter ch))
			    (set! letters (cons ch letters))))
		       (format #t "wokring on x [~a ] , y [~a] : ~a~%" x y ch)
		       ))
	     (set! y (+ y 1)))
    (hash-table-set! hash 'width slen)
    (hash-table-set! hash 'height (length xs))
    (hash-table-set! hash 'letters  (sort letters char<?))
    (tag 'grid hash)))



(define (strings-from-grid g)
  (assert (grid? g))
  (let* ((hash (untag g))
	 (width (hash-table-ref hash 'width))
	 (height (hash-table-ref hash 'height)))
    (format #t "width ~a : height ~a ~%" width height)
    ))




(define input
  (convert-to-grid
   (with-input-from-file "input" (lambda () (read-lines)))))

(define example
  (convert-to-grid
   (with-input-from-file "example" (lambda () (read-lines)))))

;; grid entry may yield false -- no entry for that square
(define (grid-entry g x y)
  (let* ((hash (untag g)))
    (hash-table-ref/default hash (list x y) #f)))
  

(define (find-start-square g)
  (assert (grid? g))
  (call/cc (lambda (found)
	     (let* ((hash (untag g))    
		    (width (hash-table-ref hash 'width))
		    (height (hash-table-ref hash 'height)))
	       (do-for (x 1 width)
		       (let ((y 1))
			 (let ((elem (grid-entry g x y)))
			   (cond
			    ((eq? elem 'vert) (found (list x y)))))))
	       (error "find-start-square not-found")))))

#|
really only the cross + that means a direction change required

up on grid is negative y
down on grid is positive y

|#


(define (iterate g x y direction letters result steps)
  
  (define (go-right)
    (format #t "going right ~%")
    (iterate g (+ x 1) y 'right letters result (+ 1 steps)))
  (define (go-left)
    (format #t "going left ~%")
    (iterate g (- x 1) y 'left letters result (+ 1 steps)))
  (define (go-up)
    (format #t "going up ~%")
    (iterate g x (- y 1) 'up letters result (+ 1 steps)))
  (define (go-down)
    (format #t "going down ~%")
    (iterate g x (+ y 1) 'down letters result (+ 1 steps)))
  (define (found-letter ch)
    (format #t "found letter ~a ~%" ch)
    (cond
     ((not (member ch letters))
      (iterate g x y direction (cons ch letters) result steps))))
  
  (define (go-left-or-right)
      (let ((elem-right (grid-entry g (+ x 1) y))
	    (elem-left (grid-entry g (- x 1) y)))
	(cond
	 ((and elem-right (not elem-left)) (go-right))
	 ((and (not elem-right) elem-left) (go-left))
	 (#t (error "iterate undecidable left or right - either both viable or none are viable")))))

  (define (go-up-or-down)
      (let ((elem-up (grid-entry g x (- y 1)))
	    (elem-down (grid-entry g x (+ y 1))))
	(cond
	 ((and elem-up (not elem-down)) (go-up))
	 ((and (not elem-up) elem-down) (go-down))
	 (#t (error "iterate undecidable up or down - either both viable or none are viable")))))
  
  ;; entry
  (format #t "iterate position ~a ~a with direction ~a and letters found so far ~a ~%" x y direction letters)
  (let ((elem (grid-entry g x y)))
    (format #t "elem [~a] at grid [~a] [~a] ~%" elem x y)
    ;; record letters
    (cond
     ((and (pair? elem) (eq? (car elem) 'letter)) (found-letter (second elem))))
    
    (cond
     ((and (eq? elem 'cross) (eq? direction 'down)) (go-left-or-right))
     ((and (eq? elem 'cross) (eq? direction 'up))   (go-left-or-right))
     ((and (eq? elem 'cross) (eq? direction 'left)) (go-up-or-down))
     ((and (eq? elem 'cross) (eq? direction 'right)) (go-up-or-down))
     ;; where return result of iteration
     ((eq? elem #f) 
      (format #t "iterate element on grid is empty space should not reach here~%")
      (result (list 'letters (reverse letters) 'steps (- steps 1))))
     (#t (cond
	  ((eq? direction 'down) (go-down))
	  ((eq? direction 'up) (go-up))
	  ((eq? direction 'left) (go-left))
	  ((eq? direction 'right) (go-right))
	  (#t (error "iterate continue direction direction unknwon not up left down right ?")))))))


     
	  


(define (puzzle g)
  (let* ((start (find-start-square g))
	 (x (first start))
	 (y (second start))
	 (direction 'down)
	 (letters '())
	 (steps 1))
    (call/cc (lambda (result)
	       (iterate g x y direction letters result steps)))))

#|

(puzzle input)
...
iterate position 69 28 with direction right and letters found so far (P T A Q D M H O L) 
elem [#f] at grid [69] [28] 
iterate element on grid is empty space should not reach here
(letters (#\L #\O #\H #\M #\D #\Q #\A #\T #\P) steps 16492)

16492
accepted answer


(puzzle example)
...
elem [#f] at grid [1] [4] 
iterate element on grid is empty space should not reach here
(letters (#\A #\B #\C #\D #\E #\F) steps 38)


|#



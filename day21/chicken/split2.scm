
#|
split.scm

split vec2d into sub vec2d 's such we can then do
 £ (map-lookup vec input-map)

|#

;; all vec2d should be square no ?
(define (vec2d-size s)
  (vector-length s))

(define (split-vec2d s)
  s)

#|
'((0 1 2 3) (4 5 6 7) (8 9 10 11) (12 13 14 15))

into sub grids
(( ((0 1)
    (4 5))  ((2 3)
	     (6 7)) )
 ( ((8 9)
    (12 13))  ((10 11)
	       (14 15)) ))

;; can we make this ? 
'((0 1 2 3) (4 5 6 7) (8 9 10 11) (12 13 14 15))
(make-square 4)  ;; ((0 1 2 3) (4 5 6 7) (8 9 10 11) (12 13 14 15))

|#

(define (make-square n)
  (let ((result '())
	(i 0))    
    (dolist (v (iota n))
	    (set! result (cons (iota n i) result))
	    (set! i (+ i n)))
    (reverse result)))

(define (group-grids gs n)
  (letrec ((foo (lambda (xs ys)
		  (cond
		   ((null? xs) (reverse ys))
		   (#t (foo (drop xs n) (cons (take xs n) ys)))))))
    (foo gs '())))

;; alternative definition
;; (define (make-square n) (group-grids (iota (* n n)) n))

(define (sub-pairs xs)
  (let ((len (length (car xs))))
    (assert (= len (length (car xs))))
    (assert (= len (length (cadr xs))))
    (letrec ((foo (lambda (as bs cs)
		  (cond
		   ((null? as) (reverse cs))
		   (#t (foo (drop as 2) (drop bs 2)
			    (cons (append (take as 2) (take bs 2)) cs)))))))
      (foo (car xs) (cadr xs) '()))))

;; split grid into grids of 2 x 2
(define (split-grid2 xs)
  (let* ((size (length (car xs)))
	 (wid (/ size 2))
	 (groups (group-grids xs 2)))
    ;; size must be even
    (assert (= 0 (modulo size 2)))
    (apply append (map sub-pairs groups))))



(define (sub-triples xs)
  (let ((len (length (car xs))))
    (assert (= len (length (car xs))))
    (assert (= len (length (cadr xs))))
    (letrec ((foo (lambda (as bs cs)
		  (cond
		   ((null? as) (reverse cs))
		   (#t (foo (drop as 3) (drop bs 3)
			    (cons (append (take as 3) (take bs 3)) cs)))))))
      (foo (car xs) (cadr xs) '()))))



;; split grid into grids of 3 x 3
(define (split-grid3 xs)
  (let* ((size (length (car xs)))
	 (wid (/ size 3)))
    (format #t "size = ~a ~%" size)
    (cond
     ((= wid 1) xs)
     (#t (let ((groups (group-grids xs 3)))
	   ;; size must be even
	   (assert (= 0 (modulo size 3)))
	   (apply append (map sub-triples groups)))))))











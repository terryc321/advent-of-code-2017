
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
  (map (lambda (i) (list-ref xs i)) '(2 0 3 1)))

(define (rot2d-2 xs) (rot2d-1 (rot2d-1 xs)))

(define (rot2d-3 xs) (rot2d-1 (rot2d-1 (rot2d-1 xs))))

(define (rot2d-4 xs) (rot2d-1 (rot2d-1 (rot2d-1 (rot2d-1 xs)))))

(define (ref2d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(1 0 3 2)))

(define (ref2d-2 xs)
  (map (lambda (i) (list-ref xs i)) '(2 3 0 1)))


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
  (map (lambda (i) (list-ref xs i)) '(  6 3 0
					7 4 1
					8 5 2)))

(define (rot3d-2 xs) (rot3d-1 (rot3d-1 xs)))

(define (rot3d-3 xs) (rot3d-1 (rot3d-1 (rot3d-1 xs))))

(define (rot3d-4 xs) (rot3d-1 (rot3d-1 (rot3d-1 (rot3d-1 xs)))))

(define (ref3d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(  6 7 8
					3 4 5
					0 1 2)))

(define (ref3d-2 xs)
  (map (lambda (i) (list-ref xs i)) '(  2 1 0
					5 4 3
					8 7 6)))


#|

4 x 4 routines

rotation 90 degree right
0  1  2   3             12   8    4  0
4  5  6   7             13   9    5  1
8  9  10 11             14   10   6  2
12 13 14 15             15   11   7  3

reflect horiz
0 1 2  3           3  2  1 0
4 5 6  7           7  6  5 4
8 9 10 11          11 10 9 8

reflect vert
0 1 2  3            8 9 10 11
4 5 6  7            4 5 6  7
8 9 10 11           0 1 2  3


|#

(define (rot4d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(   12 8  4 0
					 13 9  5 1
					 14 10 6 2
					 15 11 7 3
				      )))

(define (rot4d-2 xs) (rot4d-1 (rot4d-1 xs)))

(define (rot4d-3 xs) (rot4d-1 (rot4d-1 (rot4d-1 xs))))

(define (rot4d-4 xs) (rot4d-1 (rot4d-1 (rot4d-1 (rot4d-1 xs)))))

(define (ref4d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(  3 2 1 0
					7 6 5 4
					11 10 9 8
					)))

(define (ref4d-2 xs)
  (map (lambda (i) (list-ref xs i)) '(  8 9 10 11
					4 5 6  7
					0 1 2  3
					)))



;; permute2 maps changes to 2x2 with 3x3 together
(define (rotate-flip-permute2 from2 to3)
  (let ((known '()))
    (letrec ((foo (lambda (a b)
		    (cond
		     ((member (list a b)  known) #f)
		     (#t (set! known (cons (list a b) known))
			 (foo (rot2d-1 a) (rot3d-1 b))
			 (foo (rot2d-2 a) (rot3d-2 b))
			 (foo (rot2d-3 a) (rot3d-3 b))
			 (foo (rot2d-4 a) (rot3d-4 b)) ;; redundant 4 rotations
			 (foo (ref2d-1 a) (ref3d-1 b))
			 (foo (ref2d-2 a) (ref3d-2 b))
			 )))))
      (foo from to)
      known)))



;; permute maps changes to 3x3 with 4x4 together
(define (rotate-flip-permute3 from to)
  (let ((known '()))
    (letrec ((foo (lambda (a b)
		    (cond
		     ((member (list a b) known) #f)
		     (#t (set! known (cons (list a b) known))
			 (foo (rot3d-1 a) (rot4d-1 b))
			 (foo (rot3d-2 a) (rot4d-2 b))
			 (foo (rot3d-3 a) (rot4d-3 b))
			 (foo (rot3d-4 a) (rot4d-4 b)) ;; redundant 4 rotations
			 (foo (ref3d-1 a) (ref4d-1 b))
			 (foo (ref3d-2 a) (ref4d-2 b))
			 )))))
      (foo from3 to4)
      known)))


(define (rotate-flip-permute from to)
  (cond
   ((= (length from) 4) (reverse (rotate-flip-permute2 from to)))
   ((= (length from) 9) (reverse (rotate-flip-permute3 from to)))
   (#t (error "rotate-flip-permute"))))



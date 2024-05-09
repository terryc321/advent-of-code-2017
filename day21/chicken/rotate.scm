
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

(define (rotate-flip-permute2 s)
  (let ((known '()))
    (letrec ((foo (lambda (s)
		    (cond
		     ((member s known) #f)
		     (#t (set! known (cons s known))
			 (foo (rot2d-1 s))
			 (foo (rot2d-2 s))
			 (foo (rot2d-3 s))
			 (foo (rot2d-4 s))
			 (foo (ref2d-1 s))
			 (foo (ref2d-2 s)))))))
      (foo s)
      known)))


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
  (map (lambda (i) (list-ref xs i)) '(6 3 0
					7 4 1
					8 5 2)))

(define (rot3d-2 xs) (rot3d-1 (rot3d-1 xs)))

(define (rot3d-3 xs) (rot3d-1 (rot3d-1 (rot3d-1 xs))))

(define (rot3d-4 xs) (rot3d-1 (rot3d-1 (rot3d-1 (rot3d-1 xs)))))

(define (ref3d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(6 7 8
					3 4 5
					0 1 2)))

(define (ref3d-2 xs)
  (map (lambda (i) (list-ref xs i)) '(2 1 0
					5 4 3
					8 7 6)))

(define (rotate-flip-permute3 s)
  (let ((known '()))
    (letrec ((foo (lambda (s)
		    (cond
		     ((member s known) #f)
		     (#t (set! known (cons s known))
			 (foo (rot3d-1 s))
			 (foo (rot3d-2 s))
			 (foo (rot3d-3 s))
			 (foo (rot3d-4 s))
			 (foo (ref3d-1 s))
			 (foo (ref3d-2 s)))))))
      (foo s)
      known)))

;; -----------------------------------------------------------------------------
(define (rotate-flip-permute s)
  (cond
   ((= (length s) 4) (reverse (rotate-flip-permute2 s)))
   ((= (length s) 9) (reverse (rotate-flip-permute3 s)))
   (#t (error "find"))))


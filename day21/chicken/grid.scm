
#|

if grid size is divisible by 2 , split into 2 x 2 grids

if grid size is divisible by 3 , split into 3 x 3 grids


|#

(define (grid-size xs)
  (let ((root (sqrt (length xs))))
    (assert (integer? root))
    root))

(define (grid-size-divisible-by-2 xs)
  (= (modulo (grid-size xs) 2) 0))

(define (grid-size-divisible-by-3 xs)
  (= (modulo (grid-size xs) 3) 0))


;; (define (list->vec2d xs)
;;   (let* ((size (grid-size xs))
;; 	 (vec2d (make-vector size))
;; 	 (i 0))
;;     ;; careful make a fresh vector each 
;;     (dolist (v (iota size))
;; 	    (vector-set! vec2d v (make-vector size 0)))
;;     ;;(format #t "created vec2d => ~a ~%" vec2d)
;;     (dolist (y (iota size))
;; 	    (dolist (x (iota size))
;; 		    (let ((v (list-ref xs i)))
;; 		      ;;(format #t "~a ~a <- ~a : ~a ~%" x y i v)
;; 		      (vector-set! (vector-ref vec2d y) x v)
;; 		      (set! i (+ i 1)))))
;;     vec2d))


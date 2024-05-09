
;; try to pull everything together and make a solution ??

(define (map-lookup s m)
  (call/cc (lambda (found)
	     (dolist (pr m)
		     (let ((from (car pr))
			   (to (cadr pr)))
		       (cond
			((equal? from s) (found to)))))
	     (error "map-lookup not found"))))



;;".#./..#/###"
(define init-grid  (list->vec2d '(0 1 0       0 0 1       1 1 1)))

		      
      ;; 		     ((>= x size) (foo i 0 (+ y 1) lim))
      ;; 		     ((>= y size) vec2d)
      ;; 		     (#t (vector-set! (vector-ref vec2d y) x (list-ref xs i))
      ;; 			 (foo (+ i 1) (+ x 1) y lim))))))
      ;; (foo 0 0 0 (* size size)))))


(define t0 init-grid)

;; after 1 enhance
(define t1 (map-lookup init-grid input-map))

(define tmp2 (split-vec2d t1))







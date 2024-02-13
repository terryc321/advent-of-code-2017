

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

#|


|#
(define limit #f)
(define initial-size #f)
(define current #f)
(define vec #f)
(define counter #f)
(define last #f)

(define (reset)
  (set! last 0) ;; dummy last value
  (set! limit 0)
  (set! initial-size 1000000)
  (set! current 0)
  (set! vec (make-vector initial-size 0))
  (set! counter 0))


(define (show-few)
  ;; show few items from 0 to limit
  (do-for i (0 2)
	  (cond
	   ((= i current)
	    (format #t "(~a) " (vector-ref vec i)))
	   (#t (format #t "~a " (vector-ref vec i)))))
  (format #t "~%"))


(define (show)
  ;; show all items from 0 to limit
  (do-for i (0 (+ 1 limit))
	  (cond
	   ((= i current)
	    (format #t "(~a) " (vector-ref vec i)))
	   (#t (format #t "~a " (vector-ref vec i)))))
  (format #t "~%"))

(define (next-i n)
  (cond
   ((<= n 0) #f)
   (#t
    (set! current (+ 1 current))
    (when (> current limit)
      (set! current 0))
    (next-i (- n 1)))))


(define (next)
  (set! current (+ 1 current))
  (when (> current limit)
    (set! current 0)))

;; when does vector become too small ?
(define (bump a b)
  (define (loop lo hi)
    (cond
     ((< hi lo) #t)
     (#t
      (vector-set! vec (+ hi 1) (vector-ref vec hi))
      (loop lo (- hi 1)))))
  (loop a b))    

(define (insert)
  ;; move all items [ current + 1 ] to [ limit ] inclusive up by 1
  (bump (+ 1 current) limit)
  ;; increment limit
  (set! limit (+ 1 limit))
  ;; increment counter
  (set! counter (+ 1 counter))
  ;;(format #t "inserting counter [~a] at offset [~a]~%" counter (+ current 1))
  ;; set value at current + 1
  (vector-set! vec (+ 1 current) counter)
  ;; bump current
  (set! current (+ 1 current))
  )

  ;; ;; check largest is counter
  ;; (check-largest counter))
  

(define (check-largest c)
  (define (loop lo hi)
    (cond
     ((< hi lo) #t)
     (#t
      (let ((val (vector-ref vec hi)))
	(cond
	 ((> val c) (format #t "violation at offset [~a] has value [~a] : largest expected [~a] ~%"
			    hi val c)
	  (error "check-largest")))
	(loop lo (- hi 1))))))
  (loop 0 limit))


(define (forever n)
  (cond
   ((>= n 2017) (show))
   (#t 
    ;;(show)
    ;;(next)(next)(next)
    (next-i 3)
    (insert)
    (forever (+ n 1)))))

(define (test)
  (reset)
  (forever 0))

;; next 303 times , insert , repeat 2017 times
(define (run-1 n)
  (cond
   ((>= n 2017) (show))
   (#t 
    ;;(show)
    ;;(next)(next)(next)
    (next-i 303)
    (insert)
    (run-1 (+ n 1)))))

(define (run)
  (reset)
  (run-1 0))



(define (run-2 n lim)
  #|
  (let ((val (vector-ref vec 1)))
    (when (not (= val last))
      (set! last val)
      (format #t "n = ~a : few = " n) (show-few) (format #t " ~%")))
  |#
  ;;(format #t "n = ~a ~%" n )
  ;;(when (= 0 (modulo n 10000)) (format #t "mod n 10,000= ~a ~%" n))
  
  (when (= 0 (modulo n 10000)) 
    (format #t "n = ~a : few = " n) (show-few) (format #t " ~%"))
  
  ;;(when (= 0 (modulo n 10000)) (format #t "every 100's n = ~a ~%" n))
  (cond
   ((>= n lim) (show))
   (#t 
    ;;(show)
    ;;(next)(next)(next)
    (next-i 303)
    (insert)
    (run-2 (+ n 1) lim))))

(define (run2)
  (reset)
  (run-2 0 50000000))

;;(run2)


#|

(run)

... 456 242 32 (2017) 1971 178 ...

1971 accepted answer .


------ part 2 ---- huh ??

when is 303 a multiple of size of length of list ?
is this even the correct wording ??


|#


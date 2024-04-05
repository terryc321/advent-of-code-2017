

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

;; ----------------------------------------------

;; macros
#|
make an array from 0 to 255 inclusive 256 elements

|#


(define (make-circular-vector size)
  (assert (and (integer? size) (> size 0)))
  (let ((vec (make-vector size)))
    (letrec ((foo (lambda (n)
		(cond
		 ((>= n size) #f)
		 (#t (vector-set! vec n n)
		     (foo (+ n 1)))))))
      (foo 0))
    (lambda (op . args)
      (cond
       ((eq? op 'read) (let ((n (car args)))
			 (vector-ref vec (modulo n size))))
       ((eq? op 'write) (let ((n (car args))
			      (k (cadr args)))
			  (vector-set! vec (modulo n size) k)))
       ((eq? op 'size) size)
       ((eq? op 'vec) vec)
       (#t (error "circular vector"))))))



(define (circ-reverse circ index len)
  (letrec ((bar (lambda (n acc)
		  (cond
		   ((null? acc) #f)		   
		   (#t		    
		    (circ 'write n (car acc))
		    (bar (+ n 1) (cdr acc))))))
	   (foo (lambda (n ct acc)
		  (cond
		   ((= ct 0) (bar index acc))
		   (#t (foo (+ n 1) (- ct 1) (cons (circ 'read n) acc))))))
	   )
    (let ((acc '())
	  (count len)
	  (index index))
      (foo index count acc))))


(define (act circ pos skip lengths)
  (define (recur pos skip xs)
    (cond
     ((null? xs) pos)
     (#t (let ((len (car xs)))
	   (circ-reverse circ pos len)
	   (recur (modulo (+ pos len skip) (circ 'size)) (+ skip 1) (cdr xs))))))
  ;; entry
  (recur pos skip lengths))



(define (circ-show circ pos)
  (let ((size (circ 'size)))
    (letrec ((foo (lambda (n)
		    (cond
		     ((> n (- size 1)) #f)
		     (#t
		      (cond
		       ((zero? (modulo n 20)) (format #t "~%")))
		      
		      (cond
		       ((= n pos)
			(format #t "[~a] " (circ 'read n)))
		       (#t
			(format #t "~a " (circ 'read n))))
		      (foo (+ n 1)))))))
      (foo 0)
      (format #t "~%"))))

 


(define (entry)
  (let ((circ (make-circular-vector 256))
	(lengths '(212 254 178 237 2 0 1 54 167 92 117 125 255 61 159 164))
	(pos 0)
	(skip 0))
    (let ((final-pos (act circ pos skip lengths)))
      (format #t "final pos = ~a ~%" final-pos)
      (circ-show circ final-pos)
      (circ 'vec))))


(define (example)
  (let ((circ (make-circular-vector 5))
	(lengths '(3 4 1 5))
	(pos 0)
	(skip 0))
    (let ((final-pos (act circ pos skip lengths)))
      (circ-show circ final-pos)
      (circ 'vec))))



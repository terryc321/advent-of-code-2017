

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
#|
128 x 128 grid

(list x y) => value
'free
'used

depends on day 10 of aoc 2017 knot hashes . why nobody knows



|#
(define hash (make-hash-table))
(define width 128)
(define height 128)
  
(define (clear-grid)
  (define (helper x y)
    (cond
     ((> x width) (helper 1 (+ y 1)))
     ((> y height) #t)
     (#t (hash-table-set! hash (list x y) 'free)
	 (helper (+ x 1) y))))
  (helper 1 1))

(define (show-grid)
  (define (helper x y)
    (cond
     ((> x width) (format #t "~%") (helper 1 (+ y 1)))
     ((> y height) #t)
     (#t (let ((elem (hash-table-ref hash (list x y))))
	   (cond
	    ((eq? elem 'free) (format #t "_"))
	    ((eq? elem 'used) (format #t "X"))
	    (#t (error "show-grid")))	    
	   (helper (+ x 1) y)))))
  (helper 1 1))


  







   








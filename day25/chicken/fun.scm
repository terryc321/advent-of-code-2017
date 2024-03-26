
#|

advent of code 2017
day 25

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
blank hash table
every entry is zero if not in hash


|#
(define (puzzle)  
  (let ((hash (make-hash-table))
	(target-counter 12683008)
	;;(target-counter 1000000) ;; one million
	(current-position 0)
	(diagnostic-counter 0)
	(stop #f))

    (define (checksum)
      (let ((result 0))
	(hash-table-for-each hash (lambda (key value)
				    (cond
				     ((= value 1) (set! result (+ 1 result))))))
	result))
    
    ;; lookup value on tape at position pos [an integer]
    (define (lookup pos)
      (assert (integer? pos))
      (let ((the-default-hash-value 0))
	(hash-table-ref/default hash pos the-default-hash-value)))

    (define (write n)
      (assert (and (integer? n) (or (= n 0)(= n 1))))
      (hash-table-set! hash current-position n))    
    
    (define (move-right n)
      (assert (and (integer? n) (positive? n)))
      (set! current-position (+ current-position n)))

    (define (move-left n)
      (assert (and (integer? n) (positive? n)))
      (set! current-position (- current-position n)))

    (define (increment-diagnostic-counter)
      (set! diagnostic-counter (+ 1 diagnostic-counter))
      (cond
       ((= diagnostic-counter target-counter)
	(stop (checksum)))))

    (define (next-action-A)
      (increment-diagnostic-counter)
      (action-A))

    (define (next-action-B)
      (increment-diagnostic-counter)
      (action-B))

    (define (next-action-C)
      (increment-diagnostic-counter)
      (action-C))

    (define (next-action-D)
      (increment-diagnostic-counter)
      (action-D))

    (define (next-action-E)
      (increment-diagnostic-counter)
      (action-E))
    
    (define (next-action-F)
      (increment-diagnostic-counter)
      (action-F))
    
    
    (define (action-A)
      (let ((current-value (lookup current-position)))
	(assert (integer? current-value))
	(cond
	 ((= current-value 0)
	     (write 1)
	     (move-right 1)
	     (next-action-B))
	 ((= current-value 1)
	     (write 0)
	     (move-left 1)
	     (next-action-B))
	 (#t (error "action A tape neither 1 or 0")))))

    (define (action-B)
      (let ((current-value (lookup current-position)))
	(assert (integer? current-value))
	(cond
	 ((= current-value 0)
	     (write 1)
	     (move-left 1)
	     (next-action-C))
	 ((= current-value 1)
	     (write 0)
	     (move-right 1)
	     (next-action-E))
	 (#t (error "action B tape neither 1 or 0")))))


    (define (action-C)
      (let ((current-value (lookup current-position)))
	(assert (integer? current-value))
	(cond
	 ((= current-value 0)
	     (write 1)
	     (move-right 1)
	     (next-action-E))
	 ((= current-value 1)
	     (write 0)
	     (move-left 1)
	     (next-action-D))
	 (#t (error "action C tape neither 1 or 0")))))

    (define (action-D)
      (let ((current-value (lookup current-position)))
	(assert (integer? current-value))
	(cond
	 ((= current-value 0)
	     (write 1)
	     (move-left 1)
	     (next-action-A))
	 ((= current-value 1)
	     (write 1)
	     (move-left 1)
	     (next-action-A))
	 (#t (error "action D tape neither 1 or 0")))))

    (define (action-E)
      (let ((current-value (lookup current-position)))
	(assert (integer? current-value))
	(cond
	 ((= current-value 0)
	     (write 0)
	     (move-right 1)
	     (next-action-A))
	 ((= current-value 1)
	     (write 0)
	     (move-right 1)
	     (next-action-F))
	 (#t (error "action E tape neither 1 or 0")))))


    (define (action-F)
      (let ((current-value (lookup current-position)))
	(assert (integer? current-value))
	(cond
	 ((= current-value 0)
	     (write 1)
	     (move-right 1)
	     (next-action-E))
	 ((= current-value 1)
	     (write 1)
	     (move-right 1)
	     (next-action-A))
	 (#t (error "action F tape neither 1 or 0")))))


    ;; entry point
    (call/cc (lambda (cont)
	       (set! stop cont)
	       ;; first action is action-A
	       (action-A)))
    (checksum)))



(define (example)  
  (let ((hash (make-hash-table))
	(target-counter 6)
	(current-position 0)
	(diagnostic-counter 0)
	(stop #f))

    (define (checksum)
      (let ((result 0))
	(hash-table-for-each hash (lambda (key value)
				    (cond
				     ((= value 1) (set! result (+ 1 result))))))
	result))
    
    ;; lookup value on tape at position pos [an integer]
    (define (lookup pos)
      (assert (integer? pos))
      (let ((the-default-hash-value 0))
	(hash-table-ref/default hash pos the-default-hash-value)))

    (define (write n)
      (assert (and (integer? n) (or (= n 0)(= n 1))))
      (hash-table-set! hash current-position n))    
    
    (define (move-right n)
      (assert (and (integer? n) (positive? n)))
      (set! current-position (+ current-position n)))

    (define (move-left n)
      (assert (and (integer? n) (positive? n)))
      (set! current-position (- current-position n)))

    (define (increment-diagnostic-counter)
      (set! diagnostic-counter (+ 1 diagnostic-counter))
      (cond
       ((= diagnostic-counter target-counter)
	(stop (checksum)))))

    (define (next-action-A)
      (increment-diagnostic-counter)
      (action-A))

    (define (next-action-B)
      (increment-diagnostic-counter)
      (action-B))
    
    (define (action-A)
      (let ((current-value (lookup current-position)))
	(assert (integer? current-value))
	(cond
	 ((= current-value 0)
	     (write 1)
	     (move-right 1)
	     (next-action-B))
	 ((= current-value 1)
	     (write 0)
	     (move-left 1)
	     (next-action-B))
	 (#t (error "action A tape neither 1 or 0")))))

    (define (action-B)
      (let ((current-value (lookup current-position)))
	(assert (integer? current-value))
	(cond
	 ((= current-value 0)
	     (write 1)
	     (move-left 1)
	     (next-action-A))
	 ((= current-value 1)
	     (write 1)
	     (move-right 1)
	     (next-action-A))
	 (#t (error "action B tape neither 1 or 0")))))


    ;; entry point
    (call/cc (lambda (cont)
	       (set! stop cont)
	       ;; first action is action-A
	       (action-A)))
    (checksum)))


(format #t "puzzle solution has checksum of ~A ~%"(puzzle))



#|

#;2318> (example)
3

#;2582> (puzzle)
3554


|#
	 
      
    

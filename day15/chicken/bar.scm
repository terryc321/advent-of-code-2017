
#|

advent of code 2017
day 15

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
As they do this, a judge waits for each of them to generate its next
value, compares the lowest 16 bits of both values, and keeps track of
the number of times those parts of the values match.

The generators both work on the same principle. To create its next
value, a generator will take the previous value it produced, multiply
it by a factor (generator A uses 16807; generator B uses 48271), and
then keep the remainder of dividing that resulting product by
2147483647. That final remainder is the value it produces next.

To calculate each generator's first value, it instead uses a specific
starting value as its "previous value" (as listed in your puzzle
input).

For example, suppose that for starting values, generator A uses 65,
while generator B uses 8921. Then, the first five pairs of generated
values are:

--Gen. A--  --Gen. B--
   1092455   430625591
1181022009  1233683848
 245556042  1431495498
1744312007   137874439
1352636452   285222916

|#

(define (expo)
  (let ((count 0)
	(sum 0))
    (do-for (n 0 16)
	    (set! count (+ 1 count))
	    (let ((exp-n (expt 2 n)))
	      (set! sum (+ sum exp-n))
	      (format #t "count ~a : exponent = 2 ^ ~a => ~a : sum = ~a~%" count n exp-n sum)))))


#|
Generator A multiplier is 16807
Generator B multiplier is 48271
Remainder divisor 2147483647

example 
Generator A starts with 65
Generator B starts with 8921

input 
Generator A starts with 116
Generator B starts with 299

keep result remainder dividing by 2147483647

|#

(define (make-generator start multiplier divisor)
  (let ((n start))
    (lambda (op)
      (cond
       ((eq? op 'next)
	(set! n (* n multiplier))
	(set! n (remainder n divisor)))
       ((eq? op 'val) n)
       (#t (error "gen-a"))))))

(define (make-example-a)
  (let ((start 65)
	(multiplier 16807)
	(divisor 2147483647))
    (make-generator start multiplier divisor)))

(define (make-example-b)
  (let ((start 8921)
	(multiplier 48271)
	(divisor 2147483647))
    (make-generator start multiplier divisor)))


(define (make-divisor-generator multiple-of start multiplier divisor)
  (let ((n start))
    (letrec ((foo (lambda (op)
		    (cond
		     ((eq? op 'next)
		      (set! n (* n multiplier))
		      (set! n (remainder n divisor))
		      (cond
		       ((zero? (modulo n multiple-of)) n)
		       (#t (foo 'next))))
		     ((eq? op 'val) n)
		     (#t (error "gen-a"))))))
      foo)))


(define (test)
  (let ((fa (let ((start 65)
		  (multiplier 16807)
		  (divisor 2147483647)
		  (multiple-of 4))
	      (make-divisor-generator multiple-of start multiplier divisor)))
	(fb (let ((start 8921)
		  (multiplier 48271)
		  (divisor 2147483647)
		  (multiple-of 8))
	      (make-divisor-generator multiple-of start multiplier divisor)))
	(test-no 5000000)
	(match-count 0))
    (fa 'next)
    (fb 'next)
    (do-for (pair-no 1 (+ test-no 1))
	    ;;(format #t "pair ~a : a b testing ~%~a ~b~%~a ~b~%~%" pair-no (fa 'val) (fa 'val) (fb 'val) (fb 'val))
	    (let ((lower-fa (bitwise-and (fa 'val) 65535))
		  (lower-fb (bitwise-and (fb 'val) 65535)))
	      (let ((matched (= lower-fa lower-fb)))
		(cond
		 (matched 
		  (set! match-count (+ 1 match-count))
		  ;;(format #t "match ~a : TRUE ~%" match-count)
		  ))))
	 (fa 'next)
	 (fb 'next))
    (format #t "TEST :: the number of matches for ~a is [ ~a ] ~%" test-no match-count)
    match-count))




(define (puzzle)
  (let ((fa (let ((start 116)
		  (multiplier 16807)
		  (divisor 2147483647)
		  (multiple-of 4))
	      (make-divisor-generator multiple-of start multiplier divisor)))
	(fb (let ((start 299)
		  (multiplier 48271)
		  (divisor 2147483647)
		  (multiple-of 8))
	      (make-divisor-generator multiple-of start multiplier divisor)))
	(test-no 5000000)
	(match-count 0))
    (fa 'next)
    (fb 'next)
    (do-for (pair-no 1 (+ test-no 1))
	    ;;(format #t "pair ~a : a b testing ~%~a ~b~%~a ~b~%~%" pair-no (fa 'val) (fa 'val) (fb 'val) (fb 'val))
	    (let ((lower-fa (bitwise-and (fa 'val) 65535))
		  (lower-fb (bitwise-and (fb 'val) 65535)))
	      (let ((matched (= lower-fa lower-fb)))
		(cond
		 (matched 
		  (set! match-count (+ 1 match-count))
		  ;;(format #t "match ~a : TRUE ~%" match-count)
		  ))))
	 (fa 'next)
	 (fb 'next))
    (format #t "PuZZLE : the number of matches for ~a is [ ~a ] ~%" test-no match-count)
    match-count))


(test)
(puzzle)

#|
terry@debian:~/code/advent-of-code/advent-of-code-2017/day15/chicken$ time ./bar
TEST :: the number of matches for 5000000 is [ 309 ] 
PuZZLE : the number of matches for 5000000 is [ 298 ] 

real	0m3.764s
user	0m3.747s
sys	0m0.016s

|#


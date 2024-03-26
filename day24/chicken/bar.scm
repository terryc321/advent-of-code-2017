
#|

advent of code 2017
day 24

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


;; --- fix weird geiser bug --- repl working directory
;; (change-directory "day24")
;; (current-directory)
;;(format #t "the current directory is ~a ~%" (current-directory))

(define example '(
(		  0 2)
(2 2)
(2 3)
(3 4)
(3 5)
(0 1)
(10 1)
(9 10)
))


(define input '(
(		42 37)
(28 28)
(29 25)
(45 8)
(35 23)
(49 20)
(44 4)
(15 33)
(14 19)
(31 44)
(39 14)
(25 17)
(34 34)
(38 42)
(8 42)
(15 28)
(0 7)
(49 12)
(18 36)
(45 45)
(28 7)
(30 43)
(23 41)
(0 35)
(18 9)
(3 31)
(20 31)
(10 40)
(0 22)
(1 23)
(20 47)
(38 36)
(15 8)
(34 32)
(30 30)
(30 44)
(19 28)
(46 15)
(34 50)
(40 20)
(27 39)
(3 14)
(43 45)
(50 42)
(1 33)
(6 39)
(46 44)
(22 35)
(15 20)
(43 31)
(23 23)
(19 27)
(47 15)
(43 43)
(25 36)
(26 38)
(1 10)
))


#|
For example, suppose you had the following components:

With them, you could make the following valid bridges:

    0/1
    0/1--10/1
    0/1--10/1--9/10
    0/2
    0/2--2/3
    0/2--2/3--3/4
    0/2--2/3--3/5
    0/2--2/2
    0/2--2/2--2/3
    0/2--2/2--2/3--3/4
    0/2--2/2--2/3--3/5

(Note how, as shown by 10/1, order of ports within a component doesn't matter. However, you may only use each port on a component once.)

|#


(define best-score #f)
(define best-length #f)
(define best-bridge #f)
(define bridge-counter 0)
(define bridge-hash (make-hash-table)) ;; bridge-hash now currently unused 

(define (reset)
  (format #t "resetting score hash table so have a clean slate...~%")
  (set! bridge-counter 0)
  (set! best-length 0)
  (set! best-score 0)
  (set! best-bridge '())
  (set! bridge-hash (make-hash-table)))


;; keep the items in a list
;; each time bridge-remove traverses result list may be reversed
;; thats okay because not interested in sequence of bridge links
;; only the bridge links themselves are kept or removed if they match equal?
(define (bridge-remove x ys)
  (define (bridge-remove-recur x ys zs)
    (cond
     ((null? ys) zs)
     ((equal? x (car ys)) (bridge-remove-recur x (cdr ys) zs))
     (#t (bridge-remove-recur x (cdr ys) (cons (car ys) zs)))))
  (bridge-remove-recur x ys '()))


(define (record-score-plain bridge bridge-score bridge-length)
  (cond
   ((and (>= bridge-length best-length) (> bridge-score best-score))
    (format #t "found new best score of ~a with length of ~a ~%" bridge-score bridge-length)
    (set! best-length bridge-length)
    (set! best-score bridge-score)
    (set! best-bridge bridge)
    bridge-score)))




#|
;; bridge ((0 1)(1 2)(2 3))  1 + 1 + 2 + 2 + 3  ??
(define (record-score bridge bridge-score)
  (cond
   ((not (hash-table-ref/default bridge-hash bridge #f))
    
    ;; (let ((result 0))
    ;;   (do-list (pr bridge)
    ;; 	       (let ((num (car pr))
    ;; 		     (denom (cadr pr)))
    ;; 		 (set! result (+ result num denom))))
      
      (set! bridge-counter (+ 1 bridge-counter))
      ;;(format #t "bridge [~a] : ~a : has score of ~a ~%" bridge-counter (reverse bridge) result)
      ;; remember we have seen this hash before
      (hash-table-set! bridge-hash bridge #t)
      ;;(format #t "score : result = ~a : best-score so far = ~a ~%" result best-score)
      
      (cond
       ((> bridge-score best-score)
	(format #t "counter [~a] : found new best score of ~a ~%" bridge-counter bridge-score)
	(set! best-score bridge-score)
	;;(format #t "check best-score value now is ~a ~%" best-score)	
	(set! best-bridge bridge)))
      
      bridge-score)))
|#




#|
bridges recurse 

if we find we can add to the bridge
1 - extend the bridge
2 - remove link from data
3 - record the new -current-bridge in bridges

if no extension to bridge can be made , then done
if no extension pieces left to add on to make new bridge , then done
either case result is bridges

improvements
1 - current-score computed just for extension piece of bridge added simple addition two numbers
rather than a complete traversal of list each time extracting num / denom
2 - combined condition current-id = num OR current-id = denom
again reduces traversal along all the possible remaining extension pieces

|#

(define (bridges-recurse data bridges current-bridge current-id current-score current-length)
  (cond
   ((null? data) #f)
   (#t ;; first bridge piece must be 0 / _ general look for current-id
    (do-list (pr data)
	     (let ((num (car pr))
		   (denom (cadr pr)))
	       (cond
		((= num current-id)
		 ;; forward connection like [ 0/2 -- 2/3 ]
		 (let ((new-bridge (cons pr current-bridge))
		       (new-id denom) ;; next ID is DENOM
		       (new-data (bridge-remove pr data))
		       (new-score (+ current-score num denom))
		       (new-length (+ 1 current-length)))

		   ;; make a note of score - report if new high score - 
		   (record-score-plain new-bridge new-score new-length)

		   (let ((new-bridges (cons new-bridge bridges)))
		     (bridges-recurse new-data new-bridges new-bridge new-id new-score new-length))))

		((= denom current-id)
	     	 ;; reverse connection like [ 0/1 -- 10/1 ]	     		 
		 (let ((new-bridge (cons pr current-bridge))
		       (new-id num) ;; next id is NUM
		       (new-data (bridge-remove pr data))
		       (new-score (+ current-score num denom))
		       (new-length (+ 1 current-length)))

		   ;; make a note of score - report if new high score - 
		   (record-score-plain new-bridge new-score new-length)

		   (let ((new-bridges (cons new-bridge bridges)))
		     (bridges-recurse new-data new-bridges new-bridge new-id new-score new-length))))
		))))))






;; what bridges can make from a list of 
(define (bridges-search data)
  (reset)
  (let ((empty-list '())
	(current-bridge '())
	(current-id 0)
	(current-score 0)
	(current-length 0))
    (bridges-recurse data empty-list current-bridge current-id current-score current-length)))




(define (puzzle-example)
  (bridges-search example)
  (format #t "best bridge ~a~%has a score of ~a ~%" (reverse best-bridge) best-score))

(define (puzzle-input)
  (bridges-search input)
  (format #t "best bridge ~a~%has a score of ~a ~%" (reverse best-bridge) best-score))



;; for compilation 
(puzzle-input)

(puzzle-example)


#|

now we want to find the longest bridge -- and the strongest of them

found new best score of 1814 with length of 32
found new best score of 1819 with length of 34
found new best score of 1831 with length of 34
found new best score of 1872 with length of 34
found new best score of 1928 with length of 35
best bridge ((0 35) (22 35) (0 22) (0 7) (28 7) (28 28) (19 28) (19 27) (27 39) (39 14) (3 14) (3 31) (20 31) (15 20) (15 33) (1 33) (1 10) (10 40) (40 20) (20 47) (47 15) (46 15) (46 44) (30 44) (30 30) (30 43) (43 43) (43 45) (45 45) (45 8) (8 42) (50 42) (34 50) (34 34) (34 32))
has a score of 1928


1928 

resetting score hash table so have a clean slate...
found new best score of 2 with length of 1
found new best score of 7 with length of 2
found new best score of 14 with length of 3
found new best score of 15 with length of 3
found new best score of 19 with length of 4
best bridge ((0 2) (2 2) (2 3) (3 5))
has a score of 19

real	0m0.734s
user	0m0.717s
sys	0m0.017s

|#







  
		   
   








   

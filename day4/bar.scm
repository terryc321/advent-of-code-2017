#|

day 4


           

|#


(import scheme)
(import (chicken pretty-print))
(define pp pretty-print)

(import (chicken format))
(import (chicken string))
(import (chicken sort))
(import (chicken file))
(import (chicken process-context))
;; (change-directory "../day4")
;; (current-directory)


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


;;------------------------- code -----------------------------------

;; change input file ! 
(define (get-input) (call-with-input-file "input"
		      (lambda (port)
			(read port))))

(define input (string-split (get-input) "\n"))


#|
(set! input
  (map (lambda (x)
	 (string->number (format #f "~a" x)))
       (string->list input)))
|#

(define (1+ x) (+ x 1))
(define (1- x) (- x 1))

(define (10+ x) (+ x 10))
(define (10- x) (- x 10))

;; ------------------------------------------------------------------------

(define examples '(
    "aa bb cc dd ee" ;; is valid.
    "aa bb cc dd aa" ;; is not valid - the word aa appears more than once.
    "aa bb cc dd aaa" ;; is valid - aa and aaa count as different words.
    ))


(define (f s)
  (let ((words (string-split s " ")))
    (all-unique words)))

(define (all-unique xs)
  (cond
   ((null? xs) #t)
   ((member (car xs) (cdr xs) string=?) (values #f (car xs)))
   (#t (all-unique (cdr xs)))))

(map f examples)

(define (part-1)
  (length (filter (lambda (x) (if x x #f)) (map f input))))


#|
anagram

count letters
3 a
1 n
1 g
1 r
1 m

no two words can be an anagram of each other
|#

(char->integer #\a)
(char->integer #\z)

(define ascii_a (char->integer #\a))
(define ascii_z (char->integer #\z))

(define (alphabet) (make-vector 26 0))

(define (record-letter v a)
  (let ((n (- (char->integer a) ascii_a)))
    (vector-set! v n (+ 1 (vector-ref v n)))))

(define (anagram? s s2)
  (let ((v (alphabet))
	(v2 (alphabet))
	(slen (string-length s))
	(slen2 (string-length s2)))
    (do-for i (0 slen)
	    (record-letter v (string-ref s i)))
    (do-for j (0 slen2)
	    (record-letter v2 (string-ref s2 j)))
    (equal? v v2)))

(anagram? "a" "a")
(anagram? "abcdefghijklmnopqrstuvwxyz" "abcdefghijklmnopqrstuvwxyz")



(define (member-or-anagram? x xs)
  (call/cc (lambda (result)
	     (do-list (y xs)
		      (cond
		       ((anagram? x y)
			(format #t ".......anagram ~a ~A ~%" x y)
			(result #t))
		       ((string=? x y)
			(format #t ".......strings equal ~a ~A ~%" x y)
			(result #t))))
	     #f)))
   	   

(define (all-unique-no-anagrams xs)
  (cond
   ((null? xs) #t)
   ((member-or-anagram? (car xs) (cdr xs)) #f) ;;(values #f (car xs)))
   (#t (all-unique-no-anagrams (cdr xs)))))


(define (g s)
  (let ((words (string-split s " ")))
    (format #t "g input : words = ~a  ~%" words)
    (all-unique-no-anagrams words)))


(map g examples)

(define (part-2)
  (length (filter (lambda (x) (if x x #f)) (map g input))))

#|

186

|#





    































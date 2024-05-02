

(import scheme)
(import simple-exceptions)
(import expand-full) ;; macro-expansion
(import (chicken repl))
(import (chicken string))
(import (chicken pretty-print))
(import (chicken io))
(import (chicken format))
(import (chicken bitwise))
(import (chicken sort))
(import (chicken file))
(import (chicken process-context))
;; (change-directory "day17")
;; (get-current-directory)
(import procedural-macros)
(import regex)
(import simple-md5)
(import simple-loops)
(import srfi-13) ;; string-pad
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

(define-macro (incf a)
  `(set! ,a (+ ,a 1)))

(let ((a 1))
  (incf a)
  a)


(define-macro (swap a b)
  (let ((tmp (gensym "tmp")))
    `(begin
       (set! ,tmp ,a)
       (set! ,a ,b)
       (set! ,b ,tmp))))

;; 
;; '(swap 2 3)
;; macro expansion expand
;; (expand '(swap a b))

(define (test-swap a b)
  (let ((n1 a)
	(n2 b))
    (format #t "before swap n1 = ~a : n2 = ~a ~%" n1 n2)
    (swap n1 n2)
    (format #t "after swap n1 = ~a : n2 = ~a ~%" n1 n2)))

    
(define-macro (dolist varlist . body)
  (let ((var (car varlist))
	(ls (cadr varlist))
	(fn (gensym "fn")))	
    `(begin
       (letrec
	   ((,fn (lambda (xs)
		   (cond
		    ((null? xs) #f)
		    (#t (let ((,var (car xs)))
			  ,@body
			  (,fn (cdr xs))))))))
	 (,fn ,ls)))))



;; '(dolist (x '(1 2 3)) (format #t "x = ~a ~%" x))
;; (pp (expand* '(dolist (x '(1 2 3)) (format #t "x = ~a ~%" x))))

#|
(dolist (x '(1 2 3))
	(format #t "x = ~a ~%" x))


(dolist (x '(1 2 3))
	(dolist (y '(1 2 3))
		(format #t "x = ~a : y = ~a ~%" x y)))

|#

(define-macro (dostring varstr . body)
  (let ((var (car varstr))
	(str (cadr varstr))
	(fn (gensym "fn"))
	(i (gensym "i"))
	(s (gensym "s"))
	(slim (gensym "slim")))
    `(begin
       (letrec
	   ((,fn (lambda (,s ,i ,slim)
		   (cond
		    ((>= ,i ,slim) #f)
		    (#t (let ((,var (string-ref ,s ,i)))
			  ,@body
			  (,fn ,s (+ ,i 1) ,slim)))))))
	 (,fn ,str 0 (string-length ,str))))))


;; (dostring (s "asdf")
;; 	  (format #t "s = ~a ~%" s))

	  



;;=======================================================

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


(define (act-64 circ pos skip lengths)
  (define (recur pos skip xs run)
    ;;(format #t "run ~a : pos = ~a : skip = ~a ~%" run pos skip)
    (cond
     ((null? xs)
      (cond
       ((>= run 64) pos)
       (#t (recur pos skip lengths (+ 1 run)))))
     (#t (let ((len (car xs)))
	   (circ-reverse circ pos len)
	   (recur (modulo (+ pos len skip) (circ 'size)) (+ skip 1) (cdr xs) run)))))
  ;; entry
  (recur pos skip lengths 1))



(define (circ-show circ pos)
  (let ((size (circ 'size)))
    (letrec ((foo (lambda (n)
		    (cond
		     ((> n (- size 1)) #f)
		     (#t
		      ;; insert newline
		      (cond
		       ((zero? (modulo n 20)) (format #t "~%")))
		      ;; put squares around where POS is in circular array
		      (cond
		       ((= n pos)
			(format #t "[~a] " (circ 'read n)))
		       (#t
			(format #t "~a " (circ 'read n))))
		      (foo (+ n 1)))))))
      (foo 0)
      (format #t "~%"))))


#|

input 1,2,3 is no longer numbers but to be thought of as a string of bytes 0-255 ascii
"1,2,3"

append standard suffix lengths
 '(17 31 73 47 23)

|#

;; string to ascii values
(define (string->ascii s)
  (map char->integer (string->list s)))

(define (front-door s)
  (assert (string? s))
  (let ((standard-suffix  '(17 31 73 47 23)))
    (append (string->ascii s) standard-suffix)))


(define (example)
  (let ((circ (make-circular-vector 5))
	(lengths (front-door "3,4,1,5"))
	(pos 0)
	(skip 0))
    (let ((final-pos (act-64 circ pos skip lengths)))
      (circ-show circ final-pos)
      (circ 'vec))))

;; chicken bitwise
;;65 ^ 27 ^ 9 ^ 1 ^ 4 ^ 3 ^ 40 ^ 50 ^ 91 ^ 7 ^ 6 ^ 0 ^ 2 ^ 5 ^ 68 ^ 22 => 64
;;(bitwise-xor 65   27   9   1   4   3   40   50   91   7   6   0   2   5   68  22)
;;64

;; convert circ to a list
;; take 16 , drop 16
(define (split-16 xs)
  (define (recur xs)
    (cond
     ((null? xs) xs)
     (#t (cons (take xs 16) (recur (drop xs 16))))))
  (cond
   ((vector? xs) (recur (vector->list xs)))
   (#t (recur xs))))


(define (output xs)
  (let ((result (apply string-append
		 (map (lambda (n)
			(string-pad (format #f "~X" n) 2 #\0))
		      (map (lambda (x)(apply bitwise-xor x))
			   (split-16 xs))))))
    result))


(define (entry)
  (let ((circ (make-circular-vector 256))
	(lengths (front-door "212,254,178,237,2,0,1,54,167,92,117,125,255,61,159,164"))
	(pos 0)
	(skip 0))
    (let ((final-pos (act-64 circ pos skip lengths)))
      (format #t "final pos = ~a ~%" final-pos)      
      (circ-show circ final-pos)
      (output (circ 'vec)))))


(define (explore lengths)
  (let ((circ (make-circular-vector 256))
	(pos 0)
	(skip 0))
    (act-64 circ pos skip lengths)
    (output (circ 'vec))))

(define (example-empty-string)
  (explore (front-door "")))

(define (example-aoc-2017)
  (explore (front-door "AoC 2017")))

(define (example-1-2-3)
  (explore (front-door "1,2,3")))

(define (example-1-2-4)
  (explore (front-door "1,2,4")))

(define (puzzle)
  (explore (front-door "212,254,178,237,2,0,1,54,167,92,117,125,255,61,159,164")))


#|

> (puzzle)

96de9657665675b51cd03f0b3528ba26

|#


(define *test* "flqrgnkx")
(define *input* "wenycdww")

#|

0 to 127 for rows

#;63> *test*
"flqrgnkx"
#;69> *input*
"wenycdww"
#;78> (string-append *input* "0")
"wenycdww0"
#;94> (string-append *input* "-" "0")
"wenycdww-0"
#;107> (string-append (format #f "~a-~a" *input* 0))
"wenycdww-0"
#;136> (string-append (format #f "~a-~a" *input* 0))
"wenycdww-0"
#;137> 

|#

(define (rows s)
  (letrec ((foo (lambda (n xs)
		  (cond
		   ((>= n 128) (reverse xs))
		   (#t (let ((in (string-append (format #f "~a-~a" s n))))
			 (foo (+ n 1) (cons in xs))))))))
    (map (lambda (x)
	   (explore (front-door x)))
	 (foo 0 '()))))


;; for each character in string get the dot-hash of that character
;; 
(define (viz str)
  (let* ((slen (string-length str)))
    (letrec ((foo (lambda (i xs)
		  (cond
		   ((>= i slen) (reverse xs))
		   (#t (let ((d-h (dot-hash (string-ref str i))))
			 (foo (+ i 1) (cons d-h xs))))))))
      (apply string-append (foo 0 '())))))



(define (dot-hash c)
  (cond
   ((char=? c #\0) "....")
   ((char=? c #\1) "...#")
   ((char=? c #\2) "..#.")
   ((char=? c #\3) "..##")
   ((char=? c #\4) ".#..")
   ((char=? c #\5) ".#.#")
   ((char=? c #\6) ".##.")
   ((char=? c #\7) ".###")
   ((char=? c #\8) "#...")
   ((char=? c #\9) "#..#")
   ((char=? c #\a) "#.#.")
   ((char=? c #\b) "#.##")
   ((char=? c #\c) "##..")
   ((char=? c #\d) "##.#")
   ((char=? c #\e) "###.")
   ((char=? c #\f) "####")
   (#t (error "dot-hash not recognised"))))

(define (test-dot-hash)
  (map dot-hash '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\a #\b #\c #\d #\e #\f)))


#|

(format #t "~%~%")
(pp (rows *test*))

(format #t "~%~%")
(pp (rows *input*))
|#


(define (count2 in)
  (let ((xs (map viz (rows in))))
    (let ((tot 0))
      (dolist (s xs)
	      (dostring (c s)
			(when (char=? c #\# )
			  (incf tot))))
      tot)))

#|

---------- part A ----------- solved -----------

(count2 *test*) --> 8108

(count2 *input*) --> 8226

ACCEPTED ANSWER !

|#
	      



;; 128 x 128 only
(define (rows-to-grid rows)
  (let ((xs (map viz rows))
	(hash (make-hash-table))
	(x 0)
	(y 0))
    ;; (format #t "~%~%")
    ;; (pp xs)
    ;; (format #t "~%")
    (assert (= 128 (length xs)))
    (let ((tot 0))
      (set! y 0)
      (dolist (s xs)
	      (assert (= 128 (string-length s)))
	      (set! x 0)
	      (dostring (c s)
			(cond 
			 ((char=? c #\# )
			  (incf tot)
			  ;;(format #t "setting ~a ~a => ~a ~%" x y 1)
			  (hash-table-set! hash (list x y) #t)
			  (assert (eq? #t (hash-table-ref hash (list x y))))
			  )
			 (#t 
			  (hash-table-set! hash (list x y) #f)
			  (assert (eq? #f (hash-table-ref hash (list x y))))))
			(incf x))
	      (incf y))
      hash)))



#|

all-painted?
scan whole grid 0,0 to 127,127
if hash h has entry - meaning bit set in puzzle , then it should have a value if painted ,
 otherwise not all painted

|#

(define (all-painted? h)
  (call/cc (lambda (exit)
	     (dolist (x (iota 128))
		     (dolist (y (iota 128))
			     (let ((val (hash-table-ref/default h (list x y) #f)))
			       (cond
				((and val (eq? val #t))
				 (exit #f))))))
	     #t)))



#|

forgot #t in all-painted after dolist so it would say #f if grid was fully painted or not !

(define (all-painted-check h)
  (format #t "painting checker ... ")
  (call/cc (lambda (exit)
	     (dolist (x (iota 128))
		     (dolist (y (iota 128))
			     (let ((val (hash-table-ref/default h (list x y) #f)))
			       (cond
				((and val (eq? val #t))
				 (format #t "val true at index ~a , ~a ~%" x y)
				 (exit #f))))))
	     #t)))


|#



(define (on-board? x y)
  (and (>= x 0)(< x 128)(>= y 0)(< y 128)))


(define (paint-region hg p x y)
  (cond
   ((not (on-board? x y)) #f)
   (#t (let ((val (hash-table-ref/default hg (list x y) #f)))
	 (cond
	  ((eq? val #t)  ;; can paint this
	   (hash-table-set! hg (list x y) p)
	   (format #t "painted ~a ~a with colour ~a ~%" x y p)
	   (paint-region hg p (+ x 1) y)
	   (paint-region hg p (- x 1) y)
	   (paint-region hg p x (+ y 1))
	   (paint-region hg p x (- y 1))))))))


(define (viz-grid hg)
  (let ((iot (iota 128)))
    (format #t "~%~%")
    (dolist (y iot)
	    (dolist (x iot)
		    (let ((val (hash-table-ref/default hg (list x y) #f)))
		      (cond
		       (val (format #t "~a" val))
		       (#t (format #t ".")))))
	    (format #t "~%"))
    (format #t "~%")))
  

(define (viz-fill-grid hg)
  (let ((iot (iota 128)))
    (dolist (y iot)
	    (dolist (x iot)
		    (hash-table-set! hg (list x y) 1)))))
  

(define (paint-regions hg)
  (let ((n-regions 0))
    (call/cc (lambda (exit)
	       (letrec ((foo (lambda ()
			       (cond
				((all-painted? hg) n-regions)
				(#t
				 (let ((iot (iota 128)))
				   (dolist (x iot)
					   (dolist (y iot)
						   (let ((val (hash-table-ref/default hg (list x y) #f)))
						     (cond
						      ((and val (eq? val #t))
						       (set! n-regions (+ n-regions 1))
						       (format #t "painting region ~a ~%" n-regions)
						       (paint-region hg n-regions x y))))))

				   ;; (when (= n-regions 1242)
				   ;;   (viz-grid hg)
				   ;;   (format #t "all painted then ? ~a~%" (all-painted? hg))
				   ;;   (all-painted-check hg)

				   ;;   (exit (all-painted? hg))
				   ;;   )

				   ;; (format #t "all painted then ? ~a~%" (all-painted? hg))
				   ;;(viz-grid hg)
				   (foo)))))))
		 (foo))))
    n-regions))










(define (paint h)  (paint-regions h))


(define (puzzle in)
  (let ((g (rows in)))
    (format #t "computed grid ~%")  
    (pp g)
    (let ((hg (rows-to-grid g)))
      (format #t "computed hash grid ~%")  
      (pp hg)
      (format #t "~%~%")
      (viz-grid hg)
      (let ((result (paint hg)))
	(format #t "~%~%number of painted regions ~a ~%" result)))))

  ;; (format #t "~%painting ... ~%")
  ;; (format #t "~a~%" (paint g)))
;;(viz-grid (to-grid (rows *test*)))


(puzzle *test*)

(puzzle *input*)

#|
painting region 1128 
painted 127 121 with colour 1128 
painted 127 122 with colour 1128 
painted 127 123 with colour 1128 


number of painted regions 1128 

 ACCEPTED ANSWER ! 

 SOLVED PART B




|#









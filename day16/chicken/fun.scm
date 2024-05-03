

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
#|
(define-macro (do-while con . body)
  `(letrec ((foo (lambda ()
		   (cond
		    (,con ,@body
			  (foo))))))
     (foo)))
|#


(define-macro (do-while con . body)
  (let ((fn (gensym "g")))
    `(letrec ((,fn (lambda ()
		     (cond
		      (,con ,@body
			    (,fn))))))
       (,fn))))


#|
;; this below does not compile ? answers on a post card

(define-er-macro (do-while con . body)
  %
  `(,%letrec ((,%foo (,%lambda ()
			       (,%cond
				(,con ,@body
				      (,%foo))
				(#t #f)))))
	     (,%foo)))
|#

#|
(let ((i 0))
  (do-while (< i 10)
	    (format #t "i = ~a ~%" i)
	    (incf i)))
|#


#|

(define-macro (repeat n . body)
  `(letrec ((foo (lambda (i)
		   (cond
		    ((> i 0) ,@body
		     (foo (- i 1)))))))
     (foo ,n)))
|#


;; hygienic + unhygienic 
(define-er-macro (repeat n . body)
  %
  `(,%letrec ((,%foo (,%lambda (,%i)
			       (,%cond
				((,%> ,%i 0) ,@body
				 (,%foo (,%- ,%i 1)))))))
	     (,%foo ,n)))



;;(repeat 3 (format #t "hello world!~%"))
;;(repeat 1000 (format #t "hello world !~%"))

		   


(define-macro (incf a)
  `(set! ,a (+ ,a 1)))

(let ((a 1))
  (incf a)
  a)


(define-macro (swap! a b)
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
    (swap! n1 n2)
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

(define input (with-input-from-file "input" (lambda () (read))))

(define i 0)
(define (at s i)
  (let ((slen (string-length s)))
    (cond
     ((< i slen) (string-ref s i))
     (#t #f))))

(define (atoi c) (- (char->integer c) (char->integer #\0)))

(define (digit? c) (and c (char>=? c #\0) (char<=? c #\9)))


#|
---------- not used  -----------
(define (parse-num s i)
  (cond
   ((and (digit? (at s i))
	 (digit? (at s (+ i 1))))    
    (let ((a #f)
	  (b #f))
      (set! a (atoi (at s (+ i 0))))
      (set! b (atoi (at s (+ i 1))))
      (values (+ (* 10 a) b) 2)))
   ((and (digit? (at s i)))
    (let ((a #f)
	  (b #f))
      (set! a (atoi (at s (+ i 0))))
      (values a 1)))
   (#t
    (values '() 0))))
|#


#|

pa/j  .... case 1  ..... length 4 
0123      


|#



(define (parse-p s)  
  (let ((slen (string-length s)))
    (cond
     ((and (= slen 4) (char=? #\p (at s 0)))
      (values (list 'partner (at s 1) (at s 3))
	      #t))
     (#t (values '() #f)))))



#|

s1 .... case 1 ..... length 2
01

s15 .... case 2 .....length 3
012

|#
(define (parse-s s)  
  (let ((slen (string-length s)))
    (cond
     ((and (= slen 2) (char=? #\s (at s 0)) (digit? (at s 1)))
      (values (list 'spin (atoi (at s 1)))
	      #t))
     ((and (= slen 3) (char=? #\s (at s 0)) (digit? (at s 1)) (digit? (at s 2)))
      (values (list 'spin (+ (* 10 (atoi (at s 1))) (atoi (at s 2))))
	      #t))
     (#t
      (values '() #f)))))




#|



x1/2     ... case 1 ...... length 4
0123

x12/3    ... case 2 ...... length 5
01234

x5/34    ... case 3 ...... length 5
01234 

x15/14    ... case 4 ...... length 6
012345


|#


(define (parse-x s)
  (let ((slen (string-length s)))
    (cond
     ((and (= slen 4)  (char=? #\x (at s 0)) (char=? #\/ (at s 2)))
      (values (list 'exchange (atoi (at s 1)) (atoi (at s 3)))
	      #t))
     ((and (= slen 5)  (char=? #\x (at s 0)) (char=? #\/ (at s 3)))
      (values (list 'exchange (+ (* 10 (atoi (at s 1))) (atoi (at s 2)))
		    (atoi (at s 4)))
	      #t))
     ((and (= slen 5)  (char=? #\x (at s 0))  (char=? #\/ (at s 2)))
      (values (list 'exchange (atoi (at s 1)) 
		    (+ (* 10 (atoi (at s 3))) (atoi (at s 4))))
	      #t))
     ((and (= slen 6)  (char=? #\x (at s 0)) (char=? #\/ (at s 3)))
      (values (list 'exchange (+ (* 10 (atoi (at s 1))) (atoi (at s 2)))
		    (+ (* 10 (atoi (at s 4))) (atoi (at s 5))))
	      #t))     
     (#t
      (values '() #f)))))



(define (parse str)
  (let ((splits (string-split str ",")))
    (map (lambda (s)
	   (cond
	    ((char=? (string-ref s 0) #\p)
	     (receive (r ok) (parse-p s) (cond
					  (ok r)
					  (#t (error "parse-p")))))
	    ((char=? (string-ref s 0) #\s)
	     (receive (r ok) (parse-s s) (cond
					  (ok r)
					  (#t (error "parse-s")))))
	    ((char=? (string-ref s 0) #\x)
	     (receive (r ok) (parse-x s) (cond
					  (ok r)
					  (#t (error "parse-x")))))
	    (#t (error "parse unknown letter"))))
	 splits)))

;; ===================================================================================


#|

array of length 16
puzzle is 0 .. 15 in length

|#



(define vec2 (list->vector '(#\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l #\m #\n #\o #\p)))
(define vec  (list->vector '(#\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l #\m #\n #\o #\p)))

#|

spin 1 

|#

(define (spin k)
  (letrec ((foo (lambda (i n)
		  (cond
		   ((> i 15) #t)
		   (#t ;;(format #t "copying vec[~a] -> vec2[~a] ~%" i n)
		       (vector-set! vec2 n (vector-ref vec i))
		       (foo (+ i 1) (+ n 1))))))
	   (bar (lambda (n lim)
		  (cond
		   ((> n lim) #t)
		   (#t ;;(format #t "copying vec[~a] -> vec2[~a] ~%" n (+ n k))
		       (vector-set! vec2 (+ n k) (vector-ref vec n))
		       (bar (+ n 1) lim))))))
    (foo (- 16 k) 0)
    ;; (format #t "---------~%")
    (bar 0 (- 15 k))
    (swap! vec vec2)))


;; ok 
(define (exchange a b)
  (let ((tmp (vector-ref vec a)))
    (vector-set! vec a (vector-ref vec b))
    (vector-set! vec b tmp)))


;; partner 
(define (partner ch1 ch2)
  (let ((i1 0)
	(i2 0))
    (letrec ((foo (lambda (i lim)
		    (cond
		     ((>= i lim) #t)
		     (#t (let ((ch (vector-ref vec i)))
			   (cond
			    ((char=? ch ch1) (set! i1 i))
			    ((char=? ch ch2) (set! i2 i)))
			   (foo (+ i 1) lim)))))))
      (foo 0 16)
      (assert (not (= i1 i2)))
      (exchange i1 i2))))



;; =============== part A ==============================

(define (solve!)
  (let ((xs (parse input)))
    (dolist (x xs)
	    (cond
	     ((eq? (car x) 'partner) (partner (cadr x) (caddr x)))
	     ((eq? (car x) 'exchange) (exchange (cadr x) (caddr x)))
	     ((eq? (car x) 'spin) (spin (cadr x)))
	     (#t (error "solve bad op"))))
    (list->string (vector->list vec))))

(define (reset!)
  (set! vec2 (list->vector '(#\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l #\m #\n #\o #\p)))
  (set! vec  (list->vector '(#\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l #\m #\n #\o #\p))))



(define (lots)
  (reset!)
  (let ((counter 0)
	(hash (make-hash-table)))
  (repeat (* 1000 1000 1000)
	  (incf counter)
	  (let ((result (solve!)))
	    (let ((val (hash-table-ref/default hash result #f)))
	      (cond
	       (val
		(assert (pair? val))
		(hash-table-set! hash result (cons counter val))
		(format #t "repeat ~a on ~a ~%" result (cons counter val)))		    
	       (#t (hash-table-set! hash result (list counter)))))))))


(define (lots2)
  (reset!)
  (let ((counter 1) ;; start counter at 1 => already done a solve! 
	(hash (make-hash-table))
	(result (solve!)))
    (letrec ((foo (lambda ()
		    (let ((latest (solve!)))
		      (incf counter)
		      (cond
		       ((string= latest result)
			(format #t "cyclic repetition on ~a with period ~a ~%" latest counter))
		       (#t (foo)))))))
      (foo))))


#|

problem do-while the condition was the complex case needed to check and also increment
counter at same time 

    (do-while (not (string= 
  (repeat (* 1000 1000 1000)
	  (incf counter)
	  (let ((result (solve!)))
	    (let ((val (hash-table-ref/default hash result #f)))
	      (cond
	       (val
		(assert (pair? val))
		(hash-table-set! hash result (cons counter val))
		(format #t "repeat ~a on ~a ~%" result (cons counter val)))		    
	       (#t (hash-table-set! hash result (list counter)))))))))

|#


;; check periodicity is indeed 64
(define (lots3)
  (reset!)
  (let ((counter 1) ;; start counter at 1 => already done a solve! 
	(hash (make-hash-table))
	(result (solve!)))
    (letrec ((foo (lambda ()
		    (let ((latest (solve!)))
		      (incf counter)
		      (cond
		       ((string= latest result)
			(format #t "cyclic repetition on ~a with period ~a : ~a ~%"
				latest
				counter
				(modulo counter 63))
			(foo))
		       (#t (foo)))))))
      (foo))))


#|

cyclic repetition on nlciboghjmfdapek with period 64 : 1 
cyclic repetition on nlciboghjmfdapek with period 127 : 1 
cyclic repetition on nlciboghjmfdapek with period 190 : 1 
cyclic repetition on nlciboghjmfdapek with period 253 : 1 
cyclic repetition on nlciboghjmfdapek with period 316 : 1 
cyclic repetition on nlciboghjmfdapek with period 379 : 1 
cyclic repetition on nlciboghjmfdapek with period 442 : 1 
cyclic repetition on nlciboghjmfdapek with period 505 : 1 
cyclic repetition on nlciboghjmfdapek with period 568 : 1 
cyclic repetition on nlciboghjmfdapek with period 631 : 1 
cyclic repetition on nlciboghjmfdapek with period 694 : 1 
cyclic repetition on nlciboghjmfdapek with period 757 : 1 
cyclic repetition on nlciboghjmfdapek with period 820 : 1 
cyclic repetition on nlciboghjmfdapek with period 883 : 1 
cyclic repetition on nlciboghjmfdapek with period 946 : 1 
cyclic repetition on nlciboghjmfdapek with period 1009 : 1 

using modulo 63 , meaning
 appears first at 1 , then at 1 + 63 , then at 1 + (63 * 2)

1 000 000 000  modulo 63 is 55 , which value is 55

string with one-billion modulo 63 remainder 55 should be our solution string

|#

(define (answer)
  (reset!)
  (let ((counter 1) ;; start counter at 1 => already done a solve! 
	(hash (make-hash-table))
	(result (solve!)))
    (letrec ((foo (lambda ()
		    (let ((latest (solve!)))
		      (incf counter)
		      (cond
		       ((= (modulo counter 63) 55)
			(format #t "mod C 63 rem 55 = ~a  ~%"
				latest)
			(foo))
		       (#t (foo)))))))
      (foo))))


;; (repeat 3 (format #t "hello world!"))

;;(lots2)
;;(lots3)
(answer)


#|
mod C 63 rem 55 = nlciboghmkedpfja  
mod C 63 rem 55 = nlciboghmkedpfja  
mod C 63 rem 55 = nlciboghmkedpfja  
mod C 63 rem 55 = nlciboghmkedpfja

ANSWER ACCEPTED !



|#



	   













      
    
  

  
  
  

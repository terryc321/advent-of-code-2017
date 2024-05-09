
#|


arbitrary grid either multiple of 2 or 3

divisible by 2 , break grid into 2 x 2 grids
 generate corresponding 3 x 3 grids

divisible by 3 , break grid into 3 x 3 grids
 generate corresponding 4 x 4 grids 

start : () -> grid
start () : grid 
-> (grid (size 3) (values (1 1 0) (2 1 1) (3 1 0) (1 2 0) (2 2 0) (3 2 1) (1 3 1) (2 3 1) (3 3 1)))

split-grid : grid -> list of grid 
(split-grid g)

start is a 3x3
.#.
..#
###

divisible by 3 - split into 3x3 squares convert each one to 4x4 square

#;11172> (split-grid (start))
((grid (size 3) (values (1 1 0) (2 1 1) (3 1 0) (1 2 0) (2 2 0) (3 2 1) (1 3 1) (2 3 1) (3 3 1))))


(start) -> ".#./..#/###" 
(split-grid (start)) -> (".#./..#/###")  list one 3x3 grid initial grid
match up to a 4x4 grid

(enhance ".#./..#/###" ) -> find s + lookup s if found then return result
(find ".#./..#/###" )



|#



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

;; ------------------------------- macros -------------------------------

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





#|

grid-map is now some meta data relates how string 1 < - > string 2 match up 

(map 
 (grid
  (size 2)
  (string "../..")
  (values ((2 2 0) (1 2 0) (2 1 0) (1 1 0))))
 (grid
  (size 3)
  (string ".../#.#/...")
  (values
    ((3 3 0)
     (2 3 0)
     (1 3 0)
     (3 2 1)
     (2 2 0)
     (1 2 1)
     (3 1 0)
     (2 1 0)
     (1 1 0)))))

(find "../..")

(define (gen2)
  (let ((a # .)
	(b # .)
	(c # .)
	(d # .))
    (list a b c d)))

|#


(define input2-map
  '(
    ("../.." ".../#.#/...")
    ("#./.." "..#/..#/#..")
    ("##/.." ".../#../..#")
    (".#/#." "#../.../...")
    ("##/#." "#.#/.#./#..")
    ("##/##" "..#/#.#/..#")
    ))

(define input3-map
  '(
    (".../.../..." ".#../#..#/#.../.#..")
    ("#../.../..." "..##/..##/.#.#/....")
    (".#./.../..." "..##/..##/.###/##..")
    ("##./.../..." "..../.##./#.##/..#.")
    ("#.#/.../..." "####/#.##/#.##/#.#.")
    ("###/.../..." "#..#/..#./..../##.#")
    (".#./#../..." "..#./.#../...#/#.##")
    ("##./#../..." "..../#.##/#..#/.#..")
    ("..#/#../..." "##.#/####/###./###.")
    ("#.#/#../..." "..../#.##/.###/#.#.")
    (".##/#../..." "..#./##.#/####/..##")
    ("###/#../..." "..#./.##./...#/..#.")
    (".../.#./..." ".###/#.../.#../####")
    ("#../.#./..." "###./.#.#/#.##/##.#")
    (".#./.#./..." "..##/..#./###./..#.")
    ("##./.#./..." "#..#/..#./###./...#")
    ("#.#/.#./..." "#.../##.#/#.##/#..#")
    ("###/.#./..." "...#/#..#/####/##.#")
    (".#./##./..." "#.##/#.##/..../#.#.")
    ("##./##./..." "..##/###./..#./####")
    ("..#/##./..." "..../##../##.#/.##.")
    ("#.#/##./..." "##../####/####/.#.#")
    (".##/##./..." "..../##.#/.###/##..")
    ("###/##./..." ".#../#.#./.#../..##")
    (".../#.#/..." "####/#.#./..##/#..#")
    ("#../#.#/..." ".#../.#../#..#/....")
    (".#./#.#/..." "..##/.##./####/#.#.")
    ("##./#.#/..." "..#./###./.#../....")
    ("#.#/#.#/..." "..#./..#./...#/#...")
    ("###/#.#/..." "###./.#../##../####")
    (".../###/..." "#.##/####/####/..##")
    ("#../###/..." ".#.#/...#/###./...#")
    (".#./###/..." "..../.#.#/.#../....")
    ("##./###/..." "...#/.###/..../.##.")
    ("#.#/###/..." "..##/###./.#../#..#")
    ("###/###/..." ".###/..#./..#./.###")
    ("..#/.../#.." ".##./###./####/#.#.")
    ("#.#/.../#.." "####/#.../#.../..##")
    (".##/.../#.." "###./#..#/..#./.#..")
    ("###/.../#.." ".###/.##./#.#./.###")
    (".##/#../#.." "##.#/...#/.#.#/...#")
    ("###/#../#.." "#.##/..#./..../#..#")
    ("..#/.#./#.." "#..#/##.#/.##./####")
    ("#.#/.#./#.." "###./..##/#..#/#..#")
    (".##/.#./#.." ".#../..../...#/...#")
    ("###/.#./#.." ".#../##../.###/..#.")
    (".##/##./#.." "##../..##/##../##.#")
    ("###/##./#.." "#.##/#..#/.###/####")
    ("#../..#/#.." "##.#/####/#.../..##")
    (".#./..#/#.." "#..#/..../..../###.")
    ("##./..#/#.." "#..#/##.#/##.#/#.#.")
    ("#.#/..#/#.." ".###/##.#/####/#...")
    (".##/..#/#.." "####/.##./...#/#..#")
    ("###/..#/#.." ".#.#/####/##.#/...#")
    ("#../#.#/#.." "..##/.##./..##/##..")
    (".#./#.#/#.." "#.../##../..##/..#.")
    ("##./#.#/#.." "...#/##.#/#..#/.#..")
    ("..#/#.#/#.." "#.#./##../#.##/###.")
    ("#.#/#.#/#.." "##../##.#/#.#./....")
    (".##/#.#/#.." "####/...#/####/.#..")
    ("###/#.#/#.." "..../.#../.#../....")
    ("#../.##/#.." ".#.#/..#./#..#/.###")
    (".#./.##/#.." "#.../.#.#/.###/.##.")
    ("##./.##/#.." "#.#./#.#./.#../###.")
    ("#.#/.##/#.." "####/##../.##./####")
    (".##/.##/#.." "#.../#.#./#.##/###.")
    ("###/.##/#.." "####/####/..../####")
    ("#../###/#.." "####/.##./...#/##.#")
    (".#./###/#.." ".#../#.##/#..#/..##")
    ("##./###/#.." "#.#./..##/#.../..##")
    ("..#/###/#.." "#.##/.###/#.#./###.")
    ("#.#/###/#.." "#.##/#.##/..../#..#")
    (".##/###/#.." ".##./#.#./..##/####")
    ("###/###/#.." ".##./#..#/#.../###.")
    (".#./#.#/.#." "#.#./#..#/#..#/##.#")
    ("##./#.#/.#." "...#/#.#./##.#/###.")
    ("#.#/#.#/.#." "##.#/..##/##.#/#.##")
    ("###/#.#/.#." ".#.#/..#./##../.##.")
    (".#./###/.#." "#..#/..#./..##/#...")
    ("##./###/.#." "####/.#.#/####/..#.")
    ("#.#/###/.#." "#.#./..##/##../#..#")
    ("###/###/.#." "...#/..../..../#.#.")
    ("#.#/..#/##." "..#./.##./###./.#.#")
    ("###/..#/##." "#.../###./...#/####")
    (".##/#.#/##." "..../..../.###/##..")
    ("###/#.#/##." "##../..../#.#./.##.")
    ("#.#/.##/##." ".#.#/##../..##/#.#.")
    ("###/.##/##." "###./####/...#/.#..")
    (".##/###/##." "..##/#.../..##/.#.#")
    ("###/###/##." "..##/...#/.###/.#..")
    ("#.#/.../#.#" "..##/#.../##.#/....")
    ("###/.../#.#" "#.##/#..#/..../##..")
    ("###/#../#.#" "#.../..../##.#/..#.")
    ("#.#/.#./#.#" "###./..##/.#../.##.")
    ("###/.#./#.#" "..../#..#/.###/#..#")
    ("###/##./#.#" ".#.#/###./##.#/.###")
    ("#.#/#.#/#.#" "..../..../.##./#..#")
    ("###/#.#/#.#" ".###/.#.#/...#/.###")
    ("#.#/###/#.#" ".#.#/##../.#../.#..")
    ("###/###/#.#" ".#.#/.##./#.##/....")
    ("###/#.#/###" "..#./..#./..#./..##")
    ("###/###/###" "##.#/..##/.#.#/....")
    ))

(define input-map (append input2-map input3-map))


#|

"ab/cd" => ("ba/dc" "ac/bd" "cd/ab" "db/ca" "bd/ac" "dc/ba" "ca/db" )

"abc/def/ghi" => ("cba/fed/ihg" "adg/beh/cfi" "ghi/def/abc" "ifc/heb/gda" "cfi/beh/adg" "ihg/fed/cba" "gda/heb/ifc" )

start program always same 3 x 3 
.#.
..#
###

step1
3x3                   1:  4x4 match found 
".#./..#/###" => "...#/##.#/#..#/.#.."

convert each 2 x 2 square into 3 x 3 squares , piece whole thing together ...

string on-offs -> 2 d grid 

step-1 result
...#
##.#
#..#
.#..

gives four 
../##  .#/.#
#./.#  .#/..

in turn yields 4 3x3 squares


|#

;; --------------------------------------------------------------------------
#|
2 d grid abstraction

|#
(define (grid/make) (list))
(define (grid/set g x y z)
  (cons (list x y z) g))
(define (grid/get g x y)
  (call/cc (lambda (exit)
	     (dolist (xyz g)
		     (cond
		      ((and (= x (car xyz)) (= y (cadr xyz))) (exit (caddr xyz)))))
	     (error "grid/get"))))


(define (grid/size g)
  (apply max (map car g)))

#|

#;6852> (str->grid ".#./..#/###" )
((3 3 1) (2 3 1) (1 3 1) (3 2 1) (2 2 0) (1 2 0) (3 1 0) (2 1 1) (1 1 0))

tag
label 

(grid (size 4 4)
(vals '((3 3 1) (2 3 1) (1 3 1) (3 2 1) (2 2 0) (1 2 0) (3 1 0) (2 1 1) (1 1 0))))

(tag grid ...)

|#

;;(define (tag x y) (cons x y))
(define tag cons)
(define (type x) (car x))

#|

consing is like an immutable hash table
gets built up piece by piece
can be used in recursive call because does not mutate ,
does not impeed own view of solution

|#

;; --------------------------------------------------------------------------

;;(define (start) ".#./..#/###" )

(define init ".#./..#/###" )



(define (start)
  `(grid
    (size 3)
    (flat   (0 1 0 0 0 1 1 1 1))
    (values (1 1 0)
	    (2 1 1)
	    (3 1 0)
	    (1 2 0)
	    (2 2 0)
	    (3 2 1)
	    (1 3 1)
	    (2 3 1)
	    (3 3 1))))


;; split-grid 

;; ------------------------------- like assoc a-lists -------------------------

;; get a property
(define (get-prop s p)
  (let ((ass (assoc p (cdr s))))
    (cond
     ((not ass) (error (format #f "get-prop : no property ~a in ~a " p s)))
     ((null? (cdr (cdr ass))) (cadr ass))
     (#t (cdr ass)))))


;; replace a property - non destructively - builds new property 
(define (put-prop s x y)
  (let ((tag (car s))
	(vals (cdr s))
	(result '()))
    (dolist (v vals)
	    (cond
	     ((and (pair? v) (eq? (car v) x))
	      (set! result (cons (list x y) result)))
	     (#t
	      (set! result (cons v result)))))
    (cons tag result)))
    
;; 
(define (grid-size s)
  (assert (eq? 'grid (type s)))
  (get-prop s 'size))

(define (grid-values s)
  (assert (eq? 'grid (type s)))
  (get-prop s 'values))



;; ----------------------------------------------------------------------------

;; (define (step-1)
;;   (let ((alts (find (start))))
;;     (call/cc (lambda (exit)
;; 	       (dolist (alt alts)
;; 		       (let ((as (assoc alt input-map)))
;; 			 (cond
;; 			  (as (exit (second as))))))))))

#|
as well as making a type
we are building some meta - data into the data type 
|#
;; handle 2 x 2 
(define (str->grid s)
  (let ((slen (string-length s)))
    (letrec ((foo (lambda (x y i rs)
		    (cond
		     ((>= i slen) rs)
		     (#t (let ((ch (string-ref s i)))
			   (cond
			    ((char=? ch #\. )
			     (foo (+ x 1) y (+ i 1) (grid/set rs x y 0)))
			    ((char=? ch #\# )
			     (foo (+ x 1) y (+ i 1) (grid/set rs x y 1)))
			    ((char=? ch #\/ )
			     (foo 1 (+ y 1) (+ i 1) rs))
			    (#t (error "str->grid")))))))))
      (cond
       ((= slen 5)  `((type grid) (size 2) (string ,s) (values ,(foo 1 1 0 '()))))
       ((= slen 11)  `((type grid) (size 3) (string ,s) (values ,(foo 1 1 0 '()))))
       ((= slen 19)  `((type grid) (size 4) (string ,s) (values ,(foo 1 1 0 '()))))       
       (#t (error "str->grid"))))))


;; -----------------------------------------------------------------------------------

(define (split-grid g)
  (let ((size (get-prop g 'size)))
    (cond
     ((= 0 (modulo size 2)) (split-grid-2 g size))
     ((= 0 (modulo size 3)) (split-grid-3 g size))
     (#t (error "split-grid")))))


(define (split-grid-2 g size)
  ;;(format #t "split-grid-2 ~%" )
  (let* ((lim (/ size 2))
	 (iot (iota lim 1 2))
	 (result '()))
    (dolist (y iot)
	    (dolist (x iot)
		    (let* ((sg (list
				(list x y)
				(list (+ x 1) y)
				(list x (+ y 1))
				(list (+ x 1) (+ y 1))))
			   (sg2 (map (lambda (xy) (let* ((x (car xy))
							 (y (cadr xy))
							 (v (grid/get g x y)))
						    (list x y v)))
				     sg)))				
		      ;; (format #t "~a ~%" sg)
		      ;; (format #t "~a ~%" sg2)		      
		      (set! result (cons sg2 result)))))
    result))





(define (split-grid-3 g size)
  ;;(format #t "split-grid-3 ~%" )
  (let* ((lim (/ size 3))
	 (iot (iota lim 1 3))
	 (gv (get-prop g 'values))
	 (result '()))
    (dolist (y iot)
	    (dolist (x iot)
		    (let* ((sg (list
				(list x y)
				(list (+ x 1) y)
				(list (+ x 2) y)
				(list x (+ y 1))
				(list (+ x 1) (+ y 1))
				(list (+ x 2) (+ y 1))
				(list x (+ y 2))
				(list (+ x 1) (+ y 2))
				(list (+ x 2) (+ y 2))))
			   (sg2 `(grid (size 3) (values ,@(map (lambda (xy) (let* ((x (car xy))
							 (y (cadr xy))
							 (v (grid/get gv x y)))
						    (list x y v)))
				     sg)))))				
		      ;; (format #t "~a ~%" sg)
		      ;; (format #t "~a ~%" sg2)		      
		      (set! result (cons sg2 result)))))
    result))


;; -------------------------------------------------------------------------------------------



;; (letrec ((foo (lambda (x y rs)
;; 		  (cond
;; 		   ((> y size) rs)
;; 		   ((> x size) (foo 1 (+ y 2) rs))
;; 		   (#t (foo (+ x 2) y (grid/set (grid/set rs x y (grid/get g x y))
;; 						(+ x 1) y
;; 						(grid/get g (+ x 1) y))))))))
;;   (foo 1 1 '())))







;;------------------------------- 2 x 2 routines ----------------------------------
(define (rot2d-1 s)
  (format #f "~a~a/~a~a"
	  (string-ref s 3) (string-ref s 0)
	  (string-ref s 4) (string-ref s 1)))

(define (rot2d-2 s) (rot2d-1 (rot2d-1 s)))

(define (rot2d-3 s) (rot2d-1 (rot2d-1 (rot2d-1 s))))

(define (rot2d-4 s) (rot2d-1 (rot2d-1 (rot2d-1 (rot2d-1 s)))))

(define (ref2d-1 s)
  (format #f "~a~a/~a~a" (string-ref s 1) (string-ref s 0) (string-ref s 4) (string-ref s 3)))

(define (ref2d-2 s)
  (format #f "~a~a/~a~a" (string-ref s 3) (string-ref s 4) (string-ref s 0) (string-ref s 1)))

(define (find2 s)
  (let ((known '()))
    (letrec ((foo (lambda (s)
		    (cond
		     ((member s known) #f)
		     (#t (set! known (cons s known))
			 (foo (rot2d-1 s))
			 (foo (rot2d-2 s))
			 (foo (rot2d-3 s))
			 (foo (rot2d-4 s))
			 (foo (ref2d-1 s))
			 (foo (ref2d-2 s)))))))
      (foo s)
      known)))


;; --------------------- 3x3 rotations ------------------------------------


(define (rot3d-1 s)
  (format #f "~a~a~a/~a~a~a/~a~a~a"
	  (string-ref s 8) (string-ref s 4) (string-ref s 0)
	  (string-ref s 9) (string-ref s 5) (string-ref s 1)
	  (string-ref s 10) (string-ref s 6) (string-ref s 2)
	  ))

(define (rot3d-2 s) (rot3d-1 (rot3d-1 s)))

(define (rot3d-3 s) (rot3d-1 (rot3d-1 (rot3d-1 s))))

(define (rot3d-4 s) (rot3d-1 (rot3d-1 (rot3d-1 (rot3d-1 s)))))

(define (ref3d-1 s)
  (format #f "~a~a~a/~a~a~a/~a~a~a"
	  (string-ref s 2) (string-ref s 1) (string-ref s 0)
	  (string-ref s 6) (string-ref s 5) (string-ref s 4)
	  (string-ref s 10) (string-ref s 9) (string-ref s 8)
	  ))

(define (ref3d-2 s)
  (format #f "~a~a~a/~a~a~a/~a~a~a"
	  (string-ref s 8) (string-ref s 9) (string-ref s 10)
	  (string-ref s 4) (string-ref s 5) (string-ref s 6)
	  (string-ref s 0) (string-ref s 1) (string-ref s 2)
	  ))

(define (find3 s)
  (let ((known '()))
    (letrec ((foo (lambda (s)
		    (cond
		     ((member s known) #f)
		     (#t (set! known (cons s known))
			 (foo (rot3d-1 s))
			 (foo (rot3d-2 s))
			 (foo (rot3d-3 s))
			 (foo (rot3d-4 s))
			 (foo (ref3d-1 s))
			 (foo (ref3d-2 s)))))))
      (foo s)
      known)))

;; -----------------------------------------------------------------------------
(define (find s)
  (assert (string? s))
  (cond
   ((= (string-length s) 11) (reverse (find3 s)))
   ((= (string-length s) 5) (reverse (find2 s)))
   (#t (error "find"))))

(define (enhance s)
  (let ((f (find s)))
    (call/cc (lambda (exit)
	       (dolist (str f)
		       (dolist (pr input-map)
			       (let ((p (car pr))
				     (r (cadr pr)))
				 (cond
				  ((equal? p str) (exit r))))))
	       (error (format #f "enhance : no matching string ~a ~%" s))))))



;; ------------------------------------------------------------------------------

;; ------------------------------ input map ---------------------------
(define grid-map (cons 'seq
		       (map (lambda (x) (list 'map
					      (str->grid (car x))
					      (str->grid (cadr x)))) input-map)))






#|

|#
;; ----------------------------------------------------------------------------------



#|			 
(define (ffind s xs)
(cond
((member s xs) #f)
(#t 


(define (ffind xs lim)
(cond
((= (length xs) lim) (format #t "xs = ~A ~%" xs))
(#t 
(letrec ((foo (lambda (i)
(cond
((> i lim) #f)
((member i xs) (foo (+ i 1)))
(#t (ffind (cons i xs) lim)
(foo (+ i 1)))))))
(foo 1)))))

(ffind '() 9)

xs = (9 8 7 6 5 4 3 2 1) 
xs = (8 9 7 6 5 4 3 2 1) 
xs = (9 7 8 6 5 4 3 2 1) 
xs = (7 9 8 6 5 4 3 2 1) 
xs = (8 7 9 6 5 4 3 2 1) 
xs = (7 8 9 6 5 4 3 2 1) 
...
xs = (3 1 2 4 5 6 7 8 9) 
xs = (1 3 2 4 5 6 7 8 9) 
xs = (2 1 3 4 5 6 7 8 9) 
xs = (1 2 3 4 5 6 7 8 9) 
#f

#;1187> (* 9 8 7 6 5 4 3 2 1)
362880

|#

#|
(define (pick-a)
(pick-b '(0))
(pick-b '(1))
(pick-b '(2))
(pick-b '(3)))

(define (pick-b xs)
(let ((a (car xs)))
(cond
((= a 0)
(pick-c (cons 1 xs))
(pick-c (cons 2 xs))
(pick-c (cons 3 xs)))
((= a 1)
(pick-c (cons 0 xs))
(pick-c (cons 2 xs))
(pick-c (cons 3 xs)))
((= a 2)
(pick-c (cons 0 xs))
(pick-c (cons 1 xs))
(pick-c (cons 3 xs)))
((= a 3)
(pick-c (cons 0 xs))
(pick-c (cons 1 xs))
(pick-c (cons 2 xs))))))

(define (pick-c xs)
(let ((a (cadr xs))
(b (car xs)))
(cond
((and (= a 0)(= b 1)) (cons 3 (cons 2 xs)))
)))
|#


#|

2 x 2

a b
c d

how many ways can rotate and reflect this thing

a b / c d
0 1 2 3 4 
a b  -> one rotation      c a
c d                       d b

a 0
b 1
c 3
d 4

a b  ->  reflect y      b a
c d                     d c

a b  ->  reflect x      c d
c d                     a b

a choice of 4 squares
_ _ / _ _

given a 2 x 2 matrix , what are all possible arrangements if only reflect and rotate the 2 x 2 


|#

#|
3 x 3 routines

a b c  -> one rot ->      g  d  a
d e f                     h  e  b
g h i                     i  f  c

a b c / d e f / g h i
0 1 2 3 4 5 6 7 8 9 10

a b c  ->  reflection ->  c b a
d e f                     f e d
g h i                     i h g

a b c  -> reflection  ->  g h i
d e f                     d e f
g h i                     a b c

seems like only 8 orientations for a given square if only reflected vertically , horizontally


|#

;; step 0 is 3 x 3 - every program P starts with this
(define (step-0) ".#./..#/###" )

;; step-1 is 4 x 4
(define (step-1)
  (enhance (step-0)))

;; ...#
;; ##.#
;; #..#
;; .#..

;; a b
;; c d

;; split string based on forward slash / 
(define (split-string s)
  (let ((slen (string-length s)))
    (letrec ((foo (lambda (i tmp rs)
		    (cond
		     ((>= i slen) (reverse (cons tmp rs)))
		     ((char=? #\/ (string-ref s i))
		      (foo (+ i 1) "" (cons tmp rs)))
		     (#t
		      (foo (+ i 1) (string-append tmp (string (string-ref s i))) rs))))))
      (foo 0 "" '()))))

(define (step-2a)
  (let ((a (enhance "../##"))
	(b (enhance ".#/.#"))
	(c (enhance "#./.#"))
	(d (enhance ".#/..")))
    (list (list a b)
	  (list c d))))


(define (step-2b)
  (map (lambda (x) (map split-string x)) (step-2a)))

(define (step-2c)
  (let ((ex (step-2b)))
    (dolist (v ex)
	    ;;(format #t "[v = ~a ]~%" v)
	    (dolist (i (list 0 1 2))
		    (dolist (w v)
			    (format #t "~a" (list-ref w i)))
		    (format #t "~%"))
	    )))

(define (step-2)
  (step-2c))

#|

... ...
#.. #..
..# ..#

#.. ..#
... ..#
... #..

a b
c d

|#

;; -------------------------------------------------------
(define (step-3a)
  (let ((a (enhance ".../#../..#"))
	(b (enhance ".../#../..#"))
	(c (enhance "#../.../..."))
	(d (enhance "..#/..#/#..")))
    (list (list a b)
	  (list c d))))

(define (step-3b)
  (map (lambda (x) (map split-string x)) (step-3a)))

(define (step-3c)
  (let ((ex (step-3b)))
    (dolist (v ex)
	    ;;(format #t "[v = ~a ]~%" v)
	    (dolist (i (list 0 1 2 3))
		    (dolist (w v)
			    (format #t "~a" (list-ref w i)))
		    (format #t "~%"))
	    )))

;; step 3 -> 8 x 8 
(define (step-3)
  (step-3c))

;; -----------------------------------------------------
#|

## .# ## .#
## ## ## ##

## #. ## #.
## #. ## #.

.. ## ## #.
.. ## #. .#

.# .# .. #.
.. .. .# ..


|#
(define (step-4a)
  (let ((a1 (enhance "##/##"))
	(a2 (enhance ".#/##"))
	(a3 (enhance "##/##"))
	(a4 (enhance ".#/##"))
		
	(a5 (enhance "##/##"))
	(a6 (enhance "#./#."))
	(a7 (enhance "##/##"))
	(a8 (enhance "#./#."))

	(a9 (enhance "../.."))
	(a10 (enhance "##/##"))
	(a11 (enhance "##/#."))
	(a12 (enhance "#./.#"))

	(a13 (enhance ".#/.."))
	(a14 (enhance ".#/.."))
	(a15 (enhance "../.#"))
	(a16 (enhance "#./.."))

	)
    (list (list a1 a2 a3 a4)
	  (list a5 a6 a7 a8)
	  (list a9 a10 a11 a12)
	  (list a13 a14 a15 a16)
	  )))



(define (step-4b)
  (map (lambda (x) (map split-string x)) (step-4a)))

(define (step-4c)
  (let ((ex (step-4b)))
    (dolist (v ex)
	    ;;(format #t "[v = ~a ]~%" v)
	    (dolist (i (list 0 1 2))
		    (dolist (w v)
			    (format #t "~a" (list-ref w i)))
		    (format #t "~%"))
	    )))

(define (step-4)
  (step-4c))

;;--------------------------------------------------------------------

#|

step 4 result

..# #.# ..# #.#
#.# .#. #.# .#.
..# #.. ..# #..

..# ... ..# ...
#.# #.. #.# #..
..# ..# ..# ..#

... ..# #.# #..
#.# #.# .#. ...
... ..# #.. ...

..# ..# ..# ..#
..# ..# ..# ..#
#.. #.. #.. #..

|#

(define (step-5a)
  (let ((a1  (enhance "..#/#.#/..#"))
	(a2  (enhance "#.#/.#./#.."))
	(a3  (enhance "..#/#.#/..#"))
	(a4  (enhance "#.#/.#./#.."))
		
	(a5  (enhance "..#/#.#/..#"))
	(a6  (enhance ".../#../..#"))
	(a7  (enhance "..#/#.#/..#"))
	(a8  (enhance ".../#../..#"))

	(a9  (enhance ".../#.#/..."))
	(a10 (enhance "..#/#.#/..#"))
	(a11 (enhance "#.#/.#./#.."))
	(a12 (enhance "#../.../..."))

	(a13 (enhance "..#/..#/#.."))
	(a14 (enhance "..#/..#/#.."))
	(a15 (enhance "..#/..#/#.."))
	(a16 (enhance "..#/..#/#.."))

	)
    (list (list a1 a2 a3 a4)
	  (list a5 a6 a7 a8)
	  (list a9 a10 a11 a12)
	  (list a13 a14 a15 a16)
	  )))



(define (step-5b)
  (map (lambda (x) (map split-string x)) (step-5a)))

(define (step-5c)
  (let ((ex (step-5b)))
    (dolist (v ex)
	    ;;(format #t "[v = ~a ]~%" v)
	    (dolist (i (list 0 1 2 3)) ;;  0 .. 3 for 4 x 4 tiles
		    (dolist (w v)
			    (format #t "~a" (list-ref w i)))
		    (format #t "~%"))
	    )))

(define (step-5)
  (step-5c))

#|

..#####...#####.
.##...##.##...##
..###..#..###..#
##..#..###..#..#
..####.#..####.#
.##.####.##.####
..#####...#####.
##..###.##..###.
####..#####...##
#.#..##...##..##
..##..###..#.#.#
#..###..#..#....
###.###.###.###.
#..##..##..##..#
..#...#...#...#.
.#...#...#...#..


137 matches in 16 lines for "#" in buffer: *Geiser Chicken REPL* within region: 3907-4179
    204:..#####...#####.
    205:.##...##.##...##
    206:..###..#..###..#
    207:##..#..###..#..#
    208:..####.#..####.#
    209:.##.####.##.####
    210:..#####...#####.
    211:##..###.##..###.
    212:####..#####...##
    213:#.#..##...##..##
    214:..##..###..#.#.#
    215:#..###..#..#....
    216:###.###.###.###.
    217:#..##..##..##..#
    218:..#...#...#...#.
    219:.#...#...#...#..

137

answer REJECTED !
sheesh cabbab




|#


















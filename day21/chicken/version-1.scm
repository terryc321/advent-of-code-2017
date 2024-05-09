
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


rotate.scm

2 x 2 routines

rotation 
0 1    2 0
2 3    3 1 

reflect horizontally
0 1     1 0
2 3     3 2 

reflect vertical
0 1     2 3
2 3     0 1

|#


(define (rot2d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(2 0 3 1)))

(define (rot2d-2 xs) (rot2d-1 (rot2d-1 xs)))

(define (rot2d-3 xs) (rot2d-1 (rot2d-1 (rot2d-1 xs))))

(define (rot2d-4 xs) (rot2d-1 (rot2d-1 (rot2d-1 (rot2d-1 xs)))))

(define (ref2d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(1 0 3 2)))

(define (ref2d-2 xs)
  (map (lambda (i) (list-ref xs i)) '(2 3 0 1)))


#|

3 x 3 routines

rotation 
0 1 2          6  3  0
3 4 5          7  4  1
6 7 8          8  5  2

reflect horiz
0 1 2          6 7 8 
3 4 5          3 4 5
6 7 8          0 1 2

reflect vert
0 1 2          2 1 0
3 4 5          5 4 3
6 7 8          8 7 6


|#

(define (rot3d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(  6 3 0
					7 4 1
					8 5 2)))

(define (rot3d-2 xs) (rot3d-1 (rot3d-1 xs)))

(define (rot3d-3 xs) (rot3d-1 (rot3d-1 (rot3d-1 xs))))

(define (rot3d-4 xs) (rot3d-1 (rot3d-1 (rot3d-1 (rot3d-1 xs)))))

(define (ref3d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(  6 7 8
					3 4 5
					0 1 2)))

(define (ref3d-2 xs)
  (map (lambda (i) (list-ref xs i)) '(  2 1 0
					5 4 3
					8 7 6)))


#|

4 x 4 routines

rotation 90 degree right
0  1  2   3             12   8    4  0
4  5  6   7             13   9    5  1
8  9  10 11             14   10   6  2
12 13 14 15             15   11   7  3

reflect horiz
0 1 2  3           3  2  1  0
4 5 6  7           7  6  5  4
8 9 10 11          11 10 9  8
12 13 14 15        15 14 13 12

reflect vert
0 1 2  3            12 13 14 15        
4 5 6  7            8 9 10 11
8 9 10 11           4 5 6  7
12 13 14 15         0 1 2  3



|#

(define (rot4d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(   12 8  4 0
					 13 9  5 1
					 14 10 6 2
					 15 11 7 3
				      )))

(define (rot4d-2 xs) (rot4d-1 (rot4d-1 xs)))

(define (rot4d-3 xs) (rot4d-1 (rot4d-1 (rot4d-1 xs))))

(define (rot4d-4 xs) (rot4d-1 (rot4d-1 (rot4d-1 (rot4d-1 xs)))))

(define (ref4d-1 xs)
  (map (lambda (i) (list-ref xs i)) '(  
				        3   2 1  0
					7   6 5  4
					11 10 9  8
					15 14 13 12					
					)))

(define (ref4d-2 xs)
  (map (lambda (i) (list-ref xs i)) '( 12 13 14 15
				        8 9 10 11
					4 5 6  7
					0 1 2  3					
					)))


;; puzzle states never rotate or flip the output mapping
(define (rotate-flip-permute2 from)
  (let ((known '()))
    (letrec ((foo (lambda (a)
		    (cond
		     ((member a known) #f)
		     (#t (set! known (cons a known))
			 (foo (rot2d-1 a))
			 (foo (rot2d-2 a))
			 (foo (rot2d-3 a))
			 (foo (ref2d-1 a))
			 (foo (ref2d-2 a))
			 )))))
      (foo from)
      known)))



(define (rotate-flip-permute3 from)
  (let ((known '()))
    (letrec ((foo (lambda (a)
		    (cond
		     ((member a known) #f)
		     (#t (set! known (cons a known))
			 (foo (rot3d-1 a))
			 (foo (rot3d-2 a))
			 (foo (rot3d-3 a))
			 (foo (ref3d-1 a))
			 (foo (ref3d-2 a))
			 )))))
      (foo from)
      known)))


(define (rotate-flip-permute from)
  (cond
   ((= (length from) 4)
    (reverse (rotate-flip-permute2 from)))
   ((= (length from) 9)
    (reverse (rotate-flip-permute3 from)))
   (#t (error "rotate-flip-permute"))))




;; ----------------------- map conversion --------------------------------------

(define (convert-char ch)
  (cond
   ((char=? ch #\.) 0)
   ((char=? ch #\#) 1)
   (#t (error "convert-char"))))

(define (convert s)
  (let ((slen (string-length s)))
    (cond
     ((= slen 5) (map convert-char (map (lambda (i) (string-ref s i)) '(0 1 3 4))))
     ((= slen 11) (map convert-char (map (lambda (i) (string-ref s i)) '(0 1 2
								       4 5 6
								       8 9 10))))
     ((= slen 19) (map convert-char (map (lambda (i) (string-ref s i))
				     '(0 1 2 3
					 5 6 7 8
					 10 11 12 13
					 15 16 17 18))))
     (#t (error "convert")))))

(define example-map
  '(
    ("../.#" "##./#../...")
    (".#./..#/###" "#..#/..../..../#..#")
    ))


(define input-map
  '(
    ("../.." ".../#.#/...")
    ("#./.." "..#/..#/#..")
    ("##/.." ".../#../..#")
    (".#/#." "#../.../...")
    ("##/#." "#.#/.#./#..")
    ("##/##" "..#/#.#/..#")
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



;; vectors should be square matrices 2 x 2 ( 4 elems ), 3 x 3 ( 9 elems )or 4 x 4 ( 16 elems )
(define (convert-map m)
  (map (lambda (xy)
			 (let ((x (convert (car xy)))
			       (y (convert (cadr xy))))
			   (let ((xlen (length x))
				 (ylen (length y)))				 
			     (assert (member xlen '(4 9 16)))
			     (assert (member ylen '(4 9 16)))
			     (list x y))))
		     m))


;; extend maps to cover all possible rotations and reflections
;; being careful not to introduce erroneous mappings ?
;; is the "from" part in the map already ? if so leave it alone .
(define (extend-map m)
  (let ((extras '()))
    (define (in-map-already? p)
      (call/cc (lambda (found)
		 (dolist (pr input-map)
			 (let ((p1 (car pr)))
			   (cond
			    ((equal? p p1) (found #t)))))
		 (dolist (pr extras)
			 (let ((p1 (car pr)))
			   (cond
			    ((equal? p p1) (found #t)))))
		 #f)))
    (dolist (pr input-map)
	    (let* ((from (car pr))
		   (to (cadr pr))
		   (possible (rotate-flip-permute from)))
	      (dolist (p possible)
		      (cond
		       ((in-map-already? p) #f)
		       (#t (set! extras (cons (list p to) extras)))))))
    ;;(format #t "generated ~a extra mappings ~%" (length extras))
    (append input-map extras)))





;; ---------------------------- SIDE EFFECTS HERE !!!! ----------------------
;; ;; side effects only
(set! input-map (convert-map input-map))
(set! example-map (convert-map example-map))

(set! input-map (extend-map input-map))
(set! example-map (extend-map example-map))

;; ----------------------------- sub grids ------------------------------------

;; see split.scm for contents


;; ------------------------- try solve ------------------------------------------

;; try to pull everything together and make a solution ??
(define (map-lookup s m)
  (call/cc (lambda (found)
	     (dolist (pr m)
		     (let ((from (car pr))
			   (to (cadr pr)))
		       (cond
			((equal? from s) (found to)))))
	     (error (format #f "map-lookup ~a not found" s)))))




;;".#./..#/###"
(define init-grid '(  0 1 0
		      0 0 1
		      1 1 1))

;; t0 is 3 x 3  grid - 9 numbers
(define t0 init-grid)

;; after 1 enhance (map-lookup)
;; t1 is 4 x 4 grid  - 16 numbers
(define t1 (map-lookup t0 input-map))


#|
t1 divisible by 2
t1 group into

2x2  2x2
2x2  2x2
into
3x3 3x3
3x3 3x3  result 6 x 6 matrix
|#
;; (define t2 (let* ((tmp1 (group-grids t1 4))
;; 		  (tmp2 (split-grid tmp1))
;; 		  (tmp3 (map (lambda (x) (map-lookup x input-map)) tmp2)))
;; 	     tmp3))
(define t2 (let* ((tmp1 (split-grid t1))
		  ;;(tmp3 (map (lambda (x) (map-lookup x input-map)) tmp1))
		  )
	     tmp1))









;; rain stopped play ... rowan play computer games ...




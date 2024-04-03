
#|

advent of code 2017
day 22

north is a lower Y value on GRID
south is a higher Y value on GRID
left is lower X value
right is higher X value

|#

(import scheme)
(import simple-exceptions)
(import expand-full)

(import (chicken bitwise)) ;; --- bit operations

(import (chicken repl))
(import (chicken string))
(import (chicken pretty-print))
(import (chicken io))
(import (chicken format))
(import (chicken sort))
(import (chicken file))
(import (chicken process-context))
;; (change-directory "day22")
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
(define pp pretty-print)

(define my/assign 0)

;; convert string list to grid of x y 's ?? 
(define (convert strlist)
  (let ((hash (make-hash-table))
	(width 0)
	(height 0)
	(direction #f))
    (define (recur ls y)
      (cond
       ((null? ls) #f)
       (#t (let ((xs (car ls))
		 (x 0))
	     (do-list (e xs)
		      (format #t "~a,~a = ~a ~%" x y e)
		      (set! my/assign (+ 1 my/assign))
		      (cond
		       ((char=? e #\#)
			(hash-table-set! hash (list x y) 'infected))
		       (#t
			(hash-table-set! hash (list x y) 'clean)))
		      (set! x (+ x 1)))
	     (recur (cdr ls) (+ y 1))))))
    ;; entry
    (set! height (length strlist))
    (set! width (length (string->list (car strlist))))
    (recur (map string->list strlist) 0)
    
    (hash-table-set! hash 'x (+ (/ width 2) -1/2 ))
    (hash-table-set! hash 'y (+ (/ height 2) -1/2))
    
    (hash-table-set! hash 'direction 'north)
    hash))



(define (input) (convert '(
"..####.###.##..##....##.."
".##..#.###.##.##.###.###."
"......#..#.#.....#.....#."
"##.###.#.###.##.#.#..###."
"#..##...#.....##.#..###.#"
".#..#...####...#.....###."
"##...######.#.###..#.##.."
"###..#..##.###....##....."
".#.#####.###.#..#.#.#..#."
"#.#.##.#.##..#.##..#....#"
"..#.#.#.#.#.##...#.####.."
"##.##..##...#..##..#.####"
"#.#..####.##.....####.##."
"..####..#.#.#.#.##..###.#"
"..#.#.#.###...#.##..###.."
"#.####.##..###.#####.##.."
".###.##...#.#.#.##....#.#"
"#...######...#####.###.#."
"#.####.#.#..#...##.###..."
"####.#.....###..###..#.#."
"..#.##.####.#######.###.."
"#.##.##.#.#.....#...#...#"
"###.#.###..#.#...#...##.."
"##..###.#..#####.#..##..#"
"#......####.#.##.#.###.##")))


(define (example) (convert '(
			   "..#"
			   "#.."
			   "...")))


(define-syntax swap! 
  (er-macro-transformer
   (lambda (form rename compare?)
     (let ((x (cadr form)) (y (caddr form)))
       (let ((%tmp (rename 'tmp)))
        `(let ((,%tmp ,x))
           (set! ,x ,y)
           (set! ,y ,%tmp)))))))



#|			  
  (let ((tmp (gensym 'x)))
    `(begin
       (set! ,x ,y)
       (set! ,y ,tmp))))
|#

;;(macro-expand '(swap! a b))
#|
(let ((a 1)(b 2))
  (swap! a b)
  (list a b))

|#



;; for some unknown size of hash table 
(define (show hash)
  (let ((max-x 0)(min-x 0)(max-y 0)(min-y 0))
    (hash-table-for-each hash
			 (lambda (key val)
			   (cond
			    ((pair? key)
			     (let ((x (first key))
				   (y (second key)))
			       (when (< x min-x) (set! min-x x))
			       (when (> x max-x) (set! max-x x))
			       (when (< y min-y) (set! min-y y))
			       (when (> y max-y) (set! max-y y))
			       )))))
    (let ((px (hash-table-ref hash 'x))
	  (py (hash-table-ref hash 'y))
	  (dir (hash-table-ref hash 'direction)))
    (format #t "~%")
    (do-for (y min-y (+ 1 max-y))    
	    (do-for (x min-x (+ 1 max-x))	    
		    (let ((pos (list x y)))
		      (let ((elem (hash-table-ref/default hash pos 'clean)))

			;; [
			(cond
			 ((and (= x px)(= y py)) (format #t "["))
			 (#t (format #t " ")))

			;; now 4 states to represent
			(case elem
			  ((clean) (format #t "."))
			  ((infected) (format #t "#"))
			  ((weakened) (format #t "W"))
			  ((flagged) (format #t "F")))
			
			;; ] 
			(cond
			 ((and (= x px)(= y py)) (format #t "]"))
			 (#t (format #t " ")))
			)))
	    (format #t "~%"))
    (format #t "~%"))))




(define (right dir)
  (cond
   ((eq? dir 'north) 'east)
   ((eq? dir 'east) 'south)
   ((eq? dir 'south) 'west)
   ((eq? dir 'west) 'north)
   (#t (error "right bad direction"))))

(define (left dir)
  (cond
   ((eq? dir 'north) 'west)
   ((eq? dir 'east) 'north)
   ((eq? dir 'south) 'east)
   ((eq? dir 'west) 'south)
   (#t (error "left bad direction"))))

(define (opposite dir)
  (cond
   ((eq? dir 'north) 'south)
   ((eq? dir 'east) 'west)
   ((eq? dir 'south) 'north)
   ((eq? dir 'west) 'east)
   (#t (error "opposite bad direction"))))


(define (change h x y s)
  (hash-table-set! h (list x y) s))

(define (next hash)
  (let ((cause-infection #f)
	(px (hash-table-ref hash 'x))
	(py (hash-table-ref hash 'y))
	(dir (hash-table-ref hash 'direction)))
    (let ((state (hash-table-ref/default hash (list px py) 'clean)))

      ;; state one of clean / weakened / infected / flagged
      (assert (or (eq? state 'clean)
		  (eq? state 'weakened)
		  (eq? state 'infected)
		  (eq? state 'flagged)))

      ;; change direction based on state
      (case state
	((clean) (set! dir (left dir)))
	((weakened) (set! dir dir)) ;; nop 
	((infected) (set! dir (right dir)))
	((flagged) (set! dir (opposite dir))))

      ;; change current node based on state
      (case state
	((clean) (change hash px py 'weakened))
	((weakened) ;; caused node to become infected
	 (set! cause-infection #t)
	 (change hash px py 'infected))
	((infected) (change hash px py 'flagged))
	((flagged) (change hash px py 'clean)))

      ;; move forward in direction dir
      (hash-table-set! hash 'direction dir)
      (cond
       ((eq? dir 'north) (set! py (- py 1)))
       ((eq? dir 'east) (set! px (+ px 1)))
       ((eq? dir 'west) (set! px (- px 1)))
       ((eq? dir 'south) (set! py (+ py 1))))
      (hash-table-set! hash 'x px)
      (hash-table-set! hash 'y py)
      hash
      cause-infection)))


      
(define (test-1 limit)
  (let ((hash (example))
	(fires 0)
	(infection-counter 0))
    (define (increment-infection-counter)
      (set! infection-counter (+ 1 infection-counter)))
      (do-for (i 0 limit)
	      ;;(show hash)
	      (set! fires (+ 1 fires))
	      (let ((cause-infection (next hash)))
		(when cause-infection
		  (increment-infection-counter))))
      (format #t "infections caused = ~a ~%" infection-counter)
      (format #t "loop fired for ~a times ~%" fires)
      (format #t "direction = ~a ~%" (hash-table-ref hash 'direction))))


(define (test-2 limit)
  (let ((hash (input))
	(fires 0)
	(infection-counter 0))
    (define (increment-infection-counter)
      (set! infection-counter (+ 1 infection-counter)))
      (do-for (i 0 limit)
	      ;;(show hash)
	      (set! fires (+ 1 fires))
	      (let ((cause-infection (next hash)))
		(when cause-infection
		  (increment-infection-counter))))
      (format #t "infections caused = ~a ~%" infection-counter)
      (format #t "loop fired for ~a times ~%" fires)
      (format #t "direction = ~a ~%" (hash-table-ref hash 'direction))))

#|
(test-2 10000)

infections caused = 5176 
loop fired for 10000 times 
direction = north 

|#

(define (part-2-test)
  (test-1 10000000))


(define (part-2)
  (test-2 10000000))


#|

(part-2)

infections caused = 2512017 
loop fired for 10000000 times 
direction = west 

real	0m19.873s
user	0m19.748s
sys	0m0.124s


|#










       
      
      
      
      

      
  
  


			     
			     


			 
			   












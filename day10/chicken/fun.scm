

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

ideas 

(define (circular-elem xs cp n)
  (let ((i (modulo (+ cp n) len)))
    i))
drop xs n
take xs n
if current position is at start of list
reverse n elements and append the rest
if all n elements used , rest should be empty list
-------------------------------------------------

knot hash

skip size starts 0
current position starts 0
lengths larger than size of list are invalid

initial list ( 0 1 2 3 4 )
input lengths of ( 3 4 1 5 )

puzzle part 1
'(212 254 178 237 2 0 1 54 167 92 117 125 255 61 159 164)

|#

(define the-lengths '(3 4 1 5))
(define the-list (list 0 1 2 3 4))
(define len (length the-list))
(define (rev-n xs n)
  (let ((len (length xs)))
    (append (reverse (take xs n)) (drop xs n))))

(define skip-size 0)

(define current-position the-list)

;; xs : the list
;; ys : the lengths

(define (forward xs n)
  (cond
   ((< n 1) xs)
   (#t (forward (append (cdr xs) (list (car xs))) (- n 1)))))


(define (iter xlist xlengths skip-size)
  (format #t "~a : ~a : ~a ~%" xlist xlengths skip-size)
  (cond
   ((null? xlengths) xlist)
   (#t (let* ((n (car xlengths))
	      (next (forward (rev-n xlist n) (+ n skip-size))))
	 (iter (forward next (- n 1)) (cdr xlengths) (+ 1 skip-size))))))


(define (example)
  (let ((xlist (list 0 1 2 3 4))
	(xlengths (list 3 4 1 5))
	(skip-size 0))
    (iter xlist xlengths skip-size)))

;; ------ version 2 -----------------

;; skip size 
(define skip 0)

;; current position cp
(define cp 0)

(define xlist '(0 1 2 3 4))

(define xlen (length xlist))

(define (show)
  (define (rec ys i)
    (cond
     ((null? ys) (format #t "~%") #t)
     (#t (let ((elem (car ys)))
	   (cond
	    ((= i cp) (format #t "[~a] " elem))
	    (#t (format #t "~a " elem)))
	   (rec (cdr ys) (+ i 1))))))
  (rec xlist cp))

;; reverse a portion of list xs n items with current position as cp2
(define (xrev xs n cp2)
  #t)

;; conjure the portion of xs of length n given a starting point cp2
(define (xportion xs n cp2)
  (cond
   ((< n 1) '())
   (#t (let ((i (modulo cp2 (length xs))))
	 (cons (list-ref xs i)
	       (xportion xs (- n 1) (+ cp2 1)))))))

#|

the list

0 1 2 3 4

want to somehow preserve the list itself whilst at same time changing parts of it ?

xlen 5
xlist (0 1 2 3 4)
skip 0
lengths (3 4 1 5)

0 1 2 3 4
^ cp = 0
2 1 0 3 4
      ^

skip = 1  
len 3 *4* 1 5
2 1 0 [3] 4 2 1 0 3 4 2 1 
    0
   cut      3 4 2 1
   rev-cut  1 2 4 3

4 3 0 1 2
      ^      cp 

skip = 2
len 3 4 *1* 5
cut 3
rev-cut 3
forward 1 + 2 = 3
4 3 0 1 2
      ^
4 3 0 1 2
  ^ cp


|#

(vector 5)
;;
(make-vector (* 5 3))
;; inclusive ... 0 thru 10 inclusive
(do-for (i 0 (+ 10 1)) (format #t "i = ~a ~%" i))
;; exclusive ... 0 thru 9 inclusive
(do-for (i 0 10) (format #t "i = ~a ~%" i))

;; do something three times
(do-for (i 0 3) (format #t "i = ~a ~%" i))

;;(define (xrev 


;; -------------------
(define (foo xlist xlengths)
  (define run 0)
  (define cp 0)
  (define skip 0)
  (define vec (list->vector xlist))
  (define vlen (vector-length vec))
  (define (copy-vec)
    (let ((v (make-vector vlen)))
      (do-for (i 0 vlen)
	      (vector-set! v i (vector-ref vec i)))
      v))
  (define (show len)
    (format #t "run ~a : len ~a : cp ~a : skip ~a : vec " run len cp skip)
    (do-for (i 0 vlen)
	    (let ((elem (vector-ref vec i)))
	      (cond
	       ((= i cp) (format #t "[~a] " elem))
	       (#t (format #t "~a " elem)))))
    (format #t "~%"))  
  (define (rev-x len)
    (show len)
    (let ((vec2 (copy-vec)))
    (do-for (i 0 len) ;; exclusive 0 1 2 .. len-1
	    (let ((j (modulo (+ cp i) vlen))
		  (k (modulo (- (- (+ cp len) i) 1) vlen )))
	      (let ((tmp (vector-ref vec j)))
		(vector-set! vec2 k (vector-ref vec j))
		(format #t "swapping ~a with ~a ~%" j k)
		)))
    (set! vec vec2)
    (let ((advance (+ len skip)))
      (format #t "moving forward ~a ~%" advance)
      (set! cp (modulo (+ cp advance) vlen)))
    (set! skip (+ skip 1))))
  (define (solve)
    (do-list (len xlengths)
	     (rev-x len)
	     (set! run (+ run 1)))
    (show 0)
    (let ((a (vector-ref vec 0))
	  (b (vector-ref vec 1)))
      (format #t "first two numbers of list are ~a and ~a ~%" a b)
      (* a b)))
  ;; entry
  (solve))

(define (bar)
  (foo '(0 1 2 3 4) '(3 4 1 5)))

(define (puzzle)
  (foo (iota 256)
       '(212 254 178 237 2 0 1 54 167 92 117 125 255 61 159 164)))

#|

(puzzle)

moving forward 179 
run 16 : len 0 : cp 150 : skip 16 : vec 212 1 178 177 176 175 174 173 172 171 170 169 168 167 166 165 164 163 162 161 160 159 158 157 156 155 154 153 152 151 150 149 148 147 146 145 144 143 142 141 140 139 138 137 136 135 134 133 132 131 130 129 48 47 46 45 44 43 42 41 40 39 38 37 36 99 98 97 96 95 94 93 92 91 90 89 88 87 86 85 84 83 82 81 187 186 185 184 183 182 181 17 198 197 196 195 194 193 192 191 190 189 188 80 79 78 77 76 75 74 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 100 204 205 206 207 111 112 113 114 242 243 244 245 246 247 248 249 250 251 252 253 254 255 211 [210] 209 208 110 109 108 107 106 105 104 103 102 101 203 202 201 200 199 16 15 13 14 12 11 10 9 8 7 6 5 4 3 2 0 179 180 18 19 73 72 71 70 69 68 67 66 65 64 63 62 61 60 59 58 57 56 55 54 53 52 51 50 49 128 127 126 125 124 123 122 121 120 119 118 117 116 115 241 240 239 238 237 236 235 234 233 232 231 230 229 228 227 226 225 224 223 222 221 220 219 218 217 216 215 214 213 

first two numbers of list are 212 and 1 
212

accepted answer

|#


  
   
    
		
	      
  
  

  









	   
  
  
   








;;;; lisp.lisp


#|
  (labels ((foo (k xs)
	     (cond
	       ((>= k n) xs)
	       (t (foo (+ k 1) (cons k xs))))))
    (foo (- n 1) '())))
|#

(in-package #:lisp)

#|

things move down and up again 

puck moves horizontally : delta X , with constant Y of Y = 1

players move vertically : delta Y , with constant X  X = n

puck advances one X at tick
then
check collision if puck (x , y) = player (x , y) then puck caught
then
every player will advance vertically after puck moves

|#

(defparameter *input*
  '(
    (0  3)
    (1  2)
    (2  5)
    (4  4)
    (6  4)
    (8  6)
    (10  6)
    (12  6)
    (14  8)
    (16  6)
    (18  8)
    (20  8)
    (22  8)
    (24  12)
    (26  8)
    (28  12)
    (30  8)
    (32  12)
    (34  12)
    (36  14)
    (38  10)
    (40  12)
    (42  14)
    (44  10)
    (46  14)
    (48  12)
    (50  14)
    (52  12)
    (54  9)
    (56  14)
    (58  12)
    (60  12)
    (64  14)
    (66  12)
    (70  14)
    (76  20)
    (78  17)
    (80  14)
    (84  14)
    (86  14)
    (88  18)
    (90  20)
    (92  14)
    (98  18)
    ))



(defun iota (n)
  (let ((rs '()))
    (loop for i from (- n 1) downto 0 do
      (setq rs (cons i rs)))
    rs))

;; (defun make-cycle (n)
;;   (let ((xs (append (cdr (iota (+ n 1)))
;; 		    (cdr (reverse (cdr (iota (+ n 1))))))))
;;     xs))

(defun make-puck (xi)
  (let ((x xi)
	(y 1))
    (lambda (op)
      (cond
	((eq op 'x) x)
	((eq op 'y) 1)
	((eq op 'tick) (setq x (+ x 1)))
	(t (error "puck bad op"))))))

(defun make-cycle (xi n)
  (let* ((x (cdr (iota (+ n 1))))
	 (y (cdr (reverse (cdr x))))
	 (zs (append x y))
	 (z zs))
    (let ((x xi)
	  (y (car zs)))
      (lambda (op)
	(cond
	  ((eq op 'x) x)
	  ((eq op 'y) (car z))
	  ((eq op 'tick)
	   (setq z (cdr z))
	   (when (null z)
	     (setq z zs)))
	  (t (error "plyr bad op")))))))


;; dummy-cycle just returns height of 2 ,
;; puck only ever at height 1 so no conflict can ever occur
(defun make-dummy-cycle (xi)
  (let ((x xi)
	(y 2))
    (lambda (op)
      (cond
	((eq op 'x) x)
	((eq op 'y) y)
	((eq op 'tick) t)
	(t (error "plyr bad op"))))))


#|
because know last item is 98 we can go to 100 cover all plyrs that move up / down
any items that are not

puck xi -1 -->  no wait as puck advanced first so xi = 0 , then gets caught by first scanner

|#

(defun process (wait)
  (catch 'caught
    (let ((procs '())
	  (puck (make-puck -1)))
      (loop for i from 0 to 100 do
	(let ((pr (assoc i *input*)))
	  (cond
	    (pr (destructuring-bind (a b) pr
		  (let ((p (make-cycle a b)))
		    (setq procs (cons p procs)))))
	    (t  ;; dummy cycle
	     (let ((p (make-dummy-cycle i)))
	       (setq procs (cons p procs)))))))

      ;; no wait handling yet
      (loop for i from 1 to wait do
	;; advance all plyrs
	(dolist (proc procs)
	  (funcall proc 'tick)))
      
      ;; when no wait now continue tick on each proc and puck
      (loop for i from 0 to 100 do
	;; advance puck
	(funcall puck 'tick)
	;; 
	(let ((px (funcall puck 'x))
	      (py (funcall puck 'y)))
	  ;; for each player check not caught puck
	  (dolist (proc procs)
	    (let ((plx (funcall proc 'x))
		  (ply (funcall proc 'y)))
	      (cond
		((and (= px plx) (= py ply))
		 ;;(format t "caught at ~a ~a ~%" px py)
		 (throw 'caught px)))))
	  
	  ;; advance all plyrs
	  (dolist (proc procs)
	    (funcall proc 'tick))))
      'survived)))


(defun brute (init)
  (let ((best 0)
	(best-wait 0))
    (catch 'solution 
      (loop for wait from init do
	(let ((result (process wait)))
	  (cond
	    ((eq result 'survived)
	     (throw 'solution wait))
	    ((> result best)
	     (setq best result)
	     (setq best-wait wait)
	     (format t "best so far : distance ~a : wait of ~a ~%" best best-wait))))))))


#|

LISP> (brute)
best so far : distance 1 : wait of 1 
best so far : distance 4 : wait of 2 
best so far : distance 10 : wait of 10 
best so far : distance 16 : wait of 34 
best so far : distance 20 : wait of 106 
best so far : distance 26 : wait of 226 
best so far : distance 38 : wait of 466 
best so far : distance 44 : wait of 1306 
best so far : distance 54 : wait of 4666 
best so far : distance 66 : wait of 27346 

brute force approach is too slow in this case 

(multiple-value-bind (a b c)
    (catch 'result
      (throw 'result (values 1 2 3)))
  (list 'a a 'b= b 'c= c))

     
	
(let ((p (make-cycle 1 3)))
  (loop for i from 0 to 100 do
    (format t "(~a,~a) ~%" (funcall p 'x) (funcall p 'y))
    (funcall p 'tick)))


how about think more like modulo math
caught when

( 0  3 ) => 0 , 4 , 8 , 12 , 16 , 20 , 24  multiple of 4 
  x  3 


the WAIT parameter is the one we control , to solve the puzzle
     offset and depth of scanner are defined by problem
     what WAIT values pass though the scanner X , D  description



|#

(defun explore (x d wait)
  (catch 'collision 
    ;;(format t "x ~A : d ~A : wait ~A ~%" x d wait)  
    (let ((pk (- 0 (abs wait) 1)))
      ;;(format t "pk = ~a ~%" pk)
      
      (loop while (<= pk x) do
	(loop for i from 1 to d do
	  ;; advance puck
	  (incf pk)
	  ;; check collision i --- note i not j
	  ;; i depth of scanner , pk is puck horz position
	  (cond
	    ((and (= pk x)(= i 1))
	     ;;(format t " * collision[i] *")
	     (throw 'collision 'collide)
	     )
	    (t
	     ;;(format t "~a : ~a ~%" pk i)
	     1 ;; 1 any number as commecnt format out , cond complain if no dummy values after t
	     )))
      
	(loop for j from (- d 1) downto 2 do
	  ;; advance puck
	  (incf pk)
	  ;;  j depth of scanner , pk is puck horz position 
	  ;;(format t "~a : ~a ~%" pk j)
	      )
	);; while loop
      )
    'survive
    )
  )


      


(defun brute-explore (x d)
  (let ((collisions '())
	(n-collide 0))
    (catch 'collide
    (loop for wait from 0 do
      (let ((result (explore x d wait)))
	(cond
	  ((eq result 'collide)
	   (setq collisions (cons wait collisions))
	   (incf n-collide)
	   (when (> n-collide 10)
	     (throw 'collide (reverse collisions)))
	   )
	  (t nil
	     ;;(format t "~a : ~a : ~a ~%"  x d wait)
	     )
	  ))))))




(defun brute-input ()
  (dolist (pr *input*)
    (destructuring-bind (x d) pr
      (let* ((collisions (brute-explore x d))
	     (a0 (car collisions))
	     (a1 (cadr collisions))
	     (diff (- a1 a0)))	
	(format t "~a ~a : ~a : ~a + ~a n ~%" x d collisions a0 diff)))))



(defun linear (a0 a1)
  (let ((diff (- a1 a0))
	(result '()))
    (loop for i from 0 to 10 do
      (let ((v (+ a0 (* diff i))))
	(setq result (cons v result))))
    (list 'diff diff 'values (reverse result))))

(defun linear-solve (a0 diff guess)
  (cond
    ((< guess a0) nil)
    ((= guess a0) 0)
    (t (let ((n (/ (- guess a0) diff)))
	 (cond
	   ((integerp n) n)
	   (t nil))))))

(defun generate-solver ()
  (let ((lins '()))
    (dolist (pr *input*)
      (destructuring-bind (x d) pr
	(let* ((collisions (brute-explore x d))
	       (a0 (car collisions))
	       (a1 (cadr collisions))
	       (diff (- a1 a0)))	
	  (setq lins (cons `(linear-solve ,a0 ,diff wait) lins)))))
    (setq lins (reverse lins))

    `(defun solver ()
       (catch 'sol
       (loop for wait from 0 by 2 do
	 (when (not (or ,@lins))
	   (throw 'sol wait)))))))


;; generated code by running (generate-solver)
(DEFUN SOLVER ()
  (CATCH 'SOL
    (LOOP FOR WAIT FROM 0 BY 2
          DO (WHEN
                 (NOT
                  (OR (LINEAR-SOLVE 0 4 WAIT) (LINEAR-SOLVE 1 2 WAIT)
                      (LINEAR-SOLVE 6 8 WAIT) (LINEAR-SOLVE 2 6 WAIT)
                      (LINEAR-SOLVE 0 6 WAIT) (LINEAR-SOLVE 2 10 WAIT)
                      (LINEAR-SOLVE 0 10 WAIT) (LINEAR-SOLVE 8 10 WAIT)
                      (LINEAR-SOLVE 0 14 WAIT) (LINEAR-SOLVE 4 10 WAIT)
                      (LINEAR-SOLVE 10 14 WAIT) (LINEAR-SOLVE 8 14 WAIT)
                      (LINEAR-SOLVE 6 14 WAIT) (LINEAR-SOLVE 20 22 WAIT)
                      (LINEAR-SOLVE 2 14 WAIT) (LINEAR-SOLVE 16 22 WAIT)
                      (LINEAR-SOLVE 12 14 WAIT) (LINEAR-SOLVE 12 22 WAIT)
                      (LINEAR-SOLVE 10 22 WAIT) (LINEAR-SOLVE 16 26 WAIT)
                      (LINEAR-SOLVE 16 18 WAIT) (LINEAR-SOLVE 4 22 WAIT)
                      (LINEAR-SOLVE 10 26 WAIT) (LINEAR-SOLVE 10 18 WAIT)
                      (LINEAR-SOLVE 6 26 WAIT) (LINEAR-SOLVE 18 22 WAIT)
                      (LINEAR-SOLVE 2 26 WAIT) (LINEAR-SOLVE 14 22 WAIT)
                      (LINEAR-SOLVE 10 16 WAIT) (LINEAR-SOLVE 22 26 WAIT)
                      (LINEAR-SOLVE 8 22 WAIT) (LINEAR-SOLVE 6 22 WAIT)
                      (LINEAR-SOLVE 14 26 WAIT) (LINEAR-SOLVE 0 22 WAIT)
                      (LINEAR-SOLVE 8 26 WAIT) (LINEAR-SOLVE 0 38 WAIT)
                      (LINEAR-SOLVE 18 32 WAIT) (LINEAR-SOLVE 24 26 WAIT)
                      (LINEAR-SOLVE 20 26 WAIT) (LINEAR-SOLVE 18 26 WAIT)
                      (LINEAR-SOLVE 14 34 WAIT) (LINEAR-SOLVE 24 38 WAIT)
                      (LINEAR-SOLVE 12 26 WAIT) (LINEAR-SOLVE 4 34 WAIT)))
               (THROW 'SOL WAIT)))))


#|
LISP> (solver)
3913186
LISP>

ANSWER ACCEPTED !! 

|#
    




#|

(brute-input)

0 3 : (0 4 8 12 16 20 24 28 32 36 40) : 0 + 4 n 
1 2 : (1 3 5 7 9 11 13 15 17 19 21) : 1 + 2 n 
2 5 : (6 14 22 30 38 46 54 62 70 78 86) : 6 + 8 n 
4 4 : (2 8 14 20 26 32 38 44 50 56 62) : 2 + 6 n 
6 4 : (0 6 12 18 24 30 36 42 48 54 60) : 0 + 6 n 
8 6 : (2 12 22 32 42 52 62 72 82 92 102) : 2 + 10 n 
10 6 : (0 10 20 30 40 50 60 70 80 90 100) : 0 + 10 n 
12 6 : (8 18 28 38 48 58 68 78 88 98 108) : 8 + 10 n 
14 8 : (0 14 28 42 56 70 84 98 112 126 140) : 0 + 14 n 
16 6 : (4 14 24 34 44 54 64 74 84 94 104) : 4 + 10 n 
18 8 : (10 24 38 52 66 80 94 108 122 136 150) : 10 + 14 n 
20 8 : (8 22 36 50 64 78 92 106 120 134 148) : 8 + 14 n 
22 8 : (6 20 34 48 62 76 90 104 118 132 146) : 6 + 14 n 
24 12 : (20 42 64 86 108 130 152 174 196 218 240) : 20 + 22 n 
26 8 : (2 16 30 44 58 72 86 100 114 128 142) : 2 + 14 n 
28 12 : (16 38 60 82 104 126 148 170 192 214 236) : 16 + 22 n 
30 8 : (12 26 40 54 68 82 96 110 124 138 152) : 12 + 14 n 
32 12 : (12 34 56 78 100 122 144 166 188 210 232) : 12 + 22 n 
34 12 : (10 32 54 76 98 120 142 164 186 208 230) : 10 + 22 n 
36 14 : (16 42 68 94 120 146 172 198 224 250 276) : 16 + 26 n 
38 10 : (16 34 52 70 88 106 124 142 160 178 196) : 16 + 18 n 
40 12 : (4 26 48 70 92 114 136 158 180 202 224) : 4 + 22 n 
42 14 : (10 36 62 88 114 140 166 192 218 244 270) : 10 + 26 n 
44 10 : (10 28 46 64 82 100 118 136 154 172 190) : 10 + 18 n 
46 14 : (6 32 58 84 110 136 162 188 214 240 266) : 6 + 26 n 
48 12 : (18 40 62 84 106 128 150 172 194 216 238) : 18 + 22 n 
50 14 : (2 28 54 80 106 132 158 184 210 236 262) : 2 + 26 n 
52 12 : (14 36 58 80 102 124 146 168 190 212 234) : 14 + 22 n 
54 9 : (10 26 42 58 74 90 106 122 138 154 170) : 10 + 16 n 
56 14 : (22 48 74 100 126 152 178 204 230 256 282) : 22 + 26 n 
58 12 : (8 30 52 74 96 118 140 162 184 206 228) : 8 + 22 n 
60 12 : (6 28 50 72 94 116 138 160 182 204 226) : 6 + 22 n 
64 14 : (14 40 66 92 118 144 170 196 222 248 274) : 14 + 26 n 
66 12 : (0 22 44 66 88 110 132 154 176 198 220) : 0 + 22 n 
70 14 : (8 34 60 86 112 138 164 190 216 242 268) : 8 + 26 n 
76 20 : (0 38 76 114 152 190 228 266 304 342 380) : 0 + 38 n 
78 17 : (18 50 82 114 146 178 210 242 274 306 338) : 18 + 32 n 
80 14 : (24 50 76 102 128 154 180 206 232 258 284) : 24 + 26 n 
84 14 : (20 46 72 98 124 150 176 202 228 254 280) : 20 + 26 n 
86 14 : (18 44 70 96 122 148 174 200 226 252 278) : 18 + 26 n 
88 18 : (14 48 82 116 150 184 218 252 286 320 354) : 14 + 34 n 
90 20 : (24 62 100 138 176 214 252 290 328 366 404) : 24 + 38 n 
92 14 : (12 38 64 90 116 142 168 194 220 246 272) : 12 + 26 n 
98 18 : (4 38 72 106 140 174 208 242 276 310 344) : 4 + 34 n 

|#























(defpackage :foo
  (:use :cl))

(in-package :foo)

#|
--- Day 16: Permutation Promenade ---

You come upon a very unusual sight; a group of programs here appear to
be dancing.

There are sixteen programs in total, named a through p. They start by
standing in a line: a stands in position 0, b stands in position 1,
and so on until p, which stands in position 15.

The programs' dance consists of a sequence of dance moves:

Spin, written sX, makes X programs move from the end to the front, but
maintain their order otherwise. (For example, s3 on abcde produces
cdeab).  Exchange, written xA/B, makes the programs at positions A and
B swap places.  Partner, written pA/B, makes the programs named A and
B swap places.

For example, with only five programs standing in a line (abcde), they
could do the following dance:

s1, a spin of size 1: eabcd.

x3/4, swapping the last two programs:
eabdc.

pe/b, swapping programs e and b: baedc.

After finishing their dance, the programs end up in order baedc.

You watch the dance for a while and record their dance moves (your
puzzle input). In what order are the programs standing after their
dance?

|#

;; ;; p holds the characters
;; (defvar p (make-array 17 :initial-element #\a))
;; ;; q holds the index of where 
;; (defvar q (make-array 17 :initial-element 0))
;; ;; temp array q2 
;; (defvar q2 (make-array 17 :initial-element 0))


;; (loop for i from 0 to 16 do
;;       (let* ((letter-a (char-code #\a))
;;             (letter-n (code-char (+ letter-a i))))
;;         (setf (aref p i) letter-n)
;;         (setf (aref q i) i)
;;       (format t "i = ~a : letter ~a : index ~a~%" i (aref p i) (aref q i))))


#|
pe/m
x5/12

spin s15 makes X programs move from the end to the front
s3 abcde => cdeab

what do these spin actions mean ?

s0 - spin none ?
s1 - last one to front , shift all rest up by one
s2
s3 - 
s4
s5
s6
s7
s8
s9
s10
s11
s12
s13
s14
s15
s16
s17
s18 ?? 

|#
;;(defun (swap 

;; ;; display config
;; (defun config ()
;;     (loop for i from 0 to 16 do
;;           (catch 'found
;;           (loop for j from 0 to 16 do
;;                 (let ((ch (aref p j))
;;                       (n (aref q j)))
;;                   (cond
;;                     ((= n i) (format t " ~a" ch)
;;                              (throw 'found t)))))))
;;   (format t "~%"))

;; abcdefghijklmnopq
(defparameter *str* "abcdefghijklmnopq")

;; (char *str* 0) get the 0th character

(defun spin (s n)
  (let ((len-s (length s)))
  (concatenate 'string
	       (subseq s (- len-s n) len-s)
	       (subseq s 0 (- len-s n) ))))

(spin "abcde" 1)
(spin "abcde" 3)

(defun exchange (s a b)
  (let ((c (char s a))
	(d (char s b)))
    (setf (aref s a) d)
    (setf (aref s b) c)
    s))

(exchange (spin "abcde" 1) 3 4)

(defun partner (s a b)  
  (let ((len-s (length s))
	(i-a 0)
	(i-b 0))
    ;; find chars a b
    (loop for i from 0 to (- len-s 1) do
      (let ((ch (aref s i)))
	(cond
	  ((char= a ch) (setq i-a i))
	  ((char= b ch) (setq i-b i)))))
    (exchange s i-a i-b)))

(partner "abcde" #\e #\b)

#|
parser

sXX where XX is 0 to 17
xAA/BB where AA is 0 to 17 , B is 0 to 17
pA/B  where A is char #\a to #\q , B is char #\a to #\q

|#

(defun process ()
  (let ((str "abcdefghijklmnop"))
  (loop for i from 0 to (- (length parse::arr) 1) do
    (let ((cmd (aref parse::arr i)))
      (cond
	((eq (car cmd) 'parse::spin)
	 (let ((n (second cmd)))
	   (format t "spin [~a] [~a] " str n)
	   (setq str (spin str n))
	   (format t " => [~a] ~%" str)
	   ))
	((eq (car cmd) 'parse::exchange)
	 (let ((n (second cmd))
	       (m (third cmd)))
	   (format t "exchange [~a] [~a] [~a] " str n m)	   
	   (setq str (exchange str n m))
	   (format t " => [~a] ~%" str)	   
	   ))
	((eq (car cmd) 'parse::partner)
	 (let ((n (second cmd))
	       (m (third cmd)))
	   (format t "partner [~a] [~a] [~a] " str n m)	   	   
	   (setq str (partner str n m))
	   (format t " => [~a] ~%" str)	   	   
	   ))
	(t (error "processing")))))
    str))

#|

nlciboghjmfdapek

......accepted answer

a billion times .... hmmm...


|#




	
	
    



        
  
        






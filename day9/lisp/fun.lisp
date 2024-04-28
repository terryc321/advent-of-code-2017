

(uiop:define-package :aoc
    (:use :cl))

(in-package :aoc)

(declaim (optimize (speed 0) (space 0)(safety 3)(debug 3) (compilation-speed 0)))



;; read a file and
;;(uiop/os:getcwd)
(defun get-input (f)
  (with-open-file (in f :direction :input)
    (read-line in)))


;;
(defparameter i 0)
(defparameter str (get-input "../input"))
(defparameter slen (length str))
(defparameter s "")
(defparameter group-total 0)
(defparameter group-height 0)
(defparameter verbose nil)

(defparameter non-cancelled-char-count 0)


(defun at (i ch)
  (cond
    ((and (>= i 0) (< i slen)) (char= ch (char s i)))
    (t nil)))

(defun advance ()
  (setq i (+ i 1)))

(defun is (ch)
  (at i ch))

(defun garbage ()
  (cond
    ((is #\< )
     (when verbose (format t "start of garbage at ~a : ~a~%" i (char s i)))
     (advance)
     (loop while (not (is #\> )) do
       (cond
	 ((is #\! ) (advance) (advance))
	 (t
	  (incf non-cancelled-char-count)
	  (advance))))
     (cond
       ((is #\>)
	(when verbose (format t "end of garbage at ~a : ~a~%" i (char s i)))
	(advance))
       (t (error "garbage not > ~%"))))))


(defun group-or-garbage ()
  (cond
    ((is #\{ )
     (group))
    ((is #\< )
     (garbage))))

(defun group ()
  (cond
    ((is #\{ )
     (when verbose (format t "start of group at ~a : ~a~%" i (char s i)))
     (setq group-height (+ 1 group-height))
     (setq group-total (+ group-total group-height))
     (advance)
     (group-or-garbage)
     (loop while (is #\, ) do
       (advance)
       (group-or-garbage))))  
  (cond
    ((is #\} )
     (when verbose (format t "end of group at ~a : ~a~%" i (char s i)))
     (setq group-height (+ -1 group-height))
     (advance))
    (t
     (format t "err : at ~a : ~a ~%" i (char s i))
     (error "malformed input"))))


#|

(defun comma ()
(group)
(loop while (is #\, ) do
(advance)
(group)))

(cond
((at s  #\, )
(cond
((at s (+ i 1) #\{ ) (group s (+ i 1)))
((at s (+ i 1) #\< ) (group s (+ i 1)))


(cond     
((at s (+ i 1) #\{ ) (group s (+ i 1)))        ; { another group
((at s (+ i 1) #\< ) (garbage s (+ i 1)))      ; < garbage
)))
t)
(t nil)))
|#


(defun run (&optional (s str))
  (setq non-cancelled-char-count 0)
  (setq group-total 0)
  (setq group-height 0)  
  (setq i 0)
  (setq slen (length s))
  (group)
  (when verbose (format t "i = ~a : slen = ~a ~%" i slen))
  (when verbose (format t "group total = ~a ~%" group-total))
  (values group-total non-cancelled-char-count)
  )



#|
    {}, score of 1.
    {{{}}}, score of 1 + 2 + 3 = 6.
    {{},{}}, score of 1 + 2 + 2 = 5.
    {{{},{},{{}}}}, score of 1 + 2 + 3 + 3 + 3 + 4 = 16.
    {<a>,<a>,<a>,<a>}, score of 1.
    {{<ab>},{<ab>},{<ab>},{<ab>}}, score of 1 + 2 + 2 + 2 + 2 = 9.
    {{<!!>},{<!!>},{<!!>},{<!!>}}, score of 1 + 2 + 2 + 2 + 2 = 9.
    {{<a!>},{<a!>},{<a!>},{<ab>}}, score of 1 + 2 = 3.
|#
(defun test () (mapcar (lambda (x) (let ((in (car x))
				       (expect (cadr x))
				       (result (multiple-value-bind (gp nc) (run (car x)) gp)))
				   (cond
				     ((equalp expect result) (list 'PASS in result))
				     (t (list 'FAIL in result 'EXPECTED= expect)))))
		     '(
		       ("{}" 1)
		       ("{{{}}}" 6)
		       ("{{},{}}" 5)
		       ("{{{},{},{{}}}}" 16)
		       ("{<a>,<a>,<a>,<a>}" 1)
		       ("{{<ab>},{<ab>},{<ab>},{<ab>}}" 9)
		       ("{{<!!>},{<!!>},{<!!>},{<!!>}}" 9)
		       )))



;;(mapcar (lambda (x) (+ x 2)) '(2 3 4))

#|
AOC> (test)
((PASS "{}" 1) (PASS "{{{}}}" 6) (PASS "{{},{}}" 5) (PASS "{{{},{},{{}}}}" 16)
 (PASS "{<a>,<a>,<a>,<a>}" 1) (PASS "{{<ab>},{<ab>},{<ab>},{<ab>}}" 9)
 (PASS "{{<!!>},{<!!>},{<!!>},{<!!>}}" 9))
AOC> (run)
11347
AOC>

suggests there are 11347 groups in the input file provided for test

|#


(defun test2 () (mapcar (lambda (x) (let ((in (car x))
				       (expect (cadr x))
				       (result (multiple-value-bind (gp nc) (run (car x)) nc)))
				   (cond
				     ((equalp expect result) (list 'PASS in result))
				     (t (list 'FAIL in result 'EXPECTED= expect)))))
		     '(
		       ("{<>}" 0)
		       ("{<random characters>}" 17)
		       ("{<<<<>}" 3)
		       ("{<{!>}>}" 2)
		       ("{<!!>}" 0)
		       ("{<!!!>>}" 0)
		       ("{<{o\"i!a,<{i<a>}" 10)
		       )))

#|
    <>, 0 characters.
    <random characters>, 17 characters.
    <<<<>, 3 characters.
    <{!>}>, 2 characters.
    <!!>, 0 characters.
    <!!!>>, 0 characters.
    <{o"i!a,<{i<a>, 10 characters.
|#
    
#|

changed run to return TWO values
    first is the total number of groups , each inner group extra + 1 height of group
    second is total non cancelled characters

AOC> (test)
((PASS "{}" 1) (PASS "{{{}}}" 6) (PASS "{{},{}}" 5) (PASS "{{{},{},{{}}}}" 16)
 (PASS "{<a>,<a>,<a>,<a>}" 1) (PASS "{{<ab>},{<ab>},{<ab>},{<ab>}}" 9)
 (PASS "{{<!!>},{<!!>},{<!!>},{<!!>}}" 9))
AOC> (test2)
((PASS "{<>}" 0) (PASS "{<random characters>}" 17) (PASS "{<<<<>}" 3)
 (PASS "{<{!>}>}" 2) (PASS "{<!!>}" 0) (PASS "{<!!!>>}" 0)
 (PASS "{<{o\"i!a,<{i<a>}" 10))
AOC> (run)
11347
5404
AOC>

5404 is stated as number of non cancelled characters

accepted both answers


|#


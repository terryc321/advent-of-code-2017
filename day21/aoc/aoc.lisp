;;;; aoc.lisp

(in-package #:aoc)

(defparameter *transform-lines* (uiop:read-file-lines "../input"))

#|
;; cannot do this " => " with split-sequence wants only #\Space single character
;;(defparameter *foo*  (split-sequence:split-sequence " => " (first *transform-lines*) ))

now have to disgard middle " =>" match 
|#
(defparameter *foo*  (mapcar #'(lambda (x)
				 (split-sequence:split-sequence #\Space x))
			     *transform-lines*))

#|
AOC> (mapcar (lambda (x) (length (first x))) *foo*)
(5 5 5 5 5 5 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
 11 11)
AOC> (+ 9 2)
11
AOC> (+ 4 1)
5
AOC> (mapcar (lambda (x) (length (third x))) *foo*)
(11 11 11 11 11 11 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19
 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19
 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19
 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19
 19 19 19 19)
5  = 4 + 1 / slashes
1 2 / 3 4   ........ 4 + 1 slash (5 total)

11 = 9 + 2 / slashes
1 2 3 / 4 5 6 / 7 8 9  .... 9 + 2 slashes  (11 total)

19 = 16 + 3 / slashes
1 2 3 4 / 5 6 7 8 / 9 10 11 12 / 13 14 15 16  = 16 + 3 slashes  (19 total)

a b
c d

rotate reflect
how many ways can this be done ?

a b c
d e f
g h i

rotate / reflect
how many ways can this be done


AOC> 
|#







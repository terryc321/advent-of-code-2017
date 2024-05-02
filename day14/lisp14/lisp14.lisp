;;;; lisp14.lisp

(in-package #:lisp14)

#|

(ql:quickload #:quickproject)
(quickproject:make-project "lisp14")

does not like 
(in-package "lisp14")
(ql:quickload "lisp14")

uiop 
:depends-on 
no help writing the asd file

------------------------------------------------

knot hashes

128 x 128  grid on / off s 



|#


(defparameter example "flqrgnkx")
(defparameter input "wenycdww")

#|

take string and compose with 0 ... 127 inclusive to make 128 

output 32 hex digits 
each digit takes 4 bits 

(* 32 4) 128

|#


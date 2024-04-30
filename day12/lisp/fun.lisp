
(defpackage :aoc
  (:use :cl))

(in-package :aoc)



#|
;;(ql:quickload :sb-posix)
;;(ql:quickload :local-projects)

(sb-posix:chdir "/home/apugachev")
(sb-posix:chdir "../")
(sb-posix:chdir "day12")
(sb-posix:getcwd)
|#
(defun run ()
  (let ((input (with-open-file (f "input")
                 (read f))))
    input))

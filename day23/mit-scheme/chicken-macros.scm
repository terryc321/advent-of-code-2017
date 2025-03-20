

(import (expand-full))
(import (chicken format))
(import (chicken pretty-print))
;; ppexpand*

#|
(define-syntax while
  (er-macro-transformer
   (lambda (x r c)
     (let ((test (cadr x))
           (body (cddr x)))
       `(,(r 'loop)
         (,(r 'if) (,(r 'not) ,test) (exit #f))
         ,@body)))))


common lisp defmacro -> chicken scheme + macroexpand -> mit-scheme er-macro-transformer

whats also not clear is what is available at compile time ?

drawbacks of a macro

1 . not composable like functions

2 . difficult to debug

3 . hairy worlds

4 . language is not available at compile time - some sort of restricted sub-language

5 . difficult conceptually

6 . not like defmacro


|#

(define-syntax swap!
  (er-macro-transformer
   (lambda (x r c)
     (let ((a (cadr x))
     	   (b (caddr x))
	   (%begin (r 'begin))
	   (%let (r 'let))
	   (%set! (r 'set!))
	   ;;(tmp (gensym "tmp"))
	   (tmp (gensym 'tmp)))
       `(,%begin
	 (,%let ((,tmp a))
	  (,%set! a b)
	  (,%set! b ,tmp)))))))



(define (test-swap!)
  (let ((a 1)(b 2))
    (swap! a b)
    (list a b)))

(ppexpand* '(let ((a 1)(b 2))
	      (swap! a b)
	      (list a b)))

(define (test-while)
  (let ((i 0))
    (while (< i 10)
      (format #t "i = ~a~%" i)
      (set! i (+ i 1)))))





;; fun.scm

;; mit-scheme
;; compile this file
;; (cf "fun.scm")
;; .......... generates fun.bin fun.com ....
;;   fun.bin is Scode like java byte code
;;   fun.com is native code compiler raw machine code
;;
;; load the compiled file
;; (load "fun")
;;


;; we will not redefine ~ scheme usual procedures car cdr etc.. r5rs ~  procedures
(declare (usual-integrations))



;; mit-scheme *think* setup has **slib included**
(require 'format)


;; registers a through h all start at 0
(define *reg-a* 0)
(define *reg-b* 0)
(define *reg-c* 0)
(define *reg-d* 0)
(define *reg-e* 0)
(define *reg-f* 0)
(define *reg-g* 0)
(define *reg-h* 0)
(define *mul-counter* 0)
(define *ip* 0)

(define *ins* '((set b 81)
		(set c b)
		(jnz a 2)
		(jnz 1 5)
		(mul b 100)
		(sub b -100000)
		(set c b)
		(sub c -17000)
		(set f 1)
		(set d 2)
		(set e 2)
		(set g d)
		(mul g e)
		(sub g b)
		(jnz g 2)
		(set f 0)
		(sub e -1)
		(set g e)
		(sub g b)
		(jnz g -8)
		(sub d -1)
		(set g d)
		(sub g b)
		(jnz g -13)
		(jnz f 2)
		(sub h -1)
		(set g b)
		(sub g c)
		(jnz g 2)
		(jnz 1 3)
		(sub b -17)
		(jnz 1 -23)))





#|

 we can compile each instruction
 (set b 81) -> (set! *register-b* 81)
 (set! *instruction-pointer* (+ 1 *instruction-pointer*))

|#


(define (test)
  (let ((a 1)(b 2))
    (let ((p1 (list a b)))
      (swap! a b)
      (let ((p2 (list a b)))
	(list p1 p2)))))

;;    (list 'a a 'b b (swap! a b) 'a a 'b b)))


;; compile-sub : i = (sub c -17000) :: integer = -17000 
;; compile-sub : i = (sub g b) :: 
;; compile-sub : i = (sub e -1) :: integer = -1 
;; compile-sub : i = (sub g b) :: 
;; compile-sub : i = (sub d -1) :: integer = -1 
;; compile-sub : i = (sub g b) :: 
;; compile-sub : i = (sub h -1) :: integer = -1 
;; compile-sub : i = (sub g c) :: 
;; compile-sub : i = (sub b -17) :: integer = -17
(define (compile-symbol s)
  (cond
   ((eq? s 'a) '*reg-a*)
   ((eq? s 'b) '*reg-b*)
   ((eq? s 'c) '*reg-c*)
   ((eq? s 'd) '*reg-d*)
   ((eq? s 'e) '*reg-e*)
   ((eq? s 'f) '*reg-f*)
   ((eq? s 'g) '*reg-g*)
   ((eq? s 'h) '*reg-h*)
   (#t (error (format #f "compile-symbol bad symbol [~a]" s)))))

   
(define (compile-sub i)
  (cond
   ((integer? (third i))    
  ;;  (format #t "compile-sub : integer = ~a ~%" (third i))
    (let* ((dest (compile-symbol (second i)))
	   (num (third i))
	   (the-expression i)
	   (expr `(lambda ()
		    ',the-expression		    
		    (set! ,dest (- ,dest ,num))
		    (set! *ip* (+ *ip* 1)))))
      ;; (pp expr)      
      ;; (newline)
      expr
      ))
   (#t
;;    (format #t "compile-sub : ~a ~a = ~%" (second i)(third i))
    (let* ((dest (compile-symbol (second i)))
	   (src (compile-symbol (third i)))
	   (the-expression i)
	   (expr `(lambda ()
		    ',the-expression
		    (set! ,dest (- ,dest ,src))
		    (set! *ip* (+ *ip* 1)))))
      ;; (pp expr)
      ;; (newline)
      expr
      ))))


(define (compile-set i)
  (cond
   ((integer? (third i))    
    ;;  (format #t "compile-set : integer = ~a ~%" (third i))
    (let* ((dest (compile-symbol (second i)))
	   (num (third i))
	   (the-expression i)
	   (expr `(lambda ()
		    ',the-expression		    
		    (set! ,dest ,num)
		    (set! *ip* (+ *ip* 1)))))
      ;; (pp expr)      
      ;; (newline)
      expr
      ))
   (#t
    ;;    (format #t "compile-set : ~a ~a = ~%" (second i)(third i))
    (let* ((dest (compile-symbol (second i)))
	   (src (compile-symbol (third i)))
	   (the-expression i)
	   (expr `(lambda ()
		    ',the-expression
		    (set! ,dest ,src)
		    (set! *ip* (+ *ip* 1)))))
      ;; (pp expr)
      ;; (newline)
      expr
      ))))




(define (compile-jnz i)  
  ;; (format #t "compile-jnz : ~a ~%" i)
  (cond
   ((integer? (second i))  ;; (jnz N Y) N are all positive integers , so just run the jump
    (let* (;; (num (second i))
	   (offset (third i))
	   (the-expression i)
	   (expr `(lambda ()
		    ',the-expression		    		    
		    (set! *ip* (+ *ip* ,offset)))))
      ;; (pp expr)      
      ;; (newline)
      expr
      ))
   (#t
    ;;    (format #t "compile-set : ~a ~a = ~%" (second i)(third i))
    (let* ((var (compile-symbol (second i)))
	   (offset (third i))
	   (the-expression i)
	   (expr `(lambda ()
		    ',the-expression
		    (if (not (zero? ,var))
			(set! *ip* (+ *ip* ,offset))
			(set! *ip* (+ *ip* 1))))))
      ;; (pp expr)
      ;; (newline)
      expr
      ))))


(define (compile-mul i)
  (cond
   ((integer? (third i))    
    ;;  (format #t "compile-mul : integer = ~a ~%" (third i))
    (let* ((dest (compile-symbol (second i)))
	   (num (third i))
	   (the-expression i)
	   (expr `(lambda ()
		    ',the-expression		    
		    (set! ,dest (* ,dest ,num))
		    (set! *mul-counter* (+ 1 *mul-counter*))
		    (set! *ip* (+ *ip* 1)))))
      ;; (pp expr)      
      ;; (newline)
      expr
      ))
   (#t
    ;;    (format #t "compile-mul : ~a ~a = ~%" (second i)(third i))
    (let* ((dest (compile-symbol (second i)))
	   (src (compile-symbol (third i)))
	   (the-expression i)
	   (expr `(lambda ()
		    ',the-expression
		    (set! ,dest (* ,dest ,src))
		    (set! *mul-counter* (+ 1 *mul-counter*))
		    (set! *ip* (+ *ip* 1)))))
      ;; (pp expr)
      ;; (newline)
      expr
      ))))







(define (compile i)
  ;;(format #t "compile : i = ~a~%" i)
  (cond
   ((eq? (car i) 'sub) (compile-sub i))
   ((eq? (car i) 'set) (compile-set i))
   ((eq? (car i) 'jnz) (compile-jnz i))   
   ((eq? (car i) 'mul) (compile-mul i))   
   (#t (error (format #f "compile ~a" i)))))


(define *the-program* (map compile *ins*))

;; evaluate 
(define (make-fast)
  (list->vector
   (eval (cons 'list *the-program*)
	 (interaction-environment))))


(define (regs)
  (newline)
  (format #t "a(~a) b(~a) c(~a) d(~a) ~%" *reg-a* *reg-b* *reg-c* *reg-d* )
  (format #t "e(~a) f(~a) g(~a) h(~a) ~%" *reg-e* *reg-f* *reg-g* *reg-h* )
  (newline))

  

(define (simulation)
  (set! *reg-a* 0)
  (set! *reg-b* 0)
  (set! *reg-c* 0)
  (set! *reg-d* 0)
  (set! *reg-e* 0)
  (set! *reg-f* 0)
  (set! *reg-g* 0)
  (set! *reg-h* 0)
  (set! *ip* 0)
  (set! *mul-counter* 0)
  (let* ((code (make-fast))
	 (vlen (vector-length code)))
    (let loop ()
      (cond
       ((or (< *ip* 0) (>= *ip* vlen))
	(format #t "*halt*~%")
	(regs)
	(format #t "*mul-counter* ~a ~%" *mul-counter*))
       (#t
	(format #t "*ip* = ~a ~%" *ip*)
	(let ((lam (vector-ref code *ip*)))
	  (lam)
	  (loop)))))))



;; shorthand
(define sim simulation)


(define (simulation2)
  (set! *reg-a* 1) ;; set a to 1 
  (set! *reg-b* 0)
  (set! *reg-c* 0)
  (set! *reg-d* 0)
  (set! *reg-e* 0)
  (set! *reg-f* 0)
  (set! *reg-g* 0)
  (set! *reg-h* 0)
  (set! *ip* 0)
  (set! *mul-counter* 0)
  (let* ((code (make-fast))
	 (vlen (vector-length code)))
    (let loop ()
      (cond
       ((or (< *ip* 0) (>= *ip* vlen))
	(format #t "*halt*~%")
	(regs)
	(format #t "*mul-counter* ~a ~%" *mul-counter*))
       (#t
	;; (format #t "*ip* = ~a ~%" *ip*)
	(let ((lam (vector-ref code *ip*)))
	  (lam)
	  (loop)))))))

;; shorthand
(define sim2 simulation2)




				   





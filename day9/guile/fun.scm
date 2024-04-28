


#|
--- Day 9: Stream Processing ---

A large stream blocks your path. According to the locals, it's not
safe to cross the stream at the moment because it's full of
garbage. You look down at the stream; rather than water, you discover
that it's a stream of characters.

You sit for a while and record part of the stream (your puzzle
input). The characters represent groups - sequences that begin with {
and end with }. Within a group, there are zero or more other things,
separated by commas: either another group or garbage. Since groups can
contain other groups, a } only closes the most-recently-opened
unclosed group - that is, they are nestable. Your puzzle input
represents a single, large group which itself contains many smaller
ones.

Sometimes, instead of a group, you will find garbage. Garbage begins
with < and ends with >. Between those angle brackets, almost any
character can appear, including { and }. Within garbage, < has no
special meaning.

In a futile attempt to clean up the garbage, some program has canceled
some of the characters within it using !: inside garbage, any
character that comes after ! should be ignored, including <, >, and
even another !.

You don't see any characters that deviate from these rules. Outside
garbage, you only find well-formed groups, and garbage always
terminates according to the rules above.

Here are some self-contained pieces of garbage:

    <>, empty garbage.
    <random characters>, garbage containing random characters.
    <<<<>, because the extra < are ignored.
    <{!>}>, because the first > is canceled.
    <!!>, because the second ! is canceled, allowing the > to terminate the garbage.
    <!!!>>, because the second ! and the first > are canceled.
    <{o"i!a,<{i<a>, which ends at the first >.

Here are some examples of whole streams and the number of groups they contain:

    {}, 1 group.
    {{{}}}, 3 groups.
    {{},{}}, also 3 groups.
    {{{},{},{{}}}}, 6 groups.
    {<{},{},{{}}>}, 1 group (which itself contains garbage).
    {<a>,<a>,<a>,<a>}, 1 group.
    {{<a>},{<a>},{<a>},{<a>}}, 5 groups.
    {{<!>},{<!>},{<!>},{<a>}}, 2 groups (since all but the last > are canceled).

Your goal is to find the total score for all groups in your
input. Each group is assigned a score which is one more than the score
of the group that immediately contains it. (The outermost group gets a
score of 1.)

    {}, score of 1.
    {{{}}}, score of 1 + 2 + 3 = 6.
    {{},{}}, score of 1 + 2 + 2 = 5.
    {{{},{},{{}}}}, score of 1 + 2 + 3 + 3 + 3 + 4 = 16.
    {<a>,<a>,<a>,<a>}, score of 1.
    {{<ab>},{<ab>},{<ab>},{<ab>}}, score of 1 + 2 + 2 + 2 + 2 = 9.
    {{<!!>},{<!!>},{<!!>},{<!!>}}, score of 1 + 2 + 2 + 2 + 2 = 9.
    {{<a!>},{<a!>},{<a!>},{<ab>}}, score of 1 + 2 = 3.

What is the total score for all groups in your input?

|#


#|
  { } 
  nestable groups , may contain other groups seperated by commas
garbage < >
inside garbage any character after ! is ignored including ! 

|#
(use-modules (ice-9 textual-ports))

;; (getcwd)
;; (chdir "day9")

;; read a file ?
(define (get-input)
  (let ((ndim 1))
    (list->array ndim 
		 (with-input-from-file "input"
		   (lambda ()
		     (let ((port (current-input-port))
			   (result '()))
		       (letrec ((foo (lambda () (let ((ch (read-char port)))
						  (cond
						   ((eof-object? ch)
						    ;; drop last newline
						    (set! result (cdr result))
						    #f)
						   (#t
						    (set! result (cons ch result))
						    (foo)))))))
			 (foo)
			 (reverse result))))))))


#|

scheme@(guile-user)> (length (get-input))
$9 = 16402
16402 characters in input , possibly extra newline

convert list to list->array
(define arr (list->array 1 (get-input)))

group => parse a group

start of group { 
 is { another group ? 

|#


(define arr (get-input))
(define i 0)
(define vlen (vector-length arr))

(define (advance)
  (set! i (+ i 1))
  (cond
   ((and (>= i 0) (< i vlen))
    (format #t "advanced char = [~a]~%" (vector-ref arr i))
    #t
    )
   (#t
    (format #t "end of input reached (~a) ~%" i))))

(define (unsafe-charat n)
  (vector-ref arr n))

(define (is-char ch)
  (cond
   ((and (>= i 0) (< i vlen)) (char=? ch (vector-ref arr i)))
   (#t #f)))

(define (end-of-file-reached?)
  (cond
   ((>= i vlen) #t)
   (#t #f)))

(define (garbage-recur)
  (cond
   ((is-char #\!)
    (advance)
    (advance)
    (garbage-recur))
   ((is-char #\>)
    (format #t "garbage end at ~a ~%" i)
    (advance)
    #t)
   (#t (advance)
       (garbage-recur))))


(define (garbage)
  (cond
   ((is-char #\<)
    (format #t "garbage identified start ~a~%" i)
    (advance)
    (garbage-recur))))



(define (group-recur)
  (cond
   ((is-char #\{) 
    (format #t "group recognised start at ~a [~a] ~%" i (vector-ref arr i))
    (advance)
									     
    (letrec ((foo (lambda ()
		    (cond
		     ((is-char #\}) (advance)
		      (format #t "end of group at ~a ~%" (- i 1))
		      #t)
		     (#t
		      (cond
		       ((is-char #\<) (garbage))
		       ((is-char #\,) (advance))
		       ((is-char #\{) (group-recur)))
		      (foo))))))
      (foo)))))




;; (define (group-entry)
;;   (cond
;;    ((is-char #\{) (group-recur))))

(define (reset)
  (set! i 0)
  )
      
(define (run arr)
  (reset)
  (format #t "checking ~a ~%" arr)
  (set! i 0)
  (set! vlen (vector-length arr))

  (format #t "vlen = ~a ~%" vlen)
  (group-recur))


(define (puzzle)
  (run (get-input)))


#|
test suite 
|#

(define (test-1) (run (list->array 1 (string->list "{}"))))





		      
		    










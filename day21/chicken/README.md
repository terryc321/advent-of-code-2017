
# day21 

## flatten sub matrices to single matrix

```lisp
(define p1
  (let ((a '((1 2)(3 4)))
	(b '((5 6)(7 8)))
	(c '((9 10)(11 12)))
	(d '((13 14)(15 16)))
	)
    `((,a ,b)(,c ,d))))

(define (flat m)
  (let ((f (lambda (c)
	     (let ((size (length (car c))))
	       (map (lambda (i)
		      (apply append (map (lambda (z) (list-ref z i)) c)))
		    (iota size))))))
    (apply append (map f m))))
```

```lisp
> p1
((((1 2) (3 4)) ((5 6) (7 8))) (((9 10) (11 12)) ((13 14) (15 16))))

> (flat p1)
((1 2 5 6) (3 4 7 8) (9 10 13 14) (11 12 15 16)) 
```

## latest

```lisp 
split.scm  - need to program splitting of matrix into 2x2 , into 3x3 , 

finding mappings in input-map -- seems to be ok

version-1.scm need to put correct code from split.scm into version-1.scm

then done ??
huh

```



```scheme
main.scm - entry point
prelude.scm - chicken prelude 

```


## redundant and confusing mapping

```lisp
 ;; from                  to 
(((1 1 1 1 1 1 1 1 1) (1 0 1 1 1 1 0 0 1 0 1 0 0 0 0 0))
 ((1 1 1 1 1 1 1 1 1) (1 0 0 0 1 0 1 0 0 1 0 0 1 1 1 0))
 ((1 1 1 1 1 1 1 1 1) (0 0 0 0 0 1 0 1 0 0 1 1 1 1 0 1))
 ((1 1 1 1 1 1 1 1 1) (0 1 1 1 0 0 1 0 0 1 0 1 0 0 0 1))
 ((1 1 1 1 1 1 1 1 1) (1 1 1 0 0 1 0 0 1 0 1 0 1 0 0 0))
 ((1 1 1 1 1 1 1 1 1) (0 0 0 0 1 0 1 0 1 1 0 0 1 0 1 1))
 ((1 1 1 1 1 1 1 1 1) (0 0 0 1 0 1 0 1 0 0 1 0 0 1 1 1))
 ((1 1 1 1 1 1 1 1 1) (1 1 0 1 0 0 1 1 0 1 0 1 0 0 0 0))
 ((1 1 1 1 0 1 1 1 1) (0 1 0 0 0 1 0 0 0 1 0 0 1 1 0 0))
 
;; which mapping should all 1's choose ? 
```

## relax and use lisp lists 

no reason to go vector heavy

## specific orientation 

puzzle still really kicking my arse - part 2 

reason orientation matters is the pattern is split multiple times between pairs and triples

specific pattern_A must give a unique pattern_B

cannot have all rotations and flips of pattern A yield one single pattern B_0 

if pattern A matches and leads to pattern B 

pattern A has a specific orientation as does pattern B 
not enough to simply dump pattern B out , as that is B_specific to A_specific

so the patterns themselves must be taken account of.

there are EIGHT at most pattern orientations .

this puzzle is really kicking my arse

main issue is
 - lack of debugging
 - lack of user interaction / gui interface
 -
 
if we write interpreter for the language we wish to use
 -


this is a tricky bugger of a problem

lots of moving parts



 


;; chicken scheme preamble -
;; can we get other scheme implementations in on this
(include "prelude.scm") 

#| rotation and flip

need is given a mapping from pattern_A -> pattern_B

rotate pattern_A and rotate pattern_B
is this new rotation in mapping ? ,
if not put rot pat_a -> rot pat_b into table



|#
(include "rotate.scm")

;; vec2d 
(include "grid.scm") 

(include "maps.scm")  

;; split list represents grid into sub grids 
(include "split.scm")


(include "solve.scm") 


;; anything else gets put into help ?
(include "help.scm")
















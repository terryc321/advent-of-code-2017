
#|
producing a visual hexagonal grid is a bit confusing

hexagon can be thought of a circle , evenly divided into six pieces
six pieces of pie

each slice ( 360 / 6 ) or 60 degrees

computer math - sin cosine use angles are radians
pi 3.1415926535898  is 180 degrees
radians = angle / 180 * pi

really need some basic language packages where pi is defined
|#
;; 
;; (define (tag x y) (cons y x))
;; (define (tag-type x) (car x))

;; chicken scheme pre-amble - probably do not half of this cruft 
(import scheme)
(import simple-exceptions)
(import (chicken repl))
(import (chicken string))
(import (chicken pretty-print))
(import (chicken io))
(import (chicken format))
(import (chicken sort))
(import (chicken file))
(import (chicken process-context))
(import procedural-macros)
(import regex)
(import simple-md5)
(import simple-loops)
(import srfi-69)
(import srfi-178)
(import sequences)
(import srfi-1)
(import matchable)

(define pi 3.1415926535898)

(define (deg->rad x) (* pi (/ x 180)))

;; really want proper abstract data types 
(define (pos-x pos) (first pos))
(define (pos-y pos) (second pos))
(define (make-pos x y) (list x y))

(define (pos-add p p2)
  (make-pos (+ (pos-x p)(pos-x p2))
	    (+ (pos-y p)(pos-y p2))))


(define radius 10)
(define origin (make-pos 20 20))
(define start (make-pos 20 20))
(define finish (make-pos 20 20))


(define *width* 0)
(define *height* 0)


(define hex-array #f)

(define lo-x #f)
(define lo-y #f)
(define hi-x #f)
(define hi-y #f)
(define adj-x 0)
(define adj-y 0)

(define (pos-max-min p)
  (cond
   ((not lo-x) (set! lo-x (pos-x p)))
   ((and lo-x (< (pos-x p) lo-x))
    (set! lo-x (pos-x p))))
  (cond
   ((not lo-y) (set! lo-y (pos-y p)))
   ((and lo-y (< (pos-y p) lo-y))
    (set! lo-y (pos-y p))))
  (cond
   ((not hi-x) (set! hi-x (pos-x p)))
   ((and hi-x (> (pos-x p) hi-x))
    (set! hi-x (pos-x p))))
  (cond
   ((not hi-y) (set! hi-y (pos-y p)))
   ((and hi-y (> (pos-y p) hi-y))
    (set! hi-y (pos-y p))))
  )
  
  
(define (ten-thousand n)
  (cond
   ((integer? n) (ten-thousand (format #f "~a" n)))
   ((and (string? n) (= (string-length n) 1)) (string-append "0000" n))
   ((and (string? n) (= (string-length n) 2)) (string-append "000" n))
   ((and (string? n) (= (string-length n) 3)) (string-append "00" n))
   ((and (string? n) (= (string-length n) 4)) (string-append "0" n))
   ((and (string? n) (= (string-length n) 5)) (string-append "" n))
   (#t (error "ten-thousand"))))
   

(define (in-vicinity p p2 range)  
  (let* ((dx (- (pos-x p) (pos-x p2)))
	 (dy (- (pos-y p) (pos-y p2)))
	 (dist (sqrt (+ (* dx dx) (* dy dy)))))
    (< dist range)))



;; south , negative y direction, x same vertical alignment,
;; x same
;; y less , by 2 * radius * sin 60

;; SVG coordinates are actually upside down
;; TOP LEFT is 0,0 say
;; BOTTOM RIGHT is 1000,1000 
(define (north p)
  (make-pos (pos-x p) 
	    (- (pos-y p) (* 2 radius (sin (deg->rad 60))))))

(define (south p)
  (make-pos (pos-x p) 
	    (+ (pos-y p) (* 2 radius (sin (deg->rad 60))))))

(define (south-east p)
  (make-pos (+ (pos-x p) (* 3/2 radius))
	    (+ (pos-y p) (* radius (sin (deg->rad 60))))))

(define (south-west p)
  (make-pos (- (pos-x p) (* 3/2 radius))
	    (+ (pos-y p) (* radius (sin (deg->rad 60))))))

(define (north-east p)
  (make-pos (+ (pos-x p) (* 3/2 radius))
	    (- (pos-y p) (* radius (sin (deg->rad 60))))))

(define (north-west p)
  (make-pos (- (pos-x p) (* 3/2 radius))
	    (- (pos-y p) (* radius (sin (deg->rad 60))))))


;; draw hexagon centred on position p
(define (draw-hex p status)
  (letrec ((draw-loop (lambda (angle iter last)
		   (let* ((x (pos-x p))
			  (y (pos-y p))
			  (dx (* radius (cos (deg->rad angle))))
			  (dy (* radius (sin (deg->rad angle))))			  
			  (this (make-pos (+ x dx) (+ y dy))))
		   (cond
		    ((eq? last '())
		     (draw-loop (+ angle 60) (+ iter 1) this))
		    ((> iter 6) #f)
		    (#t
		     ;;(draw-line last this)
		     (draw-point this)
		     (draw-loop (+ angle 60) (+ iter 1) this)))))))
    (draw-start-polygon)
    (draw-loop 0 0 '() )
    (draw-end-polygon status)
    ))

(define (draw-start-polygon)
  (format #t "<polygon points=\""))

(define (draw-end-polygon status)
  (cond
   ((eq? status 'off)
    (format #t "\" style=\"fill:lime;stroke:purple;stroke-width:3\" />~%")
    ;;(format #t "\" style=\"fill:lime\" />~%")
    )
   ((eq? status 'on)
    (format #t "\" style=\"fill:red;stroke:purple;stroke-width:3\" />~%")
    ;;(format #t "\" style=\"fill:red\" />~%")
    )
   ((eq? status 'pink)
    (format #t "\" style=\"fill:pink;stroke:purple;stroke-width:3\" />~%")
    ;;(format #t "\" style=\"fill:pink\" />~%")
    )
   (#t (error "draw-end-polygon"))))


(define (draw-point p)
  (format #t "~a,~a ~%" (pos-x p) (pos-y p)))



(define (draw-line p p2)
  (format #t "<line x1=\"~a\" y1=\"~a\" x2=\"~a\" y2=\"~a\" style=\"stroke:red;stroke-width:2\" />~%"
	  (pos-x p) (pos-y p)
	  (pos-x p2) (pos-y p2)))


;; may not know on first pass what the lows and highs of the x and y directions are , so
;; just default to 1000 by 1000 
(define (svg-header width height)                                   ;;adj-x adj-y
    (format #t "<svg width=\"~a\" height=\"~a\" xmlns=\"http://www.w3.org/2000/svg\">~%"
	    width
	    height)
    ;;(format #t "<rect width=\"100%\" height=\"100%\" fill=\"black\"\/>~%")
    (format #t "
    <style>
    .small {
      font: italic 13px sans-serif;
    }
    .heavy {
      font: bold 30px sans-serif;
    }
    </style> ~%"))




(define (svg-start-position)
  (format #t "<circle cx=\"~a\" cy=\"~a\" r=\"~a\" stroke=\"green\" stroke-width=\"1\" fill=\"yellow\" />~%"
	  (+ adj-x (pos-x origin))
	  (+ adj-y (pos-y origin))
	  radius))


(define (svg-finish-position)
  (format #t "<circle cx=\"~a\" cy=\"~a\" r=\"~a\" stroke=\"orange\" stroke-width=\"1\" fill=\"red\" />~%"
	  (+ adj-x (pos-x finish))
	  (+ adj-y (pos-y finish))
	  radius)
  (format #t "<circle cx=\"~a\" cy=\"~a\" r=\"~a\" stroke=\"orange\" stroke-width=\"1\" fill=\"red\" />~%"
	  (+ adj-x (pos-x finish))
	  (+ adj-y (pos-y finish))
	  (/ radius 2.0))
  )

(define (svg-footer)
  (format #t "</svg>~%"))


(define (svg-text s)
  ;;(format #t "<text x=\"20\" y=\"35\" class=\"small\">~a</text>~%" s)
  (format #t "<text x=\"20\" y=\"500\" class=\"heavy\">~a</text>~%" s)
  )


 
#|
<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="40" stroke="green" stroke-width="4" fill="yellow" />
</svg>
|#

(define (reset)
  (set! adj-x 0)
  (set! adj-y 0)
  (set! lo-x #f)
  (set! lo-y #f)
  (set! hi-x #f)
  (set! hi-y #f)
  (set! origin (make-pos 20 20))
  (set! finish (make-pos 20 20)))

;; path has 8223 hexagon steps ... ok ...
(define *path* '(
		ne n ne s nw s s sw sw sw sw sw nw nw sw nw nw n nw nw nw nw nw s n nw s n n nw n n se n n n s n n n n sw se n n ne s ne ne nw ne n ne ne ne ne ne s ne ne s se ne ne ne ne ne nw ne se ne ne n ne ne se ne ne se se se se se n se ne se se ne ne se sw sw se se s sw se se se s n se se s se s se se se se se se n s s nw se s s nw s se se s s s sw s s se n ne s s s s s s nw s n s n se s s sw s ne s s s s s nw ne s s sw s s s s se n nw s s s s s sw s n sw s s sw sw s sw sw ne sw sw s ne s sw sw sw sw s sw se sw sw s sw se s sw sw sw se sw sw sw sw s sw s sw s sw sw ne sw sw ne sw sw s sw sw sw ne sw sw sw sw se se sw nw sw sw nw sw nw nw sw sw sw sw nw sw nw sw sw nw sw n sw nw sw s s se nw s nw sw nw nw sw nw s nw se s sw se nw nw n sw sw nw sw nw nw nw ne sw ne se sw sw ne nw sw nw nw nw ne nw nw sw nw sw nw sw nw nw nw nw nw ne nw nw nw nw nw nw nw ne nw nw nw nw nw nw nw ne ne nw s sw nw nw nw se nw se se nw nw nw n nw nw ne nw nw nw ne nw n sw nw ne nw sw nw n nw s nw n nw nw nw nw nw n n sw nw nw n nw n nw nw nw nw se n nw nw nw ne nw n nw n nw n nw nw nw nw n nw sw nw n n se n n n nw nw n nw n ne nw nw nw nw n s nw s nw nw n nw n n n n s nw nw n n se nw nw nw s n n sw sw n n nw n n n nw sw n ne s n n n n nw n nw n n n sw n n n n nw n n n n n ne n se n n n n n n ne n n n se n n n n n ne n n n ne nw n n n n n ne ne n n n n n n n n n n n nw se n ne n sw n n n n ne ne n ne n n s n sw nw n ne ne nw s se ne n ne n n ne se n sw ne n n se s ne ne n n n ne ne n se s n n n n n ne s nw ne n n n ne ne sw ne ne n ne ne ne ne sw ne n n ne n ne n n n s n n ne n ne n ne ne ne nw ne sw s ne n ne ne ne n n ne ne ne se nw ne n ne ne n ne ne ne ne ne n n n nw ne ne se n n n n ne n ne ne nw ne ne n ne ne ne ne ne nw n ne se ne ne ne ne nw ne ne ne ne ne ne ne se se ne ne ne ne ne ne ne n nw ne ne ne ne ne nw ne ne ne ne nw ne ne nw se ne ne ne ne ne ne ne ne nw ne ne ne ne ne se ne sw ne ne se ne sw ne ne ne ne ne ne se ne ne ne ne ne nw ne n ne s ne ne se ne n ne sw se ne ne sw se ne se se ne ne se se ne s ne s ne n ne ne ne ne sw ne ne se ne ne ne se ne se ne ne ne se nw ne ne ne ne ne s ne s se ne ne se n ne se se se ne ne ne ne ne se sw ne ne se se se ne ne se se se ne se s ne se sw ne se ne se ne se ne se se n se se n ne se se se ne n ne se ne n n ne s ne se n ne ne se nw se se ne se ne sw s n se nw ne se se ne ne se se se se se ne ne ne ne se se se se ne se ne se se n se sw sw se se se se se se se se ne se nw se se se ne ne n se ne se se ne se s n s ne se se ne se ne se se se ne se se se se ne se se ne se se ne se se se se se ne ne ne se se se se se n se s nw se n s se se se se se se sw se sw se se sw se nw se se se se se ne se se se ne se se s se se se se nw s nw se se se se se s se ne se n se se se sw se n se se se se se se sw se se n se se se se se n sw s se se n se se se se sw se se se nw se se se se se s s sw se sw se se s se se se s ne se sw se s se se ne se se se se s se se se se s se se s s s se sw se se se n se sw s s se sw se s s s se ne se se se s se sw s s se se n sw s n sw s se se s s s n se se se s se se se s se se se se nw se n se s se se s se s nw se s ne se se s sw se s n se n s se se se ne se s s s ne se se se se n se s se se s se n se se s n se s s se s nw se s s se se s s s nw se se se se s nw se s se s se se s se s s n s s se s nw s se s se s s ne se s s n se s s s n se se s s ne s se s s s s se s se sw s s s se nw s s nw se s s s s s s se sw sw nw s sw s s s s sw s s s s sw s s s s s s se s s s se s se s n s s s se s s s s ne s s s se s s s s s s s s sw s s s s se s s ne s se s se nw s nw n n s se s s s n s s se s n s s s sw s nw s sw nw ne s s s s s s s s s sw s nw s s s s s s s s nw s n s s s s ne s s sw s s s n n s s sw s s se sw s s s nw s nw sw s n s s se n s s s s sw s s s nw s s s s s s s s s s s ne s nw s s s sw s s s s s s s nw n n s se s s s s sw s s s s s nw sw s s sw s s se s s s s s s s sw s s s s sw s s s s n s nw sw s s s s s s s sw s s sw s sw s sw s sw s n s sw s n sw s s s s sw s s s ne sw s s s s s s s sw s s nw ne s s se sw sw s s n s s s s s s sw sw ne s s s s s s s s s sw s s s sw sw sw sw s s sw ne sw sw s s s s ne sw s se s s s s s s sw s sw s ne sw sw s s n sw s s sw se s nw s sw s s sw s sw sw s sw sw sw sw s sw s s s s s s s sw s s sw s sw n s s s sw ne s sw s sw n n sw sw sw s nw nw sw sw n n s sw se sw sw sw sw sw s s s sw sw s s sw sw n s s sw s sw sw sw nw sw s sw sw se sw s sw sw sw s s sw s s s s s nw s sw n s sw n sw nw sw sw s sw n s s n sw sw s ne s sw s sw sw s sw s s nw s s nw s sw n s sw sw sw sw sw sw s se s n s s s s sw sw ne nw sw s nw sw nw n sw s sw se sw s sw n s s sw sw n sw sw sw s sw n sw sw sw n nw s sw sw s sw s se sw sw n sw sw sw ne sw s s s sw sw s se se sw sw s s sw ne nw sw s sw sw sw s sw sw sw sw sw sw n sw sw s s sw sw sw sw s sw sw s sw s s sw sw sw sw sw sw sw sw sw sw s n nw sw n sw sw sw se sw nw sw se sw sw sw ne sw sw sw sw sw n sw sw sw sw s se s sw sw s sw sw nw sw sw sw sw s se sw sw sw sw sw sw sw sw sw sw sw sw sw nw sw sw sw sw sw sw sw sw sw n sw sw sw sw nw sw ne sw sw sw sw n sw n sw nw sw sw ne s sw sw sw sw nw sw se sw sw sw sw sw sw sw sw nw s n nw nw sw nw sw sw sw nw sw sw n sw se nw sw ne sw sw sw nw sw sw sw sw sw se sw sw sw nw n nw ne sw sw sw sw sw sw sw sw nw sw sw sw sw se sw n sw sw sw sw sw sw sw s n sw sw sw sw sw s sw sw sw sw sw sw sw nw sw sw sw nw sw sw s nw sw nw sw sw ne sw nw sw se sw nw s nw sw nw sw nw sw sw sw sw sw n sw ne nw ne sw sw sw sw s nw sw sw sw ne s sw sw sw sw sw sw sw sw sw sw sw sw sw nw sw sw sw sw sw sw sw nw sw sw nw ne sw s sw se s nw sw sw sw ne sw sw n sw sw sw nw nw ne sw sw sw sw sw se sw nw se sw se sw sw sw sw sw ne se sw sw s sw sw nw sw sw sw sw sw sw sw nw nw nw ne nw sw sw n sw se nw sw sw n nw nw se n s se se ne sw sw nw sw sw sw sw sw nw sw ne n sw sw se se sw nw nw nw nw sw nw ne sw nw sw nw se nw n sw sw sw sw sw nw sw sw nw sw sw nw se s sw ne nw ne nw sw sw sw n sw sw nw sw sw nw se sw sw s sw nw nw sw sw nw sw se sw sw nw nw n sw nw s nw sw se s nw sw sw sw sw sw ne nw sw nw nw sw nw se nw se s sw sw nw nw sw sw sw sw sw nw sw nw ne nw nw sw se sw nw nw sw nw sw sw sw nw ne ne sw sw s sw nw s nw sw nw sw sw sw se se sw sw sw sw sw sw sw sw se n nw nw nw sw sw n sw s sw nw nw nw s sw sw n sw n ne nw sw nw nw sw sw s sw sw nw nw nw sw sw nw nw nw nw sw se sw nw nw sw sw nw sw sw sw sw nw nw ne se nw n sw nw sw se sw nw ne nw sw sw nw nw nw sw nw nw nw sw nw sw ne nw s sw nw nw nw sw sw n nw n nw nw sw s nw nw sw nw nw sw nw nw sw nw sw nw se sw nw sw sw sw sw nw sw nw sw nw ne nw nw nw nw se sw sw nw sw nw sw sw nw nw nw sw sw sw s nw sw n sw sw nw nw nw sw sw nw nw sw sw nw nw se ne nw se s nw s nw sw sw sw nw sw nw n nw sw sw nw nw nw nw nw nw sw nw sw ne nw nw s se nw sw sw nw nw nw nw nw sw nw sw ne ne nw nw sw s nw nw nw nw nw nw sw nw nw nw ne nw se nw n nw sw sw sw se ne nw sw sw nw nw nw nw sw sw s n ne nw nw nw sw nw sw nw nw nw nw ne nw nw nw nw nw se nw s nw sw n sw sw nw se nw nw nw sw nw nw sw sw sw sw nw nw n nw nw ne nw nw nw s nw sw ne nw nw nw nw nw nw nw nw s nw sw se n nw nw sw nw n nw nw nw sw nw n sw nw nw nw nw sw nw sw nw nw s s nw nw nw n nw nw nw nw sw se nw sw nw nw nw nw se nw n se nw n nw nw s sw nw nw nw n nw nw nw nw nw nw nw nw nw ne nw n n sw nw sw nw nw nw ne nw nw s nw nw nw nw nw nw sw nw sw nw nw ne sw nw s nw nw ne nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw ne s nw nw se sw nw nw nw s nw nw nw nw nw nw nw nw nw nw nw nw sw nw nw nw nw nw se nw ne s sw nw n nw nw nw se nw nw sw nw sw nw nw n ne nw nw nw nw nw nw nw s n sw s nw ne s nw nw sw ne n nw nw nw nw nw nw sw s nw nw sw nw n nw nw n nw nw nw nw nw n sw nw nw nw sw s nw se nw nw nw s nw nw nw nw nw nw nw nw nw nw n nw nw sw nw n nw nw nw n nw nw nw nw nw nw nw nw nw nw nw nw nw nw n nw n n nw se nw nw nw n nw nw nw sw nw nw n nw nw nw nw s nw s nw nw s nw ne s nw nw nw s n nw nw nw nw nw nw n nw nw nw sw nw n nw nw nw nw s n nw se nw nw n nw nw n nw nw nw n n nw ne n nw se nw nw se nw nw nw n se nw nw nw nw nw nw nw nw n se nw nw ne n nw n nw se nw n nw n nw nw nw nw nw se nw nw nw nw nw ne nw n n nw nw sw se nw nw nw nw nw nw s s se n nw n nw se nw nw nw nw nw sw n nw nw nw nw n s n nw nw n nw nw n nw nw nw nw ne nw nw nw nw nw nw nw nw sw nw nw ne s ne nw nw nw nw sw nw n nw nw se n nw nw n ne nw nw n n nw n n nw nw nw nw ne nw nw nw n nw n n nw n nw ne nw nw nw n nw se n nw ne n nw n nw nw nw nw s n n nw n se nw nw nw nw ne n nw nw nw n nw nw s nw n sw nw nw s n n nw nw nw n n sw n se nw nw nw nw s nw n nw ne nw nw nw nw s sw n nw n nw ne nw nw n n nw n sw n nw nw nw nw nw n nw nw n n n s n sw ne n nw ne nw n n nw ne se nw nw s nw n sw nw sw n nw ne nw nw nw nw s nw n s nw n n ne sw nw nw nw nw n n nw sw n n nw nw ne n s nw n n nw se n n n nw n nw n nw nw nw nw n n nw n n n n nw n nw nw nw sw nw n ne n se ne n nw nw n n s n n nw n ne s n nw sw se n n nw nw n n n n n s n n n sw n s nw n n nw nw n sw n nw nw nw n nw n nw nw nw nw sw nw nw s sw s n n nw s nw nw se nw nw nw n se n n nw nw n n ne n sw s n nw nw nw n s n nw nw nw n n n n n nw nw nw nw nw n nw nw se n n se nw ne n sw nw n n se s se n nw sw nw n s nw n nw nw nw se nw nw nw s n n nw s n n nw n n n n n n nw n n nw n n n n n nw s sw nw ne n n nw nw nw n nw nw n n n nw n nw nw n n n nw n nw n nw nw nw n n nw nw nw n ne s nw nw nw nw nw n n nw n nw n n nw nw n nw nw n se n n nw n ne nw n ne ne sw n n n n nw n se nw nw n se n nw nw n s n n nw nw nw sw n ne s n n n nw nw n sw n nw nw n n nw n ne n nw nw nw nw nw n n n nw n n n nw nw n n n n n n nw nw s nw n n n n nw nw n n sw n sw n n nw n sw n n n nw nw n ne n n nw se s n n n n n n n n n n n n n n se se ne n n n n n nw nw n n ne n nw n n sw n nw n n s se n n n nw n n n n n n nw n n sw s n s n n n n sw n nw n n se n n n sw n ne n n n n n n n n n n n n n n n nw n n n n n n nw n n n n nw n n n nw nw nw n nw n n se ne n n nw n sw n n n n n s nw n n n n n nw nw sw n n sw se n n n n n n n n n n n n n ne n n nw nw sw n n n s se n sw n n n n ne n nw n n n n sw n sw n n n se n nw nw s ne n n n s n n se n n n nw n n n n n sw n s n n s n n n n ne nw n n n nw n n n nw nw nw n n nw n n n n n n n n n n n n n ne nw n n sw ne n n sw nw n n n n nw n n n n n n nw nw n n n n s s n n n n n n nw sw n n n n n se n n ne se n n se n n n n nw n s n n s n n n n sw n n n n n n n n n nw n n n n n se n n se n n n n n n n n n se n n n n n s n n n n n ne n n n n n ne n n nw n n n s n n n n ne n se ne n nw n n sw s n nw n n ne n sw n ne n n n n s sw n n n sw n ne n n n n s nw n n n n n n ne n se ne n se n n s nw n n n nw n n n ne n n n n n n ne n n nw n n sw sw s n n n n n ne n sw n n n n n n n se ne nw n n n n n n n se n n nw ne n n n ne ne nw n n n n ne n n nw n ne n n n ne n n n ne n n n nw n s ne n ne n n n n nw se se n ne n n ne n se n n n n n se s n n n n n n n n sw n n n n n n n n n n n n ne sw se n se n n n se ne ne n n n se nw n s ne n n s n n n n ne ne sw n n n n n n n n n se n nw n n n ne n s n nw n nw n ne n ne n ne n n ne ne n s n ne n n n sw n n n se n n n n nw n n sw n n n n n n sw n n sw n n ne n n n n n ne n n n n nw n sw n n n n ne n n n sw n n n n n n ne ne n n n ne se sw sw n n n n ne s se n n sw ne sw n nw n sw n n sw n ne ne n n ne ne sw n s n n n ne ne n n n n n ne n ne nw ne n n ne n ne n n n n ne n n n n n n n n n n n n ne sw se n n n nw n ne s sw n ne sw n n ne n sw n n ne ne n ne n n ne ne n n n n ne ne ne n n ne nw n n n se sw ne ne n n n n ne n ne nw n s n n se n n n nw ne ne n s se ne se ne nw ne n n n n ne ne n n n ne nw se ne s ne sw n n nw ne sw ne n ne ne ne n n se nw nw ne ne ne ne ne sw ne n ne se n sw ne ne ne ne n n ne n ne n nw ne ne ne ne se n se ne ne ne n n n n sw n n sw ne ne ne n s ne n n ne ne ne sw n n ne n sw ne s n n ne n ne n ne n sw ne n ne n n n n n n ne ne n s ne s n n n n n ne ne ne ne sw ne s n ne se ne ne ne ne ne nw sw ne nw se n ne n n n n ne ne ne s ne n ne n n n n n nw ne ne n s n ne se n ne n n n ne ne n ne n ne nw n ne n n ne n n ne n n n ne nw n ne n ne n ne n n ne s ne n n n ne ne n n ne n n ne ne n n ne nw nw nw n n n n n n ne n ne ne n n n se n n n s n n n n ne n n n ne ne ne n ne ne n ne n n ne ne ne ne n ne ne n n s ne n ne n n n ne ne n ne ne sw ne ne n ne nw n ne n n ne n nw s ne se ne ne ne n se ne se se ne ne ne ne n ne n nw n n n n n s n ne n sw s n ne n ne ne n n ne n se se ne ne ne ne ne ne nw nw n ne n n n ne ne n n n ne ne ne ne ne n ne ne n n ne n s sw n ne ne n n n sw n ne ne ne n ne ne ne ne ne ne ne n ne s sw n n n ne n ne nw se n n n n n ne n ne n n s sw ne n ne n n n n n ne ne n n ne n s n ne ne se ne n se n n n ne ne n n ne ne ne n n ne ne n ne ne ne sw ne ne ne ne s s n ne n ne s ne ne s ne se ne ne ne ne n n ne ne ne se se ne n ne n s n se nw ne sw ne n s ne ne ne sw n ne ne ne nw n se ne ne ne s s n ne ne n ne se ne ne n n n n ne ne ne ne ne ne nw s sw sw ne ne sw ne ne n se ne ne sw n ne s ne ne n n ne sw ne ne ne ne ne n ne ne ne ne ne ne n ne ne ne n ne ne s ne ne ne se ne s ne nw n ne ne ne s ne ne ne ne ne ne ne n ne n n n ne se n ne ne n n ne n n ne ne ne n ne ne ne ne n n n ne ne ne ne ne ne ne n se n nw ne s sw n ne n n ne n ne ne ne ne ne ne ne n se ne ne ne se se ne nw ne ne ne ne n ne ne ne ne n n ne s n sw nw n nw ne ne n ne ne ne ne s ne n ne ne ne ne ne ne n ne n ne se ne ne n ne n ne n ne ne ne ne sw ne ne ne ne ne n ne sw ne ne ne ne ne ne s n ne n ne ne ne nw ne ne ne n n ne s n n n ne ne nw n ne n sw ne ne ne n ne ne ne ne s n ne ne ne ne ne ne ne ne ne ne n n se ne n nw ne s ne ne ne sw n se nw se ne ne ne ne se n nw ne ne ne ne s nw ne ne ne s ne se ne ne ne ne nw ne ne n ne ne ne ne n ne ne ne ne se ne ne ne ne ne ne ne ne ne ne ne s ne ne n ne ne ne ne n ne sw ne ne ne ne s se ne ne n n ne ne ne ne sw sw ne s ne ne ne ne ne n n n ne ne ne ne ne ne ne ne ne ne ne ne ne ne ne sw sw ne n ne ne n ne ne ne sw ne ne ne ne n ne ne ne ne n ne n se ne s nw ne sw sw n n n ne ne n ne sw ne ne n ne n ne ne ne ne ne s sw n ne ne ne se ne s ne ne s s ne ne s ne n ne n n ne n ne ne ne ne ne sw ne sw ne ne ne ne ne ne ne ne ne ne ne ne ne se n ne ne ne s ne ne ne ne ne ne ne ne sw nw ne ne nw nw n ne ne sw ne nw ne ne n ne nw se ne ne ne ne s ne ne n ne ne se n ne n ne ne ne ne ne ne ne nw ne ne sw ne n n sw ne ne ne ne ne ne ne ne ne ne ne s nw ne ne ne ne ne ne ne nw ne ne s ne ne ne ne ne n ne ne ne ne ne ne s ne ne ne ne ne ne s ne ne ne ne ne ne ne ne ne se ne ne ne nw ne ne ne n nw nw sw sw sw sw nw s se s s s se ne se n se s ne s ne nw se se ne se ne ne s se se ne ne ne ne ne s sw ne ne n ne ne ne n n n n n n n n n nw n n n ne sw sw n n n ne n s se nw n nw nw n n sw nw s n n sw sw n nw nw nw n se nw nw sw n nw n nw nw nw nw nw nw nw nw ne n nw n nw s s se nw s se sw nw s nw s sw nw nw nw sw nw nw nw nw sw s nw ne sw ne sw sw nw sw nw sw sw nw ne sw sw ne se nw sw sw sw sw sw s sw s sw sw s sw s sw sw s ne se s sw sw sw s s s se s sw sw s s s nw s s s s s n s sw nw sw s sw sw sw s s s sw se se s s s s s s s s s s s se s s sw s s s se s se s s s s s s se se se s s s nw s se ne se s se s se s s s s se ne se s s s s s ne s s s se s s nw se nw se s se se s se s n sw s se s s n n s se se se nw se sw se s se s se se se s se se s sw sw n s se se se se se se se se ne se se s se se se se se se nw s se se se se se se se se nw se se se se se se se s n se se se se se se ne se se se se se s sw se se se s se se se se ne se se se se ne se ne se se se ne ne ne se se ne sw se se ne se sw ne ne se se ne se ne se nw n ne se se ne se ne se se ne ne s se nw ne se se se se ne ne se se ne ne se se ne s ne ne se se ne s s ne ne se s ne se ne se ne ne ne ne n ne ne se nw se ne ne ne ne ne ne nw ne ne n ne ne ne ne ne nw n ne ne s ne ne ne ne n ne ne ne s ne ne ne ne ne ne ne ne ne ne ne ne ne n ne ne se ne ne ne n sw ne nw s ne n ne ne ne ne ne sw ne ne ne ne ne n ne ne ne ne ne ne ne sw ne ne ne s n ne n n ne ne n s ne n ne s n ne ne ne ne ne ne ne n ne n n ne s ne ne n ne ne ne nw s n se ne ne n n ne n sw se ne sw ne ne ne n n se ne s n n n ne ne n n nw ne ne n n ne ne ne n n ne n n n n n ne ne ne n n n ne n n sw n n ne ne s ne sw ne n s n se n ne n n n n ne ne n n n sw n sw n ne n n n sw n n n s ne n n n n sw n sw n n n n n s s se n n n n n nw s s n n n n n n nw n n n n n n sw se n n n n n nw s n sw sw n nw n ne nw s n n n s nw n n n n n n n n s n n n n n n n sw n n n n n n ne s nw sw sw ne nw n n n n nw ne n n nw n se n n nw nw n sw nw n n nw n n nw n n n n nw nw nw n nw nw n n nw n n nw n sw n nw n n n s n nw n n s n n n n nw n n s nw nw n sw nw n n n n nw n nw n n n s ne n n se n se n n nw se n nw nw nw s nw n nw nw n nw nw se n nw sw nw nw nw nw n nw nw nw nw sw n n nw n s se n n n nw s nw n nw n n nw nw nw n nw n nw n n s n nw nw n ne n n n n nw s nw n nw nw nw nw ne nw n n n nw nw n nw nw n nw nw n n n n nw nw ne ne ne nw n sw nw n nw nw nw nw nw nw nw nw nw nw nw s nw ne nw se nw nw nw ne se nw nw nw nw n ne nw nw nw nw nw nw nw nw nw nw ne nw nw nw nw n ne nw nw nw nw nw se nw nw nw nw s sw nw nw se nw nw ne nw nw nw nw nw sw nw sw ne nw se ne nw nw sw sw ne s nw se nw sw nw nw nw nw nw se nw nw nw sw nw nw sw ne nw sw nw nw nw s s nw nw nw n se nw nw nw nw nw nw nw sw sw ne s n nw nw se nw nw sw nw se nw nw se s se sw sw nw nw nw n nw nw nw se nw sw nw nw sw nw sw nw n nw sw ne se nw nw s sw nw n sw nw sw se ne sw nw nw sw s nw sw nw n sw nw ne ne nw s nw nw nw nw sw nw sw sw nw sw nw nw s nw nw nw nw se nw nw sw nw n nw nw nw nw sw nw nw sw nw sw sw nw sw nw nw sw n sw nw sw nw nw nw sw sw sw sw nw sw sw nw nw sw s sw n sw nw nw sw n sw sw ne nw sw s sw ne nw nw n sw nw sw sw s n sw sw nw se sw nw nw ne sw nw ne sw nw sw sw nw n sw ne sw n s sw sw sw sw sw nw sw s n sw nw ne sw sw sw nw se se nw sw se sw n sw sw ne sw s nw sw sw sw sw se nw n sw sw sw sw se sw nw sw nw s nw sw sw ne nw sw sw sw sw sw s nw sw s sw nw sw nw sw se sw n nw sw sw sw sw nw sw sw sw nw s nw sw n sw n sw sw sw nw sw sw sw sw sw sw sw sw s nw n sw sw sw sw sw n nw sw s sw sw sw sw se nw sw sw nw sw sw sw sw sw sw nw sw sw sw se sw sw sw sw sw sw sw nw s sw sw sw sw nw sw sw sw n sw ne nw n sw sw sw sw sw sw sw sw sw se sw sw se sw sw nw nw sw sw ne sw sw s sw nw sw sw sw ne ne sw ne sw sw sw sw sw s se sw s nw sw sw ne sw nw sw s sw sw sw s sw sw n se sw sw sw sw sw sw s sw ne sw ne s sw n sw s n sw sw sw sw nw sw sw s sw ne ne sw sw sw sw sw sw se sw sw sw n sw sw sw sw sw sw ne sw s s sw sw sw sw sw se sw n ne sw sw nw s ne sw sw sw s sw sw sw sw sw sw se ne se se sw sw nw s sw sw sw sw sw ne sw sw n sw se s sw sw n sw sw se sw sw sw s s nw ne s sw sw s s n n s sw s sw s s s sw se s s n sw nw sw sw sw sw sw sw sw sw s sw sw s ne ne sw se s sw s sw s nw sw s s s s nw sw s nw sw s s ne s s sw s sw se sw sw s sw n n s s sw sw ne ne sw s s sw sw s s sw s s s s s s ne sw sw sw sw s sw s s n s sw sw s nw s sw sw s sw nw sw sw sw sw n s sw sw ne s ne s sw sw sw sw s sw sw s s s sw s s sw s s s sw se nw se s sw s sw s se sw s s sw s sw sw s sw s sw sw sw sw sw s sw s s ne sw s s s sw s s s s s s s n s nw se s sw s sw s sw sw sw ne nw sw sw s s sw s s s s ne se s s s sw s sw sw s s s sw s s s s s sw s s s s n s s s ne s s sw sw s s s ne s n s sw s sw sw s s sw sw sw sw sw sw s n n s ne ne sw nw s s s nw s s s nw ne s s s s s n ne s s sw s s s s s ne sw s s se s sw n n s sw ne ne s se s s ne s s s sw se s s s sw s s s nw s se s s s nw sw s s sw s s s s s sw se s s s s s s n nw s s se nw s s s s s se se s s n s s nw nw n sw se s s n s s s s sw sw nw s ne s n s nw ne s s s s s s s s s sw sw s s s s sw s nw n s s s s s s s s s s sw s s s ne n nw s sw s s s s s nw s s s s nw s s n s s s s nw s n nw s n s s s nw s nw s s s s sw s sw s s s s s s sw s s s n s sw s s s n ne s s s s s s nw s s s nw se s s sw s s s sw s sw se n s sw s s s s s ne se s nw s s n n s s s s s se s se s s se n s s ne s s s s s s s s s s s se s s s s s se s s se n sw s s s s s s s s s s s se s nw s s n s nw s s nw s s n s sw s s n s s s s s s sw s s nw s nw se se se s s n se s s n s s n se s se nw se se s s s se n se se s se s s s s s s s nw se s s nw se ne se ne s s s s s n sw se se s sw se s s s se s se s s s s s s se s s s s s ne se se s s se se s se s s s nw s s s se s se s se s n sw ne se ne s se s s s s s s s s s s n s n s se ne s nw s s se nw sw se se s se s s sw s n s s s s ne se s s ne s ne se se s ne se s s se se s n se s n se s sw se s se s s se s s s nw s se s s s s se s s s s ne s s s s se ne s sw se s s sw s sw s sw se s n s s s n s se se s s s s s se se se s se ne s se s se s s s se s se se s nw s n s s s s s se se s ne nw n se ne s se se se sw se ne se s s se s s se n sw nw se ne s se s s se se s s s n s s n s se s nw se n se se nw se s sw se se s s se se se n s se se se ne se sw s s s s se s s se se nw nw s n se s se se s se s se nw ne se se s nw s s s se s se se s sw se se s se se se ne se s se s s s se sw se s se nw se nw se n n s s s se se se ne s se se se sw s se nw se nw se se s se ne s se se sw s se se nw s s se se se se s se se s se ne se n sw se ne se se se se se n s se se s s s sw se se s s se s se se se se se se ne s s s se se se s s se se se ne s s s se se se se se se n se s s se se se se se se s se se se s n se sw s se sw se se se s nw se s se se se se s se s se sw se ne se s se sw se s se se se se s se ne se nw se se se se s se s se se ne se s se nw sw se ne se n se s se s se sw se se s se se se se se se se sw s se se se se se ne se se nw se nw se nw se se se se se se se se se se sw sw se se se n se se n s se se n se se se se sw nw se se se se se se se se se s se se s se se se s se s sw se se se sw se n se sw se s se se se se nw se se se se se se se se se se se se))

#|

			(draw-hex (north origin) 'pink)
			(draw-hex (north-west origin) 'pink)
			(draw-hex (north-east origin) 'pink)			
			(draw-hex (south origin) 'pink)
			(draw-hex (south-west origin) 'pink)
			(draw-hex (south-east origin) 'pink)
			
			;; (draw-hex (south-east origin) 'pink)
			;; (draw-hex (south-east (south-east origin)) 'on)
			;; (draw-hex (north-east (south-east origin)) 'off)
			;; (draw-hex (north-east (north-east (south-east origin))) 'pink)
			;; (draw-hex (north-east (north-east (north-east (south-east origin)))) 'on)

			;;(draw-hex (north-east (north-east (north-east (north-east (north-east (north-east (south-east origin))))))) 'on)
			
|#

(define flat-array (make-vector (+ 1 (length *path*)) #f))

(define (flat)
  (letrec ((iter (lambda (xs pos n)		    
		   ;; record position in flat array
		   (vector-set! flat-array n pos)
		   (cond
		    ((null? xs) #t)
		    (#t (let ((op (car xs))
			      (next-pos '()))
			  (cond
			   ((eq? op 'n) (set! next-pos (north pos)))
			   ((eq? op 'ne) (set! next-pos (north-east pos)))
			   ((eq? op 'nw) (set! next-pos (north-west pos)))
			   ((eq? op 's) (set! next-pos (south pos)))
			   ((eq? op 'se) (set! next-pos (south-east pos)))
			   ((eq? op 'sw) (set! next-pos (south-west pos)))
			   (#t (error "test bad direction")))
			  (iter (cdr xs) next-pos (+ n 1))))))))
    (iter *path* origin 0)
    ))

(define (uniform)
  ;; run the *path* from start to finish on hexagon
  ;; use some trig to work out where centres end up
  (flat)
  ;; adjust these centres so SVG can display them > 0 x and y coords 
  (let ((len (vector-length flat-array))
	(lo-x 0)
	(lo-y 0)
	(hi-x 0)
	(hi-y 0)
	(adj-x 0)
	(adj-y 0)
	(width 0)
	(height 0))
    (do-for (i 0 len)
	    (let* ((pos (vector-ref flat-array i))
		   (x (pos-x pos))
		   (y (pos-y pos)))
	      (when (< x lo-x) (set! lo-x x))
	      (when (< y lo-y) (set! lo-y y))
	      (when (> x hi-x) (set! hi-x x))
	      (when (> y hi-y) (set! hi-y y))))
    (when (< lo-x 0) (set! adj-x (- lo-x)))
    (when (< lo-y 0) (set! adj-y (- lo-y)))    
    (do-for (i 0 len)
	    (let* ((pos (vector-ref flat-array i))
		   (x (+ adj-x (pos-x pos)))
		   (y (+ adj-y (pos-y pos))))
	      (vector-set! flat-array i (make-pos x y))))
    (set! *width*  (+ (* 2 radius) (- hi-x lo-x)))
    (set! *height* (+ (* 2 radius) (- hi-y lo-y)))
    (format #t "global image width ~a , height ~a ~%" *width* *height*)))

;; check output to a file 
(define (output-1)
  (with-output-to-file "svg-1.svg" (lambda ()
				     (svg-header *width* *height*)
				     (let ((len (vector-length flat-array)))
				       (do-for (i 0 len)
					       (let* ((pos (vector-ref flat-array i)))
						 (draw-hex pos 'on))))
				     (svg-footer)
				     )))


;; check output to a file - zoomed in 
(define (zoom-1 n)
  (let ((filename (format #f  "zoom/zoom-~a.svg" (ten-thousand n))))
    (format #t "generating file [~a]~%" filename)
    (with-output-to-file filename
      (lambda ()
	(let* ((w (* 2 radius 30))
	       (h (* 2 radius 30))
	       (range (* radius 60))
	       (ref (vector-ref flat-array n )))
	  (svg-header w h)
	  (let ((len (vector-length flat-array)))
	    (do-for (i 0 len)
		    (let* ((pos (vector-ref flat-array i)))
		      (cond
		       ((in-vicinity ref pos range)
			(let* ((local-x (- (pos-x ref) (/ w 2)))
			       (local-y (- (pos-y ref) (/ h 2)))
			       (x (pos-x pos))
			       (y (pos-y pos))
			       (new-pos (make-pos (- x local-x)
						  (- y local-y))))
			  ;; (format #t "local x y : ~a ~a ~%"
			  ;; 	local-x local-y)
			  ;; (format #t "ref x y : ~a ~a ~%"
			  ;; 	x y)
			  ;; (format #t "new pos ~a ~%" new-pos)
			  (cond
			   ((< i n) (draw-hex new-pos 'on))
			   ((= i n) (draw-hex new-pos 'pink))
			   (#t (draw-hex new-pos 'off)))))))))
	  (svg-footer)
	  ))
      )))



;; like zoom-1 but tries to follow " region of hexagon space "
;; rather than track centre hexagon 
(define (zoom-2 n)
  (let ((filename (format #f  "zoom/zoom-~a.svg" (ten-thousand n))))
    (format #t "generating file [~a]~%" filename)
    (with-output-to-file filename
      (lambda ()
	(let* ((w (* 2 radius 30))
	       (h (* 2 radius 30))
	       (range (* radius 60))
	       (ref (vector-ref flat-array n )))
	  (svg-header w h)
	  (let ((len (vector-length flat-array)))
	    (do-for (i 0 len)
		    (let* ((pos (vector-ref flat-array i)))
		      (cond
		       ((in-vicinity ref pos range)
			(let* ((local-x (- (pos-x ref) (/ w 2)))
			       (local-y (- (pos-y ref) (/ h 2)))
			       (x (pos-x pos))
			       (y (pos-y pos))
			       (new-pos (make-pos (- x local-x)
						  (- y local-y))))
			  ;; (format #t "local x y : ~a ~a ~%"
			  ;; 	local-x local-y)
			  ;; (format #t "ref x y : ~a ~a ~%"
			  ;; 	x y)
			  ;; (format #t "new pos ~a ~%" new-pos)
			  (cond
			   ((< i n) (draw-hex new-pos 'on))
			   ((= i n) (draw-hex new-pos 'pink))
			   (#t (draw-hex new-pos 'off)))))))))
	  (svg-text "hello world")
	  (svg-footer)
	  ))
      )))





(define (zooms)
  (let ((len (vector-length flat-array)))  
    (do-for (i 0 len)
	    (zoom-2 i))))


(define (run)
  (flat)
  (uniform)
  (output-1)
  (zooms))









	      
	      
#|	      


;;(change-directory "day11")
(define (test)
  (let ((instructions (lambda ()
			(letrec ((iter (lambda (xs pos n)
					 (set! finish pos)
					 (cond ;; skip drawing first position
					  ((= n 0) #t)
					  (#t
					   (draw-hex pos 'on)
					   ))
					 ;; record position in hex array
					 (when hex-array
					   (vector-set! hex-array n (make-pos (+ adj-x (pos-x pos))
									      (+ adj-y (pos-y pos)))))
					 (cond
					  ((null? xs) #t)
					  (#t (let ((op (car xs))
						    (next-pos '()))
						(cond
						 ((eq? op 'n) (set! next-pos (north pos)))
						 ((eq? op 'ne) (set! next-pos (north-east pos)))
						 ((eq? op 'nw) (set! next-pos (north-west pos)))
						 ((eq? op 's) (set! next-pos (south pos)))
						 ((eq? op 'se) (set! next-pos (south-east pos)))
						 ((eq? op 'sw) (set! next-pos (south-west pos)))
						 (#t (error "test bad direction")))
						(iter (cdr xs) next-pos (+ n 1))))))))
			  ;; first hexagon
			  (set! start (make-pos (+ adj-x (pos-x origin))
						(+ adj-y (pos-y origin))))
			  (draw-hex origin 'on)
			  (svg-start-position)
			  ;; 
			  (set! finish origin)
			  ;; draw rest hexagons 
			  (iter *path* origin 0)
			  ;; draw final hexagon end position as circle overlay ?
			  (svg-finish-position)
			  ;;(draw-hex finish 'on)			  
			  ))))
  ;; reset mutable variables  
  (reset)
  ;; trial run
  ((lambda ()
    (svg-header)
    (instructions)
    (svg-footer)))
  (set! adj-x (cond ((< lo-x 0) (+ (* 2 radius) (abs lo-x)))(#t 0)))
  (set! adj-y (cond ((< lo-y 0) (+ (* 2 radius) (abs lo-y)))(#t 0)))

  (when (< lo-x 0)
    (set! adj-x (+ (* 2 radius) (abs lo-x))))

  (when (< lo-y 0)
    (set! adj-y (+ (* 2 radius) (abs lo-y))))

  (format #t "lo-y is [~a]~%" lo-y)
  
  (format #t "adj-y should be ~a ~%" (+ (* 2 radius) (abs lo-y)))
  ;;(set! adj-y (+ (* 2 radius) (abs lo-y)))
  (format #t "adj-y should be ~a ~%" adj-y)

  (set! hex-array (make-vector (+ 2 (length *path*)) #f))
  
  ;; to a file
  (with-output-to-file "svg-1.svg" (lambda ()
				     (svg-header)
				     (instructions)
				     (svg-footer)
				     ))
  (format #t "lo ~a , ~a -> hi ~a , ~a ~%" lo-x lo-y hi-x hi-y)
  (format #t "adjustments made ~a , ~a ~%" adj-x adj-y)
  ))

;; last entry in array that is not #f falsey
(define (last-valid-index-hex-array)
  (call/cc (lambda (exit)
	     (do-for (i 0 (vector-length hex-array))
		     (when (not (vector-ref hex-array i))
		       (exit (- i 1)))
		     i))))





;;(change-directory "day11")
(define (test2)
  ;; run test before do anything
  (test)
  ;; just work with hex-array
  ;; if n <= lim then they're on
  ;;  n simply index into hex-array a position centre of hexagon
  ;;  --------------------------------------------------------
  (letrec ((iter (lambda (n at lim target)
		   (cond
		    ;; exit iter
		    ((>= n lim) #t)
		    (#t
		     ;; iter loop
		     (let ((pos (vector-ref hex-array n)))
		     (cond
		      ((and (< n at) (in-vicinity pos target ???))
		       (draw-hex pos 'on))
		      ((and (= n at) (in-vicinity pos target ???))
		       (draw-hex pos 'pink))
		      ((in-vicinity pos target)
		       (draw-hex pos 'off)
		       ))
		     (iter (+ n 1) at lim target)))))))
    ;; to a file

    (let ((lim (last-valid-index-hex-array))
	  (n 0))
      (do-for (at 0 (+ 1 lim))
	      (let ((filename (format #f "large-svg/large-~a.svg" (ten-thousand at))))
		(format #t "creating file [~a]~%" filename)
	      (with-output-to-file filename
		(lambda ()
		  (svg-header)
		  (let ((target (vector-ref hex-array at )))
		    (iter n at lim target)    
		    (svg-footer)
		    ))))))))

|#








	     




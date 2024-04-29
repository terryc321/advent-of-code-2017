

(cond-expand
 (chicken-4 (use (prefix sdl2 "sdl2:")))
 (chicken-5 (import (prefix sdl2 "sdl2:")
		    (chicken condition)
		    )))

;; Initialize SDL
(sdl2:set-main-ready!)
(sdl2:init! '(video)) ;; or whatever init flags your program needs

;; Schedule quit! to be automatically called when your program exits normally.
(on-exit sdl2:quit!)

;; Install a custom exception handler that will call quit! and then
;; call the original exception handler. This ensures that quit! will
;; be called even if an unhandled exception reaches the top level.
(current-exception-handler
 (let ((original-handler (current-exception-handler)))
   (lambda (exception)
     (sdl2:quit!)
     (original-handler exception))))

;; ...
;; ... the rest of your program code ...
;; ...

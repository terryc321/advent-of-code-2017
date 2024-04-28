;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

;; (add-hook 'lisp-mode
;; 	  (lambda ()
;; 	    (local-set-key [TAB] 'slime-fuzzy-complete-symbol)))

(eval-after-load 'lisp-mode 
                 '(define-key lisp-mode-map [(tab)] 'slime-fuzzy-complete-symbol))

;;(local-set-key [TAB] 'slime-fuzzy-complete-symbol)

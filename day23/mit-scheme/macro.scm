

;; debugging mit-scheme macros
;;https://stackoverflow.com/questions/72444053/how-to-expand-a-macro-in-mit-scheme

;; do not include USUAL-INTEGRATIONS declaration

;; load this file with
;; (sf "macro.scm")
;;(pp (fasload "macro.bin"))


(define-syntax myif
  (syntax-rules ()
    ((_ condition a b)
     (if condition a b))))



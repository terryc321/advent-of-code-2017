

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
;; (change-directory "day17")
;; (get-current-directory)
(import procedural-macros)
(import regex)
(import simple-md5)
(import simple-loops)
(import srfi-69)
;; hash-table-ref  hash key thunk
;; hash-table-set! hash key val
;; sudo chicken-install srfi-178
(import srfi-178)
;; srfi-178 provides bit-vectors
;; (import-for-syntax
;;   (only checks <<)
;;   (only bindings bind bind-case)
;;   (only procedural-macros macro-rules with-renamed-symbols once-only))
(import sequences)
(import srfi-1)
(import matchable)
(define pp pretty-print)

;; ----------------------------------------------

(define input '(
		ne n ne s nw s s sw sw sw sw sw nw nw sw nw nw n nw nw nw nw nw s n nw s n n nw n n se n n n s n n n n sw se n n ne s ne ne nw ne n ne ne ne ne ne s ne ne s se ne ne ne ne ne nw ne se ne ne n ne ne se ne ne se se se se se n se ne se se ne ne se sw sw se se s sw se se se s n se se s se s se se se se se se n s s nw se s s nw s se se s s s sw s s se n ne s s s s s s nw s n s n se s s sw s ne s s s s s nw ne s s sw s s s s se n nw s s s s s sw s n sw s s sw sw s sw sw ne sw sw s ne s sw sw sw sw s sw se sw sw s sw se s sw sw sw se sw sw sw sw s sw s sw s sw sw ne sw sw ne sw sw s sw sw sw ne sw sw sw sw se se sw nw sw sw nw sw nw nw sw sw sw sw nw sw nw sw sw nw sw n sw nw sw s s se nw s nw sw nw nw sw nw s nw se s sw se nw nw n sw sw nw sw nw nw nw ne sw ne se sw sw ne nw sw nw nw nw ne nw nw sw nw sw nw sw nw nw nw nw nw ne nw nw nw nw nw nw nw ne nw nw nw nw nw nw nw ne ne nw s sw nw nw nw se nw se se nw nw nw n nw nw ne nw nw nw ne nw n sw nw ne nw sw nw n nw s nw n nw nw nw nw nw n n sw nw nw n nw n nw nw nw nw se n nw nw nw ne nw n nw n nw n nw nw nw nw n nw sw nw n n se n n n nw nw n nw n ne nw nw nw nw n s nw s nw nw n nw n n n n s nw nw n n se nw nw nw s n n sw sw n n nw n n n nw sw n ne s n n n n nw n nw n n n sw n n n n nw n n n n n ne n se n n n n n n ne n n n se n n n n n ne n n n ne nw n n n n n ne ne n n n n n n n n n n n nw se n ne n sw n n n n ne ne n ne n n s n sw nw n ne ne nw s se ne n ne n n ne se n sw ne n n se s ne ne n n n ne ne n se s n n n n n ne s nw ne n n n ne ne sw ne ne n ne ne ne ne sw ne n n ne n ne n n n s n n ne n ne n ne ne ne nw ne sw s ne n ne ne ne n n ne ne ne se nw ne n ne ne n ne ne ne ne ne n n n nw ne ne se n n n n ne n ne ne nw ne ne n ne ne ne ne ne nw n ne se ne ne ne ne nw ne ne ne ne ne ne ne se se ne ne ne ne ne ne ne n nw ne ne ne ne ne nw ne ne ne ne nw ne ne nw se ne ne ne ne ne ne ne ne nw ne ne ne ne ne se ne sw ne ne se ne sw ne ne ne ne ne ne se ne ne ne ne ne nw ne n ne s ne ne se ne n ne sw se ne ne sw se ne se se ne ne se se ne s ne s ne n ne ne ne ne sw ne ne se ne ne ne se ne se ne ne ne se nw ne ne ne ne ne s ne s se ne ne se n ne se se se ne ne ne ne ne se sw ne ne se se se ne ne se se se ne se s ne se sw ne se ne se ne se ne se se n se se n ne se se se ne n ne se ne n n ne s ne se n ne ne se nw se se ne se ne sw s n se nw ne se se ne ne se se se se se ne ne ne ne se se se se ne se ne se se n se sw sw se se se se se se se se ne se nw se se se ne ne n se ne se se ne se s n s ne se se ne se ne se se se ne se se se se ne se se ne se se ne se se se se se ne ne ne se se se se se n se s nw se n s se se se se se se sw se sw se se sw se nw se se se se se ne se se se ne se se s se se se se nw s nw se se se se se s se ne se n se se se sw se n se se se se se se sw se se n se se se se se n sw s se se n se se se se sw se se se nw se se se se se s s sw se sw se se s se se se s ne se sw se s se se ne se se se se s se se se se s se se s s s se sw se se se n se sw s s se sw se s s s se ne se se se s se sw s s se se n sw s n sw s se se s s s n se se se s se se se s se se se se nw se n se s se se s se s nw se s ne se se s sw se s n se n s se se se ne se s s s ne se se se se n se s se se s se n se se s n se s s se s nw se s s se se s s s nw se se se se s nw se s se s se se s se s s n s s se s nw s se s se s s ne se s s n se s s s n se se s s ne s se s s s s se s se sw s s s se nw s s nw se s s s s s s se sw sw nw s sw s s s s sw s s s s sw s s s s s s se s s s se s se s n s s s se s s s s ne s s s se s s s s s s s s sw s s s s se s s ne s se s se nw s nw n n s se s s s n s s se s n s s s sw s nw s sw nw ne s s s s s s s s s sw s nw s s s s s s s s nw s n s s s s ne s s sw s s s n n s s sw s s se sw s s s nw s nw sw s n s s se n s s s s sw s s s nw s s s s s s s s s s s ne s nw s s s sw s s s s s s s nw n n s se s s s s sw s s s s s nw sw s s sw s s se s s s s s s s sw s s s s sw s s s s n s nw sw s s s s s s s sw s s sw s sw s sw s sw s n s sw s n sw s s s s sw s s s ne sw s s s s s s s sw s s nw ne s s se sw sw s s n s s s s s s sw sw ne s s s s s s s s s sw s s s sw sw sw sw s s sw ne sw sw s s s s ne sw s se s s s s s s sw s sw s ne sw sw s s n sw s s sw se s nw s sw s s sw s sw sw s sw sw sw sw s sw s s s s s s s sw s s sw s sw n s s s sw ne s sw s sw n n sw sw sw s nw nw sw sw n n s sw se sw sw sw sw sw s s s sw sw s s sw sw n s s sw s sw sw sw nw sw s sw sw se sw s sw sw sw s s sw s s s s s nw s sw n s sw n sw nw sw sw s sw n s s n sw sw s ne s sw s sw sw s sw s s nw s s nw s sw n s sw sw sw sw sw sw s se s n s s s s sw sw ne nw sw s nw sw nw n sw s sw se sw s sw n s s sw sw n sw sw sw s sw n sw sw sw n nw s sw sw s sw s se sw sw n sw sw sw ne sw s s s sw sw s se se sw sw s s sw ne nw sw s sw sw sw s sw sw sw sw sw sw n sw sw s s sw sw sw sw s sw sw s sw s s sw sw sw sw sw sw sw sw sw sw s n nw sw n sw sw sw se sw nw sw se sw sw sw ne sw sw sw sw sw n sw sw sw sw s se s sw sw s sw sw nw sw sw sw sw s se sw sw sw sw sw sw sw sw sw sw sw sw sw nw sw sw sw sw sw sw sw sw sw n sw sw sw sw nw sw ne sw sw sw sw n sw n sw nw sw sw ne s sw sw sw sw nw sw se sw sw sw sw sw sw sw sw nw s n nw nw sw nw sw sw sw nw sw sw n sw se nw sw ne sw sw sw nw sw sw sw sw sw se sw sw sw nw n nw ne sw sw sw sw sw sw sw sw nw sw sw sw sw se sw n sw sw sw sw sw sw sw s n sw sw sw sw sw s sw sw sw sw sw sw sw nw sw sw sw nw sw sw s nw sw nw sw sw ne sw nw sw se sw nw s nw sw nw sw nw sw sw sw sw sw n sw ne nw ne sw sw sw sw s nw sw sw sw ne s sw sw sw sw sw sw sw sw sw sw sw sw sw nw sw sw sw sw sw sw sw nw sw sw nw ne sw s sw se s nw sw sw sw ne sw sw n sw sw sw nw nw ne sw sw sw sw sw se sw nw se sw se sw sw sw sw sw ne se sw sw s sw sw nw sw sw sw sw sw sw sw nw nw nw ne nw sw sw n sw se nw sw sw n nw nw se n s se se ne sw sw nw sw sw sw sw sw nw sw ne n sw sw se se sw nw nw nw nw sw nw ne sw nw sw nw se nw n sw sw sw sw sw nw sw sw nw sw sw nw se s sw ne nw ne nw sw sw sw n sw sw nw sw sw nw se sw sw s sw nw nw sw sw nw sw se sw sw nw nw n sw nw s nw sw se s nw sw sw sw sw sw ne nw sw nw nw sw nw se nw se s sw sw nw nw sw sw sw sw sw nw sw nw ne nw nw sw se sw nw nw sw nw sw sw sw nw ne ne sw sw s sw nw s nw sw nw sw sw sw se se sw sw sw sw sw sw sw sw se n nw nw nw sw sw n sw s sw nw nw nw s sw sw n sw n ne nw sw nw nw sw sw s sw sw nw nw nw sw sw nw nw nw nw sw se sw nw nw sw sw nw sw sw sw sw nw nw ne se nw n sw nw sw se sw nw ne nw sw sw nw nw nw sw nw nw nw sw nw sw ne nw s sw nw nw nw sw sw n nw n nw nw sw s nw nw sw nw nw sw nw nw sw nw sw nw se sw nw sw sw sw sw nw sw nw sw nw ne nw nw nw nw se sw sw nw sw nw sw sw nw nw nw sw sw sw s nw sw n sw sw nw nw nw sw sw nw nw sw sw nw nw se ne nw se s nw s nw sw sw sw nw sw nw n nw sw sw nw nw nw nw nw nw sw nw sw ne nw nw s se nw sw sw nw nw nw nw nw sw nw sw ne ne nw nw sw s nw nw nw nw nw nw sw nw nw nw ne nw se nw n nw sw sw sw se ne nw sw sw nw nw nw nw sw sw s n ne nw nw nw sw nw sw nw nw nw nw ne nw nw nw nw nw se nw s nw sw n sw sw nw se nw nw nw sw nw nw sw sw sw sw nw nw n nw nw ne nw nw nw s nw sw ne nw nw nw nw nw nw nw nw s nw sw se n nw nw sw nw n nw nw nw sw nw n sw nw nw nw nw sw nw sw nw nw s s nw nw nw n nw nw nw nw sw se nw sw nw nw nw nw se nw n se nw n nw nw s sw nw nw nw n nw nw nw nw nw nw nw nw nw ne nw n n sw nw sw nw nw nw ne nw nw s nw nw nw nw nw nw sw nw sw nw nw ne sw nw s nw nw ne nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw ne s nw nw se sw nw nw nw s nw nw nw nw nw nw nw nw nw nw nw nw sw nw nw nw nw nw se nw ne s sw nw n nw nw nw se nw nw sw nw sw nw nw n ne nw nw nw nw nw nw nw s n sw s nw ne s nw nw sw ne n nw nw nw nw nw nw sw s nw nw sw nw n nw nw n nw nw nw nw nw n sw nw nw nw sw s nw se nw nw nw s nw nw nw nw nw nw nw nw nw nw n nw nw sw nw n nw nw nw n nw nw nw nw nw nw nw nw nw nw nw nw nw nw n nw n n nw se nw nw nw n nw nw nw sw nw nw n nw nw nw nw s nw s nw nw s nw ne s nw nw nw s n nw nw nw nw nw nw n nw nw nw sw nw n nw nw nw nw s n nw se nw nw n nw nw n nw nw nw n n nw ne n nw se nw nw se nw nw nw n se nw nw nw nw nw nw nw nw n se nw nw ne n nw n nw se nw n nw n nw nw nw nw nw se nw nw nw nw nw ne nw n n nw nw sw se nw nw nw nw nw nw s s se n nw n nw se nw nw nw nw nw sw n nw nw nw nw n s n nw nw n nw nw n nw nw nw nw ne nw nw nw nw nw nw nw nw sw nw nw ne s ne nw nw nw nw sw nw n nw nw se n nw nw n ne nw nw n n nw n n nw nw nw nw ne nw nw nw n nw n n nw n nw ne nw nw nw n nw se n nw ne n nw n nw nw nw nw s n n nw n se nw nw nw nw ne n nw nw nw n nw nw s nw n sw nw nw s n n nw nw nw n n sw n se nw nw nw nw s nw n nw ne nw nw nw nw s sw n nw n nw ne nw nw n n nw n sw n nw nw nw nw nw n nw nw n n n s n sw ne n nw ne nw n n nw ne se nw nw s nw n sw nw sw n nw ne nw nw nw nw s nw n s nw n n ne sw nw nw nw nw n n nw sw n n nw nw ne n s nw n n nw se n n n nw n nw n nw nw nw nw n n nw n n n n nw n nw nw nw sw nw n ne n se ne n nw nw n n s n n nw n ne s n nw sw se n n nw nw n n n n n s n n n sw n s nw n n nw nw n sw n nw nw nw n nw n nw nw nw nw sw nw nw s sw s n n nw s nw nw se nw nw nw n se n n nw nw n n ne n sw s n nw nw nw n s n nw nw nw n n n n n nw nw nw nw nw n nw nw se n n se nw ne n sw nw n n se s se n nw sw nw n s nw n nw nw nw se nw nw nw s n n nw s n n nw n n n n n n nw n n nw n n n n n nw s sw nw ne n n nw nw nw n nw nw n n n nw n nw nw n n n nw n nw n nw nw nw n n nw nw nw n ne s nw nw nw nw nw n n nw n nw n n nw nw n nw nw n se n n nw n ne nw n ne ne sw n n n n nw n se nw nw n se n nw nw n s n n nw nw nw sw n ne s n n n nw nw n sw n nw nw n n nw n ne n nw nw nw nw nw n n n nw n n n nw nw n n n n n n nw nw s nw n n n n nw nw n n sw n sw n n nw n sw n n n nw nw n ne n n nw se s n n n n n n n n n n n n n n se se ne n n n n n nw nw n n ne n nw n n sw n nw n n s se n n n nw n n n n n n nw n n sw s n s n n n n sw n nw n n se n n n sw n ne n n n n n n n n n n n n n n n nw n n n n n n nw n n n n nw n n n nw nw nw n nw n n se ne n n nw n sw n n n n n s nw n n n n n nw nw sw n n sw se n n n n n n n n n n n n n ne n n nw nw sw n n n s se n sw n n n n ne n nw n n n n sw n sw n n n se n nw nw s ne n n n s n n se n n n nw n n n n n sw n s n n s n n n n ne nw n n n nw n n n nw nw nw n n nw n n n n n n n n n n n n n ne nw n n sw ne n n sw nw n n n n nw n n n n n n nw nw n n n n s s n n n n n n nw sw n n n n n se n n ne se n n se n n n n nw n s n n s n n n n sw n n n n n n n n n nw n n n n n se n n se n n n n n n n n n se n n n n n s n n n n n ne n n n n n ne n n nw n n n s n n n n ne n se ne n nw n n sw s n nw n n ne n sw n ne n n n n s sw n n n sw n ne n n n n s nw n n n n n n ne n se ne n se n n s nw n n n nw n n n ne n n n n n n ne n n nw n n sw sw s n n n n n ne n sw n n n n n n n se ne nw n n n n n n n se n n nw ne n n n ne ne nw n n n n ne n n nw n ne n n n ne n n n ne n n n nw n s ne n ne n n n n nw se se n ne n n ne n se n n n n n se s n n n n n n n n sw n n n n n n n n n n n n ne sw se n se n n n se ne ne n n n se nw n s ne n n s n n n n ne ne sw n n n n n n n n n se n nw n n n ne n s n nw n nw n ne n ne n ne n n ne ne n s n ne n n n sw n n n se n n n n nw n n sw n n n n n n sw n n sw n n ne n n n n n ne n n n n nw n sw n n n n ne n n n sw n n n n n n ne ne n n n ne se sw sw n n n n ne s se n n sw ne sw n nw n sw n n sw n ne ne n n ne ne sw n s n n n ne ne n n n n n ne n ne nw ne n n ne n ne n n n n ne n n n n n n n n n n n n ne sw se n n n nw n ne s sw n ne sw n n ne n sw n n ne ne n ne n n ne ne n n n n ne ne ne n n ne nw n n n se sw ne ne n n n n ne n ne nw n s n n se n n n nw ne ne n s se ne se ne nw ne n n n n ne ne n n n ne nw se ne s ne sw n n nw ne sw ne n ne ne ne n n se nw nw ne ne ne ne ne sw ne n ne se n sw ne ne ne ne n n ne n ne n nw ne ne ne ne se n se ne ne ne n n n n sw n n sw ne ne ne n s ne n n ne ne ne sw n n ne n sw ne s n n ne n ne n ne n sw ne n ne n n n n n n ne ne n s ne s n n n n n ne ne ne ne sw ne s n ne se ne ne ne ne ne nw sw ne nw se n ne n n n n ne ne ne s ne n ne n n n n n nw ne ne n s n ne se n ne n n n ne ne n ne n ne nw n ne n n ne n n ne n n n ne nw n ne n ne n ne n n ne s ne n n n ne ne n n ne n n ne ne n n ne nw nw nw n n n n n n ne n ne ne n n n se n n n s n n n n ne n n n ne ne ne n ne ne n ne n n ne ne ne ne n ne ne n n s ne n ne n n n ne ne n ne ne sw ne ne n ne nw n ne n n ne n nw s ne se ne ne ne n se ne se se ne ne ne ne n ne n nw n n n n n s n ne n sw s n ne n ne ne n n ne n se se ne ne ne ne ne ne nw nw n ne n n n ne ne n n n ne ne ne ne ne n ne ne n n ne n s sw n ne ne n n n sw n ne ne ne n ne ne ne ne ne ne ne n ne s sw n n n ne n ne nw se n n n n n ne n ne n n s sw ne n ne n n n n n ne ne n n ne n s n ne ne se ne n se n n n ne ne n n ne ne ne n n ne ne n ne ne ne sw ne ne ne ne s s n ne n ne s ne ne s ne se ne ne ne ne n n ne ne ne se se ne n ne n s n se nw ne sw ne n s ne ne ne sw n ne ne ne nw n se ne ne ne s s n ne ne n ne se ne ne n n n n ne ne ne ne ne ne nw s sw sw ne ne sw ne ne n se ne ne sw n ne s ne ne n n ne sw ne ne ne ne ne n ne ne ne ne ne ne n ne ne ne n ne ne s ne ne ne se ne s ne nw n ne ne ne s ne ne ne ne ne ne ne n ne n n n ne se n ne ne n n ne n n ne ne ne n ne ne ne ne n n n ne ne ne ne ne ne ne n se n nw ne s sw n ne n n ne n ne ne ne ne ne ne ne n se ne ne ne se se ne nw ne ne ne ne n ne ne ne ne n n ne s n sw nw n nw ne ne n ne ne ne ne s ne n ne ne ne ne ne ne n ne n ne se ne ne n ne n ne n ne ne ne ne sw ne ne ne ne ne n ne sw ne ne ne ne ne ne s n ne n ne ne ne nw ne ne ne n n ne s n n n ne ne nw n ne n sw ne ne ne n ne ne ne ne s n ne ne ne ne ne ne ne ne ne ne n n se ne n nw ne s ne ne ne sw n se nw se ne ne ne ne se n nw ne ne ne ne s nw ne ne ne s ne se ne ne ne ne nw ne ne n ne ne ne ne n ne ne ne ne se ne ne ne ne ne ne ne ne ne ne ne s ne ne n ne ne ne ne n ne sw ne ne ne ne s se ne ne n n ne ne ne ne sw sw ne s ne ne ne ne ne n n n ne ne ne ne ne ne ne ne ne ne ne ne ne ne ne sw sw ne n ne ne n ne ne ne sw ne ne ne ne n ne ne ne ne n ne n se ne s nw ne sw sw n n n ne ne n ne sw ne ne n ne n ne ne ne ne ne s sw n ne ne ne se ne s ne ne s s ne ne s ne n ne n n ne n ne ne ne ne ne sw ne sw ne ne ne ne ne ne ne ne ne ne ne ne ne se n ne ne ne s ne ne ne ne ne ne ne ne sw nw ne ne nw nw n ne ne sw ne nw ne ne n ne nw se ne ne ne ne s ne ne n ne ne se n ne n ne ne ne ne ne ne ne nw ne ne sw ne n n sw ne ne ne ne ne ne ne ne ne ne ne s nw ne ne ne ne ne ne ne nw ne ne s ne ne ne ne ne n ne ne ne ne ne ne s ne ne ne ne ne ne s ne ne ne ne ne ne ne ne ne se ne ne ne nw ne ne ne n nw nw sw sw sw sw nw s se s s s se ne se n se s ne s ne nw se se ne se ne ne s se se ne ne ne ne ne s sw ne ne n ne ne ne n n n n n n n n n nw n n n ne sw sw n n n ne n s se nw n nw nw n n sw nw s n n sw sw n nw nw nw n se nw nw sw n nw n nw nw nw nw nw nw nw nw ne n nw n nw s s se nw s se sw nw s nw s sw nw nw nw sw nw nw nw nw sw s nw ne sw ne sw sw nw sw nw sw sw nw ne sw sw ne se nw sw sw sw sw sw s sw s sw sw s sw s sw sw s ne se s sw sw sw s s s se s sw sw s s s nw s s s s s n s sw nw sw s sw sw sw s s s sw se se s s s s s s s s s s s se s s sw s s s se s se s s s s s s se se se s s s nw s se ne se s se s se s s s s se ne se s s s s s ne s s s se s s nw se nw se s se se s se s n sw s se s s n n s se se se nw se sw se s se s se se se s se se s sw sw n s se se se se se se se se ne se se s se se se se se se nw s se se se se se se se se nw se se se se se se se s n se se se se se se ne se se se se se s sw se se se s se se se se ne se se se se ne se ne se se se ne ne ne se se ne sw se se ne se sw ne ne se se ne se ne se nw n ne se se ne se ne se se ne ne s se nw ne se se se se ne ne se se ne ne se se ne s ne ne se se ne s s ne ne se s ne se ne se ne ne ne ne n ne ne se nw se ne ne ne ne ne ne nw ne ne n ne ne ne ne ne nw n ne ne s ne ne ne ne n ne ne ne s ne ne ne ne ne ne ne ne ne ne ne ne ne n ne ne se ne ne ne n sw ne nw s ne n ne ne ne ne ne sw ne ne ne ne ne n ne ne ne ne ne ne ne sw ne ne ne s n ne n n ne ne n s ne n ne s n ne ne ne ne ne ne ne n ne n n ne s ne ne n ne ne ne nw s n se ne ne n n ne n sw se ne sw ne ne ne n n se ne s n n n ne ne n n nw ne ne n n ne ne ne n n ne n n n n n ne ne ne n n n ne n n sw n n ne ne s ne sw ne n s n se n ne n n n n ne ne n n n sw n sw n ne n n n sw n n n s ne n n n n sw n sw n n n n n s s se n n n n n nw s s n n n n n n nw n n n n n n sw se n n n n n nw s n sw sw n nw n ne nw s n n n s nw n n n n n n n n s n n n n n n n sw n n n n n n ne s nw sw sw ne nw n n n n nw ne n n nw n se n n nw nw n sw nw n n nw n n nw n n n n nw nw nw n nw nw n n nw n n nw n sw n nw n n n s n nw n n s n n n n nw n n s nw nw n sw nw n n n n nw n nw n n n s ne n n se n se n n nw se n nw nw nw s nw n nw nw n nw nw se n nw sw nw nw nw nw n nw nw nw nw sw n n nw n s se n n n nw s nw n nw n n nw nw nw n nw n nw n n s n nw nw n ne n n n n nw s nw n nw nw nw nw ne nw n n n nw nw n nw nw n nw nw n n n n nw nw ne ne ne nw n sw nw n nw nw nw nw nw nw nw nw nw nw nw s nw ne nw se nw nw nw ne se nw nw nw nw n ne nw nw nw nw nw nw nw nw nw nw ne nw nw nw nw n ne nw nw nw nw nw se nw nw nw nw s sw nw nw se nw nw ne nw nw nw nw nw sw nw sw ne nw se ne nw nw sw sw ne s nw se nw sw nw nw nw nw nw se nw nw nw sw nw nw sw ne nw sw nw nw nw s s nw nw nw n se nw nw nw nw nw nw nw sw sw ne s n nw nw se nw nw sw nw se nw nw se s se sw sw nw nw nw n nw nw nw se nw sw nw nw sw nw sw nw n nw sw ne se nw nw s sw nw n sw nw sw se ne sw nw nw sw s nw sw nw n sw nw ne ne nw s nw nw nw nw sw nw sw sw nw sw nw nw s nw nw nw nw se nw nw sw nw n nw nw nw nw sw nw nw sw nw sw sw nw sw nw nw sw n sw nw sw nw nw nw sw sw sw sw nw sw sw nw nw sw s sw n sw nw nw sw n sw sw ne nw sw s sw ne nw nw n sw nw sw sw s n sw sw nw se sw nw nw ne sw nw ne sw nw sw sw nw n sw ne sw n s sw sw sw sw sw nw sw s n sw nw ne sw sw sw nw se se nw sw se sw n sw sw ne sw s nw sw sw sw sw se nw n sw sw sw sw se sw nw sw nw s nw sw sw ne nw sw sw sw sw sw s nw sw s sw nw sw nw sw se sw n nw sw sw sw sw nw sw sw sw nw s nw sw n sw n sw sw sw nw sw sw sw sw sw sw sw sw s nw n sw sw sw sw sw n nw sw s sw sw sw sw se nw sw sw nw sw sw sw sw sw sw nw sw sw sw se sw sw sw sw sw sw sw nw s sw sw sw sw nw sw sw sw n sw ne nw n sw sw sw sw sw sw sw sw sw se sw sw se sw sw nw nw sw sw ne sw sw s sw nw sw sw sw ne ne sw ne sw sw sw sw sw s se sw s nw sw sw ne sw nw sw s sw sw sw s sw sw n se sw sw sw sw sw sw s sw ne sw ne s sw n sw s n sw sw sw sw nw sw sw s sw ne ne sw sw sw sw sw sw se sw sw sw n sw sw sw sw sw sw ne sw s s sw sw sw sw sw se sw n ne sw sw nw s ne sw sw sw s sw sw sw sw sw sw se ne se se sw sw nw s sw sw sw sw sw ne sw sw n sw se s sw sw n sw sw se sw sw sw s s nw ne s sw sw s s n n s sw s sw s s s sw se s s n sw nw sw sw sw sw sw sw sw sw s sw sw s ne ne sw se s sw s sw s nw sw s s s s nw sw s nw sw s s ne s s sw s sw se sw sw s sw n n s s sw sw ne ne sw s s sw sw s s sw s s s s s s ne sw sw sw sw s sw s s n s sw sw s nw s sw sw s sw nw sw sw sw sw n s sw sw ne s ne s sw sw sw sw s sw sw s s s sw s s sw s s s sw se nw se s sw s sw s se sw s s sw s sw sw s sw s sw sw sw sw sw s sw s s ne sw s s s sw s s s s s s s n s nw se s sw s sw s sw sw sw ne nw sw sw s s sw s s s s ne se s s s sw s sw sw s s s sw s s s s s sw s s s s n s s s ne s s sw sw s s s ne s n s sw s sw sw s s sw sw sw sw sw sw s n n s ne ne sw nw s s s nw s s s nw ne s s s s s n ne s s sw s s s s s ne sw s s se s sw n n s sw ne ne s se s s ne s s s sw se s s s sw s s s nw s se s s s nw sw s s sw s s s s s sw se s s s s s s n nw s s se nw s s s s s se se s s n s s nw nw n sw se s s n s s s s sw sw nw s ne s n s nw ne s s s s s s s s s sw sw s s s s sw s nw n s s s s s s s s s s sw s s s ne n nw s sw s s s s s nw s s s s nw s s n s s s s nw s n nw s n s s s nw s nw s s s s sw s sw s s s s s s sw s s s n s sw s s s n ne s s s s s s nw s s s nw se s s sw s s s sw s sw se n s sw s s s s s ne se s nw s s n n s s s s s se s se s s se n s s ne s s s s s s s s s s s se s s s s s se s s se n sw s s s s s s s s s s s se s nw s s n s nw s s nw s s n s sw s s n s s s s s s sw s s nw s nw se se se s s n se s s n s s n se s se nw se se s s s se n se se s se s s s s s s s nw se s s nw se ne se ne s s s s s n sw se se s sw se s s s se s se s s s s s s se s s s s s ne se se s s se se s se s s s nw s s s se s se s se s n sw ne se ne s se s s s s s s s s s s n s n s se ne s nw s s se nw sw se se s se s s sw s n s s s s ne se s s ne s ne se se s ne se s s se se s n se s n se s sw se s se s s se s s s nw s se s s s s se s s s s ne s s s s se ne s sw se s s sw s sw s sw se s n s s s n s se se s s s s s se se se s se ne s se s se s s s se s se se s nw s n s s s s s se se s ne nw n se ne s se se se sw se ne se s s se s s se n sw nw se ne s se s s se se s s s n s s n s se s nw se n se se nw se s sw se se s s se se se n s se se se ne se sw s s s s se s s se se nw nw s n se s se se s se s se nw ne se se s nw s s s se s se se s sw se se s se se se ne se s se s s s se sw se s se nw se nw se n n s s s se se se ne s se se se sw s se nw se nw se se s se ne s se se sw s se se nw s s se se se se s se se s se ne se n sw se ne se se se se se n s se se s s s sw se se s s se s se se se se se se ne s s s se se se s s se se se ne s s s se se se se se se n se s s se se se se se se s se se se s n se sw s se sw se se se s nw se s se se se se s se s se sw se ne se s se sw se s se se se se s se ne se nw se se se se s se s se se ne se s se nw sw se ne se n se s se s se sw se se s se se se se se se se sw s se se se se se ne se se nw se nw se nw se se se se se se se se se se sw sw se se se n se se n s se se n se se se se sw nw se se se se se se se se se s se se s se se se s se s sw se se se sw se n se sw se s se se se se nw se se se se se se se se se se se se))


;; incf macro
(define-syntax incf
  (er-macro-transformer
    (lambda (form rename compare?)
      (let (
            (var (cadr form))	    
            (%set! (rename 'set!))
            (%+ (rename '+))
        )
	`(,%set! ,var (,%+ ,var 1))))))
;; ,x (incf a)

#|

 hexagonal grid 

                            north
              north-west     |      north-east
                        \    |    /
                           centre
                        /    |    \ 
              south-west     |      south-east
                           south

< hexagonal grid proofs >

theorem :   s + n  =  nothing
we can simplify e.g south + north = cancels out
proof : start at north. go south to centre. go north to north. finish at start point. QED.

theorem : se + n = ne
theorem : sw + n = nw
theorem : nw + s = sw
theorem : ne + s = se

simplification puzzle

axiom 
A + B = B + A
order of move not important ,
meaning can exchange move position with + operator
then can apply corresponding simplifier
e.g south + north = nothing
from n + s = nothing
     s + n = nothing  by order axiom
     QED

working way around hexagonal grid starting at
north and working clockwise , apply + operator
to each available direction on hex grid

.................................

1 n + ne
2 : *** : n + se = ne
3 : *** : n + s  = nothing
4 : *** : n + sw = nw
5 n + nw 
6 n + n

7 ne + ne
8 ne + se 
9  : *** : ne + s = se 
10 : *** : ne + sw = nothing
11 : *** : ne + nw = n 

12 se + se
13 se + s
14 : *** : se + sw = s
15 : *** : se + nw = nothing

16 s + s
17 s + sw
18 : *** : s + nw = sw

19 sw + sw
20 sw + nw

21 nw + nw
................................

|#

(define (rev-member xs a)
  (member a xs))


(define (remove xs a)
  (cond
   ((null? xs) xs)
   ((eq? (car xs) a)
    (cdr xs))
   (#t (cons (car xs) (remove (cdr xs) a)))))

;; 2 : n + se = ne
(define (simp-2 xs)
  (cond
   ((and (rev-member xs 'n)
	 (rev-member xs 'se))
    (cons 'ne (remove (remove xs 'n) 'se)))
   (#t xs)))

;; 3 : n + s = nothing
(define (simp-3 xs)
  (cond
   ((and (rev-member xs 'n)
	 (rev-member xs 's))
    (remove (remove xs 'n) 's))
   (#t xs)))

;; 4 : n + sw = nw
(define (simp-4 xs)
  (cond
   ((and (rev-member xs 'n)
	 (rev-member xs 'sw))
    (cons 'nw (remove (remove xs 'n) 'sw)))
   (#t xs)))

;; 9 : ne + s = se
(define (simp-9 xs)
  (cond
   ((and (rev-member xs 'ne)
	 (rev-member xs 's))
    (cons 'se (remove (remove xs 'ne) 's)))
   (#t xs)))

;; 10 : ne + sw = 
(define (simp-10 xs)
  (cond
   ((and (rev-member xs 'ne)
	 (rev-member xs 'sw))
    (remove (remove xs 'ne) 'sw))
   (#t xs)))

;; 11 : ne + nw = n
(define (simp-11 xs)
  (cond
   ((and (rev-member xs 'ne)
	 (rev-member xs 'nw))
    (cons 'n (remove (remove xs 'ne) 'nw)))
   (#t xs)))

;; 14 : se + sw = s
(define (simp-14 xs)
  (cond
   ((and (rev-member xs 'se)
	 (rev-member xs 'sw))
    (cons 's (remove (remove xs 'se) 'sw)))
   (#t xs)))

;; 15 : se + nw = sw
(define (simp-15 xs)
  (cond
   ((and (rev-member xs 'se)
	 (rev-member xs 'nw))
    (cons 'sw (remove (remove xs 'se) 'nw)))
   (#t xs)))

;; 18 : s + nw = sw
(define (simp-18 xs)
  (cond
   ((and (rev-member xs 's)
	 (rev-member xs 'nw))
    (cons 'sw (remove (remove xs 's) 'nw)))
   (#t xs)))

(define (simp xs)
  (let* ((s2 (simp-2 xs))
	 (s3 (simp-3 s2))
	 (s4 (simp-4 s3))
	 ;;
	 (s9 (simp-9 s4))
	 (s10 (simp-10 s9))
	 (s11 (simp-11 s10))
	 ;;
	 (s14 (simp-14 s11))
	 (s15 (simp-15 s14))
	 ;;
	 (s18 (simp-18 s15))
	 )
    (cond
     ((= (length xs) (length s18))
      s18)
     (#t (simp s18)))))


(define (bar xs)
  (define ne 0)
  (define se 0)
  (define nw 0)
  (define sw 0)
  (define n 0)
  (define s 0)
  (define (foo ys)
    (cond
     ((null? ys) #t)
     (#t
      (let ((dir (car ys)))
	(cond
	 ((eq? dir 'ne) (incf ne))
	 ((eq? dir 'nw) (incf nw))
	 ((eq? dir 'se) (incf se))
	 ((eq? dir 'sw) (incf sw))
	 ((eq? dir 'n) (incf n))
	 ((eq? dir 's) (incf s))
	 (#t (error (list "foo dir unknown" dir))))
	(foo (cdr ys))))))
  (define (foo-2 ys)
    (foo ys)
    (list 'ne ne 'se se 'nw nw 'sw sw 'n n 's s)
    (list (+ (abs (- ne sw))
	     (abs (- nw se))
	     (abs (- n s)))))
  
  ;; entry point
  (foo-2 xs))

#|

#;1200> (length (simp input))
902

accepted ??
i got it wrong ... nope not 902

|#
    
;;(foo input)

#|

hexagon if think of set of equilateral triangles

             X5     X6

        X4      O       X1
         
             X3     X2       

textual representation of graphical image , huh...
if O is the centre ,



  \ n  /
nw +--+ ne
  /    \
-+ here +-
  \    /
sw +--+ se
  / s  \

if located at *here*
then north east movement will mean

points R , theta

draws hexagon 

moveTo 100 (deg2rad (* 60 0))
lineTo 100 (deg2rad (* 60 1))
lineTo 100 (deg2rad (* 60 2))
lineTo 100 (deg2rad (* 60 3))
lineTo 100 (deg2rad (* 60 4))
lineTo 100 (deg2rad (* 60 5))
lineTo 100 (deg2rad (* 60 6))

|#

(define pi 3.1415926535898)

(define (deg2rad d)
  (* 2 pi (/ d 360)))

#|

for some hexagon centre 0,0 with points touch at circle radius R
equilateral triangles 

delta x = (* R (cos (deg2rad 60)))    or R / 2 
delta y = (* R (sin (deg2rad 60)))    or (* R (sqrt 3) 1/2)         R (sqrt 3) / 2
R cos (deg2rad 60)

west x = x - R
east x = x + R

south 
                
           *       *      |
         *   *   *   *   tri-y
        * * * * * * * *   |
        -      0-tx-  [3]
        * * * * * * * *
         *   *   *   *
           !*!     *
            [1]   [2]
OO be the centre of the hexagon

tx is R / 2 
dist 0 - 2 along x axis is R cos (deg2rad 60)
                    or  R / 2 

look centre to far right of hexagon 
              0 - tx - tx - 3

point 0 to 3  distance (* 2 tx)
                distance R

total width of hexagon from far left to far right is (* 2 R)

north  (+ y (* 2 tri-y))
south  (- y (* 2 tri-y))
east   (+ x (* 2 tri-x))
west   (- x (* 2 tri-x))

north east
look at point 1 to point 2 is 


(define (tri-y R)
  (* R (sqrt 3) 1/2))

(define (tri-x R)
  (/ R 2))

;; here 150 is 1.5 R
;; here 100 is R

n / s =>  x same ; y = y +/- (* 100 (sqrt 3))

ne /se /nw / sw => x +/- 150  ; y +/- (* 100 (/ (sqrt 3) 2))
                     +/- 150      ;        50 sqrt 3

no east / west defined but if there were they would be

------------------------------------------------------------------
Proof. East / West of Hexagon.
since hexagon points (vertice?) are on 100 radius from centre , point left and right are at
radius 100 on x axis.
to reach middle next hexagon is similarly another 100 .
e / w => x +/- 200  .
QED
-------------------------------------------------------------------

imagine start at 0,0 coordinates - two dimensional plotting system (arbitrarily large)
positive x = to right
negative x = to left

positive y = up in plot 
negative y = down in plot

same as math diagram

initial hexagon centre is at 0 , 0
|#

(define (north p)
  (let ((x (car p))
	(y (cadr p)))
    (list x
	  (+ y (* 100 (sqrt 3))))))

(define (south p)
  (let ((x (car p))
	(y (cadr p)))
    (list x
	  (- y (* 100 (sqrt 3))))))

(define (north-east p)
  (let ((x (car p))
	(y (cadr p)))
    (list (+ x 150)
	  (+ y (* 100 (/ (sqrt 3) 2))))))

(define (north-west p)
  (let ((x (car p))
	(y (cadr p)))
    (list (- x 150)
	  (+ y (* 100 (/ (sqrt 3) 2))))))

(define (south-east p)
  (let ((x (car p))
	(y (cadr p)))
    (list (+ x 150)
	  (- y (* 100 (/ (sqrt 3) 2))))))

(define (south-west p)
  (let ((x (car p))
	(y (cadr p)))
    (list (- x 150)
	  (- y (* 100 (/ (sqrt 3) 2))))))


(define (fix xs p)  
  (cond
   ((null? xs) p)
   (#t (let ((s (car xs)))
	 (cond
	  ((eq? s 'ne) (fix (cdr xs) (north-east p)))
	  ((eq? s 'se) (fix (cdr xs) (south-east p)))
	  ((eq? s 'nw) (fix (cdr xs) (north-west p)))
	  ((eq? s 'sw) (fix (cdr xs) (south-west p)))
	  ((eq? s 'n) (fix (cdr xs) (north p)))
	  ((eq? s 's) (fix (cdr xs) (south p)))
	  (#t (error "fix")))))))

(define (part-1)
  (fix input (list 0 0)))

;; fix lisp documentation - mind bogglingly poor user interface

;; epsilon some small value such that its equal
;; since dealing with moves around 86 vertical and 150 horizontal , epsilon could be around 30 
(define (epsilon= x y)
  (< (abs (- x y)) 1e-2))

;; have we reached the place already ? not exact molecule position 
(define (here? p1 p2)
  (let ((x1 (car p1))
	(y1 (cadr p1))
	(x2 (car p2))
	(y2 (cadr p2)))   
     (and (epsilon= x1 x2) (epsilon= y1 y2))))

(define (square x) (* x x))

(define (distance p1 p2)
  (let ((x1 (car p1))
	(y1 (cadr p1))
	(x2 (car p2))
	(y2 (cadr p2)))     
    (sqrt 
     (+ (square (abs (- x1 x2)))
	(square (abs (- y1 y2)))))))


;; given list of [direction + point] (nw (0.3 0.4) 123.2) (se (0.2 04) 39.4) (sw (0.2 0.1) 56.6)
;; 
(define (distance-sort dir-points)
  (sort dir-points
	(lambda (x y) (< (third x) (third y)))))


;; given a current point p , target point and some path we took to get here
;; have we arrived ? if so return the path 
(define (my-find p target path)  
  (cond
   ((here? p target) (reverse path))
   (#t
    ;; not there yet - pick a move that reduces the distance to target
    (let* ((dir-points (list (list 'ne (north-east p) (distance (north-east p) target))
			 (list 'nw (north-west p) (distance (north-west p) target))
			 (list 'se (south-east p) (distance (south-east p) target))
			 (list 'sw (south-west p) (distance (south-west p) target))
			 (list 'n (north p) (distance (north p) target))
			 (list 's (south p) (distance (south p) target))))
	   (sorted-points (distance-sort dir-points)))
      (let* ((mix (car sorted-points))
	     (pt (second mix)))
	(my-find pt target (cons mix path)))))))



(define (part-2)
  (let ((target (part-1)))
    (let ((current-point (list 0 0))
	  (path '()))
      (my-find current-point target path))))

   
#|
How many steps away is the furthest he ever got from his starting position?

xs : list of directions
p  : current point on grid of hexagons
path : build result of where been with direction taken + position reached

(let ((path '())
      (start '(0 0))
      (step 0))
  (my-traverse input step start path))

|#
(define my-traverse
  (let ((target (list 0 0)))
    (lambda (xs step p path)  
      (cond
       ((null? xs) (reverse path))
       (#t (let ((sym (car xs)))
	     (cond
	      ((eq? sym 'ne) (my-traverse (cdr xs) (+ 1 step) (north-east p) (cons (list 'ne step (north-east p) (distance (north-east p) target)) path)))
	      ((eq? sym 'nw) (my-traverse (cdr xs) (+ 1 step) (north-west p) (cons (list 'nw step (north-west p) (distance (north-west p) target)) path)))
	      ((eq? sym 'se) (my-traverse (cdr xs) (+ 1 step) (south-east p) (cons (list 'se step (south-east p) (distance (south-east p) target)) path)))
	      ((eq? sym 'sw) (my-traverse (cdr xs) (+ 1 step) (south-west p) (cons (list 'sw step (south-west p) (distance (south-west p) target)) path)))
	      ((eq? sym 'n) (my-traverse (cdr xs) (+ 1 step) (north p)  (cons (list 'n step (north p) (distance (north p) target)) path)))
	      ((eq? sym 's) (my-traverse (cdr xs) (+ 1 step) (south p) (cons (list 's step (south p) (distance (south p) target)) path)))
	      (#t (error "my-traverse")))))))))

   
(define (part-3)
  (let ((path '())
	(start '(0 0))
	(step 1))
    (let* ((mix (my-traverse input step start path))
	   (sorted (sort mix (lambda (x y) (< (fourth x)(fourth y))))))
      sorted)))

;; (pp (part-3))
;;
#|

sort steps taken , direction , step number , position end up at , distance from start 0 0 
...
...
...
 (sw 6674 (-53100 223261.34909562) 229489.08470774)
 (s 6676 (-53100 223261.34909562) 229489.08470774)
 (n 6671 (-52950 223347.951635999) 229538.689549271)
 (ne 6673 (-52950 223347.951635999) 229538.689549271)
 (n 6675 (-53100 223434.554176377) 229657.59295089))



looks like at step 6675 this (-53100 223434.554176377) coordinate is the furthest point away .

|#

(define (part-4)
  (let ((target '(-53100 223434.554176377)))
    (let ((current-point (list 0 0))
	  (path '()))
      (my-find current-point target path))))

(define (part-5)
  (let ((target '(0 0)))
    (let ((current-point '(-53100 223434.554176377))
	  (path '()))
      (my-find current-point target path))))


#|
 (nw (-52650 222481.926232218) 1053.56537528166)
 (n (-52650 222655.131312975) 899.999999996537)
 (nw (-52800 222741.733853353) 754.983443523419)
 (n (-52800 222914.93893411) 599.999999996549)
 (nw (-52950 223001.541474489) 458.257569491832)
 (n (-52950 223174.746555246) 299.999999996561)
 (nw (-53100 223261.349095624) 173.20508075293)
 (n (-53100 223434.554176381) 3.95812094211578e-09))
#;2110> (length (part-4))
1467
#;2113>

1467 steps to get to furthest point ?

|#








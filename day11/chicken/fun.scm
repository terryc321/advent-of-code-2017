

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
#;1357> (pp (part-2))
((nw (-150 86.6025403784439) 108035.133174348)
 (nw (-300 173.205080756888) 107880.350388749)
 (nw (-450 259.807621135332) 107725.623692784)
 (nw (-600 346.410161513775) 107570.953328486)
 (nw (-750 433.012701892219) 107416.339539193)
 (nw (-900 519.615242270663) 107261.782569558)
 (nw (-1050 606.217782649107) 107107.282665556)
 (nw (-1200 692.820323027551) 106952.840074489)
 (nw (-1350 779.422863405995) 106798.455045002)
 (nw (-1500 866.025403784439) 106644.127827083)
 (nw (-1650 952.627944162883) 106489.858672078)
 (nw (-1800 1039.23048454133) 106335.647832696)
 (nw (-1950 1125.83302491977) 106181.495563018)
 (nw (-2100 1212.43556529821) 106027.402118505)
 (nw (-2250 1299.03810567666) 105873.367756009)
 (nw (-2400 1385.6406460551) 105719.39273378)
 (nw (-2550 1472.24318643355) 105565.477311473)
 (nw (-2700 1558.84572681199) 105411.621750162)
 (nw (-2850 1645.44826719043) 105257.826312342)
 (nw (-3000 1732.05080756888) 105104.091261945)
 (nw (-3150 1818.65334794732) 104950.416864342)
 (nw (-3300 1905.25588832576) 104796.803386359)
 (nw (-3450 1991.85842870421) 104643.251096281)
 (nw (-3600 2078.46096908265) 104489.760263861)
 (nw (-3750 2165.0635094611) 104336.331160336)
 (nw (-3900 2251.66604983954) 104182.964058426)
 (nw (-4050 2338.26859021798) 104029.659232352)
 (nw (-4200 2424.87113059643) 103876.416957841)
 (nw (-4350 2511.47367097487) 103723.237512137)
 (nw (-4500 2598.07621135332) 103570.121174011)
 (nw (-4650 2684.67875173176) 103417.068223767)
 (nw (-4800 2771.2812921102) 103264.078943257)
 (nw (-4950 2857.88383248865) 103111.153615888)
 (nw (-5100 2944.48637286709) 102958.292526631)
 (nw (-5250 3031.08891324553) 102805.495962031)
 (nw (-5400 3117.69145362398) 102652.764210221)
 (nw (-5550 3204.29399400242) 102500.097560925)
 (nw (-5700 3290.89653438087) 102347.496305475)
 (nw (-5850 3377.49907475931) 102194.960736815)
 (nw (-6000 3464.10161513775) 102042.491149517)
 (nw (-6150 3550.7041555162) 101890.087839786)
 (nw (-6300 3637.30669589464) 101737.751105473)
 (nw (-6450 3723.90923627308) 101585.481246088)
 (nw (-6600 3810.51177665153) 101433.278562803)
 (nw (-6750 3897.11431702997) 101281.143358471)
 (nw (-6900 3983.71685740842) 101129.075937632)
 (nw (-7050 4070.31939778686) 100977.076606521)
 (nw (-7200 4156.9219381653) 100825.145673087)
 (nw (-7350 4243.52447854375) 100673.283446996)
 (nw (-7500 4330.12701892219) 100521.490239646)
 (nw (-7650 4416.72955930064) 100369.766364176)
 (nw (-7800 4503.33209967908) 100218.112135478)
 (nw (-7950 4589.93464005753) 100066.527870209)
 (nw (-8100 4676.53718043597) 99915.0138867991)
 (nw (-8250 4763.13972081441) 99763.5705054669)
 (nw (-8400 4849.74226119286) 99612.1980482273)
 (nw (-8550 4936.3448015713) 99460.8968389048)
 (nw (-8700 5022.94734194975) 99309.6672031442)
 (nw (-8850 5109.54988232819) 99158.5094684226)
 (nw (-9000 5196.15242270663) 99007.4239640607)
 (nw (-9150 5282.75496308508) 98856.4110212345)
 (nw (-9300 5369.35750346352) 98705.4709729874)
 (nw (-9450 5455.96004384197) 98554.6041542416)
 (nw (-9600 5542.56258422041) 98403.8109018104)
 (nw (-9750 5629.16512459886) 98253.0915544099)
 (nw (-9900 5715.7676649773) 98102.4464526714)
 (nw (-10050 5802.37020535574) 97951.8759391532)
 (nw (-10200 5888.97274573419) 97801.3803583531)
 (nw (-10350 5975.57528611263) 97650.9600567207)
 (nw (-10500 6062.17782649108) 97500.6153826696)
 (nw (-10650 6148.78036686952) 97350.34668659)
 (nw (-10800 6235.38290724797) 97200.1543208614)
 (nw (-10950 6321.98544762641) 97050.0386398649)
 (nw (-11100 6408.58798800485) 96899.9999999962)
 (nw (-11250 6495.1905283833) 96750.0387596784)
 (n (-11250 6668.39560914019) 96599.9999999962)
 (nw (-11400 6754.99814951863) 96450.0388802372)
 (n (-11400 6928.20323027552) 96299.9999999962)
 (nw (-11550 7014.80577065396) 96150.0390015484)
 (n (-11550 7188.01085141085) 95999.9999999962)
 (nw (-11700 7274.61339178929) 95850.0391236189)
 (n (-11700 7447.81847254618) 95699.9999999962)
 (nw (-11850 7534.42101292463) 95550.039246456)
 (n (-11850 7707.62609368151) 95399.9999999962)
 (nw (-12000 7794.22863405996) 95250.0393700668)
 (n (-12000 7967.43371481685) 95099.9999999962)
 (nw (-12150 8054.03625519529) 94950.0394944588)
 (n (-12150 8227.24133595218) 94799.9999999962)
 (nw (-12300 8313.84387633062) 94650.0396196393)
 (n (-12300 8487.04895708751) 94499.9999999962)
 (nw (-12450 8573.65149746595) 94350.0397456158)
 (n (-12450 8746.85657822284) 94199.9999999962)
 (nw (-12600 8833.45911860129) 94050.0398723961)
 (n (-12600 9006.66419935818) 93899.9999999962)
 (nw (-12750 9093.26673973662) 93750.0399999877)
 (n (-12750 9266.47182049351) 93599.9999999962)
 (nw (-12900 9353.07436087195) 93450.0401283985)
 (n (-12900 9526.27944162884) 93299.9999999962)
 (nw (-13050 9612.88198200729) 93150.0402576365)
 (n (-13050 9786.08706276417) 92999.9999999962)
 (nw (-13200 9872.68960314262) 92850.0403877096)
 (n (-13200 10045.8946838995) 92699.9999999962)
 (nw (-13350 10132.497224278) 92550.0405186259)
 (n (-13350 10305.7023050348) 92399.9999999962)
 (nw (-13500 10392.3048454133) 92250.0406503938)
 (n (-13500 10565.5099261702) 92099.9999999962)
 (nw (-13650 10652.1124665486) 91950.0407830214)
 (n (-13650 10825.3175473055) 91799.9999999962)
 (nw (-13800 10911.9200876839) 91650.0409165174)
 (n (-13800 11085.1251684408) 91499.9999999962)
 (nw (-13950 11171.7277088193) 91350.0410508901)
 (n (-13950 11344.9327895762) 91199.9999999962)
 (nw (-14100 11431.5353299546) 91050.0411861483)
 (n (-14100 11604.7404107115) 90899.9999999962)
 (nw (-14250 11691.3429510899) 90750.0413223009)
 (n (-14250 11864.5480318468) 90599.9999999962)
 (nw (-14400 11951.1505722253) 90450.0414593565)
 (n (-14400 12124.3556529822) 90299.9999999962)
 (nw (-14550 12210.9581933606) 90150.0415973244)
 (n (-14550 12384.1632741175) 89999.9999999962)
 (nw (-14700 12470.7658144959) 89850.0417362136)
 (n (-14700 12643.9708952528) 89699.9999999962)
 (nw (-14850 12730.5734356313) 89550.0418760333)
 (n (-14850 12903.7785163882) 89399.9999999962)
 (nw (-15000 12990.3810567666) 89250.042016793)
 (n (-15000 13163.5861375235) 89099.9999999962)
 (nw (-15150 13250.1886779019) 88950.0421585022)
 (n (-15150 13423.3937586588) 88799.9999999962)
 (nw (-15300 13509.9962990373) 88650.0423011705)
 (n (-15300 13683.2013797942) 88499.9999999962)
 (nw (-15450 13769.8039201726) 88350.0424448077)
 (n (-15450 13943.0090009295) 88199.9999999962)
 (nw (-15600 14029.6115413079) 88050.0425894237)
 (n (-15600 14202.8166220648) 87899.9999999962)
 (nw (-15750 14289.4191624433) 87750.0427350285)
 (n (-15750 14462.6242432002) 87599.9999999962)
 (nw (-15900 14549.2267835786) 87450.0428816323)
 (n (-15900 14722.4318643355) 87299.9999999962)
 (nw (-16050 14809.0344047139) 87150.0430292455)
 (n (-16050 14982.2394854708) 86999.9999999962)
 (nw (-16200 15068.8420258493) 86850.0431778784)
 (n (-16200 15242.0471066062) 86699.9999999962)
 (nw (-16350 15328.6496469846) 86550.0433275417)
 (n (-16350 15501.8547277415) 86399.9999999962)
 (nw (-16500 15588.4572681199) 86250.0434782461)
 (n (-16500 15761.6623488768) 86099.9999999962)
 (nw (-16650 15848.2648892553) 85950.0436300026)
 (n (-16650 16021.4699700122) 85799.9999999962)
 (nw (-16800 16108.0725103906) 85650.0437828221)
 (n (-16800 16281.2775911475) 85499.9999999962)
 (nw (-16950 16367.8801315259) 85350.043936716)
 (n (-16950 16541.0852122828) 85199.9999999962)
 (nw (-17100 16627.6877526613) 85050.0440916955)
 (n (-17100 16800.8928334182) 84899.9999999962)
 (nw (-17250 16887.4953737966) 84750.0442477723)
 (n (-17250 17060.7004545535) 84599.9999999962)
 (nw (-17400 17147.3029949319) 84450.0444049579)
 (n (-17400 17320.5080756888) 84299.9999999962)
 (nw (-17550 17407.1106160673) 84150.0445632643)
 (n (-17550 17580.3156968242) 83999.9999999962)
 (nw (-17700 17666.9182372026) 83850.0447227034)
 (n (-17700 17840.1233179595) 83699.9999999962)
 (nw (-17850 17926.7258583379) 83550.0448832876)
 (n (-17850 18099.9309390948) 83399.9999999962)
 (nw (-18000 18186.5334794733) 83250.0450450291)
 (n (-18000 18359.7385602302) 83099.9999999962)
 (nw (-18150 18446.3411006086) 82950.0452079405)
 (n (-18150 18619.5461813655) 82799.9999999962)
 (nw (-18300 18706.1487217439) 82650.0453720346)
 (n (-18300 18879.3538025008) 82499.9999999962)
 (nw (-18450 18965.9563428793) 82350.0455373242)
 (n (-18450 19139.1614236362) 82199.9999999962)
 (nw (-18600 19225.7639640146) 82050.0457038226)
 (n (-18600 19398.9690447715) 81899.9999999962)
 (nw (-18750 19485.5715851499) 81750.045871543)
 (n (-18750 19658.7766659068) 81599.9999999962)
 (nw (-18900 19745.3792062853) 81450.0460404988)
 (n (-18900 19918.5842870422) 81299.9999999962)
 (nw (-19050 20005.1868274206) 81150.0462107039)
 (n (-19050 20178.3919081775) 80999.9999999962)
 (nw (-19200 20264.9944485559) 80850.0463821721)
 (n (-19200 20438.1995293128) 80699.9999999962)
 (nw (-19350 20524.8020696913) 80550.0465549176)
 (n (-19350 20698.0071504481) 80399.9999999962)
 (nw (-19500 20784.6096908266) 80250.0467289545)
 (n (-19500 20957.8147715835) 80099.9999999962)
 (nw (-19650 21044.4173119619) 79950.0469042976)
 (n (-19650 21217.6223927188) 79799.9999999962)
 (nw (-19800 21304.2249330973) 79650.0470809616)
 (n (-19800 21477.4300138541) 79499.9999999962)
 (nw (-19950 21564.0325542326) 79350.0472589613)
 (n (-19950 21737.2376349895) 79199.9999999962)
 (nw (-20100 21823.8401753679) 79050.0474383121)
 (n (-20100 21997.0452561248) 78899.9999999962)
 (nw (-20250 22083.6477965033) 78750.0476190294)
 (n (-20250 22256.8528772601) 78599.9999999962)
 (nw (-20400 22343.4554176386) 78450.0478011288)
 (n (-20400 22516.6604983955) 78299.9999999962)
 (nw (-20550 22603.2630387739) 78150.0479846264)
 (n (-20550 22776.4681195308) 77999.9999999962)
 (nw (-20700 22863.0706599093) 77850.0481695381)
 (n (-20700 23036.2757406661) 77699.9999999962)
 (nw (-20850 23122.8782810446) 77550.0483558805)
 (n (-20850 23296.0833618015) 77399.9999999962)
 (nw (-21000 23382.6859021799) 77250.0485436702)
 (n (-21000 23555.8909829368) 77099.9999999962)
 (nw (-21150 23642.4935233153) 76950.0487329242)
 (n (-21150 23815.6986040721) 76799.9999999962)
 (nw (-21300 23902.3011444506) 76650.0489236596)
 (n (-21300 24075.5062252075) 76499.9999999962)
 (nw (-21450 24162.1087655859) 76350.0491158939)
 (n (-21450 24335.3138463428) 76199.9999999962)
 (nw (-21600 24421.9163867213) 76050.0493096449)
 (n (-21600 24595.1214674781) 75899.9999999962)
 (nw (-21750 24681.7240078566) 75750.0495049305)
 (n (-21750 24854.9290886135) 75599.9999999962)
 (nw (-21900 24941.5316289919) 75450.0497017691)
 (n (-21900 25114.7367097488) 75299.9999999962)
 (nw (-22050 25201.3392501273) 75150.0499001792)
 (n (-22050 25374.5443308841) 74999.9999999962)
 (nw (-22200 25461.1468712626) 74850.0501001798)
 (n (-22200 25634.3519520195) 74699.9999999962)
 (nw (-22350 25720.9544923979) 74550.0503017901)
 (n (-22350 25894.1595731548) 74399.9999999962)
 (nw (-22500 25980.7621135332) 74250.0505050295)
 (n (-22500 26153.9671942901) 74099.9999999962)
 (nw (-22650 26240.5697346686) 73950.0507099179)
 (n (-22650 26413.7748154255) 73799.9999999962)
 (nw (-22800 26500.3773558039) 73650.0509164755)
 (n (-22800 26673.5824365608) 73499.9999999962)
 (nw (-22950 26760.1849769392) 73350.0511247227)
 (n (-22950 26933.3900576961) 73199.9999999962)
 (nw (-23100 27019.9925980746) 73050.0513346804)
 (n (-23100 27193.1976788315) 72899.9999999962)
 (nw (-23250 27279.8002192099) 72750.0515463697)
 (n (-23250 27453.0052999668) 72599.9999999962)
 (nw (-23400 27539.6078403452) 72450.051759812)
 (n (-23400 27712.8129211021) 72299.9999999962)
 (nw (-23550 27799.4154614806) 72150.0519750294)
 (n (-23550 27972.6205422375) 71999.9999999962)
 (nw (-23700 28059.2230826159) 71850.052192044)
 (n (-23700 28232.4281633728) 71699.9999999962)
 (nw (-23850 28319.0307037512) 71550.0524108784)
 (n (-23850 28492.2357845081) 71399.9999999962)
 (nw (-24000 28578.8383248866) 71250.0526315556)
 (n (-24000 28752.0434056435) 71099.9999999961)
 (nw (-24150 28838.6459460219) 70950.0528540991)
 (n (-24150 29011.8510267788) 70799.9999999961)
 (nw (-24300 29098.4535671572) 70650.0530785325)
 (n (-24300 29271.6586479141) 70499.9999999961)
 (nw (-24450 29358.2611882926) 70350.05330488)
 (n (-24450 29531.4662690495) 70199.9999999961)
 (nw (-24600 29618.0688094279) 70050.0535331663)
 (n (-24600 29791.2738901848) 69899.9999999962)
 (nw (-24750 29877.8764305632) 69750.0537634163)
 (n (-24750 30051.0815113201) 69599.9999999961)
 (nw (-24900 30137.6840516986) 69450.0539956555)
 (n (-24900 30310.8891324555) 69299.9999999961)
 (nw (-25050 30397.4916728339) 69150.0542299098)
 (n (-25050 30570.6967535908) 68999.9999999961)
 (nw (-25200 30657.2992939692) 68850.0544662055)
 (n (-25200 30830.5043747261) 68699.9999999961)
 (nw (-25350 30917.1069151046) 68550.0547045695)
 (n (-25350 31090.3119958615) 68399.9999999961)
 (nw (-25500 31176.9145362399) 68250.054945029)
 (n (-25500 31350.1196169968) 68099.9999999961)
 (nw (-25650 31436.7221573752) 67950.0551876117)
 (n (-25650 31609.9272381321) 67799.9999999961)
 (nw (-25800 31696.5297785106) 67650.0554323459)
 (n (-25800 31869.7348592675) 67499.9999999961)
 (nw (-25950 31956.3373996459) 67350.0556792604)
 (n (-25950 32129.5424804028) 67199.9999999961)
 (nw (-26100 32216.1450207812) 67050.0559283844)
 (n (-26100 32389.3501015381) 66899.9999999961)
 (nw (-26250 32475.9526419166) 66750.0561797478)
 (n (-26250 32649.1577226735) 66599.9999999961)
 (nw (-26400 32735.7602630519) 66450.0564333807)
 (n (-26400 32908.9653438088) 66299.9999999961)
 (nw (-26550 32995.5678841872) 66150.0566893143)
 (n (-26550 33168.7729649441) 65999.9999999961)
 (nw (-26700 33255.3755053226) 65850.0569475797)
 (n (-26700 33428.5805860794) 65699.9999999961)
 (nw (-26850 33515.1831264579) 65550.0572082092)
 (n (-26850 33688.3882072148) 65399.9999999961)
 (nw (-27000 33774.9907475932) 65250.0574712352)
 (n (-27000 33948.1958283501) 65099.9999999961)
 (nw (-27150 34034.7983687286) 64950.057736691)
 (n (-27150 34208.0034494854) 64799.9999999961)
 (nw (-27300 34294.6059898639) 64650.0580046105)
 (n (-27300 34467.8110706208) 64499.9999999961)
 (nw (-27450 34554.4136109992) 64350.058275028)
 (n (-27450 34727.6186917561) 64199.9999999961)
 (nw (-27600 34814.2212321346) 64050.0585479787)
 (n (-27600 34987.4263128914) 63899.9999999961)
 (nw (-27750 35074.0288532699) 63750.0588234984)
 (n (-27750 35247.2339340268) 63599.9999999961)
 (nw (-27900 35333.8364744052) 63450.0591016234)
 (n (-27900 35507.0415551621) 63299.9999999961)
 (nw (-28050 35593.6440955406) 63150.059382391)
 (n (-28050 35766.8491762974) 62999.9999999961)
 (nw (-28200 35853.4517166759) 62850.0596658389)
 (n (-28200 36026.6567974328) 62699.9999999961)
 (nw (-28350 36113.2593378112) 62550.0599520058)
 (n (-28350 36286.4644185681) 62399.9999999961)
 (nw (-28500 36373.0669589466) 62250.0602409308)
 (n (-28500 36546.2720397034) 62099.9999999961)
 (nw (-28650 36632.8745800819) 61950.0605326542)
 (n (-28650 36806.0796608388) 61799.9999999961)
 (nw (-28800 36892.6822012172) 61650.0608272167)
 (n (-28800 37065.8872819741) 61499.9999999961)
 (nw (-28950 37152.4898223526) 61350.06112466)
 (n (-28950 37325.6949031094) 61199.9999999961)
 (nw (-29100 37412.2974434879) 61050.0614250266)
 (n (-29100 37585.5025242448) 60899.9999999961)
 (nw (-29250 37672.1050646232) 60750.0617283598)
 (n (-29250 37845.3101453801) 60599.9999999961)
 (nw (-29400 37931.9126857586) 60450.0620347037)
 (n (-29400 38105.1177665154) 60299.9999999961)
 (nw (-29550 38191.7203068939) 60150.0623441035)
 (n (-29550 38364.9253876508) 59999.9999999961)
 (nw (-29700 38451.5279280292) 59850.0626566049)
 (n (-29700 38624.7330087861) 59699.9999999961)
 (nw (-29850 38711.3355491645) 59550.062972255)
 (n (-29850 38884.5406299214) 59399.9999999961)
 (nw (-30000 38971.1431702999) 59250.0632911015)
 (n (-30000 39144.3482510568) 59099.9999999961)
 (nw (-30150 39230.9507914352) 58950.0636131933)
 (n (-30150 39404.1558721921) 58799.9999999961)
 (nw (-30300 39490.7584125705) 58650.0639385802)
 (n (-30300 39663.9634933274) 58499.9999999961)
 (nw (-30450 39750.5660337059) 58350.0642673129)
 (n (-30450 39923.7711144628) 58199.9999999961)
 (nw (-30600 40010.3736548412) 58050.0645994434)
 (n (-30600 40183.5787355981) 57899.9999999961)
 (nw (-30750 40270.1812759765) 57750.0649350245)
 (n (-30750 40443.3863567334) 57599.9999999961)
 (nw (-30900 40529.9888971119) 57450.0652741105)
 (n (-30900 40703.1939778688) 57299.9999999961)
 (nw (-31050 40789.7965182472) 57150.0656167563)
 (n (-31050 40963.0015990041) 56999.9999999961)
 (nw (-31200 41049.6041393825) 56850.0659630185)
 (n (-31200 41222.8092201394) 56699.9999999961)
 (nw (-31350 41309.4117605179) 56550.0663129546)
 (n (-31350 41482.6168412748) 56399.9999999961)
 (nw (-31500 41569.2193816532) 56250.0666666233)
 (n (-31500 41742.4244624101) 56099.9999999961)
 (nw (-31650 41829.0270027885) 55950.0670240846)
 (n (-31650 42002.2320835454) 55799.9999999961)
 (nw (-31800 42088.8346239239) 55650.0673854)
 (n (-31800 42262.0397046808) 55499.9999999961)
 (nw (-31950 42348.6422450592) 55350.0677506321)
 (n (-31950 42521.8473258161) 55199.9999999961)
 (nw (-32100 42608.4498661945) 55050.068119845)
 (n (-32100 42781.6549469514) 54899.9999999961)
 (nw (-32250 42868.2574873299) 54750.0684931039)
 (n (-32250 43041.4625680868) 54599.9999999961)
 (nw (-32400 43128.0651084652) 54450.068870476)
 (n (-32400 43301.2701892221) 54299.9999999961)
 (nw (-32550 43387.8727296005) 54150.0692520294)
 (n (-32550 43561.0778103574) 53999.9999999961)
 (nw (-32700 43647.6803507359) 53850.0696378341)
 (n (-32700 43820.8854314928) 53699.9999999961)
 (nw (-32850 43907.4879718712) 53550.0700279615)
 (n (-32850 44080.6930526281) 53399.9999999961)
 (nw (-33000 44167.2955930065) 53250.0704224847)
 (n (-33000 44340.5006737634) 53099.9999999961)
 (nw (-33150 44427.1032141419) 52950.0708214785)
 (n (-33150 44600.3082948988) 52799.9999999961)
 (nw (-33300 44686.9108352772) 52650.0712250191)
 (n (-33300 44860.1159160341) 52499.9999999961)
 (nw (-33450 44946.7184564125) 52350.0716331849)
 (n (-33450 45119.9235371694) 52199.9999999961)
 (nw (-33600 45206.5260775479) 52050.0720460557)
 (n (-33600 45379.7311583048) 51899.9999999961)
 (nw (-33750 45466.3336986832) 51750.0724637135)
 (n (-33750 45639.5387794401) 51599.9999999961)
 (nw (-33900 45726.1413198185) 51450.0728862418)
 (n (-33900 45899.3464005754) 51299.9999999961)
 (nw (-34050 45985.9489409539) 51150.0733137265)
 (n (-34050 46159.1540217108) 50999.9999999961)
 (nw (-34200 46245.7565620892) 50850.0737462553)
 (n (-34200 46418.9616428461) 50699.9999999961)
 (nw (-34350 46505.5641832245) 50550.0741839179)
 (n (-34350 46678.7692639814) 50399.9999999961)
 (nw (-34500 46765.3718043599) 50250.0746268063)
 (n (-34500 46938.5768851168) 50099.9999999961)
 (nw (-34650 47025.1794254952) 49950.0750750147)
 (n (-34650 47198.3845062521) 49799.9999999961)
 (nw (-34800 47284.9870466305) 49650.0755286395)
 (n (-34800 47458.1921273874) 49499.9999999961)
 (nw (-34950 47544.7946677659) 49350.0759877795)
 (n (-34950 47717.9997485228) 49199.9999999961)
 (nw (-35100 47804.6022889012) 49050.0764525359)
 (n (-35100 47977.8073696581) 48899.9999999961)
 (nw (-35250 48064.4099100365) 48750.0769230123)
 (n (-35250 48237.6149907934) 48599.9999999961)
 (nw (-35400 48324.2175311719) 48450.0773993151)
 (n (-35400 48497.4226119287) 48299.9999999961)
 (nw (-35550 48584.0251523072) 48150.077881553)
 (n (-35550 48757.2302330641) 47999.9999999961)
 (nw (-35700 48843.8327734425) 47850.0783698379)
 (n (-35700 49017.0378541994) 47699.9999999961)
 (nw (-35850 49103.6403945779) 47550.078864284)
 (n (-35850 49276.8454753347) 47399.9999999961)
 (nw (-36000 49363.4480157132) 47250.0793650088)
 (n (-36000 49536.6530964701) 47099.9999999961)
 (nw (-36150 49623.2556368485) 46950.0798721326)
 (n (-36150 49796.4607176054) 46799.9999999961)
 (nw (-36300 49883.0632579839) 46650.0803857789)
 (n (-36300 50056.2683387407) 46499.9999999961)
 (nw (-36450 50142.8708791192) 46350.0809060743)
 (n (-36450 50316.0759598761) 46199.9999999961)
 (nw (-36600 50402.6785002545) 46050.0814331488)
 (n (-36600 50575.8835810114) 45899.9999999961)
 (nw (-36750 50662.4861213899) 45750.0819671358)
 (n (-36750 50835.6912021467) 45599.9999999961)
 (nw (-36900 50922.2937425252) 45450.082508172)
 (n (-36900 51095.4988232821) 45299.9999999961)
 (nw (-37050 51182.1013636605) 45150.0830563981)
 (n (-37050 51355.3064444174) 44999.9999999961)
 (nw (-37200 51441.9089847959) 44850.0836119583)
 (n (-37200 51615.1140655527) 44699.9999999961)
 (nw (-37350 51701.7166059312) 44550.0841750007)
 (n (-37350 51874.9216866881) 44399.9999999961)
 (nw (-37500 51961.5242270665) 44250.0847456776)
 (n (-37500 52134.7293078234) 44099.9999999961)
 (nw (-37650 52221.3318482019) 43950.0853241453)
 (n (-37650 52394.5369289587) 43799.9999999961)
 (nw (-37800 52481.1394693372) 43650.0859105644)
 (n (-37800 52654.3445500941) 43499.9999999961)
 (nw (-37950 52740.9470904725) 43350.0865051001)
 (n (-37950 52914.1521712294) 43199.9999999961)
 (nw (-38100 53000.7547116078) 43050.0871079219)
 (n (-38100 53173.9597923647) 42899.9999999961)
 (nw (-38250 53260.5623327432) 42750.0877192043)
 (n (-38250 53433.7674135001) 42599.9999999961)
 (nw (-38400 53520.3699538785) 42450.0883391267)
 (n (-38400 53693.5750346354) 42299.9999999961)
 (nw (-38550 53780.1775750138) 42150.0889678737)
 (n (-38550 53953.3826557707) 41999.9999999961)
 (nw (-38700 54039.9851961492) 41850.0896056349)
 (n (-38700 54213.1902769061) 41699.9999999961)
 (nw (-38850 54299.7928172845) 41550.0902526056)
 (n (-38850 54472.9978980414) 41399.999999996)
 (nw (-39000 54559.6004384198) 41250.0909089868)
 (n (-39000 54732.8055191767) 41099.999999996)
 (nw (-39150 54819.4080595552) 40950.0915749852)
 (n (-39150 54992.6131403121) 40799.999999996)
 (nw (-39300 55079.2156806905) 40650.0922508139)
 (n (-39300 55252.4207614474) 40499.999999996)
 (nw (-39450 55339.0233018258) 40350.092936692)
 (n (-39450 55512.2283825827) 40199.999999996)
 (nw (-39600 55598.8309229612) 40050.0936328454)
 (n (-39600 55772.0360037181) 39899.999999996)
 (nw (-39750 55858.6385440965) 39750.0943395067)
 (n (-39750 56031.8436248534) 39599.999999996)
 (nw (-39900 56118.4461652318) 39450.0950569157)
 (n (-39900 56291.6512459887) 39299.999999996)
 (nw (-40050 56378.2537863672) 39150.0957853195)
 (n (-40050 56551.4588671241) 38999.999999996)
 (nw (-40200 56638.0614075025) 38850.0965249727)
 (n (-40200 56811.2664882594) 38699.999999996)
 (nw (-40350 56897.8690286378) 38550.0972761379)
 (n (-40350 57071.0741093947) 38399.999999996)
 (nw (-40500 57157.6766497732) 38250.0980390861)
 (n (-40500 57330.8817305301) 38099.999999996)
 (nw (-40650 57417.4842709085) 37950.0988140966)
 (n (-40650 57590.6893516654) 37799.999999996)
 (nw (-40800 57677.2918920438) 37650.0996014579)
 (n (-40800 57850.4969728007) 37499.999999996)
 (nw (-40950 57937.0995131792) 37350.1004014675)
 (n (-40950 58110.3045939361) 37199.999999996)
 (nw (-41100 58196.9071343145) 37050.1012144327)
 (n (-41100 58370.1122150714) 36899.999999996)
 (nw (-41250 58456.7147554498) 36750.1020406707)
 (n (-41250 58629.9198362067) 36599.999999996)
 (nw (-41400 58716.5223765852) 36450.1028805093)
 (n (-41400 58889.7274573421) 36299.999999996)
 (nw (-41550 58976.3299977205) 36150.103734287)
 (n (-41550 59149.5350784774) 35999.999999996)
 (nw (-41700 59236.1376188558) 35850.1046023539)
 (n (-41700 59409.3426996127) 35699.999999996)
 (nw (-41850 59495.9452399912) 35550.1054850716)
 (n (-41850 59669.1503207481) 35399.999999996)
 (nw (-42000 59755.7528611265) 35250.1063828142)
 (n (-42000 59928.9579418834) 35099.999999996)
 (nw (-42150 60015.5604822618) 34950.1072959687)
 (n (-42150 60188.7655630187) 34799.999999996)
 (nw (-42300 60275.3681033972) 34650.1082249352)
 (n (-42300 60448.5731841541) 34499.999999996)
 (nw (-42450 60535.1757245325) 34350.1091701282)
 (n (-42450 60708.3808052894) 34199.999999996)
 (nw (-42600 60794.9833456678) 34050.1101319765)
 (n (-42600 60968.1884264247) 33899.999999996)
 (nw (-42750 61054.7909668032) 33750.1111109242)
 (n (-42750 61227.9960475601) 33599.999999996)
 (nw (-42900 61314.5985879385) 33450.1121074315)
 (n (-42900 61487.8036686954) 33299.999999996)
 (nw (-43050 61574.4062090738) 33150.113121975)
 (n (-43050 61747.6112898307) 32999.999999996)
 (nw (-43200 61834.2138302092) 32850.1141550488)
 (n (-43200 62007.4189109661) 32699.999999996)
 (nw (-43350 62094.0214513445) 32550.1152071654)
 (n (-43350 62267.2265321014) 32399.999999996)
 (nw (-43500 62353.8290724798) 32250.1162788562)
 (n (-43500 62527.0341532367) 32099.999999996)
 (nw (-43650 62613.6366936152) 31950.1173706725)
 (n (-43650 62786.841774372) 31799.999999996)
 (nw (-43800 62873.4443147505) 31650.1184831866)
 (n (-43800 63046.6493955074) 31499.999999996)
 (nw (-43950 63133.2519358858) 31350.1196169927)
 (n (-43950 63306.4570166427) 31199.999999996)
 (nw (-44100 63393.0595570212) 31050.120772708)
 (n (-44100 63566.264637778) 30899.999999996)
 (nw (-44250 63652.8671781565) 30750.1219509737)
 (n (-44250 63826.0722589134) 30599.999999996)
 (nw (-44400 63912.6747992918) 30450.1231524563)
 (n (-44400 64085.8798800487) 30299.999999996)
 (nw (-44550 64172.4824204272) 30150.1243778489)
 (n (-44550 64345.687501184) 29999.999999996)
 (nw (-44700 64432.2900415625) 29850.1256278724)
 (n (-44700 64605.4951223194) 29699.999999996)
 (nw (-44850 64692.0976626978) 29550.1269032768)
 (n (-44850 64865.3027434547) 29399.999999996)
 (nw (-45000 64951.9052838332) 29250.1282048432)
 (n (-45000 65125.11036459) 29099.999999996)
 (nw (-45150 65211.7129049685) 28950.129533385)
 (n (-45150 65384.9179857254) 28799.999999996)
 (nw (-45300 65471.5205261038) 28650.1308897494)
 (n (-45300 65644.7256068607) 28499.999999996)
 (nw (-45450 65731.3281472392) 28350.1322748197)
 (n (-45450 65904.533227996) 28199.999999996)
 (nw (-45600 65991.1357683745) 28050.133689517)
 (n (-45600 66164.3408491314) 27899.999999996)
 (nw (-45750 66250.9433895098) 27750.1351348021)
 (n (-45750 66424.1484702667) 27599.999999996)
 (nw (-45900 66510.7510106452) 27450.1366116779)
 (n (-45900 66683.956091402) 27299.999999996)
 (nw (-46050 66770.5586317805) 27150.1381211916)
 (n (-46050 66943.7637125374) 26999.999999996)
 (nw (-46200 67030.3662529158) 26850.1396644372)
 (n (-46200 67203.5713336727) 26699.999999996)
 (nw (-46350 67290.1738740512) 26550.1412425582)
 (n (-46350 67463.378954808) 26399.999999996)
 (nw (-46500 67549.9814951865) 26250.1428567501)
 (n (-46500 67723.1865759434) 26099.999999996)
 (nw (-46650 67809.7891163218) 25950.1445082642)
 (n (-46650 67982.9941970787) 25799.999999996)
 (nw (-46800 68069.5967374571) 25650.1461984098)
 (n (-46800 68242.801818214) 25499.999999996)
 (nw (-46950 68329.4043585925) 25350.1479285585)
 (n (-46950 68502.6094393494) 25199.999999996)
 (nw (-47100 68589.2119797278) 25050.1497001475)
 (n (-47100 68762.4170604847) 24899.999999996)
 (nw (-47250 68849.0196008631) 24750.1515146837)
 (n (-47250 69022.22468162) 24599.999999996)
 (nw (-47400 69108.8272219985) 24450.1533737481)
 (n (-47400 69282.0323027554) 24299.999999996)
 (nw (-47550 69368.6348431338) 24150.1552789999)
 (n (-47550 69541.8399238907) 23999.999999996)
 (nw (-47700 69628.4424642691) 23850.1572321821)
 (n (-47700 69801.647545026) 23699.999999996)
 (nw (-47850 69888.2500854045) 23550.1592351264)
 (n (-47850 70061.4551661614) 23399.999999996)
 (nw (-48000 70148.0577065398) 23250.1612897591)
 (n (-48000 70321.2627872967) 23099.999999996)
 (nw (-48150 70407.8653276751) 22950.1633981071)
 (n (-48150 70581.070408432) 22799.999999996)
 (nw (-48300 70667.6729488105) 22650.1655623048)
 (n (-48300 70840.8780295674) 22499.999999996)
 (nw (-48450 70927.4805699458) 22350.1677846011)
 (n (-48450 71100.6856507027) 22199.999999996)
 (nw (-48600 71187.2881910811) 22050.1700673673)
 (n (-48600 71360.493271838) 21899.999999996)
 (nw (-48750 71447.0958122165) 21750.1724131057)
 (n (-48750 71620.3008929734) 21599.999999996)
 (nw (-48900 71706.9034333518) 21450.1748244584)
 (n (-48900 71880.1085141087) 21299.999999996)
 (nw (-49050 71966.7110544871) 21150.1773042173)
 (n (-49050 72139.916135244) 20999.999999996)
 (nw (-49200 72226.5186756225) 20850.1798553354)
 (n (-49200 72399.7237563794) 20699.999999996)
 (nw (-49350 72486.3262967578) 20550.1824809376)
 (n (-49350 72659.5313775147) 20399.999999996)
 (nw (-49500 72746.1339178931) 20250.1851843344)
 (n (-49500 72919.33899865) 20099.999999996)
 (nw (-49650 73005.9415390285) 19950.1879690353)
 (n (-49650 73179.1466197854) 19799.999999996)
 (nw (-49800 73265.7491601638) 19650.1908387639)
 (n (-49800 73438.9542409207) 19499.999999996)
 (nw (-49950 73525.5567812991) 19350.1937974751)
 (n (-49950 73698.761862056) 19199.999999996)
 (nw (-50100 73785.3644024345) 19050.1968493726)
 (n (-50100 73958.5694831914) 18899.999999996)
 (nw (-50250 74045.1720235698) 18750.1999989293)
 (n (-50250 74218.3771043267) 18599.999999996)
 (nw (-50400 74304.9796447051) 18450.203250909)
 (n (-50400 74478.184725462) 18299.999999996)
 (nw (-50550 74564.7872658405) 18150.2066103902)
 (n (-50550 74737.9923465974) 17999.999999996)
 (nw (-50700 74824.5948869758) 17850.2100827933)
 (n (-50700 74997.7999677327) 17699.999999996)
 (nw (-50850 75084.4025081111) 17550.2136739089)
 (n (-50850 75257.607588868) 17399.999999996)
 (nw (-51000 75344.2101292465) 17250.2173899305)
 (n (-51000 75517.4152100034) 17099.999999996)
 (nw (-51150 75604.0177503818) 16950.2212374902)
 (n (-51150 75777.2228311387) 16799.999999996)
 (nw (-51300 75863.8253715171) 16650.2252236979)
 (n (-51300 76037.030452274) 16499.999999996)
 (nw (-51450 76123.6329926525) 16350.2293561854)
 (n (-51450 76296.8380734094) 16199.999999996)
 (nw (-51600 76383.4406137878) 16050.2336431552)
 (n (-51600 76556.6456945447) 15899.999999996)
 (nw (-51750 76643.2482349231) 15750.2380934344)
 (n (-51750 76816.45331568) 15599.999999996)
 (nw (-51900 76903.0558560585) 15450.242716536)
 (n (-51900 77076.2609368153) 15299.999999996)
 (nw (-52050 77162.8634771938) 15150.2475227264)
 (n (-52050 77336.0685579507) 14999.999999996)
 (nw (-52200 77422.6710983291) 14850.2525231014)
 (n (-52200 77595.876179086) 14699.999999996)
 (nw (-52350 77682.4787194645) 14550.2577296721)
 (n (-52350 77855.6838002213) 14399.999999996)
 (nw (-52500 77942.2863405998) 14250.2631554608)
 (n (-52500 78115.4914213567) 14099.999999996)
 (nw (-52650 78202.0939617351) 13950.2688146102)
 (n (-52650 78375.299042492) 13799.999999996)
 (nw (-52800 78461.9015828705) 13650.2747225061)
 (n (-52800 78635.1066636273) 13499.999999996)
 (nw (-52950 78721.7092040058) 13350.2808959172)
 (n (-52950 78894.9142847627) 13199.999999996)
 (nw (-53100 78981.5168251411) 13050.2873531541)
 (n (-53100 79154.721905898) 12899.999999996)
 (nw (-53250 79241.3244462765) 12750.2941142507)
 (n (-53250 79414.5295270333) 12599.999999996)
 (nw (-53400 79501.1320674118) 12450.3012011718)
 (n (-53400 79674.3371481687) 12299.999999996)
 (nw (-53550 79760.9396885471) 12150.3086380512)
 (n (-53550 79934.144769304) 11999.999999996)
 (nw (-53700 80020.7473096825) 11850.3164514668)
 (n (-53700 80193.9523904393) 11699.999999996)
 (nw (-53850 80280.5549308178) 11550.3246707574)
 (n (-53850 80453.7600115747) 11399.999999996)
 (nw (-54000 80540.3625519531) 11250.3333283911)
 (n (-54000 80713.56763271) 11099.999999996)
 (nw (-54150 80800.1701730885) 10950.3424603941)
 (n (-54150 80973.3752538453) 10799.999999996)
 (nw (-54300 81059.9777942238) 10650.3521068514)
 (n (-54300 81233.1828749807) 10499.999999996)
 (nw (-54450 81319.7854153591) 10350.3623124949)
 (n (-54450 81492.990496116) 10199.999999996)
 (nw (-54600 81579.5930364945) 10050.3731273977)
 (n (-54600 81752.7981172513) 9899.99999999595)
 (nw (-54750 81839.4006576298) 9750.38460779474)
 (n (-54750 82012.6057383867) 9599.99999999595)
 (nw (-54900 82099.2082787651) 9450.39681706134)
 (n (-54900 82272.413359522) 9299.99999999595)
 (nw (-55050 82359.0158999004) 9150.40982688346)
 (n (-55050 82532.2209806573) 8999.99999999595)
 (nw (-55200 82618.8235210358) 8850.42371866612)
 (n (-55200 82792.0286017927) 8699.99999999595)
 (nw (-55350 82878.6311421711) 8550.4385852382)
 (n (-55350 83051.836222928) 8399.99999999595)
 (nw (-55500 83138.4387633064) 8250.45453292924)
 (n (-55500 83311.6438440633) 8099.99999999594)
 (nw (-55650 83398.2463844418) 7950.4716841163)
 (n (-55650 83571.4514651987) 7799.99999999594)
 (nw (-55800 83658.0540055771) 7650.49018036998)
 (n (-55800 83831.259086334) 7499.99999999594)
 (nw (-55950 83917.8616267124) 7350.51018637074)
 (n (-55950 84091.0667074693) 7199.99999999594)
 (nw (-56100 84177.6692478478) 7050.53189482484)
 (n (-56100 84350.8743286047) 6899.99999999594)
 (nw (-56250 84437.4768689831) 6750.55553269098)
 (n (-56250 84610.68194974) 6599.99999999594)
 (nw (-56400 84697.2844901184) 6450.58136914396)
 (n (-56400 84870.4895708753) 6299.99999999594)
 (nw (-56550 84957.0921112538) 6150.60972586862)
 (n (-56550 85130.2971920107) 5999.99999999594)
 (nw (-56700 85216.8997323891) 5850.64099051993)
 (n (-56700 85390.104813146) 5699.99999999594)
 (nw (-56850 85476.7073535244) 5550.67563454707)
 (n (-56850 85649.9124342813) 5399.99999999593)
 (nw (-57000 85736.5149746598) 5250.71423712593)
 (n (-57000 85909.7200554167) 5099.99999999593)
 (nw (-57150 85996.3225957951) 4950.75751779052)
 (n (-57150 86169.527676552) 4799.99999999593)
 (nw (-57300 86256.1302169304) 4650.80638168928)
 (n (-57300 86429.3352976873) 4499.99999999593)
 (nw (-57450 86515.9378380658) 4350.8619835573)
 (n (-57450 86689.1429188227) 4199.99999999593)
 (nw (-57600 86775.7454592011) 4050.9258201017)
 (n (-57600 86948.950539958) 3899.99999999593)
 (nw (-57750 87035.5530803364) 3750.99986669809)
 (n (-57750 87208.7581610933) 3599.99999999593)
 (nw (-57900 87295.3607014718) 3451.08678534335)
 (n (-57900 87468.5657822287) 3299.99999999593)
 (nw (-58050 87555.1683226071) 3151.19025131361)
 (n (-58050 87728.373403364) 2999.99999999593)
 (nw (-58200 87814.9759437424) 2851.31548587251)
 (n (-58200 87988.1810244993) 2699.99999999593)
 (nw (-58350 88074.7835648778) 2551.47016443046)
 (n (-58350 88247.9886456347) 2399.99999999592)
 (nw (-58500 88334.5911860131) 2251.66604983538)
 (n (-58500 88507.79626677) 2099.99999999592)
 (nw (-58650 88594.3988071484) 1951.92212959014)
 (n (-58650 88767.6038879053) 1799.99999999592)
 (nw (-58800 88854.2064282838) 1652.27116418164)
 (n (-58800 89027.4115090407) 1499.99999999592)
 (nw (-58950 89114.0140494191) 1352.77492584265)
 (n (-58950 89287.219130176) 1199.99999999592)
 (nw (-59100 89373.8216705544) 1053.56537528101)
 (n (-59100 89547.0267513113) 899.99999999592)
 (nw (-59250 89633.6292916898) 754.983443522751)
 (n (-59250 89806.8343724467) 599.999999995919)
 (nw (-59400 89893.4369128251) 458.257569491131)
 (n (-59400 90066.641993582) 299.999999995918)
 (nw (-59550 90153.2445339604) 173.205080752174)
 (n (-59550 90326.4496147173) 4.71482053399086e-09))
#;1381> (map car (part-2))
(nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n nw n)
#;1382> (length (part-2))
720
#;1383>

720 accepted answer.


|#
	  
   








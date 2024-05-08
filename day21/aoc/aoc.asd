;;;; aoc.asd

(asdf:defsystem #:aoc
  :description "Describe aoc here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("uiop"
	       "split-sequence")
  :components ((:file "package")
               (:file "aoc")))




;;;; ambar.asd

(asdf:defsystem #:ambar
  :description "Ambar, a primitive file server for Raspberry Pi"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:cl-who #:hunchentoot #:cl-fad #:iterate)
  :components ((:file "package")
               (:file "ambar")))

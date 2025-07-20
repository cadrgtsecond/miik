(defsystem "miik"
  :version "0.0.0"
  :author "cadrgtsecond"
  :license ""
  :homepage ""
  :depends-on (usocket bordeaux-threads)
  :serial t
  :components ((:module "src" :components ((:file "package"))))
  :description "The Meagre Lisp Interaction Mode for Kakoune")

(defsystem "miik"
  :version "0.0.0"
  :author "cadrgtsecond"
  :license ""
  :homepage ""
  :depends-on (usocket bordeaux-threads #+sbcl sb-introspect)
  :serial t
  :components ((:module "src" :components ((:file "package"))))
  :description "The Meagre Lisp Interface for Kakoune")

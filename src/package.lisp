(defpackage #:miik
  (:use #:cl)
  (:export #:start-server
           #:stop-server
           #:*real-stdout*
           #:get-object-compilation-info
           #:get-definition-compilation-info
           #:with-compilation-info
           #:print-plist))

(in-package #:miik)

(defvar *real-stdout*)

(defun evaluate-stream (stream)
  (handler-case
    (loop
      (eval (read stream)))
   ;; We have done evaluating
   (end-of-file ())
   (error (e) (format *real-stdout* "miik error: ~a~%" e))))

(defun handle-connection (stream)
  (let ((*real-stdout* *standard-output*))
    (format stream "~a~%"
      (with-output-to-string (*standard-output*)
        (evaluate-stream stream))))
  (force-output stream))

(defun main (host port)
  (usocket:with-socket-listener (listener host port)
    (loop
      (usocket:with-server-socket (conn (usocket:socket-accept listener))
        (handle-connection (usocket:socket-stream conn))))))

(defvar *miik-thread* '())
(defun start-server (&optional (host "localhost") (port 3700))
  (setf *miik-thread* (bt:make-thread (lambda () (main host port)) :name "miik server")))

(defun stop-server ()
  (bt:destroy-thread *miik-thread*))

(defun print-plist (plist)
  "Prints a PLIST in a form more suitable for consumption by Unix"
  (loop for vals on plist by #'cddr
        ;; TODO: Escape cadr vals
        do (format t "~a~a~a~%" (car vals) #\Tab (cadr vals))))

#+nil
(print-plist '(:hello "world"))

;;;; Source tracking
(defmacro with-compilation-info ((&rest data &key pathname &allow-other-keys) form)
  "Compiles FORM, with any DATA specified attached to the definition.
This DATA may be later retrieved with MIIK:GET-COMPILATION-INFO"
  `(with-compilation-unit
     #+sbcl
     (:source-namestring ,pathname
      :source-plist ',data)
     #+(not sbcl)
     ()
     (eval ',form)))

(defun get-source-info (source)
  "Returns the compilation info associated with the given source"
  (or (sb-introspect:definition-source-plist source)
      (with-accessors ((pathname sb-introspect:definition-source-pathname)
                       (character-offset sb-introspect:definition-source-character-offset))
        source
        `(:pathname ,pathname
          :character-offset ,character-offset))))
  
(defun get-object-compilation-info (obj)
  "Returns the compilation information associated with the given object"
  #+sbcl
  (get-source-info (sb-introspect:find-definition-source obj))
                            
  #+(not sbcl)
  (error "Not implemented yet"))

(defun get-definition-compilation-info (name type)
  #+sbcl
  (mapcar #'get-source-info (sb-introspect:find-definition-sources-by-name name type)))

#+nil
(with-compilation-info (:pathname "src/package.lisp" :kak-selection "32.31")
  (defun hello () (print "hello")))
#+nil
(print (get-object-compilation-info #'evaluate-stream))
#+nil
(print (get-definition-compilation-info 'evaluate-stream :function))
#+nil
(print (get-definition-compilation-info 'with-compilation-info :macro))
#+nil
(print (get-object-compilation-info #'stop-server))

#+nil
(let ((*standard-output* *real-stdout*))
  (generate-completions "test"))

#+nil
(progn
  (defparameter *counter* 0)
  (defun test ()
    (format t "Counter: ~a~%" *counter*)
    (incf *counter*)))
#+nil
(test)
#+nil
(print *counter*)
#+nil
(apropos 'server)

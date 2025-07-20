(defpackage miik
  (:use :cl)
  (:export start stop))

(in-package :miik)

(defun main (host port)
  (usocket:with-socket-listener (listener host port)
    (loop
      for conn = (usocket:socket-accept listener)
      for stream = (usocket:socket-stream conn)
      do (format stream "~a~%"
                 (with-output-to-string (*standard-output*)
                   (eval (read stream))))
      do (force-output stream))))

(defvar *miik-thread* '())
(defun start-server (&optional (host "localhost") (port 3700))
  (setf *miik-thread* (bt:make-thread (lambda () (main host port)) :name "miik Server")))

(defun stop-server ()
  (bt:destroy-thread *miik-thread*))

(defun test ()
  (print "Hello 2"))

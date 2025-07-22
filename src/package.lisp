(defpackage #:miik
  (:use #:cl)
  (:export #:start-server #:stop-server #:*real-stdout*))

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

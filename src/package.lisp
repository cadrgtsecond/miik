(defpackage #:miik
  (:use #:cl)
  (:export #:start-server #:stop-server #:*real-stdout*))

(in-package #:miik)

(defvar *real-stdout*)

(defun handle-connection (stream)
  (format stream "~a~%"
    (let ((*real-stdout* *standard-output*))
      (handler-case
        (with-output-to-string (*standard-output*)
          (eval (read stream)))
        (error (e) (format t "miik error: ~a~%" e)))))
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

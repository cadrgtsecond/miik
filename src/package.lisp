(defpackage #:miik
  (:use #:cl)
  (:export #:start-server #:stop-server #:*real-stdout*))

(in-package #:miik)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; CORE PLUGIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; KAKOUNE HELPERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun kak-quoted-string (str)
  "Converts a Common Lisp string into one that can be sent to kakoune"
  (format nil "'~a'"
    (with-output-to-string (s)
      (loop for char across str
            do (format s "~a"
                 (case char
                   (#\' "''")
                   (t char)))))))

(defun escape-completion-result (str)
  "Escape the result of completion by escaping | and \\"
  (with-output-to-string (s)
    (loop
      for char across str
      do (format s "~a"
           (case char
             (#\\ "\\\\")
             (#\|  "\\|")
             (t   char))))))

(defun generate-completions ()
  (loop
    for sym in (apropos-list "")
    ;; TODO: Generate more useful informating for each symbol, such as whether it is fbound
    ;; TODO: Generate docs
    for sym-name = (escape-completion-result (string-downcase (format nil "~s" sym)))
    do (format t "~a " (kak-quoted-string (format nil "~a||{\\}~a" sym-name sym-name)))))

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

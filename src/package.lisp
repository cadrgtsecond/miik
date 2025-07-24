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

(defun symbol-kakoune-string (sym)
  "Converts a symbol into a string suitable to send to Kakoune, escaping special characters"
  (escape-for-kakoune (string-downcase (format nil "~s" sym))))

(defun escape-for-kakoune (str)
  "Makes a string safe for Kakoune by escaping \\ or |"
  (with-output-to-string (s)
    (loop
      for char across str
      do (format s "~a"
           (case char
             (#\\ "\\\\")
             (#\|  "\\|")
             (t   char))))))

#+nil
(print (escape-for-kakoune "some|ugly|\\stuff"))

(defun generate-completions ()
  (loop
    for sym in (apropos-list "")
    ;; TODO: Generate more useful informating for each symbol, such as whether it is fbound
    ;; TODO: Generate docs
    do (format t "~a||{\\}~a~%" (symbol-kakoune-string sym) (symbol-kakoune-string sym))))

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

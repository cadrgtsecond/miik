(defpackage miik
  (:use :cl)
  (:export start stop))

(in-package :miik)

(defun repl-loop (connection-path)
  (alexandria:when-let ((connection-dir (probe-file connection-path)))
    (loop
      (let ((res (with-open-file (stdin (merge-pathnames #p"stdin" connection-dir))
                      (with-open-file (*standard-output* (merge-pathnames #p"stdout" connection-dir)
                                                         :direction :output
                                                         :if-exists :append)
                        (eval (read stdin))))))
        (with-open-file (result (merge-pathnames #p"result" connection-dir)
                                :direction :output
                                :if-exists :append)
          (write res :stream result))))))

(defvar *connection-thread*)
(defvar *repl-threads* '())

(defun connection-loop ()
  (loop
    (with-open-file (fifo #p"/tmp/miikfifo")
      (alexandria:when-let ((connection-dir (read-line fifo nil)))
        (push (bt:make-thread (lambda () (repl-loop connection-dir))) *repl-threads*)))))

(defun start ()
  "Starts listening for incoming connections from /tmp/miikfifo"
  (uiop:run-program '("mkfifo" "/tmp/miikfifo") :ignore-error-status t)
  (setf *connection-thread* (bt:make-thread #'connection-loop :name "miik-thread")))

(defun test3 ()
  (print "Hello"))

(defun stop ()
  "Stops listening for more connections, and kills all threads. Does not delete /tmp/miikfifo"
  (when (bt:thread-alive-p *connection-thread*)
    (bt:destroy-thread *connection-thread*))
  (loop until (null *repl-threads*)
        for thread = (car *repl-threads*)
        do (when (bt:thread-alive-p thread)
             (bt:destroy-thread thread))
        do (setf *repl-threads* (cdr *repl-threads*))))

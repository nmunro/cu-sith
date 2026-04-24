(defpackage cu-sith
  (:use :cl)
  (:export #:invalid-password
           #:invalid-user
           #:login
           #:logged-in-p
           #:logout
           #:msg
           #:setup
           #:user))

(in-package cu-sith)

(defparameter *user-p* nil)

(define-condition invalid-password (error)
  ((msg :initarg :msg :reader msg)))

(define-condition invalid-user (error)
  ((msg :initarg :msg :reader msg)))

(defun setup (&key user-p user-permissions)
  (setf *user-p* user-p))

(defun login (&key user password)
  (let ((user-obj (funcall *user-p* user)))
    (cond
        ((not user-obj)
            (error 'invalid-user :msg (format nil "No such user '~A'" user)))

        ((not (mito-auth:auth user-obj password))
            (error 'invalid-password :msg (format nil "Invalid Password for ~A" user)))

        (t
            (setf (gethash :user ningle:*session*) user-obj)))))

(defun logged-in-p ()
  (handler-case
    (gethash :user ningle:*session*)
    (type-error ()
      nil)))

(defun user ()
  (logged-in-p))

(defun logout ()
  (remhash :user ningle:*session*))

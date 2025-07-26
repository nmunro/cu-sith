(defpackage cu-sith
  (:use :cl)
  (:export #:auth
           #:invalid-password
           #:invalid-user
           #:login
           #:logged-in-p
           #:logout
           #:msg
           #:roles
           #:role-p
           #:setup
           #:user-name))

(in-package cu-sith)

(defparameter *user-p* nil)
(defparameter *user-roles* nil)

(define-condition invalid-password (error)
  ((msg :initarg :msg :reader msg)))

(define-condition invalid-user (error)
  ((msg :initarg :msg :reader msg)))

(defun setup (&key user-p user-roles)
  (setf *user-p* user-p)
  (setf *user-roles* user-roles))

(defun login (&key user password)
  (let ((user-obj (funcall *user-p* user)))
    (cond
        ((not user-obj)
            (error 'invalid-user :msg (format nil "No such user '~A'" user)))

        ((not (mito-auth:auth user-obj password))
            (error 'invalid-password :msg (format nil "Invalid Password for ~A" user)))

        (t
            (setf (gethash :user ningle:*session*) user-obj)
            (setf (gethash :roles ningle:*session*) (funcall *user-roles* user-obj))))))

(defun logged-in-p ()
  (handler-case (gethash :user ningle:*session*)
    (type-error () nil)))

(defun user-name ()
  (logged-in-p))

(defun roles ()
  (gethash :roles ningle:*session*))

(defun role-p (role)
  (member role (roles) :test #'equal))

(defun logout ()
  (remhash :user ningle:*session*)
  (remhash :roles ningle:*session*))

(defun auth (&rest roles)
  (intersection roles (roles) :test #'equal))

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
(defparameter *user-pass* nil)
(defparameter *password-p* nil)
(defparameter *user-roles* nil)

(define-condition invalid-password (error)
  ((msg :initarg :msg :reader msg)))

(define-condition invalid-user (error)
  ((msg :initarg :msg :reader msg)))

(defun setup (&key user-p user-pass password-p user-roles)
  (setf *user-p* user-p)          ; Returns a generalised boolean representing if the user exists
  (setf *user-pass* user-pass)    ; Returns the hashed password of a given user
  (setf *password-p* password-p)  ; Returns a generalised boolean representing if a password matches its hash
  (setf *user-roles* user-roles)) ; Returns a list of roles of a given user

(defun login (&key user password)
  (cond
    ((not (funcall *user-p* user))
      (error 'invalid-user :msg (format nil "No such user ~A" user)))

    ((not (funcall *password-p* :plain password :hashed (funcall *user-pass* user)))
      (error 'invalid-password :msg (format nil "Invalid Password for ~A" user)))

    (t
      (setf (gethash :username ningle:*session*) user)
      (setf (gethash :roles ningle:*session*) (funcall *user-roles* user)))))

(defun logged-in-p ()
  (handler-case (gethash :username ningle:*session*)
    (type-error () nil)))

(defun user-name ()
  (logged-in-p))

(defun roles ()
  (gethash :roles ningle:*session*))

(defun role-p (role)
  (member role (roles) :test #'equal))

(defun logout ()
  (remhash :username ningle:*session*)
  (remhash :roles ningle:*session*))

(defun auth (&rest roles)
  (intersection roles (roles) :test #'equal))

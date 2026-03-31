(defpackage cu-sith
  (:use :cl)
  (:export #:has-permissions-p
           #:invalid-password
           #:invalid-user
           #:login
           #:logged-in-p
           #:logout
           #:msg
           #:permissions
           #:permission-p
           #:setup
           #:user))

(in-package cu-sith)

(defparameter *user-p* nil)
(defparameter *user-permissions* nil)

(define-condition invalid-password (error)
  ((msg :initarg :msg :reader msg)))

(define-condition invalid-user (error)
  ((msg :initarg :msg :reader msg)))

(defun setup (&key user-p user-permissions)
  (setf *user-p* user-p)
  (setf *user-permissions* user-permissions))

(defun login (&key user password)
  (let ((user-obj (funcall *user-p* user)))
    (cond
        ((not user-obj)
            (error 'invalid-user :msg (format nil "No such user '~A'" user)))

        ((not (mito-auth:auth user-obj password))
            (error 'invalid-password :msg (format nil "Invalid Password for ~A" user)))

        (t
            (setf (gethash :user ningle:*session*) user-obj)
            (setf (gethash :permissions ningle:*session*) (funcall *user-permissions* user-obj))))))

(defun logged-in-p ()
  (handler-case
    (gethash :user ningle:*session*)
    (type-error ()
      nil)))

(defun user ()
  (logged-in-p))

(defun permissions ()
  (gethash :permissions ningle:*session*))

(defun permission-p (permission)
  (member permission (permissions) :test #'equal))

(defun logout ()
  (remhash :user ningle:*session*)
  (remhash :permissions ningle:*session*))

(defun has-permissions-p (&rest permissions)
  (intersection permissions (permissions) :test #'equal))

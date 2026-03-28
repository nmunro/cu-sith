(defpackage cu-sith
  (:use :cl)
  (:export #:has-roles-p
           #:invalid-password
           #:invalid-user
           #:login
           #:login-required
           #:logged-in-p
           #:logout
           #:msg
           #:roles
           #:role-p
           #:setup
           #:user))

(in-package cu-sith)

(defparameter *user-p* nil)
(defparameter *user-roles* nil)
(defparameter *login-redirect* nil)

(define-condition invalid-password (error)
  ((msg :initarg :msg :reader msg)))

(define-condition invalid-user (error)
  ((msg :initarg :msg :reader msg)))

(defun setup (&key user-p user-roles login-redirect)
  (setf *user-p* user-p)
  (setf *user-roles* user-roles)
  (setf *login-redirect* login-redirect))

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
  (handler-case
    (gethash :user ningle:*session*)
    (type-error ()
      nil)))

(defun user ()
  (logged-in-p))

(defun roles ()
  (gethash :roles ningle:*session*))

(defun role-p (role)
  (member role (roles) :test #'equal))

(defun logout ()
  (remhash :user ningle:*session*)
  (remhash :roles ningle:*session*))

(defun has-roles-p (&rest roles)
  (intersection roles (roles) :test #'equal))

(defun request-redirect-path ()
  "Returns path + query string suitable for use as a ?next= value."
  (let ((path  (lack/request:request-path-info ningle:*request*))
        (query (lack/request:request-query-string ningle:*request*)))
    (if (and query (plusp (length query)))
        (format nil "~A?~A" path query)
      path)))

(defun login-required (handler)
  (lambda (params)
    (if (logged-in-p)
        (funcall handler params)
        (ingle:redirect (format nil "~A?next=~A" *login-redirect* (quri:url-encode (request-redirect-path)))))))

(defpackage cu-sith/tests/main
  (:use :cl
        :cu-sith
        :rove))
(in-package :cu-sith/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cu-sith)` in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
  (format t "Testing~%")
    (ok (= 1 1))))

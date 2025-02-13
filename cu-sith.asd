(defsystem "cu-sith"
  :version "1.0.0"
  :author "nmunro"
  :license "BSD3-Clause"
  :depends-on (:ningle)
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description "An authentication workflow system for ningle"
  :in-order-to ((test-op (test-op "cu-sith/tests"))))

(defsystem "cu-sith/tests"
  :author "nmunro"
  :license "BSD3-Clause"
  :depends-on ("cu-sith"
               :rove)
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for cu-sith"
  :perform (test-op (op c) (symbol-call :rove :run c)))

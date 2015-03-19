;; Custom Org TODO states
                                        ;     (setq org-todo-keywords
                                        ;       '((sequence "TODO(t)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")))
                                        ; [[info:org#Tracking%20TODO%20state%20changes][info:org#Tracking TODO state changes]]

                                        ;    (setq org-todo-keywords
                                        ;       '((sequence "TODO(t)" "DOING(s!)" "|" "DONE(d!)" )))



;;   If you would like a TODO entry to automatically change to DONE when
;;all children are done, you can use the following setup:
;;
;;     (defun org-summary-todo (n-done n-not-done)
;;       "Switch entry to DONE when all subentries are done, to TODO otherwise."
;;       (let (org-log-done org-log-states)   ; turn off logging
;;         (org-todo (if (= n-not-done 0) "DONE" "TODO"))))
;;
;;     (add-hook 'org-after-todo-statistics-hook 'org-summary-todo)



;; Setting Colours (faces) for todo states to give clearer view of work
                                        ;(setq org-todo-keyword-faces
                                        ;  '(("TODO" . org-warning)
                                        ;   ("DOING" . "yellow")
                                        ;   ("BLOCKED" . "red")
                                        ;   ("REVIEW" . "orange")
                                        ;   ("DONE" . "green")
                                        ;   ("ARCHIVED" . "blue")))


                                        ; Friday, 13. September 2013
                                        ; Possibly create an org-table-create-or-convert-from-region shortcut


                                        ; Friday, 13. September 2013 add eding

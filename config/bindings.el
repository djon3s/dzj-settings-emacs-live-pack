;; Place your bindings here.

;; For example:
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; Easier to look up source code for elisp function.
;; Rather than bind M-h C-f to the FAQ.
(global-set-key (kbd "M-h C-f") 'find-function)

;; To pull up magit status
(global-set-key (kbd "C-c g s") 'magit-status)

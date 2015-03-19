;;;;;;;;;;;;;;;;;;;;;;;
;; Org-mode bindings ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; for org-mode global link grabbing awesome
(global-set-key (kbd "C-c L") 'org-insert-link-global)
(global-set-key (kbd "C-c o") 'org-open-at-point-global)
(global-set-key (kbd "C-c C-l") 'org-store-link)

;; Bind org-capture key
;; Todo : if there's a todo item, make it current git repo specific?
(define-key global-map "\C-cc" 'org-capture)

;; To add key to access org-mode agenda globally
(define-key global-map (kbd "C-c a") 'org-agenda)

;; To pull up magit status
(global-set-key (kbd "C-c g s") 'magit-status)
;; key to stage item in list
(add-hook 'magit-mode
          (lambda ()
            (local-set-key (kbd "C-c g a") 'magit-stage-item)))

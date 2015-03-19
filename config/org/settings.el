;; Dan's org-mode customizations

;;;;;;;;;;;;;;
;; Settings ;;
;;;;;;;;;;;;;;

;; Set the org directory
(setq org-directory "~/org/")

;; Org capture, for grabbing shit to remember and deal with later
(setq org-default-notes-file (concat org-directory "/notes.org"))

(require 'org-drill)

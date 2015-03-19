;; Dan's start-up settings

;; Check if emacs is running as a server, if not, run the server.
(if (not (boundp 'server-process))
    (server-start))

;; Persist Emacs Sessions
;; with the server/daemon - hopefully this means the only way to close a
;; file is to explicitly C-x k it (not C-c C-x) Documentation at
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Saving-Emacs-Sessions.html
(desktop-save-mode 1)

;; Saves command histories between shutdowns
(savehist-mode 1)

;; On start, make an org mode scratch buffer
(switch-to-buffer (get-buffer-create (generate-new-buffer-name "*org-scratch*")))
(insert "Scratch buffer with org-mode.\n\n")
(org-mode)

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

;; Require stuff from our libs
(require 'ox-anki)
(require 'i3)
(require 'i3-integration)

;; Get rid of annoying tendency for ido to require you to visit
;; frame to see buffer.
(setq ido-default-buffer-method 'selected-window)

;; Open links in Eww browser.
(setq browse-url-browser-function 'eww-browse-url)
;;; ... and make links open in a new window with buffername that's from url
(defadvice eww-render (after set-eww-buffer-name activate)
  (rename-buffer (concat "*eww-" (or eww-current-title
                                     (if (string-match "://" eww-current-url)
                                         (substring eww-current-url (match-beginning 0))
                                       eww-current-url)) "*") t))

;; Add eldoc like mode for clojure...
;(add-hook 'cider-mode-hook #'cljdoc)

;; Fri 17 Jul 2015
;; Work around to allow ansi-term / term mode to have tab completion.
;; As per... http://stackoverflow.com/questions/18278310/emacs-ansi-term-not-tab-completing
(add-hook 'term-mode-hook (lambda()
        (setq yas-dont-activate t)))

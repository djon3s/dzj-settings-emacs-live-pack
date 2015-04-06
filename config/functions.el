;; Sudo save - enables us to open files with root only write
;; permissions with emacsclient and not have emacsclient get confused
;; it's the sudo user opening with sudo emacsclient etc
;;
;; From http://www.emacswiki.org/emacs/SudoSave
;;
(defun sudo-save ()
  (interactive)
  (if (not buffer-file-name)
      (write-file (concat "/sudo:root@localhost:" (ido-read-file-name "File:")))
    (write-file (concat "/sudo:root@localhost:" buffer-file-name))))

;; I often forget the name of fill-column or fill-region
;; This is because I often search for "line wrap"
(defun line-wrap 'fill-region)

;; Useful for saving a list of open buffers if you don't want
;; to have desktop save load all those other settings etc
(defun copy-open-files ()
  "Add paths to all open files to kill ring"
  (interactive)
  (kill-new (mapconcat 'identity
                       (delq nil (mapcar 'buffer-file-name (buffer-list)))
                       "\n")))

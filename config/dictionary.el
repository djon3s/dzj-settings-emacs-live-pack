;;; For using with eding the dictionary.

(live-add-pack-lib "eding") ;; does this do load-path?
;; (setq load-path
;;       (append (list nil "~/malaparte_old/.eding")
;;               load-path))
(require 'eding)

;; Add hook for looking up dictionary words quickly
(global-set-key (kbd "C-c C-w") 'dictionary-lookup-definition)

;; Set dictionary location (this will over-ride something in
;; lib/eding/eding.el I assume.
;; TODO. add Oxford? Like GoldenDict?

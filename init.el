;; User pack init file
;;
;; Use this file to initiate the pack configuration.
;; See README for more information.

;; Load libs
(live-add-pack-lib "org-anki")
(live-add-pack-lib "i3-emacs")

;; Load configs
(live-load-config-file "startup.el")
(live-load-config-file "bindings.el")
(live-load-config-file "functions.el")
(live-load-config-file "org/settings.el")
(live-load-config-file "org/capture-templates.el")
(live-load-config-file "org/export-templates.el")
(live-load-config-file "org/bindings.el")
(live-load-config-file "dictionary.el")

;; Some custom org-capture templates
(setq org-capture-templates
      '(
        ("t" "Todo - project" entry
         (file+headline
          (progn
            (shell-command (concat "touch " (ffip-project-root) "todo.org"))
            (concat (ffip-project-root) "todo.org"))
 "Tasks")
         "* TODO %?\n  %i\n  %a")

        ("T" "Todo" entry (file+headline "~/org/todo.org" "Tasks")
         "* TODO %?\n  %i\n  %a")

        ("e" "Emacs" entry (file+headline "~/org/learning/emacs_commands.org" "Emacs Commands"))

        ("w" "Words" entry (file+headline "~/org/learning/new_words.org" "New words"))

        ("u" "Unix" entry (file+headline "~/org/learning/unix_commands.org" "Unix Commands"))

        ("c" "C" entry (file+headline "~/org/learning/c_lang.org" "C Syntax"))

        ("g" "Git" entry (file+headline "~/org/learning/git_commands.org" "Git Commands"))

        ("n" "Networking" entry (file+headline "~/org/learning/networking.org" "Networking"))

	("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")

	 ("b" "Bug or Error noticed to follow up with bugtracker." entry (file+headline "~/org/bugs.org" "Bugs and Errors noticed to follow up."))))

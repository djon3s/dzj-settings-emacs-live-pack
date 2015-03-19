;;;;;;;;;;;;;;;;;;;;;;;;;;-*-Emacs-Lisp-*-;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                      ;
;;; eding - Ding dictionary lookup routines/SRS System for Emacs         ;
;;;                                                                      ;
;;; Copyright © Steve Lipa 2007,2008                                     ;
;;;                                                                      ;
;;; These routines are free software; you can redistribute them          ;
;;; and/or modify them under the terms of the GNU Library General Public ;
;;; License as published by the Free Software Foundation; either         ;
;;; version 2 of the License, or (at your option) any later version.     ;
;;;                                                                      ;
;;; This software is distributed in the hope that it will be useful,     ;
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of       ;
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    ;
;;; Library General Public License for more details.                     ;
;;;                                                                      ;
;;; You should have received a copy of the GNU Library General Public    ;
;;; License along with Emacs; if not, write to the                       ;
;;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,         ;
;;; Boston, MA 02111-1307, USA.                                          ;
;;;                                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; SYNOPSIS
;;;
;;; eding can be used to look up words in Frank Richter's Ding
;;; German-English dictionary, to store selected words in a quiz file, and
;;; to quiz the user using an SRS challenge-response system.  The system
;;; uses sorting routines specifically designed for UTF-8 German text that
;;; may be of interest independently.
;;;
;;; PREREQUISITES
;;;
;;; The main thing you need is Frank Richter's Ding dictionary.
;;;
;;; Last time I checked the Ding dictionary was available at
;;;
;;;             http://www-user.tu-chemnitz.de/~fri/ding/
;;;
;;; N.B. You only need the dictionary file. Usually there is a production
;;; version in a directory called de-en, and a development version in
;;; a directory called de-en-devel.  By the time you read this, things
;;; may have changed!  If so, you're on your own. The important thing
;;; is to get a file named de-en.txt.gz.  (So far, I have always used
;;; the one in de-en-devel, but I suspect the production version will
;;; work fine.)
;;;
;;; IMPORTANT NOTE: eding provides a routine called eding-check-dictionary
;;;                 DON'T PANIC if you run it and it finds problems in the
;;;                 dictionary. I normally find 40 to 50 problems in the
;;;                 dictionary but it doesn't keep eding from working!
;;;                 You don't need to run eding-check-dictionary.
;;;
;;; The only other thing you need is a version of Emacs that can
;;; handle UTF-8 encoding and the german-postfix input method.  
;;; Unless you are running a very old version of Emacs, you are probably
;;; all set, so you can skip down to INSTALLATION below.  If you are
;;; running an old version of Emacs, or have trouble, read the next
;;; paragraph:
;;;
;;; Your Emacs installation *has* to be able to handle utf-8 file encoding
;;; and needs to be able to handle the german-postfix input method.  If you
;;; are using an older version of Emacs, you may need to add a package
;;; containing Emacs lisp code for internationalization.  Linux
;;; distributions using older versions of Emacs generally have packages for
;;; this.  Look for a package with a name something like
;;; emacs-leim-etc. for your distribution. THE FOLLOWING FIX IS EASY AND 
;;; ALWAYS WORKS: just go to http://ftp.gnu.org/pub/gnu/emacs/ to get 
;;; Emacs 22.1 or later. It is dead easy to compile and install and simply 
;;; has everything you need built right in!
;;;
;;; INSTALLATION
;;; 
;;; QUICK START FOR THE IMPATIENT: (N.B. C-c means "control-c" below)  
;;;  
;;;    1) create a directory named ~/.eding
;;;    2) gunzip de-en.txt.gz
;;;    3) move de-en.txt to ~/.eding/de-en-devel.de
;;;       -or- move it wherever you want and put a soft
;;;            link to it named de-en-devel.de in ~/.eding.
;;;            (for example if you put it in /tmp/de-en.txt,
;;;             type
;;;                     cd ~/.eding
;;;                     ln -s /tmp/de-en.txt de-en-devel.de
;;;             and you should be all set)
;;;    4) append the file eding.el that came with the eding
;;;       distribution to the end of your ~/.emacs file. 
;;;       (If you don't have a ~/.emacs file just copy eding.el
;;;        to ~/.emacs) 
;;;    5) start Emacs
;;;    6) type C-c d h to read the built-in manual
;;;
;;; ALTERNATIVE, MORE EFFICIENT INSTALLATION
;;;
;;;    1) do steps 1) through 3) above.
;;;    2) copy the eding.el file that came with the eding
;;;       distribution to ~/.eding/eding.el
;;;    3) start Emacs
;;;    4) type:  M-x byte-compile-file <RETURN>
;;;       then:  "~/.eding/eding.el" at the prompt
;;;    5) Add this to your ~/.emacs file:
;;;
;;;                (setq load-path
;;;                      (append (list nil "~/.eding")
;;;                              load-path))
;;;
;;;                (load "eding")
;;;
;;;      (If you don't have a ~/.emacs file, just create one
;;;       with those lines in it.)
;;;    6) Re-start Emacs
;;;    7) type C-c d h to read the built-in manual

(defvar eding-keymap 
  '(keymap                             ;  full command
    (97  . eding-quiz-addline)         ;    C-c d a
    (67  . eding-check-dictionary)     ;    C-c d C
    (100 . eding-lookup)               ;    C-c d d
    (68  . eding-soft-lookup)          ;    C-c d D
    (101 . eding-toggle-english)       ;    C-c d e
    (102 . eding-set-quizfile)         ;    C-c d f
    (104 . eding-help)                 ;    C-c d h
    (112 . eding-set-postfix)          ;    C-c d p
    (113 . eding-start-quiz)           ;    C-c d q
    (114 . eding-randomize-quizfile))  ;    C-c d r
  "keymap for the eding system.

This keymap sets the commands that will be used under
the prefix key \"C-c d\" which is defined below.  \"C-c d\"
was chosen to suggest Ding.")

(global-set-key "\C-cd" eding-keymap) ; binds the prefix key

(defvar eding-quiz-file "~/.eding/eding-quiz.de"
  "Filename for the quiz file used by eding.

This should always be set to some name that
ends with '.de' so that the auto-mode-alist 
causes it to be read in as a utf-8 file!
You can reset it using the eding-set-quizfile
command C-c d f")

;;; make sure the quizfile is always edited in fundamental mode
(let ((newmode (cons (concat (file-name-nondirectory eding-quiz-file) "$") 
		     `fundamental-mode)))
  (setq auto-mode-alist (cons newmode auto-mode-alist)))

(defvar eding-dictionary-file "~/.eding/de-en-devel.de"
  "Actual file name for eding dictionary file.

This should always be set to some name that
ends with '.de' so that the auto-mode-alist 
causes it to be read in as a utf-8 file!
You need to either copy your dictionary there or
change this variable to point to your actual file.")

(defvar eding-soft-match nil
  "Sets eding matching level.

This variable causes eding-lookup to show ALL of
the parts of any line that contains a match for the
target regexp.  Normally, eding-lookup only prints out
the parts of the line that match the regexp exactly.
By setting this to t, you can get eding-lookup to return
words that are directly related to the word you are
looking up.  This can give you a lot of insight 
about the word you are interested in if you are 
patient enough to deal with the extra output!")

(defvar eding-english nil
  "Boolean for choosing eding language preference.

Setting this variable to t causes eding-lookup to 
assume that you speak German and want eding-lookup 
to list the English part of the definitions first.  
You can toggle this variable with the command C-c d e
(eding-toggle-english) ")

;;; this dolist adds elements to the auto-coding-alist 
;;; associative array to cause Emacs to assume ding-
;;; related files and buffers are stored in utf-8
;;; format.
(dolist (x '(("^*ding*$" . utf-8)
	     ("^*eding*$" . utf-8)
	     ("^*eding-help*$" . utf-8)
	     ("^*eding-quiz*$" . utf-8)
	     ("\\.de$" . utf-8)))
  (setq auto-coding-alist (cons x auto-coding-alist)))

(defun eding-help ()
  "Prints detailed help for the eding system in a temporary buffer."
  (interactive)
  (save-selected-window
    (with-output-to-temp-buffer "*eding-help*"
    (let ()
      (princ "We start with the key bindings for ding-related commands,
but there is a lot of information that follows the table:

Key      Function                  Description
------------------------------------------------------------------
C-c d d: eding-lookup	      	   Opens the dictionary, creates a
         		      	   buffer *eding* and makes it current.
         		      	   Prompts for a \"String-Aufdruck\" 
                                   which is used as a regular expression
                                   in a regular expression search.
C-c d D: eding-lookup-soft    	   Same as C-c d d, but locally sets
         		      	   the variable eding-soft-lookup which
         		      	   causes eding-lookup to print out 
         		      	   results from *related* words in 
         		      	   addition to words that directly
         		      	   match.   Vortrefflich!
C-c d e: eding-toggle-english 	   Toggles the eding-english variable.
         		      	   This variable is nil by default.
         		      	   When non-nil, it makes the routines
         		      	   act as if the user were German.
C-c d f: eding-set-quizfile   	   Sets the filename used to store
         		      	   lines that can be used in a quiz
         		      	   at a later date.   You *need* to
         		      	   either set this or create a ~/.eding
         		      	   directory if you want to use the
         		      	   quiz capability.
C-c d a: eding-quiz-addline   	   Causes the line that the cursor is on
         		      	   to be appended to the quiz file.
         		      	   If the mark is active any line that
         		      	   is part of the region is added.
C-c d q: eding-start-quiz     	   Starts a quiz made up from the lines
         		      	   that were previously saved in the
         		      	   currently-active quiz file.
C-c d p: eding-set-postfix    	   Explicitly sets input method to
         		      	   german-postfix.
C-c d C: eding-check-dictionary    Runs a check on the dictionary
                                   file.
C-c d r: eding-randomize-quizfile  Randomizes the due dates of
                                   challenges.  Why you would want
                                   to do this is explained in the
                                   help string.
C-c d h: eding-help	      	   Prints out a list of ding-related
         		      	   commands, the corresponding
         		      	   keystrokes, and general help.

You can get detailed help on most of these commands by
typing \"C-h f\" followed by the command name. The easy way 
to remember these (and most Emacs key bindings in general) 
is to realize that Emacs key bindings can consist of 
\"prefixes\" and command keys.  Think of C-c d as the \"Dictionary 
prefix,\" the \"Deutsch prefix,\" or even the \"Ding prefix.\"
C-c is the standard first character for user-defined commands. 
\"d\" means Dictionary, Deutch, or Ding.  Then each command is 
mnemonic. \"a\" for addline, \"h\" for help, etc. \"d\" was originally 
chosen to remind me of \"Ding lookup.\"  It is by far the most
often-used command and the double-d at the end makes it easy to
type quickly.

The rest of this help file explains the system in a general sense 
to give you a feel for using it, and describes the use of the 
eding-start-quiz function in some detail because it is, after all, 
the main reason that the system exists in the first place.

First, you can search the dictionary using eding-lookup and 
eding-soft-lookup.  These routines prompt you for a regular 
expression (Explained below if you don't know what this means. 
For now just think of it as a search string.) and print out 
parsed lines from the dictionary that match the regular expression. 
eding-lookup only prints out lines that match while eding-soft-lookup
also includes lines that don't match but are related to lines that 
do match.  The soft match can be a good way to get a better feel 
for the use of a word and to discover synonyms for words. By default,
the search searches both the German and English parts of the line,
but you can easily change this using regular expression syntax.

eding search strings are used as regular expressions for searching
the dictionary.  A regular expression is a string of characters
that describes a text pattern.  The simplest regular expressions
are just strings of letters and numbers.  A simple string like
\"Klo\" will match any line that contains the sequence of letters
\"Klo.\" (or \"klo\" for that matter...)  So if you don't want to 
bother learning about regular expressions, the program will work 
fine for you if you just type words in as search strings.

More complicated regular expressions include elements that match
word boundaries, the beginning or end of the line, etc.  They *can*
be quite complicated, but very simple regular expressions are all
you need to make your eding searches more precise. The following
table and examples will tell you all you really need to know: 
 
Rule 1: \\d (or \\D) as the first thing in your search string 
        means only look at the German side.  \\e (or \\E) as 
        the first thing means only look at the English side. 
        (N.B. this is an eding extension to regular expression 
        syntax! It is not normally available outside eding.)
Rule 2: By default regular expressions don't care much about
        case.  If you search for \"fratz\" you will get both
        fratzenhaft and Fratze. (plus some other stuff...)
Rule 3: ^ as the first thing (other than an optional \\e or
        \\d) in your search string matches the beginning of 
        the line.
Rule 4: $ as the last thing in your search string matches 
        the end of the line. You can't use it anywhere else.
        (In eding this is probably the only reason you would
        use it anyway. As of this writing there is only one
        dollar sign in the Ding dictionary and I'll bet you
        already know where it is.)
Rule 5: \\b matches a word boundary
Rule 6: [xyz] matches the character x, y, or z. (You can put
        any list of charaters you want in the brackets!)
        If the first character in the list is a caret ('^')
        it means \"match any character NOT in this list.\"
Rule 7: [^ ]* matches zero or more characters that ARE NOT
        spaces.  The asterisk means \"match zero or more
        of the thing right before me.\"  N.B.: As of this
        writing, there are NO OCCURANCES of the caret in the 
        Ding dictionary.  (Not even in the definition of 
        \"Einschaltungszeichen!\") So the only reasons you 
        should use it are for negating a bracketed character 
        list or as described in Rule 3 above. 
Rule 8: Period ('.') is a special character in regular 
        expressions which matches ANY character.  So if you
        want to search for something that has a period in
        it (the dictionary has many abbreviations in it!)
        you need to \"escape\" the period with a backslash.
        If you want to know what \"d.h.\" stands for, you 
        need to search for \"d\\.h\\.\" or you will get about
        two thousand results including daheim, daher, etc. 

Examples:

SEARCH STRING     FINDS LINES THAT
----------------------------------------------------------
streng            have German or English words containing 
                  \"streng\"   
\\dstreng          have German words containing \"streng\"
\\estreng          have English words containing \"streng\"
\\d^streng         have a German side starting with \"streng\"
\\d\\bstreng        have German words that start with \"streng\"
\\dstreng\\b        have German words that end with \"streng\"
                  (Note that most German entries end with 
                  a designation of gender or part of speech,
                  e.g. {m} to denote a masculine noun.  Thus
                  if you are looking for German words that 
                  end a certain way it is much better to use
                  \\b than it is to use $ at the end!)
\\d\\bkla[^ ]*ch\\b  have German words that start with \"kla\" 
                  and end with \"ch\" (like Kladderadatsch!)
\\d^kl[äü]         have a German side that starts with \"klä\"
                  or \"klü\"

As you can see, regular expressions are very powerful, and
we've only scratched the surface here. You can learn more about 
them by reading the Emacs documentation.

The lines found by the lookup routines are printed in 
alphabetical order in a special buffer named *eding* which is 
created if it doesn't already exist.

The sorting routine emulates the approach used by my Brockhaus 
dictionary when alphabetizing. In the Brockhaus approach, 'ä' 
is essentially equivalent to 'a' but follows 'a' if the words 
are otherwise the same alphabetically.  Thus träge follows 
trage but Tragetasche follows Trägerwelle. 

Once you have some lines in the *eding* buffer, you can
automatically add lines to a quiz file using the function
eding-quiz-addline.  Just move the cursor to a line you
want to add and type \"C-c d a.\" This copies the line
to your quiz file.  See the documentation for this 
function (by typing \"C-h f <return> eding-quiz-addline\")
for tips on improving your quiz file.

Once you have a bunch of lines in your quiz file, you
can quiz yourself periodically to ingrain the words 
you have learned into your vocabulary. It's pretty 
amazing how fast and well you can learn a lot of words
if you do just one quiz session (usually about 20 minutes)
each day.  You start the quiz by typing \"C-c d q.\"

The quiz routine implements an SRS system which schedules
challenges based on your past performance in responding to
them.  The system is designed to rate your performance 
based on speed of response. The idea is simple: The computer 
prints out a challenge and starts a timer.  Once you have 
read the challenge and stated the correct response out loud, 
you hit return and the computer stops the timer.  Since the
challenge generally has at most a handful of words or phrases
to read and respond to, the system assumes that any response 
that takes more than 5 seconds to respond to is a problem for
you. (This value is actually variable and you can control
it by modifying the value of prob-thresh in the code.)
Any challenge that gives you trouble is automatically 
added to a list of challenges that will be re-presented 
after you have gone through the entire quiz once.  These 
problem challenges will be re-presented over and over until 
you can respond to them in less than 5 seconds.

The program automatically keeps track of your performance
and stores it in the quiz file.  For each quiz session, 
however, only your initial response to a challenge is stored.
The secondary phase where you are presented with problem
challenges is just there to help you learn the information
so you can do better next time.

Here are some important things to know about how the quiz
works:

  1) The computer measures your response time, but you
     can overrule this measurement by typing in a number.
     This is really meant for interruptions like a 
     ringing phone or crying child.  It is probably 
     better not to override the data for any other 
     reason except:

  2) If you override the data by typing any number that
     is greater than 10 you will reset the challenge.
     This resets the iteration number of the challenge
     to 0 and the average score to 11.0, which assures
     that the question will be asked every session 
     until you get the average score below 3.0.
     (also variable.  See crit-thresh in the code)

  3) Yes, that's right. 3.0.  This is because the system
     also considers any challenge that takes you more than
     3 seconds to answer (on average) to be a problem for 
     you. (Remember, this is language, you need to get it
     virtually instantly to be fluent!)  The scheduling
     algorithm always includes any words that have
     average scores over crit-thresh even if it bumps off
     challenges that are due.

  4) The quiz is set up assuming you have a pretty big
     quiz file.  By default it assumes you will want to
     be challenged about 250 times in a session, which
     usually takes about 15 to 20 minutes.

  5) The program makes sure you see all of your challenges
     on a regular basis, but is skewed to show you the
     ones with the highest scores (high being bad here,
     since it is your average response time) more often.
     However, if you do multiple sessions in one day
     it will not re-present challenges that were
     presented within the previous six hours.

  6) For best results in setting up your quiz file, see 
     the help for eding-quiz-addline!

  7) You don't need to use the standard quiz file location
     and/or you can have more than one. The currently active 
     quiz filename can be found by typing \"C-h v eding-quiz-file.\"  
     You can set this variable using the command 
     \"C-c d f\" (eding-set-quizfile). N.B.: quiz files
     *must* use utf-8 coding for the program to work right!

  8) By default the system assumes that the user is an 
     English speaker learning German unless the variable 
     eding-english is set non-nil.  As of this writing, 
     setting eding-english non-nil has not been extensively
     tested.  See eding-toggle-english, but if you are a
     German that wants to use the system, it is probably
     better to change the defvar for eding-english....

  9) There is more detailed information about customization
     in the comments to the source code.

 10) If you have gotten this far you must be very dedicated,
     so here are a few more pro tips:

     a) Read German mystery/detective novels and romance novels. 
        These have lots of dialog and provide examples of how 
        people really talk in common situations so they help
        develop your Sprachgefühl. The first couple will 
        probably take a while to get through, but once you have 
        read about a half dozen you will be able to read just 
        about anything with just a little help from eding, and
        your reading speed will be much faster.  Also, these
        are easy to find at very low prices at used book stores!

     b) Keep a half-dozen Post-it notes on the inside back 
        cover of any novel you are reading.  Whenever you 
        come to a word or phrase that you aren't sure about, 
        mark it with a Post-it note. Unless it is critically
        important for you to know exactly what the word
        means, try to figure it out from the context and
        delay looking it up. Wait and see if something later
        in the text helps clue you in. You may learn the
        language more throuroughly if you absorb it rather
        than treat it as a table-lookup exercise.  
        Later, when you have amassed a few Post-its, look 
        them up with eding and add them to your quiz file. 
        (The Post-it note trick is also useful for books 
        written in your native language!)   

     c) Read http://www.heute.de every day, with an Emacs
        window open under your browser so you can look up and 
        add interesting words to your quiz file on the fly. This
        site provides lots of examples of contemporary usage
        and is written in simple language. 

     d) There is a website called redensarten-index
        (http://www.redensarten-index.de/suche.php) that
        is great for looking up idioms you might come
        across.")
      (message "To remove help window try C-x 1.  To scroll try ESC C-v.")
      ))))

(defun eding-remove-white (instr)
  "Removes leading and trailing whitespace from string INSTR."
  nil
  (let (ss se)
    (string-match "^\\(\\s *\\)" instr 0)
    (setq ss (match-end 0))
    (string-match "\\(\\s *\\)$" instr 0) 
    (setq se (match-beginning 0))
    (if (> se ss)
	(substring instr ss se)
      (substring instr 0 0))))

(defun eding-next-token (istr)
  "Gets the next token from a string ISTR.

Tokens are: any string, the character |, the character pair ::,
and any semicolon not surrounded by parentheses.  These are
the elements that make up a Ding dictionary line."
  nil
  (let ((lp0 0)    ; left paren level (lp1... reserved for {,<,[ )
	(ts 0)     ; token start
	(te 0)     ; token end
        (text nil) ; token is text 
	(cp 0)     ; current position
	(token nil))
    (while 
	(and (< cp (length istr))
	     (or 
	      (string= (substring istr cp (1+ cp)) " ")
	      (string= (substring istr cp (1+ cp)) "	")))
      (setq ts cp)
      (setq cp (1+ cp)))
    (while (not token)
      (cond
       ((equal cp (length istr))
	(setq token (cons istr nil)))
       ((string= (substring istr cp (1+ cp)) "|")
	(if text
	    (let ()
	      (setq te cp)
	      (setq token (cons (substring istr ts cp)
				(substring istr cp (length istr)))))
	  (setq token (cons '|
			    (substring istr (1+ cp) (length istr))))))
       ((string= (substring istr cp (1+ cp)) ":")
	(if text
	    (if (and
		 (< (1+ cp) (length istr))
		 (string= (substring istr (1+ cp) (+ 2 cp)) ":"))
		(let ()
		  (setq te cp)
		  (setq token (cons (substring istr ts cp)
				    (substring istr cp (length istr))))))
	  (and (< cp (length istr))
	       (string= (substring istr (1+ cp) (+ 2 cp)) ":")
	       (setq token (cons ':
				 (substring istr (+ 2 cp) (length istr)))))))
       ((string-match "(\\|<\\|\\[\\|{" (substring istr cp (1+ cp)))
	(setq text t)
	(setq lp0 (1+ lp0)))
       ((string-match ")\\|>\\|\\]\\|}" (substring istr cp (1+ cp)))
	(setq text t)
	(setq lp0 (1- lp0)))
       ((string= (substring istr cp (1+ cp)) ";")
	(cond 
	 ((and text (equal lp0 0))
	  (let ()
	    (setq te cp)
	    (setq token (cons (substring istr ts te)
			      (substring istr te (length istr))))))
	 ((and text (> lp0 0))
	  (let ()
	    (setq te cp)))
	 (t
	  (setq token (cons 's
			    (substring istr (1+ cp) (length istr)))))))
       (t
	(setq text t)
	(setq te cp))
       )
      (setq cp (1+ cp)))  
    token))

(defun eding-list-tokens (is)
  "This function returns a list of the tokens in a string IS.

The list is made up of strings and the following identifiers:
'|, ':, and 's, which correspond to the |, ::, and semicolon
tokens respectively."
  nil
  (let (token next (retval ()))
    (setq token (eding-next-token is))
    (setq retval (cons (car token) retval) next (cdr token))
    (while next
      (setq token (eding-next-token next))
      (setq retval (cons (car token) retval))
      (setq next (cdr token)))
    retval))

(defun eding-parse-line (dic-line)
  "Parses German and English bits of line DIC-LINE from dictionary file.

Returns a list which contains two lists that each have at
least one element.  The first list contains one element for
each |-delimited section of the German (pre ::) part of the
dictionary line (dic-line).  The second list contains the
corresponding elements for the English (post ::) part of 
the line.  Each |-delimited section can be further ;-delimited,
but there is not necessarily a one-to-one correspondence
at the ; level."
  nil
  (let ((tlist (eding-list-tokens dic-line))
	token delist enlist sublist current retval)
    (setq token (pop tlist))
    (while (not enlist)
      (cond
       ((stringp token)
	(setq current (cons token current)))
       ((equal token '|)
	(setq sublist (cons current sublist))
	(setq current ()))
       ((equal token ':)
	(if sublist
	    (let ()
	      (if current
		  (setq sublist (cons current sublist)))
	      (setq enlist (cons sublist enlist)))
	  (setq enlist (cons (cons current ()) enlist))))
       ((eq token nil) 
	(setq enlist (cons (cons current ()) enlist)))) 
      (setq token (pop tlist)))
    (setq current () sublist ())
    (while token
      (cond
       ((stringp token)
	(setq current (cons token current)))
       ((equal token '|)
	(setq sublist (cons current sublist))
	(setq current ())))
      (setq token (pop tlist)))
    (if sublist
	(let ()
	  (if current
	      (setq sublist (cons current sublist)))
	  (setq delist (cons sublist delist)))
      (setq delist (cons (cons current ()) delist)))
    (setq retval (cons (car enlist) delist))))

(defun eding-get-parsed-line (rawline)
  "Returns a list of strings that result from parsing a Ding line."
  nil
  (let 
      ((es (car (eding-parse-line rawline)))
       (ds (cadr (eding-parse-line rawline)))
       elist glist retlist
       )
    (while (and (setq elist (pop es)) (setq glist (pop ds))) 
      (dolist (e elist)
	(dolist (g glist)
	  (setq retlist 
		(cons (concat (eding-remove-white 
			       (if eding-english e g)) 
			      " <---> " 
			      (eding-remove-white
			       (if eding-english g e)))
		      retlist)))))
    retlist))

(defvar eding-utf-list
  '(
    (32 . 18)     ;space
    (97 . 20)	  ;a
    (65 . 20)	  ;A
    (2276 . 21)	  ;ä
    (2244 . 21)	  ;Ä
    (98 . 24)	  ;b     IF YOU WANT TO ADD OTHER CHARACTERS:
    (66 . 24)	  ;B     ----------------------------------------
    (99 . 26)	  ;c     To figure out the number that
    (67 . 26)	  ;C     corresponds to a particular letter
    (100 . 28)	  ;d     just put the character in the
    (68 . 28)	  ;D     quotes in this expression, put the
    (101 . 30)	  ;e     cursor right after the right parenthesis
    (69 . 30)	  ;E     and type C-x e:
    (102 . 32)    ;f
    (70 . 32)     ;F          (string-to-char " ")
    (103 . 34)    ;g
    (71 . 34)     ;G     Each element of the eding-utf-list is of the
    (104 . 36)    ;h     form (character-number . ranking) where lower
    (72 . 36)     ;H     ranking means the character comes earlier in
    (105 . 38)    ;i     the alphabet.
    (73 . 38)     ;I
    (106 . 40)    ;j
    (74 . 40)     ;J
    (107 . 42)    ;k
    (75 . 42)     ;K
    (108 . 44)    ;l
    (76 . 44)     ;L
    (109 . 46)    ;m
    (77 . 46)     ;M
    (110 . 48)    ;n
    (78 . 48)     ;N
    (111 . 50)    ;o
    (79 . 50)     ;O
    (2294 . 51)   ;ö
    (2262 . 51)   ;Ö
    (112 . 54)    ;p
    (80 . 54)     ;P
    (113 . 56)    ;q
    (81 . 56)     ;Q
    (114 . 58)    ;r
    (82 . 58)     ;R
    (115 . 60)    ;s
    (83 . 60)     ;S
    (2271 . 61)   ;ß
    (116 . 62)    ;t
    (84 . 62)     ;T
    (117 . 64)    ;u
    (85 . 64)     ;U
    (2300 . 65)   ;ü
    (2268 . 65)   ;Ü
    (118 . 68)    ;v
    (86 . 68)     ;V
    (119 . 70)    ;w
    (87 . 70)     ;W
    (120 . 72)    ;x
    (88 . 72)     ;X
    (121 . 74)    ;y
    (89 . 74)     ;Y
    (122 . 76)    ;z
    (90 . 76)     ;Z
    (48 . 78)     ;0
    (49 . 80)     ;1
    (50 . 82)     ;2
    (51 . 84)     ;3
    (52 . 86)     ;4
    (53 . 88)     ;5
    (54 . 90)     ;6
    (55 . 92)     ;7
    (56 . 94)     ;8
    (57 . 96)     ;9
    (40 . 98)     ;(
    (41 . 98)     ;)
    (91 . 98)     ;[
    (93 . 98)     ;]
    (60 . 98)     ;<
    (62 . 98)     ;>
    (58 . 98)     ;:
    (45 . 98)     ;-
    (95 . 98)     ;_
    (39 . 98)     ;'
    (38 . 98)     ;&    
    (43 . 98)     ;+
    (45 . 98)     ;-
    (46 . 98)     ;.
    (47 . 98)     ;/
    (92 . 98)     ;\
             )
  "Association list for German UTF string sorting.

This variable is used by  eding-char-p to service eding-german-p")
 
(defun eding-char-p (a b)
  "Tests two chars to see which is 'bigger.'

Returns positive if A comes before B in
alphabet.  If two letters are equal returns
zero.  Returns positive if B comes before A."
  nil
  (let ((x (cdr (assoc a eding-utf-list)))
	(y (cdr (assoc b eding-utf-list))))
    (cond
     ((and x y)
      (- x y))
     (x 5)
     (y -5)
     (t 0))))

(defun eding-german-p (a b)
  "Search predicate for sorting German strings!

Returns t if string A comes before string B"
  nil
  (let ((slen (if (> (length a) (length b))
		  (length b)
		(length a)))
	(idx 0)
	(not-done t)
	(retval 0))
    (while (and not-done (> slen idx))
      (setq retval (eding-char-p (string-to-char
				  (substring a idx (1+ idx))) 
				 (string-to-char
				  (substring b idx (1+ idx)))))
      (if (not (equal retval 0))
	  (setq not-done nil)
	(setq idx (1+ idx))))
    (cond
     ((and (equal retval 1) (> slen idx))
      (let ()
	(eding-german-p (substring a (1+ idx) slen) 
			(substring b (1+ idx) slen)))) 
     ((and (equal retval -1) (> slen idx))
      (let ()
	(eding-german-p (substring a (1+ idx) slen) 
			(substring b (1+ idx) slen)))) 
     ((or (equal slen idx) (> retval 0))
      nil)
     (t t))))

(defun eding-lookup ()
  "Looks up words in the Ding dictionary.

For complete documentation type \"C-c d h.\" The
section after the table of keybindings provides
a lot of detailed help on how to get the most out
of this function."
  (interactive)
  (if (not (equal "*eding*" (buffer-name)))
      (let ((gbuf (get-buffer-create "*eding*")))
	(switch-to-buffer gbuf)
	(erase-buffer)
	(set-input-method 'german-postfix)
	(eding-lookup))
    (let ((x ())
	  (dlist ())
	  (dsublist ())
	  (dfinal ())
	  (dbuf (get-buffer-create "*ding*"))
	  (gbuf (get-buffer-create "*eding*"))
	  (rescount 0)
          subtarget
	  target
	  (searchstring (read-from-minibuffer "String-Ausdruck erwartet: "
					nil nil nil nil nil t)))
      (save-excursion
	(set-buffer dbuf)
	(setq target searchstring)
	(if (< (point-max) 10000)
	    (let ()
	      (message "Warte mal.  Massiv Datei wird geladen...")
	      (insert-file-contents eding-dictionary-file nil nil nil t)
	      (message "Warte mal.  Massiv Datei wird geladen...fertig")))
	(goto-char (point-min))
        ;; This next section implements an extension to the regular
        ;; expression syntax. Basically, if you prefix your search with
        ;; \d or \D it will limit the search to the German half of the
        ;; line.  \e or \E will limit the search to the English side. 
	(let ((pd (if eding-english "^\\\\\\([Ee]\\)\\(.*\\)"
		    "^\\\\\\([Dd]\\)\\(.*\\)"))
	      (pe (if eding-english "^\\\\\\([Dd]\\)\\(.*\\)"  
		    "^\\\\\\([Ee]\\)\\(.*\\)"))
	      (pc "^\\^\\(.*\\)" )
	      (pdol "\\(.*\\)\\$$")
	      (caret nil)
	      (dollar nil)
	      (original_target target))
	  (if (string-match pd target)
	      (let ((st (substring target (match-beginning 2) (match-end 2))))
		(if (string-match pc st)
		    (setq caret t
			  st (substring st (match-beginning 1) 
					(match-end 1))))
		(if (string-match pdol st)
		    (setq dollar t
			  st (substring st (match-beginning 1) 
					(match-end 1))))
		(setq target st
		      subtarget (concat (if caret "^" "")
					st
					(if dollar "[ \\t]*<--->" 
					  ".*?<--->"))))
	    (if (string-match pe target)
		(let ((st (substring target (match-beginning 2) 
				     (match-end 2))))
		  (if (string-match pc st)
		      (setq caret t
			    st (substring st (match-beginning 1) 
					  (match-end 1))))
		  (if (string-match pdol st)
		      (setq dollar t
			    st (substring st (match-beginning 1) 
					  (match-end 1))))
		  (setq target st
			subtarget (concat (if caret "<--->[ \\t]" 
					    "<--->.*?")
					  st
					  (if dollar "[ \\t]*$" 
					    ""))))
	      (let ((st target))
		(if (string-match pc st)
		    (setq caret t
			  st (substring st (match-beginning 1) 
					(match-end 1))))
		(if (string-match pdol st)
		    (setq dollar t
			  st (substring st (match-beginning 1) 
					(match-end 1))))
		(setq target st
		      subtarget (concat (if caret "^[ \\t]*" 
					  "")
					st
					(if dollar "[ \\t]*$" 
					  "")))))))
	;;(message "target %s subtarget %s" target subtarget)
	(message "Ding Wörterbuch wird gesucht...")
	(while (re-search-forward target nil t)
	  (let ()
	    (setq x (cons (buffer-substring-no-properties 
			   (let ()
			     (beginning-of-line)
			     (point))
			   (line-end-position)) x ))
	    (end-of-line)))
      (message "Ding Wörterbuch wird gesucht...fertig")
      (if (equal x ())
	  (message (concat target " steht leider nicht in *ding*"))
	(let ((nomatch t))
	  ;; all but the last message concerning the number of
	  ;; results will blow by if there is a small number,
	  ;; so we don't waste time checking for non-plural
          ;; results until the last one. 
	  (message "%d Linien werden zergliedert..." (length x))
	  (switch-to-buffer gbuf)
	  (erase-buffer)
	  (dolist (dstr x)
	    (setq dsublist (cons (eding-get-parsed-line dstr) dsublist)))
	  (dolist (dlist dsublist)
	    (dolist (dstr dlist)
	      (setq dfinal (cons dstr dfinal))))
	  (message "%d Linien werden zergliedert...fertig" (length x))
	  (message "%d Ergebnisse werden geordnet..." (length dfinal))
	  (setq dfinal (sort dfinal 'eding-german-p))
	  (message "%d Ergebnisse werden geordnet...fertig" (length dfinal))
	  (goto-char (point-min))
	  (beginning-of-line)
	  (dolist (dstr dfinal)
	    (if (or (string-match subtarget dstr) eding-soft-match)
		(let ()
		  (insert (concat dstr "\n"))
		  (setq rescount (1+ rescount))
		  (setq nomatch nil)))
	    (beginning-of-line 2))
	  (if nomatch
	      (message (concat "\"" searchstring "\"" 
			       " geht nicht.  " 
			       "\"" target "\" klappt!"))
	    (if (eq rescount 1)
		(message "Ein Ergebnis")
	      (message "%d Ergebnisse insgesamt" rescount)))
	  (goto-char (point-min))))))))

(defun eding-set-quizfile (f)
  "This routine sets the variable eding-quiz-file.

Obviously you can also do it directly if you want to.
Probably the main reason to have this function is so
that you don't have to remember the name of the
variable!"
  (interactive "FNeue Datei: ")
  (let ()
    (setq eding-quiz-file f)
    (if (not (string-match "\\.de?" f))
	(message "Vorsichtig!  Dateiname soll mit \".de\" enden!"))))
 
(defun eding-quiz-addline ()
  "Adds the line that point is on to the current quiz file.

If the mark is active, this function adds all the lines
that contain any part of the region to the quiz file.
You can set the filename of the current quiz file using
the command \"C-c d f\" (eding-set-quizfile)

N.B.: eding-quiz-addline is great for adding lines to 
your quiz file, but it is also a great way for you to
add lines to your quizfile which you subsequently edit
to end up with a better quizfile.  Here is an example.
Say you look up \"Unterscheidung.\" One of the lines
you get will be:

Unterscheidung {f} <---> distinction

but you realize you already have this line in your
quiz file:

Unterschied {m} <---> distinction

I don't have a function for this (yet) but what I do in
this case is type \"C-c d a\" to add the first line
and then combine the two lines manually in the quiz
file to give me:

Unterschied {m}, Unterscheidung {f} <---> distinction (GIVE 2!)

Keep in mind that the *eding* buffer is editable. Thus
you can edit and/or combine lines as you look them up
*before* you type C-c d a to store them in the quiz file.

One final note:  I have a number of words in my quiz file 
that have (GIVE 5!) on them, but it can be difficult to blurt
out 5 words or phrases in less than three seconds, even if you 
know them well.  So until you have some experience using the 
system it is probably better not to make your challenges *too* 
challenging."
  (interactive)
  (save-excursion
    (let ((coding-system-for-write 'mule-utf-8-unix)
	  (qfbuf (find-file-noselect eding-quiz-file)))
      (if mark-active
	  (let ((p0 (min (mark) (point)))
		(p1 (max (mark) (point)))
		(tstamp (number-to-string (float-time)))
		cline
		numlines)
	    (setq numlines (count-lines p0 p1))
	    (goto-char p0)
	    (beginning-of-line)
	    (while (> numlines 0)
	      (setq p0 (point))
	      (setq p1 (line-end-position))
	      (setq cline (concat tstamp " 0 11.0 0.0 " 
				  (buffer-substring p0 (1+ p1))))
	      (save-excursion
		(set-buffer qfbuf)
		(goto-char (point-max))
		(insert cline)
		(save-buffer))
	      (beginning-of-line 2)
	      (setq numlines (1- numlines))
	      ))
	(let ((p0 (let ()
		    (beginning-of-line)
		    (point)))
	      (tstamp (number-to-string (float-time)))
	      cline
	      (p1 (line-end-position)))
	  (setq cline (concat tstamp " 0 11.0 0.0 " 
			      (buffer-substring p0 (1+ p1))))
	  (save-excursion
	    (set-buffer qfbuf)
	    (goto-char (point-max))
	    (insert cline)
	    (save-buffer))))
      (kill-buffer qfbuf))))

(defun eding-quiz-writeline (tstamp f1 f2 f3 qstr lineno)
  "Writes a ding quiz line to current buffer.

Parameters are:

  TSTAMP:      floating time stamp
  F1:          first hardness factor
  F2:          second hardness factor
  F3:          third hardness factor
  QSTR:        actual string
  LINENO:      line number; if nil, put at end"
  nil
  (let ((quizline (concat
		   (number-to-string tstamp) " "
		   (number-to-string f1) " "
		   (number-to-string f2) " "
		   (number-to-string f3) " "
		   qstr)))
    (if lineno
	(let ()
	  (goto-line lineno)
	  (kill-line)
	  (insert quizline))
      (let ()
	(goto-char (point-max))
	(insert (concat quizline "\n"))))))

(defun eding-quiz-line-elements (istr)
  "Finds elements of an eding quiz line in string ISTR.

Returns a list with the following elements in order:
   1) (float-time) of last update. (float - obviously!)
   2) first hardness factor (float)
   3) second hardness factor (float)  
   4) third hardness factor (float)
   5) actual string for this line."
  nil
  (let (retval)
    (string-match "^\\([[:digit:].]*\\)\\(\\s *\\)\\([[:digit:].]*\\)\\(\\s *\\)\\([[:digit:].]*\\)\\(\\s *\\)\\([[:digit:].]*\\)\\(\\s *\\)" istr 0)
    (setq retval (list
		  (string-to-number 
		   (substring istr (match-beginning 1) (match-end 1)))
		  (string-to-number 
		   (substring istr (match-beginning 3) (match-end 3)))
		  (string-to-number 
		   (substring istr (match-beginning 5) (match-end 5)))
		  (string-to-number 
		   (substring istr (match-beginning 7) (match-end 7)))
		  (substring istr (match-end 8) (length istr))))))

(defun eding-time-sort-p ( a b )
  "Simple predicate function for sorting quiz list.

This function is used to sort the master quiz list in 
order of ascending cf2 (time to answer a question)."
  nil
  (let ()
    (cond
     ((< (nth 1 a) (nth 1 b))
      nil)
     ((equal (nth 1 a) (nth 1 b))
      (if (< (nth 2 a) (nth 2 b))
	  nil
	t))
     (t t))))

(defun eding-start-quiz ()
  "Starts a quiz based on the current quiz file.

For complete documentation type \"C-c d h.\" The
section after the table of keybindings provides
a detailed explanation of how this function works."
  (interactive)
  (let ((quizlist ())          ; lines to be included in quiz
        (master ())            ; master list of quiz lines
	(rseed (random t))     ; random seed
	(lineno 1)             ; line counter
	(daylen 86400.0)       ; length of day in secs
	(sixhrs 21600.0)       ; six hours in seconds
	below4                 ; list of problem lines
	elements               ; list of elements on a quiz line
	qline                  ; holder for current line
	curq                   ; line number of current quest.
	cf1                    ; number of times question has
                               ; been presented to the user.
	cf2                    ; current avg for this question
	cf3                    ; reserved!
	cts                    ; current time stamp
        (now (float-time))     ; the time this routine is started
	minum                  ; numerical version of mi
	mi                     ; mi is a minibuffer input string
        totprompt              ; total prompt for grading
        asktime                ; time stamp when challenge placed
        anstime                ; time stamp when answer ready
        (response-time 0.0)    ; total of all response times
        (crit-thresh 3.0)      ; threshold for problem words
        (prob-thresh 4.99)     ; threshold for *real* problem words
        f1 f2 f3               ; hardness factors
        ival since             ; interval (days), days since last asked
	(dur 0.0)              ; number of seconds for answer
	ascore                 ; auto-score
        (hd 0.05)              ; multiplier for factor for figuring out
                               ; how long it takes just to *read* the
                               ; quiz line.  This is a "handicap" to
                               ; make autoscoring more fair for really
                               ; long quiz lines. 
        (qdue 0)               ; number of questions due to be asked
	(qival 0)              ; number of questions >= ival
	(abovet 0)             ; number of questions with avg score above 
                               ; threshold
        (qtot 0)               ; number of questions available in quiz file
	(qavg 0)               ; number of questions used to compute average
        qmean qstd             ; statistical variables
        (qsum 0)               ; running sum of quiz entry scores (for stats)
        (secs-per 5.0)         ; average number of seconds per question
        (secs-session 1250.0)  ; max. number of seconds you want
                               ; to spend per session
	(startprompt "Drück' mal die Eingabetaste wann Sie bereit sind!")
	(preprompt "Drück' mal die Eingabetaste wann Sie bereit sind."))
    (if (and (file-exists-p eding-quiz-file)
	     (file-writable-p eding-quiz-file))
	(save-excursion
	  (let (
		(qfbuf (find-file-noselect eding-quiz-file))  ; quiz data buf
		(gbuf (get-buffer-create "*eding*")))         ; "game" buffer
	    (set-buffer qfbuf)

            ;; Read through quiz file and figure out the average score and how
            ;; many total questions are available.  Create the master list 
            ;; which is a temporary list of the line numbers and their
            ;; associated average scores, and sort the list so that 
            ;; questions which on average take longer to answer come 
            ;; earlier.  If two questions have equal average scores, put
            ;; the one that was asked less recently in front of the one
            ;; at the end.  (Actually it is the reverse of this because
            ;; the dolist that uses the master list reverses the order.
            ;; In the final quizlist the order will come out right.)

	    (goto-char (point-min))
	    (while (< (point) (point-max))
	      (setq qtot (1+ qtot))
	      (setq qline (buffer-substring (point) (line-end-position)))
	      (setq elements (eding-quiz-line-elements qline))
	      (setq cts (nth 0 elements))
	      (setq cf1 (nth 1 elements))
	      (setq cf2 (nth 2 elements))
	      (setq since (- now cts))
              (setq master (cons (list lineno cf2 since) master))
	      (let ((idx cf1))
		(while (> idx 0)
		  (setq qstd (cons cf2 qstd))
		  (setq qsum (+ qsum cf2))
		  (setq qavg (1+ qavg))
		  (setq idx (1- idx))))
	      (setq lineno (1+ lineno))
	      (forward-line 1))
            (setq qmean (/ qsum (max qavg 1))) 
            (setq master (sort master 'eding-time-sort-p))

            ;; calculate standard deviation of the mean of the scores
            ;; in the quiz file.

	    (let ((tmpsum 0.0))
	      (dolist (i qstd)
		(setq tmpsum (+ tmpsum (* (- qmean i) (- qmean i)))))
	      (setq qstd (sqrt (/ tmpsum (length qstd)))))

            ;; OK, now we have all info necessary to create the final
            ;; quizlist.
            ;;
            ;; Go through the master list, adding the line number of any 
            ;; line meets the following criteria:
            ;;
            ;;    1) You have not reached the target number of
            ;;       questions yet.
            ;;    2) The question has not been asked recently
            ;;       enough.  Right now, "recently enough" means
            ;;       within the number of days it takes to go 
            ;;       through all the questions in the file if
            ;;       you ask (/ secs-session secs-per) questions
            ;;       every day.  Eventually, when the quiz list
            ;;       gets to be thousands of lines long, this
            ;;       will need to include the score, but I need
            ;;       more experience to figure out just how to
            ;;       approach this.
            ;;
            ;; Because the questions are pre-sorted, at least the
            ;; "target" number of questions will be asked, and
            ;; these will always be the ones with the worst average
            ;; scores.

	    (let ((ival (* qtot daylen (/ secs-per secs-session))))
	      (dolist (elt master)
		(if (and (>= (nth 1 elt) crit-thresh) (>= (nth 2 elt) sixhrs)) 
		    (setq abovet (1+ abovet)))
		(if (>= (nth 2 elt) ival)
		    (setq qival (1+ qival)))))
	    
	    (let ((target (/ secs-session secs-per))
		  (ival (* qtot daylen (/ secs-per secs-session)))
		  (excess (- (/ secs-session secs-per) abovet qival)))
	      (message (concat "ival: " (number-to-string ival)))
	      (dolist (elt master quizlist)
		(cond 
		 ((and (< qdue target) (>= (nth 1 elt) crit-thresh) 
		       (>= (nth 2 elt) sixhrs)) 
		  (let ()
		    (setq quizlist (cons (nth 0 elt) quizlist))
		    (setq qdue (1+ qdue))))
		 ((and (< qdue target) (>= (nth 2 elt) ival) 
		       (>= (nth 2 elt) sixhrs))
		  (let ()
		    (setq quizlist (cons (nth 0 elt) quizlist))
		    (setq qdue (1+ qdue))))
		 ((and (< qdue target) (>= (nth 1 elt) 10.99))
		  (let ()
		    (setq quizlist (cons (nth 0 elt) quizlist))
		    (setq qdue (1+ qdue))))
		 ((and (< qdue target) (> excess 0) (>= (nth 2 elt) sixhrs))
		  (let ()
		    (setq quizlist (cons (nth 0 elt) quizlist))
		    (setq qdue (1+ qdue) excess (1- excess)))))))
		  
	    (if (< qdue 1)
		(let ()
		  (if (< qtot 1)
		      (message "Die Quiz-Datei ist ganz leer!")
		    (message "Alle Testfragen wurden in letzen sechs Uhr verbrauchen."))
		  (kill-buffer qfbuf))
	      (let ()
		(setq totprompt
		      (concat "Es sind "
			      (number-to-string qdue)
			      " Testfragen aus "
			      (number-to-string qtot)
			      " in der Datei.\n"
			      (number-to-string qival) 
			      " Testfragen sind überfällig und "
			      (number-to-string abovet)
			      " übersteigen den Grenzwert.\n"
			      (if (> qmean 0.01) 
				  (concat "Der Durchschnitt ist "
					  (let ((x (number-to-string qmean))) 
					    (substring x 0 (min 6 (length x))))
					  ". Die Standardabweichung ist "
					  (let ((x (number-to-string qstd))) 
					    (substring x 0 
						       (min 6 (length x))))
					  ".")
				"")
			      "\nDie Prüfung soll "
			      (number-to-string (round (/ (* qdue secs-per) 
							  60)))
			      (if (= (round (/ (* qdue secs-per) 60)) 1)
				  (concat " minute dauern.\n\n"
			                  "Drück' mal die Eingabetaste "
					  "wann Sie bereit sind!")
				(concat " minuten dauern.\n\n"
					"Drück' mal die Eingabetaste "
					"wann Sie bereit sind!"))))
		(setq mi (read-from-minibuffer totprompt)) ; THIS mi not used!

		;; go back to "game" buffer and go through the questions one 
                ;; by one

		(switch-to-buffer gbuf)
		(erase-buffer)
		(setq qtot 1)
		(setq quizlist (eding-randomize-list quizlist))
		(while quizlist
		  (goto-char (point-min))
		  (let (ds db de es eb ee)
		    (setq curq (car quizlist))
		    (save-excursion
		      (set-buffer qfbuf)
		      (goto-line curq)
		      (let ((p0 (point))
			    (p1 (line-end-position)))
			(setq qline (buffer-substring p0 p1))
			(setq elements (eding-quiz-line-elements qline))))
		    (setq cts (nth 0 elements))
		    (setq cf1 (nth 1 elements))
		    (setq cf2 (nth 2 elements))
		    (setq cf3 (nth 3 elements))
		    (setq qline (nth 4 elements))
		    (string-match "^\\(.*?\\)<--->" qline)
		    (setq db (match-beginning 1) de (match-end 1))
		    (string-match "<--->\\s .*?\\(.*?\\)$" qline)
		    (setq eb (match-beginning 1) ee (match-end 1))
		    (setq ds (substring qline db de))
		    (setq es (substring qline eb ee))
		    (insert (concat "\n\n\n\n" es))
		    (setq asktime (current-time))
		    (read-from-minibuffer preprompt)
		    (setq anstime (current-time))
		    (setq dur (- (eding-time-diff asktime anstime) 
				 (* hd (length qline))))
		    (setq ascore (max 0.01 dur))
		    (setq response-time (+ response-time ascore))
		    (setq totprompt
			  (concat (number-to-string qtot) ": iter: " 
				  (number-to-string cf1)
				  " ; gebraucht vor " 
				  (let ((x (number-to-string 
					    (/ (- now cts) daylen)))) 
				    (substring x 0 (min 4 (length x))))
				  " Tage; Durchschnitt: " 
				  (let ((x (number-to-string cf2))) 
				    (substring x 0 (min 6 (length x))))
				  "\nEingabetaste zu behalten, oder Zahl"
				  " nichtig zu machen.\n(Autotestergebnis " 
				  (let ((x (number-to-string ascore))) 
				    (substring x 0 (min 6 (length x))))
				  " ): "))
		    (erase-buffer)
		    (insert (concat "\n\n\n\n" ds))
		    (setq mi (read-from-minibuffer totprompt))
		    (erase-buffer))
		  (if (> (length mi) 0)
		      (setq minum (string-to-number mi))
		    (setq minum (min ascore 10.0)))
		  (if (> minum 10.9)
		      (setq cf1 0)
		    (setq cf1 (1+ cf1)))
		  (setq cts now)
		  (if (< cf1 0.9)
		      (setq cf2 11.0)
		    (setq cf2 (/ (+ (* (1- cf1) cf2) minum) cf1)))
		  (save-excursion
		    (set-buffer qfbuf)
		    (if (> cf1 10)
			(setq cf1 10))
		    (eding-quiz-writeline cts cf1 cf2 0.0 qline curq))
		  (if (> minum prob-thresh)
		      (setq below4 (cons curq below4)))
		  (setq qtot (1+ qtot))
		  (setq quizlist (cdr quizlist)))
		(erase-buffer)
		(setq quizlist (eding-randomize-list below4))
		(message (concat "Zweite Testphase Listegröße " 
				 (number-to-string (length quizlist))))
		(while quizlist
		  (goto-char (point-min))
		  (let (ds db de es eb ee)
		    (setq curq (car quizlist))
		    (save-excursion
		      (set-buffer qfbuf)
		      (goto-line curq)
		      (let ((p0 (point))
			    (p1 (line-end-position)))
			(setq qline (buffer-substring p0 p1))
			(setq elements (eding-quiz-line-elements qline))))
		    (setq qline (nth 4 elements))
		    (string-match "^\\(.*?\\)<--->" qline)
		    (setq db (match-beginning 1) de (match-end 1))
		    (string-match "<--->\\s .*?\\(.*?\\)$" qline)
		    (setq eb (match-beginning 1) ee (match-end 1))
		    (setq ds (substring qline db de))
		    (setq es (substring qline eb ee))
		    (insert (concat "\n\n\n\n" es))
		    (setq asktime (current-time))
		    (read-from-minibuffer preprompt)
		    (setq anstime (current-time))
		    (setq dur (- (eding-time-diff asktime anstime) 
				 (* hd (length qline))))
		    (setq ascore (max 0.01 dur))
		    (setq response-time (+ response-time ascore))
		    (setq totprompt
			  (concat
			   "--Zweite Testphase--\n"
			   "Eingabetaste zu behalten, oder Zahl"
			   " nichtig zu machen.\n(Autotestergebnis "
			   (let ((x (number-to-string ascore))) 
			     (substring x 0 (min 6 (length x))))
			   " ): "))
		    (erase-buffer)
		    (insert (concat "\n\n\n\n" ds))
		    (setq mi (read-from-minibuffer totprompt))
		    (erase-buffer))
		  (if (> (length mi) 0)
		      (setq minum (string-to-number mi))
		    (setq minum ascore))
		  (if (> minum prob-thresh)
		      (let ()
			(setq quizlist (append (cdr quizlist) (cons curq ())))
			(setq quizlist (eding-randomize-list quizlist)))
		    (setq quizlist (cdr quizlist))))
		(setq totprompt (concat "Abgelaufene Zeit: "
					(let ((x (number-to-string 
						  (/ (- (float-time) 
							now) 60.0)))) 
					  (substring x 0 (min 5 (length x))))
					" minuten.   Total Reaktionzeit: "
					(let ((x (number-to-string 
						  (/ response-time 60.0)))) 
					  (substring x 0 (min 5 (length x))))
					" minuten.\nQuizdatei speichern? "))
		(setq mi (read-from-minibuffer totprompt))
		(if (and (> (length mi) 0) (equal "y" (substring mi 0 1)))
		    (let ()
		      (save-excursion
			(set-buffer qfbuf)
			(save-buffer))))
		(kill-buffer qfbuf)
		(set-input-method 'german-postfix)))))
     ;; you only get here if eding-quiz-file is either missing or 
     ;; not writable...
    (message "Quizdatei Schreibschutzfehler!"))))

(defun eding-randomize-list (lin)
  "Jumbles up the order of the elements of the list LIN.

Returns the randomized list."
  nil
  (let 
      ((x1 lin)
       (n (length lin))
       (target (random t))
       (outlist ()))
    (while (> n 0)
      (setq target (random n))
      (cond
       ((= target 0)
	(let ((tmp (car x1)))
	  (setq x1 (cdr x1))
	  (setq outlist (cons tmp outlist))))
       ((= target n)
	(let ((tmp (nth target x1)))
	  (setcdr (nthcdr (1- target) ()) ())
	  (setq outlist (cons tmp outlist))))
       (t
	(let ((tmp (nth target x1)))
	  (setcdr (nthcdr (1- target) x1) (nthcdr (1+ target) x1))
	  (setq outlist (cons tmp outlist)))))
      (setq n (1- n)))
    outlist))

(defun eding-set-postfix ()
  "Explicitly set the input method to german-postfix."
  (interactive)
  (let ()
    (set-input-method 'german-postfix)))

(defun eding-soft-lookup ()
  "Perform eding-lookup using soft matching.

This routine just calls eding-lookup but locally
sets eding-soft-match to allow output of related
words that don't exactly match the search string.

For complete documentation on eding-lookup,
type \"C-c d h.\" The section after the table of 
keybindings provides a lot of detailed help on 
how to get the most out of that function."
  (interactive)
  (let ((eding-soft-match t))
    (eding-lookup)))

(defun eding-toggle-english ()
  "Toggles the variable eding-english.

The variable eding-english, if non-nil, causes 
eding-lookup to print results with the English
part first, as you would prefer if you were
German and using eding-lookup to find English
definitions."
  (interactive)
  (if eding-english
     (setq eding-english nil)
    (setq eding-english t))
  (if eding-english
     (message "eding-english set to t")
    (message "eding-english set to nil")))
    

(defun eding-time-diff (asktime anstime)
  "Returns difference between two times in seconds.

This function is used to determine the number of
seconds between the time when a question was 
asked and the time when the user asked to see 
the translation."
  nil
  (let ((h (- (nth 0 anstime) (nth 0 asktime)))
	(l (- (nth 1 anstime) (nth 1 asktime)))
	(m (- (nth 2 anstime) (nth 2 asktime)))
	retval)
    (setq retval (+ (* 65536 h) l (/ m 1000000.0)))))

(defun eding-check-dictionary (&optional df)
  "Checks for errors in the Ding dictionary file.

This routine scans the Ding dictionary file looking
for lines that give the parsing routines trouble
so you can go in and modify them if you feel like
it.  So far, these lines have never made the program
crash, but there is obviously something wrong with
them so you might be losing some information. These
lines usually number less than 50 so they are a very
small percentage of the entire dictionary."
  (interactive)
    (let ((dbuf (get-buffer-create "*ding*"))
	  (dfile (if df df eding-dictionary-file))
	  (curline 1)
	  (delists ())
	  (probs ()) pm dstr totlines repint)
      (save-selected-window
	(with-output-to-temp-buffer "*eding-check*"
	  (set-buffer dbuf)
	  (if (< (point-max) 10000)
	      (let ()
		(message "Warte mal.  Massiv Datei wird geladen...")
		(insert-file-contents eding-dictionary-file nil nil nil t)
		(message "Warte mal.  Massiv Datei wird geladen...fertig")))
	  (goto-char (point-min))
	  (setq pm (point-max))
	  (setq totlines (count-lines (point-min) pm))
	  (setq repint (/ totlines 100))
	  (message "Ding Wörterbuch wird geprüft...")
	  (while (< (point) pm)
	    (setq dstr (buffer-substring-no-properties 
			(let () (beginning-of-line) (point))
			(line-end-position)))
	    (unless (string-match "^#" dstr)
	      (setq delists (eding-parse-line dstr))
	      (unless (eq (length (car delists)) (length (cadr delists)))
		(princ (concat "Line " (number-to-string curline) 
				" is unbalanced. There are "
				(number-to-string (length (car delists)))
				" German elements and "
				(number-to-string (length (cadr delists)))
				" English elements.\n"))))
	    (setq curline (1+ curline)) 
	    (if (eq (mod curline repint) 0)
		(message "Ding Wörterbuch wird geprüft...%d%c" 
			 (round (* 100.0 (/ (float curline) 
					    (float totlines)))) ?% ))
	    (forward-line 1))))
      t))

(defun eding-randomize-quizfile ()
  "Randomizes timestamps on current quiz file.

Once in a while you should use this function to mix up the
timestamps in your quiz file.  Some challenges are related
to each other and these are often entered at the same time.
After a while you will unconsciously (or consciously!) notice
this correlation and you will know in advance that certain
challenges are coming later in the quiz, which gives you
an advantage.  Mixing up the order from time to time will 
probably make your scores more accurate."
  (interactive)
  (if (and (file-exists-p eding-quiz-file)
	   (file-writable-p eding-quiz-file))
      (save-excursion
	(let ((qfbuf (find-file-noselect eding-quiz-file))
	      (secs-session 1250.0)
	      (secs-per 5.0)
	      (daylen 86400.0)
	      (ff 1.1) ; Fudge factor. Randomness causes different
		       ; days to have different quiz sizes. ff
                       ; helps makes sure that any given day's 
                       ; test size is below (/ secs-session secs-per)
                       ; it also makes sure there is some room
                       ; for problem challenges.... 
	      (now (+ (float-time) 43200.0))  ; + half a day
	      (timelist ())
	      (n 1)
	      qline elements cts cf1 cf2 curq qtot)
	  (set-buffer qfbuf)
	  (goto-char (point-min))
	  (setq qtot (count-lines (point-min) (point-max)))
	  (dotimes (ceiling (/ (* ff qtot) 
			       (float (/ secs-session secs-per))))
	    (setq timelist (cons (fround (- now (* n daylen))) timelist) 
		  n (1+ n))) 
	  (setq curq 1)
	  (while (< (point) (point-max))
	    (setq qline (buffer-substring (point) (line-end-position)))
	    (setq elements (eding-quiz-line-elements qline))
	    (setq cf1 (nth 1 elements))
	    (setq cf2 (nth 2 elements))
	    (setq qline (nth 4 elements))
	    (setq cts (nth (random (length timelist)) timelist))
	    (eding-quiz-writeline cts cf1 cf2 0.0 qline curq)
	    (setq curq (1+ curq))
	    (forward-line))
	  (save-buffer)
	  (kill-buffer qfbuf)))
    (message "Quizdatei Schreibschutzfehler!")))

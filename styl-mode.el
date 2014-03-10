(require 'font-lock)
(defvar styl-mode-map (make-keymap)
  "Keymap for Stylus major mode.")
(defvar styl-string-regexp "\"\\([^\\]\\|\\\\.\\)*?\"\\|'\\([^\\]\\|\\\\.\\)*?'")

(defvar styl-test-regexp "^\\( *\\)123\n\\(\\1\\)  456")
(defvar styl-font-lock-keywords
  ;; *Note*: order below matters. `styl-keywords-regexp' goes last
  ;; because otherwise the keyword "state" in the function
  ;; "state_entry" would be highlighted.
  `((,styl-string-regexp . font-lock-string-face)
    ;;(,styl-query-regexp . font-lock-keyword-face)
    ;;(,styl-test-regexp . font-lock-constant-face)
    ;;    (,styl-prototype-regexp . font-lock-variable-name-face)
    ;;    (,styl-assign-regexp . font-lock-type-face)
    ;;    (,styl-regexp-regexp . font-lock-constant-face)
    ;;    (,styl-boolean-regexp . font-lock-constant-face)
    ;;    (,styl-keywords-regexp . font-lock-keyword-face)
    ))
(defcustom styl-tab-width tab-width
  "The tab width to use when indenting."
  :type 'integer
  :group 'styl)

(defun styl-previous-indent ()
  "Return the indentation level of the previous non-blank line."
  (save-excursion
    (forward-line -1)
    (if (bobp)
        0
      (progn
        (while (and (looking-at "^[ \t]*$") (not (bobp))) (forward-line -1))
        (current-indentation)))))

;;(defun styl-line-wants-indent ()
;;  "Return t if the current line should be indented relative to the
;;previous line."
;;  (interactive)
;;
;;  (save-excursion
;;    (let ((indenter-at-bol) (indenter-at-eol))
;;      ;; Go back a line and to the first character.
;;      (forward-line -1)
;;      (backward-to-indentation 0)
;;
;;      ;; If the next few characters match one of our magic indenter
;;      ;; keywords, we want to indent the line we were on originally.
;;      (when (looking-at (coffee-indenters-bol-regexp))
;;        (setq indenter-at-bol t))
;;
;;      ;; If that didn't match, go to the back of the line and check to
;;      ;; see if the last character matches one of our indenter
;;      ;; characters.
;;      (when (not indenter-at-bol)
;;        (end-of-line)
;;
;;        ;; Optimized for speed - checks only the last character.
;;        (let ((indenters coffee-indenters-eol))
;;          (while indenters
;;            (if (/= (char-before) (car indenters))
;;                (setq indenters (cdr indenters))
;;              (setq indenter-at-eol t)
;;              (setq indenters nil)))))
;;
;;      ;; If we found an indenter, return `t'.
;;      (or indenter-at-bol indenter-at-eol))))

(defun styl-newline-and-indent ()
  "Insert a newline and indent it to the same level as the previous line."
  (interactive)

  ;; Remember the current line indentation level,
  ;; insert a newline, and indent the newline to the same
  ;; level as the previous line.
  (let ((prev-indent (current-indentation)) (indent-next nil))
    (delete-horizontal-space t)
    (newline)
    (insert-tab (/ prev-indent styl-tab-width))

    ;; We need to insert an additional tab because the last line was special.
    ;;(when (styl-line-wants-indent)
    ;;  (insert-tab))
    )

  ;; Last line was a comment so this one should probably be,
  ;; too. Makes it easy to write multi-line comments (like the one I'm
  ;; writing right now).
  )

(defun styl-indent-line ()
  "Indent current line as Stylus."
  (interactive)
  (if (= (point) (point-at-bol))
      (insert-tab)
    (save-excursion
      (let ((prev-indent (styl-previous-indent))
            (cur-indent (current-indentation)))
        ;; Shift one column to the left
        (beginning-of-line)
        (insert-tab)

        (when (= (point-at-bol) (point))
          (forward-char styl-tab-width))

        ;; We're too far, remove all indentation.
        (when (> (- (current-indentation) prev-indent) styl-tab-width)
          (backward-to-indentation 0)
          (delete-region (point-at-bol) (point)))))))

(define-derived-mode styl-mode fundamental-mode
  "Stylus"
  "Major mode for editing Stylus."

  ;; key bindings
  (define-key styl-mode-map "\C-m" 'styl-newline-and-indent)
  
  ;; code for syntax highlighting
  (setq font-lock-defaults '((styl-font-lock-keywords)))

  
  ;; indentation
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'styl-indent-line)
  (set (make-local-variable 'tab-width) styl-tab-width) 
  
  ;; no tabs
  (setq indent-tabs-mode nil))

(add-to-list 'auto-mode-alist '("\\.styl$" . styl-mode))
(provide 'styl-mode)

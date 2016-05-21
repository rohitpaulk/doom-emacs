;;; core.el --- The heart of the beast
;;
;;; Naming conventions:
;;
;;   doom-...     A public variable/constant or function
;;   doom--...    An internal variable or function (non-interactive)
;;   doom/...     An autoloaded interactive function
;;   doom:...     An ex command
;;   doom|...     A hook
;;   doom*...     An advising function
;;   doom....     Custom prefix commands
;;   ...!         Macro or shortcut alias
;;
;; Autoloaded functions are in {core,modules}/defuns/defuns-*.el
;;
;;;

(setq-default
 ;; stop package.el from being annoying. I rely solely on Cask.
 package--init-file-ensured t
 package-enable-at-startup nil
 package-archives
 '(("gnu"   . "http://elpa.gnu.org/packages/")
   ("melpa" . "http://melpa.org/packages/")
   ("org"   . "http://orgmode.org/elpa/"))

 ad-redefinition-action            'accept      ; silence the advised function warnings
 compilation-always-kill            t           ; kill compilation process before spawning another
 compilation-ask-about-save         nil         ; save all buffers before compiling
 compilation-scroll-output          t           ; scroll with output while compiling
 delete-by-moving-to-trash          t
 echo-keystrokes                    0.02        ; show me what I type
 ediff-diff-options                 "-w"
 ediff-split-window-function       'split-window-horizontally   ; side-by-side diffs
 ediff-window-setup-function       'ediff-setup-windows-plain   ; no extra frames
 enable-recursive-minibuffers       nil         ; no minibufferception
 idle-update-delay                  2           ; update a little less often
 inhibit-startup-echo-area-message  "hlissner"  ; username shuts up emacs
 major-mode                        'text-mode
 ring-bell-function                'ignore      ; silence of the bells!
 save-interprogram-paste-before-kill nil
 sentence-end-double-space          nil
 confirm-nonexistent-file-or-buffer t

 ;; http://ergoemacs.org/emacs/emacs_stop_cursor_enter_prompt.html
 minibuffer-prompt-properties
 '(read-only t point-entered minibuffer-avoid-prompt face minibuffer-prompt)

 bookmark-save-flag                 t
 bookmark-default-file              (concat doom-temp-dir "/bookmarks")

 ;; Disable all backups (that's what git/dropbox are for)
 history-length                     1000
 vc-make-backup-files               nil
 auto-save-default                  nil
 auto-save-list-file-name           (concat doom-temp-dir "/autosave")
 make-backup-files                  nil
 create-lockfiles                   nil
 backup-directory-alist            `((".*" . ,(concat doom-temp-dir "/backup/")))

 ;; Remember undo history
 undo-tree-auto-save-history        nil
 undo-tree-history-directory-alist `(("." . ,(concat doom-temp-dir "/undo/"))))

;; UTF-8 please
(setq locale-coding-system    'utf-8)   ; pretty
(set-terminal-coding-system   'utf-8)   ; pretty
(set-keyboard-coding-system   'utf-8)   ; pretty
(set-selection-coding-system  'utf-8)   ; please
(prefer-coding-system         'utf-8)   ; with sugar on top
(set-charset-priority 'unicode)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))


;;
;; Variables
;;

(defvar doom-unreal-buffers '("^ ?\\*.+\\*"
                              image-mode
                              dired-mode
                              reb-mode
                              messages-buffer-mode)
  "A list of regexps or modes whose buffers are considered unreal, and will be
ignored when using `doom:next-real-buffer' and `doom:previous-real-buffer' (or
killed by `doom/kill-unreal-buffers', or after `doom/kill-real-buffer').")

(defvar doom-ignore-buffers '("*Completions*" "*Compile-Log*" "*inferior-lisp*"
                              "*Fuzzy Completions*" "*Apropos*" "*Help*" "*cvs*"
                              "*Buffer List*" "*Ibuffer*" "*NeoTree*" "
                              *NeoTree*" "*esh command on file*" "*WoMan-Log*"
                              "*compilation*" "*use-package*" "*quickrun*"
                              "*eclim: problems*" "*Flycheck errors*"
                              "*popwin-dummy*"
                              ;; Helm
                              "*helm*" "*helm recentf*" "*helm projectile*"
                              "*helm imenu*" "*helm company*" "*helm buffers*"
                              "*Helm Css SCSS*" "*helm-ag*" "*helm-ag-edit*"
                              "*Helm Swoop*" "*helm M-x*" "*helm mini*"
                              "*Helm Completions*" "*Helm Find Files*"
                              "*helm mu*" "*helm mu contacts*"
                              "*helm-mode-describe-variable*"
                              "*helm-mode-describe-function*"
                              ;; Org
                              "*Org todo*" "*Org Links*" "*Agenda Commands*")
  "List of buffer names to ignore when using `winner-undo', or `winner-redo'")

(defvar doom-cleanup-processes-alist '(("pry" . ruby-mode)
                                       ("irb" . ruby-mode)
                                       ("ipython" . python-mode))
  "An alist of (process-name . major-mode), that `doom:cleanup-processes' checks
before killing processes. If there are no buffers with matching major-modes, it
gets killed.")

(defvar doom-project-root-files
  '(".git" ".hg" ".svn" ".project" "local.properties" "project.properties"
    "rebar.config" "project.clj" "SConstruct" "pom.xml" "build.sbt"
    "build.gradle" "Gemfile" "requirements.txt" "tox.ini" "package.json"
    "gulpfile.js" "Gruntfile.js" "bower.json" "composer.json" "Cargo.toml"
    "mix.exs")
  "A list of files that count as 'project files', which determine whether a
folder is the root of a project or not.")


;;
;; Libraries
;;

(require 'f)
(require 'dash)
(require 's)

(require 'core-defuns)
(unless (require 'autoloads nil t)
  (doom-reload-autoloads)
  (unless (require 'autoloads nil t)
    (error "Autoloads couldn't be loaded or generated!")))

(autoload 'use-package "use-package" "" nil 'macro)

(use-package anaphora
  :commands (awhen aif acond awhile))

(use-package persistent-soft
  :commands (persistent-soft-store
             persistent-soft-fetch
             persistent-soft-exists-p
             persistent-soft-flush
             persistent-soft-location-readable
             persistent-soft-location-destroy)
  :init (defvar pcache-directory (concat doom-temp-dir "/pcache/")))

(use-package async
  :commands (async-start
             async-start-process
             async-get
             async-wait
             async-inject-variables))

(use-package json
  :commands (json-read-from-string json-encode json-read-file))

(use-package help-fns+ ; Improved help commands
  :commands (describe-buffer describe-command describe-file
             describe-keymap describe-option describe-option-of-type))


;;
;; Automatic minor modes
;;

(defvar doom-auto-minor-mode-alist '()
  "Alist of filename patterns vs corresponding minor mode functions, see
`auto-mode-alist'. All elements of this alist are checked, meaning you can
enable multiple minor modes for the same regexp.")

(defun doom|enable-minor-mode-maybe ()
  "Check file name against `doom-auto-minor-mode-alist'."
  (when buffer-file-name
    (let ((name buffer-file-name)
          (remote-id (file-remote-p buffer-file-name))
          (alist doom-auto-minor-mode-alist))
      ;; Remove backup-suffixes from file name.
      (setq name (file-name-sans-versions name))
      ;; Remove remote file name identification.
      (when (and (stringp remote-id)
                 (string-match-p (regexp-quote remote-id) name))
        (setq name (substring name (match-end 0))))
      (while (and alist (caar alist) (cdar alist))
        (if (string-match (caar alist) name)
            (funcall (cdar alist) 1))
        (setq alist (cdr alist))))))

(add-hook 'find-file-hook 'doom|enable-minor-mode-maybe)


;;
(setq initial-major-mode 'doom-mode
      initial-scratch-message nil
      inhibit-startup-screen t) ; don't show emacs start screen

(defvar doom-buffer-name "*doom*" "")
(defvar doom-buffer nil "")
(define-derived-mode doom-mode text-mode "DOOM"
  "Major mode for special DOOM buffers.")

(add-hook 'after-init-hook 'doom-mode-init)
(defun doom-mode-init (&optional auto-detect-frame)
  (let ((old-scratch (get-buffer "*scratch*")))
    (when old-scratch
      (with-current-buffer old-scratch
        (rename-buffer doom-buffer-name)
        (setq doom-buffer old-scratch))))
  (unless doom-buffer
    (setq doom-buffer (get-buffer-create doom-buffer-name)))
  (with-current-buffer doom-buffer
    (doom-mode)
    (erase-buffer)
    (insert
     (let* ((width (- (if auto-detect-frame (window-width) (cdr (assq 'width default-frame-alist))) 3))
            (lead (make-string (truncate (/ (- width 78) 2)) ? )))
       (concat
        (propertize
         (concat
          (make-string (min 3 (/ (if auto-detect-frame (window-height) (cdr (assq 'height default-frame-alist))) 5)) ?\n)
          lead "=================     ===============     ===============   ========  ========\n"
          lead "\\\\ . . . . . . .\\\\   //. . . . . . .\\\\   //. . . . . . .\\\\  \\\\. . .\\\\// . . //\n"
          lead "||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\\/ . . .||\n"
          lead "|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||\n"
          lead "||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||\n"
          lead "|| . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\\ . . . . ||\n"
          lead "||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\\_ . .|. .||\n"
          lead "|| . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\\ `-_/| . ||\n"
          lead "||_-' ||  .|/    || ||    \\|.  || `-_|| ||_-' ||  .|/    || ||   | \\  / |-_.||\n"
          lead "||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \\  / |  `||\n"
          lead "||    `'         || ||         `'    || ||    `'         || ||   | \\  / |   ||\n"
          lead "||            .===' `===.         .==='.`===.         .===' /==. |  \\/  |   ||\n"
          lead "||         .=='   \\_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \\/  |   ||\n"
          lead "||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \\/  |   ||\n"
          lead "||   .=='    _-'          '-__\\._-'         '-_./__-'         `' |. /|  |   ||\n"
          lead "||.=='    _-'                                                     `' |  /==.||\n"
          lead "=='    _-'                         E M A C S                          \\/   `==\n"
          lead "\\   _-'                                                                `-_   /\n"
          lead " `''                                                                     ``'")
         'face 'font-lock-comment-face)
        "\n\n"
        (propertize
         (s-center (1- width) (format "Press `,m` to open recent files, or `,E` to access emacs.d"
                                      emacs-end-time))
         'face 'font-lock-keyword-face)
        (if emacs-end-time
            (concat
             "\n\n"
             (s-trim-right (s-center (- width 2) (format "Loaded in %.3fs" emacs-end-time))))
          ""))))
    (doom|update-scratch-buffer-cwd)))

(add-hook! after-init
  ;; We add this to `after-init-hook' to allow errors to stop it
  (defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
    "Prevent annoying \"Active processes exist\" query when you quit Emacs."
    (cl-flet ((process-list ())) ad-do-it))

  ;; Prevent any auto-displayed text...
  (advice-add 'display-startup-echo-area-message :override 'ignore)
  (setq emacs-end-time (float-time (time-subtract (current-time) emacs-start-time)))
  (message ""))

(provide 'core)
;;; core.el ends here

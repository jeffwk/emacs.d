;;(package-initialize)

;; wrapping the entire file in a let form causes some problems with editing/tools
(setq file-name-handler-alist-backup file-name-handler-alist)
(setq file-name-handler-alist nil)

;; this value is approximately the default in Emacs 24,
;; but the fringes were much smaller by default in a dev snapshot of Emacs 25
(setq initial-frame-alist '((left-fringe . 15) (right-fringe . 15)))

;; raising gc-cons-threshold substantially improves Emacs startup time
;;(setq gc-cons-threshold 10000000)
(setq gc-cons-threshold 25000000)

(set-language-environment "utf-8")

(setq custom-safe-themes t)
(setq auto-save-default nil)

;;(require 'package)

(require 'cask "~/.cask/cask.el")
(cask-initialize)

(add-to-list 'package-pinned-packages '(cider . "melpa-stable") t)
(add-to-list 'package-pinned-packages '(clj-refactor . "melpa-stable") t)

;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(require 'cl)
(require 'use-package)
(require 'f)

(defun load-local (file)
  (load (f-expand file user-emacs-directory)))

;;(shell-command "~/bin/do-ssh-add")

;; load values for options that may be different across machines
(load-local "variables")

(defun active-minor-modes ()
  (--filter (and (boundp it) (symbol-value it)) minor-mode-list))

(defun minor-mode-active-p (minor-mode)
  (if (member minor-mode (active-minor-modes)) t nil))

(when nil
  ;; calling these substantially increases Emacs startup time
  ;; most are now set in .Xdefaults and loaded with xrdb -merge
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
  (when window-system
    (set-frame-font custom-font))
  (when window-system
    (set-frame-size (selected-frame) custom-frame-width custom-frame-height)))

(when (null window-system)
  ;; need to call this for terminal mode because the .Xdefaults settings won't apply
  (menu-bar-mode -1))

(use-package diminish)

(setq vc-follow-symlinks t)
(setq make-backup-files nil)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(cond ((or (eql custom-emacs-theme 'moe-dark)
           (eql custom-emacs-theme 'moe-light))
       nil)
      ((or (eql custom-emacs-theme 'sanityinc-tomorrow-night)
           (eql custom-emacs-theme 'sanityinc-tomorrow-night-rxvt)
           t)
       (let ((dark-bg "#303030")
             (bright-fg "#babcba")
             (gray-fg "#555756")
             (black-fg "#060606")
             (bright-active "#505050")
             (bright-inactive "#383838"))
         (custom-set-faces
          `(mode-line ((t (:foreground "#888888" :background ,dark-bg :box (:line-width 2 :color ,bright-active)))))
          `(mode-line-inactive ((t (:foreground ,gray-fg :background ,dark-bg :box (:line-width 2 :color ,dark-bg)))))
          `(mode-line-buffer-id ((t (:foreground "#81a2be" :background ,dark-bg))))
          `(powerline-active1 ((t (:foreground ,bright-fg :background ,bright-active))))
          `(powerline-active2 ((t (:foreground ,bright-fg :background ,dark-bg))))
          `(powerline-inactive1 ((t (:foreground ,gray-fg :background ,bright-inactive))))
          `(powerline-inactive2 ((t (:foreground ,gray-fg :background ,dark-bg)))))))
      (nil
       (let ((dark-bg "#404040")
             (darker-bg "#181818")
             (bright-bg "#ebdbb2")
             (bright-fg "#ebdbb2")
             (black-fg "#181818")
             (gray-fg "#ebdbb2"))
         (custom-set-faces
          `(mode-line ((t (:foreground ,bright-fg :background ,dark-bg :box (:line-width 2 :color "#aaa090")))))
          `(mode-line-inactive ((t (:foreground ,bright-fg :background ,dark-bg :box (:line-width 2 :color ,dark-bg)))))
          `(mode-line-buffer-id ((t (:foreground ,bright-fg :background ,dark-bg))))
          `(powerline-active1 ((t (:foreground ,black-fg :background ,bright-bg))))
          `(powerline-active2 ((t (:foreground ,bright-fg :background ,dark-bg))))
          `(powerline-inactive1 ((t (:foreground ,bright-fg :background ,darker-bg))))
          `(powerline-inactive2 ((t (:foreground ,bright-fg :background ,dark-bg))))))))

(use-package powerline
  ;; :config (powerline-default-theme)
  )

(defun switch-to-theme (theme)
  (dolist (active-theme custom-enabled-themes)
    (disable-theme active-theme))
  (when theme
    (load-theme theme t)))

(use-package esup)

;;(use-package zenburn-theme)
(use-package color-theme-sanityinc-tomorrow)
(use-package color-theme-sanityinc-solarized)
;;(use-package moe-theme)
;;(use-package base16-theme)
;;(use-package gruvbox-theme)

(defun set-theme-and-powerline (_)
  (cond
   ((or (eql custom-emacs-theme 'moe-dark)
        (eql custom-emacs-theme 'moe-light))
    (progn
      (if (eql custom-emacs-theme 'moe-dark)
          (moe-dark)
        (moe-light))
      (powerline-moe-theme)
      (add-hook 'window-setup-hook 'powerline-moe-theme)))
   (t
    (progn
      (switch-to-theme custom-emacs-theme)
      (powerline-default-theme)
      (add-hook 'window-setup-hook 'powerline-default-theme)))))

(set-theme-and-powerline nil)

'(unless (null window-system)
   (set-frame-size (selected-frame) 100 58))

(use-package yasnippet
  :config
  (diminish 'yas-minor-mode))

(use-package uniquify
  :config (setq uniquify-buffer-name-style 'post-forward))

(use-package aggressive-indent)

'(use-package lispy
   :config 
   (defun enable-lispy (mode-hook)
     (add-hook mode-hook (lambda () (lispy-mode 1)))))

(use-package systemd)

(use-package org
  :commands org-agenda org-store-link org-capture
  :config
  (define-key global-map "\C-cl" 'org-store-link)
  (define-key global-map "\C-ca" 'org-agenda)
  (define-key global-map "\C-cc" 'org-capture)
  (setq org-log-done t)
  (setq org-agenda-files (list "~/org/work.org" "~/org/self.org")))

(use-package pkgbuild-mode
  :config
  (add-to-list 'auto-mode-alist '("/PKGBUILD$" . pkgbuild-mode)))

(use-package auto-complete-config
  :config
  (ac-config-default)
  (setq global-auto-complete-mode t)
  (setq ac-use-dictionary-as-stop-words nil)
  (setq ac-use-fuzzy t)
  (define-globalized-minor-mode real-global-auto-complete-mode
    auto-complete-mode (lambda ()
                         (if (not (minibufferp (current-buffer)))
                             (auto-complete-mode 1))))
  (real-global-auto-complete-mode t))

;;(use-package helm)

(use-package projectile
  :config
  (projectile-global-mode)
  (setq projectile-enable-caching nil)
  (setq projectile-mode-line
        '(:eval (format " [%s]" (projectile-project-name))))
  (define-key global-map "\C-cpp" 'projectile-switch-project)
  (define-key global-map "\C-\M-g" 'projectile-grep)
  (setq projectile-use-git-grep t)
  (add-to-list 'grep-find-ignored-files "*.log")
  ;;(use-package helm-projectile)
  )

(use-package smex
  :bind ("M-x" . smex)
  :config (smex-initialize))

(use-package flycheck
  :config
  (define-key flycheck-mode-map "\C-c." 'flycheck-next-error)
  ;;(add-hook 'after-init-hook #'global-flycheck-mode)
  )

(use-package less-css-mode)

(use-package web-mode
  :mode
  "\\.js\\'" "\\.jsx\\'"
  :config
  (use-package tern
    :config
    (use-package tern-auto-complete
      :config
      (tern-ac-setup)))
  (use-package flycheck)
  (use-package js2-mode
    :config
    (flycheck-add-mode 'javascript-eslint 'js2-mode)
    (flycheck-add-mode 'javascript-eslint 'js2-jsx-mode)
    (setq js2-include-node-externs t)
    (setq js2-include-browser-externs t)
    (setq js2-strict-trailing-comma-warning nil)
    (setq js2-indent-switch-body t)
    (defun my-js2-mode-hook ()
      (setq js2-basic-offset 2)
      (flycheck-mode 1)
      (tern-mode t)
      (when (executable-find "eslint")
        (flycheck-select-checker 'javascript-eslint)))
    (add-hook 'js2-mode-hook 'my-js2-mode-hook)
    (add-hook 'js2-jsx-mode-hook 'my-js2-mode-hook))
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (setq-default
   flycheck-disabled-checkers
   '(javascript-jshint json-jsonlist))
  (defun my-web-mode-hook ()
    (setq web-mode-markup-indent-offset 2)
    (setq web-mode-css-indent-offset 2)
    (setq web-mode-code-indent-offset 2)
    (flycheck-mode 1)
    (tern-mode t)
    (when (executable-find "eslint")
      (flycheck-select-checker 'javascript-eslint)))
  (add-hook 'web-mode-hook 'my-web-mode-hook)
  
  )

(use-package jade-mode)

(use-package scala-mode2
  ;; :mode
  ;; ("\\.scala\\'" . scala-mode)
  ;; ("\\.sbt\\'" . scala-mode)
  :config
  ;;(setq scala-indent:default-run-on-strategy 1)
  ;;(setq scala-indent:indent-value-expression nil)
  (use-package ensime
    :config
    ;;(setq ensime-completion-style 'auto-complete)
    (setq ensime-auto-generate-config t)
    (setq ensime-typecheck-idle-interval 0.3)
    (add-hook 'scala-mode-hook 'ensime-mode)
    (add-hook 'scala-mode-hook (lambda () (auto-complete-mode -1)))
    '(add-hook 'scala-mode-hook
               (lambda ()
                 (add-hook 'post-command-hook
                           (lambda ()
                             (when (and ensime-mode (ensime-connected-p))
                               (ensime-print-errors-at-point)))
                           t t)))
    (define-key scala-mode-map "\C-t" 'ensime-print-type-at-point)
    (define-key scala-mode-map "\C-\M-e" 'ensime-print-errors-at-point)
    (define-key scala-mode-map "\C-c." 'ensime-forward-note)
    (define-key scala-mode-map "\C-c," 'ensime-backward-note)
    (define-key scala-mode-map (kbd "C-M-.") 'ensime-show-uses-of-symbol-at-point)))

(use-package ido
  :config
  (use-package flx-ido)
  (ido-mode 1)
  (ido-everywhere 1)
  (flx-ido-mode 1)
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil)
  
  ;;(use-package ido-ubiquitous :config (ido-ubiquitous-mode))
  )

(use-package mic-paren :config (paren-activate))

(use-package paren-face :config (global-paren-face-mode))

(use-package paredit
  :config
  (define-globalized-minor-mode real-global-paredit-mode
    paredit-mode (lambda ()
                   (if (not (minibufferp (current-buffer)))
                       (enable-paredit-mode))))
  ;;(real-global-paredit-mode t)
  (diminish 'paredit-mode "()"))

(use-package smartparens-config
  :config
  (use-package smartparens)
  (sp-pair "'" nil :actions :rem)
  (sp-pair "`" nil :actions :rem)
  (smartparens-global-mode t))

(add-hook
 'emacs-lisp-mode-hook
 (lambda ()
   (use-package ielm)
   (use-package elisp-slime-nav
     :config (diminish 'elisp-slime-nav-mode "M-."))
   (turn-on-elisp-slime-nav-mode)
   (aggressive-indent-mode)
   (turn-off-smartparens-mode)
   (enable-paredit-mode)
   (eldoc-mode 1)))
;; (enable-lispy 'emacs-lisp-mode-hook)

(use-package clojure-mode
  :mode
  ("\\.clj\\'" . clojure-mode)
  ("\\.cljs\\'" . clojurescript-mode)
  :config
  (defface square-brackets
    '((t (:foreground "#c0c43b"))) 'paren-face)
  (defface curly-brackets
    '((t (:foreground "#50a838"))) 'paren-face)
  (defconst clojure-brackets-keywords
    '(("\\[" 0 'square-brackets)
      ("\\]" 0 'square-brackets)
      ("[\\{\\}]" 0 'curly-brackets)))
  (add-hook
   'paren-face-mode-hook
   (lambda ()
     (if paren-face-mode
         (font-lock-add-keywords nil clojure-brackets-keywords t)
       (font-lock-remove-keywords nil clojure-brackets-keywords))
     (when (called-interactively-p 'any)
       (font-lock-fontify-buffer))))
  (use-package cider
    :config
    ;;(setq cider-cljs-repl "(cemerick.piggieback/cljs-repl (cljs.repl.rhino/repl-env))")
    (setq cider-cljs-repl "(do (require 'cljs.repl.node) (cemerick.piggieback/cljs-repl (cljs.repl.node/repl-env)))")
    ;;(setq cider-cljs-repl "(do (require 'weasel.repl.websocket) (cemerick.piggieback/cljs-repl (weasel.repl.websocket/repl-env :ip \"127.0.0.1\" :port 9001)))")
    (use-package ac-cider
      :config
      (add-hook 'cider-mode-hook 'ac-flyspell-workaround)
      (add-hook 'cider-mode-hook 'ac-cider-setup)
      (add-hook 'cider-repl-mode-hook 'ac-cider-setup))
    (use-package cider-eldoc
      :config
      (add-hook 'cider-mode-hook 'eldoc-mode)
      (add-hook 'cider-repl-mode-hook 'eldoc-mode))
    (add-hook 'clojure-mode-hook #'cider-mode)
    (add-hook 'clojurescript-mode-hook #'cider-mode)
    (add-hook 'clojure-mode-hook #'aggressive-indent-mode)
    (add-hook 'clojurescript-mode-hook #'aggressive-indent-mode)
    (add-hook 'cider-mode-hook #'aggressive-indent-mode)
    (add-hook 'clojure-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'clojurescript-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'cider-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'cider-repl-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'clojure-mode-hook 'enable-paredit-mode)
    (add-hook 'clojurescript-mode-hook 'enable-paredit-mode)
    (add-hook 'cider-mode-hook 'enable-paredit-mode)
    (add-hook 'cider-repl-mode-hook 'enable-paredit-mode)
    (defun my-cider-reload-repl-ns ()
      (cider-nrepl-request:eval
       (format "(require '%s :reload)"
               (buffer-local-value 'cider-buffer-ns (first (cider-repl-buffers))))
       ;;"(require (ns-name *ns*) :reload)"
       (lambda (_response) nil)))
    (defvar cider-figwheel-connecting nil)
    (defun cider-figwheel-init ()
      (when cider-figwheel-connecting
        (pop-to-buffer (first (cider-repl-buffers)))
        (insert "(require 'figwheel-sidecar.repl-api)")
        (cider-repl-return)
        (insert "(figwheel-sidecar.repl-api/cljs-repl)")
        (cider-repl-return)
        (when (not (zerop (length cider-figwheel-connecting)))
          (insert (format "(in-ns '%s)" cider-figwheel-connecting))
          (cider-repl-return))))
    (add-hook 'nrepl-connected-hook 'cider-figwheel-init t)
    (defun cider-connect-figwheel ()
      (interactive)
      (let ((cider-figwheel-connecting
             (if (member major-mode '(clojure-mode clojurescript-mode))
                 (clojure-expected-ns)
               "")))
        (cider-connect "localhost" 7888)))
    (defun cider-load-buffer-reload-repl (&optional buffer)
      (interactive)
      (let ((result (if buffer
                        (cider-load-buffer buffer)
                      (cider-load-buffer))))
        (my-cider-reload-repl-ns)
        result))
    (define-key cider-mode-map (kbd "C-c C-k") 'cider-load-buffer-reload-repl)
    ;;(define-key cider-mode-map (kbd "C-c C-k") 'cider-load-buffer)
    (define-key cider-mode-map (kbd "C-c n") 'cider-repl-set-ns)
    ;; (enable-lispy 'clojure-mode-hook)
    ;; (enable-lispy 'cider-mode-hook)
    ;; (enable-lispy 'cider-repl-mode-hook)
    (setq cider-lein-command "~/bin/lein")
    (setq cider-repl-popup-stacktraces t)
    (setq cider-auto-select-error-buffer t))
  (setq cider-prompt-for-symbol nil)
  (diminish 'cider-mode)
  (use-package clj-refactor
    :config
    (defun clj-refactor-clojure-mode-hook ()
      (clj-refactor-mode 1)
      (yas-minor-mode 1) ; for adding require/use/import statements
      ;; This choice of keybinding leaves cider-macroexpand-1 unbound
      (cljr-add-keybindings-with-prefix "C-c C-m"))
    (add-hook 'clojure-mode-hook 'clj-refactor-clojure-mode-hook)
    (add-hook 'clojurescript-mode-hook 'clj-refactor-clojure-mode-hook)
    (diminish 'clj-refactor-mode)))

(use-package haskell-mode
  :mode "\\.hs\\'" "\\.hs-boot\\'" "\\.lhs\\'" "\\.lhs-boot\\'"
  :config
  (use-package ghc)
  (use-package ac-haskell-process
    :config
    (add-hook 'interactive-haskell-mode-hook 'ac-haskell-process-setup)
    (add-hook 'haskell-interactive-mode-hook 'ac-haskell-process-setup)
    (add-to-list 'ac-modes 'haskell-interactive-mode))
  (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
  (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
  (autoload 'ghc-init "ghc" nil t)
  (autoload 'ghc-debug "ghc" nil t)
  (add-hook 'haskell-mode-hook (lambda () (ghc-init)))
  (setq haskell-process-suggest-remove-import-lines t)
  (setq haskell-process-auto-import-loaded-modules t)
  (setq haskell-process-log t)
  (setq haskell-process-type 'cabal-repl))

(add-hook 'java-mode-hook (lambda () (setq indent-tabs-mode nil)))

(use-package tramp
  :config
  (setq tramp-default-method "ssh"))

(use-package slime-autoloads
  :commands slime
  :mode
  ("\\.lisp\\'" . lisp-mode)
  ("\\.asd\\'" . lisp-mode)
  :config
  (setq slime-contribs '(slime-fancy slime-tramp))
  (use-package slime
    :mode
    ("\\.lisp\\'" . lisp-mode)
    ("\\.asd\\'" . lisp-mode)
    :config
    (add-hook 'lisp-mode-hook
              (lambda ()
                (setq-local lisp-indent-function
                            'common-lisp-indent-function)))
    
    (defvar sbcl-run-command "sbcl --dynamic-space-size 2000 --noinform")
    (defvar ccl-run-command "ccl64 -K utf-8")
    (defvar ecl-run-command "ecl")
    
    (setq inferior-lisp-program sbcl-run-command
          slime-net-coding-system 'utf-8-unix
          slime-complete-symbol-function 'slime-fuzzy-complete-symbol
          slime-fuzzy-completion-in-place t
          slime-enable-evaluate-in-emacs t
          slime-autodoc-use-multiline-p t
          slime-load-failed-fasl 'never
          slime-compile-file-options
          '(:fasl-directory "/tmp/slime-fasls/"))
    (make-directory "/tmp/slime-fasls/" t)
    ;;(define-key slime-mode-map [(return)] 'paredit-newline)
    (define-key slime-mode-map (kbd "C-c .") 'slime-next-note)
    (define-key slime-mode-map (kbd "C-c ,") 'slime-previous-note)

    (defun slime-sbcl ()
      (interactive)
      (setq inferior-lisp-program sbcl-run-command)
      (slime))
    (defun slime-ccl ()
      (interactive)
      (setq inferior-lisp-program ccl-run-command)
      (slime))
    (defun slime-ecl ()
      (interactive)
      (setq inferior-lisp-program ecl-run-command)
      (slime))
    (defun kill-slime ()
      (interactive)
      (kill-buffer "*inferior-lisp*")
      (cond
       ((equal inferior-lisp-program sbcl-run-command)
        (kill-buffer "*slime-repl sbcl*"))
       ((equal inferior-lisp-program ccl-run-command)
        (kill-buffer "*slime-repl ccl*"))))

    (add-to-list 'projectile-globally-ignored-modes "comint-mode")
    (add-to-list 'projectile-globally-ignored-modes "slime-repl-mode")

    (add-hook 'lisp-mode-hook #'aggressive-indent-mode)
    (add-hook 'slime-mode-hook #'aggressive-indent-mode)
    (add-hook 'lisp-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'slime-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'slime-repl-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'lisp-mode-hook 'enable-paredit-mode)
    (add-hook 'slime-mode-hook 'enable-paredit-mode)
    (add-hook 'slime-repl-mode-hook 'enable-paredit-mode)
    
    ;; (enable-lispy 'lisp-mode-hook)
    ;; (enable-lispy 'slime-mode-hook)
    ;; (enable-lispy 'slime-repl-mode-hook)

    (use-package slime-annot)
    (use-package ac-slime
      :config
      (defun set-up-slime-ac-fuzzy ()
        (set-up-slime-ac t))
      (add-hook 'slime-mode-hook 'set-up-slime-ac-fuzzy)
      (add-hook 'slime-repl-mode-hook 'set-up-slime-ac-fuzzy))))

(if (null (window-system))
    (require 'git-gutter)
  (require 'git-gutter-fringe))
(global-git-gutter-mode t)
(diminish 'git-gutter-mode)

(define-key global-map (kbd "C-x g") 'magit-status)
(define-key global-map (kbd "C-x C-g") 'magit-dispatch-popup)

(use-package magit
  :commands magit-status magit-push magit-pull
  :init (setq magit-last-seen-setup-instructions "1.4.0")
  :config
  (setq magit-revert-buffers t)
  (setq magit-completing-read-function 'magit-ido-completing-read)
  (diminish 'auto-revert-mode))

(defun xsel-paste ()
  (shell-command-to-string "xsel -ob"))

(defun xsel-copy (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "xsel -ib" "*Messages*" "xsel" "-ib")))
      (process-send-string proc text)
      (process-send-eof proc))))

(defun do-xsel-copy-paste-setup ()
  (when (and (null window-system)
             (getenv "DISPLAY")
             (file-exists-p "/usr/bin/xsel")
             (not (equal (user-login-name) "root")))
    (setq interprogram-cut-function 'xsel-copy)
    (setq interprogram-paste-function 'xsel-paste)))

(do-xsel-copy-paste-setup)
(add-hook 'window-setup-hook 'do-xsel-copy-paste-setup)

(load-local "keys")
(load-local "commands")

(if (equal (user-login-name) "root")
    (setenv "SSH_AUTH_SOCK" "/run/ssh-agent.socket")
  (setenv "SSH_AUTH_SOCK" (concat (getenv "XDG_RUNTIME_DIR") "/ssh-agent.socket")))

(setq server-socket-dir
      (format "/tmp/%s/emacs%d" (user-login-name) (user-uid)))

(setq file-name-handler-alist file-name-handler-alist-backup)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (cider zenburn-theme web-mode use-package systemd smex smartparens smart-mode-line-powerline-theme slime-annot request projectile prodigy popwin pkgbuild-mode paren-face pallet nyan-mode moe-theme mic-paren material-theme magit lispy less-css-mode json-mode js2-mode ido-ubiquitous idle-highlight-mode htmlize gruvbox-theme git-gutter-fringe ghc flycheck-cask flx-ido expand-region exec-path-from-shell esup ensime elisp-slime-nav drag-stuff color-theme-sanityinc-tomorrow color-theme-sanityinc-solarized clj-refactor base16-theme aggressive-indent ac-slime ac-haskell-process ac-cider))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

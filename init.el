;;(package-initialize)

(set-language-environment "utf-8")

(setq custom-safe-themes t)

(require 'cask "~/.cask/cask.el")
(cask-initialize)

(require 'cl)
(require 'use-package)
(require 'f)

(defun load-local (file)
  (load (f-expand file user-emacs-directory)))

(use-package diminish)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq vc-follow-symlinks t)
(setq make-backup-files nil)

(use-package uniquify
  :config (setq uniquify-buffer-name-style 'post-forward))

(defun switch-to-theme (theme)
  (dolist (active-theme custom-enabled-themes)
    (disable-theme active-theme))
  (when theme
    (load-theme theme t)))

(use-package zenburn-theme)
(use-package color-theme-sanityinc-tomorrow)
(use-package color-theme-sanityinc-solarized)

(use-package aggressive-indent)

(use-package lispy
  :config 
  (defun enable-lispy (mode-hook)
    (add-hook mode-hook (lambda () (lispy-mode 1)))))

(use-package systemd)

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

(use-package projectile
  :config
  (projectile-global-mode)
  (setq projectile-enable-caching t)
  (setq projectile-mode-line
	'(:eval (format " [%s]" (projectile-project-name)))))

(use-package smex
  :bind ("M-x" . smex)
  :config (smex-initialize))

(use-package scala-mode2
  :mode ("\\.scala\\'" . scala-mode)
  :init
  :config
  (use-package ensime
    :config
    (add-hook 'scala-mode-hook 'ensime-scala-mode-hook)))

(use-package ido
  :config
  (ido-mode 1)
  (setq ido-use-faces nil)
  (use-package flx-ido :config (flx-ido-mode 1))
  (use-package ido-ubiquitous :config (ido-ubiquitous-mode)))

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
   (enable-paredit-mode)))
;; (enable-lispy 'emacs-lisp-mode-hook)

(use-package clojure-mode
  :mode "\\.clj\\'" "\\.cljs\\'"
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
    (use-package ac-cider
      :config
      (add-hook 'cider-mode-hook 'ac-flyspell-workaround)
      (add-hook 'cider-mode-hook 'ac-cider-setup)
      (add-hook 'cider-repl-mode-hook 'ac-cider-setup))
    (use-package cider-eldoc
      :config (add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode))
    (add-hook 'clojure-mode-hook #'aggressive-indent-mode)
    (add-hook 'cider-mode-hook #'aggressive-indent-mode)
    (add-hook 'clojure-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'cider-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'cider-repl-mode-hook 'turn-off-smartparens-mode)
    (add-hook 'clojure-mode-hook 'enable-paredit-mode)
    (add-hook 'cider-mode-hook 'enable-paredit-mode)
    (add-hook 'cider-repl-mode-hook 'enable-paredit-mode)
    ;; (enable-lispy 'clojure-mode-hook)
    ;; (enable-lispy 'cider-mode-hook)
    ;; (enable-lispy 'cider-repl-mode-hook)
    (setq cider-lein-command "~/bin/lein")
    (setq cider-repl-popup-stacktraces t)
    (setq cider-auto-select-error-buffer t)))

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

(use-package tramp
  :config
  (setq tramp-default-method "ssh")
  (add-to-list 'tramp-default-user-alist
	       '("ssh" "\\`jeff-desktop\\'" "jeff"))
  (add-to-list 'tramp-default-user-alist
	       '("ssh" "\\`jeff-laptop\\'" "jeff"))
  (add-to-list 'tramp-default-user-alist
	       '("ssh" "\\`server\\'" "jeff")))

(use-package slime-autoloads
  :commands slime
  :mode
  ("\\.lisp\\'" . lisp-mode)
  ("\\.asd\\'" . lisp-mode)
  :config
  (setq slime-contribs '(slime-fancy slime-tramp))
  (use-package slime
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
      (add-hook 'lisp-mode-hook 'set-up-slime-ac-fuzzy)
      (add-hook 'slime-repl-mode-hook 'set-up-slime-ac-fuzzy))))

(if (null (window-system))
    (require 'git-gutter)
  (require 'git-gutter-fringe))
(global-git-gutter-mode t)
(diminish 'git-gutter-mode)

(use-package magit
  :init (setq magit-last-seen-setup-instructions "1.4.0"))

(defvar custom-sml-theme (if (null window-system)
			     'powerline
			   'respectful))

(use-package smart-mode-line
  :init (setq sml/theme custom-sml-theme)
  :config
  ;; (use-package smart-mode-line-powerline-theme)
  (sml/setup)
  ;; (sml/apply-theme 'powerline)
  (sml/apply-theme custom-sml-theme))

(unless (null window-system)
  ;;(set-frame-font "Droid Sans Mono:pixelsize=18")
  (set-frame-font "Source Code Pro:pixelsize=18")) 

;;(switch-to-theme 'zenburn)
;;(switch-to-theme 'sanityinc-tomorrow-night)
;;(switch-to-theme 'spacegray)
;;(switch-to-theme 'sanityinc-tomorrow-day)
;;(switch-to-theme 'sanityinc-solarized-light)
;;(switch-to-theme 'sanityinc-solarized-dark)
(if (null window-system)
    (load-theme 'sanityinc-tomorrow-night t)
  (load-theme 'sanityinc-solarized-light t))
(sml/apply-theme custom-sml-theme)
;;(load-theme 'ample t)
;;(switch-to-theme 'molokai)

(if (null window-system)
    (progn
      (setq sml/name-width 34)
      (setq sml/mode-width 46))
  (progn
    (setq sml/name-width 34)
    (setq sml/mode-width 66)))

(load-local "keys")
(load-local "commands")

(unless (null window-system)
  (set-frame-size (selected-frame) 100 58))

(setq server-socket-dir
      (format "/tmp/%s/emacs%d" (user-login-name) (user-uid)))

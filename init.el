;; enable some repositories to be used by emacs to download packages ;
(require 'package)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

(setq package-enable-at-startup nil)
(package-initialize)

;; set default font
(set-default-font "Hack")

;; disable menu bar
(menu-bar-mode -1) 

;; enable auto pairing
(electric-pair-mode 1)

;; disable the scrollbar
(toggle-scroll-bar -1)

;; disable toolbar
(tool-bar-mode -1)

;; load theme by default
(load-theme 'dracula t)

;; use space instead of tab
(setq indent-tabs-mode nil)

;; tabs to two spaces in js mode
(setq js-indent-level 2)
;; intent specific code for major modes
(defun my-setup-indent (n)
  ;; web development
  (setq-local js-indent-level n) ; js-mode
)

;; enabling js beautify mode
(require 'web-beautify) ;; Not necessary if using ELPA package
(eval-after-load 'js2-mode
  '(define-key js2-mode-map (kbd "C-c b") 'web-beautify-js))
;; Or if you're using 'js-mode' (a.k.a 'javascript-mode')
(eval-after-load 'js
  '(define-key js-mode-map (kbd "C-c b") 'web-beautify-js))

(eval-after-load 'json-mode
  '(define-key json-mode-map (kbd "C-c b") 'web-beautify-js))

(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd "C-c b") 'web-beautify-html))

(eval-after-load 'web-mode
  '(define-key web-mode-map (kbd "C-c b") 'web-beautify-html))

(eval-after-load 'css-mode
  '(define-key css-mode-map (kbd "C-c b") 'web-beautify-css))

;; two space indent style
(defun two-space-indent ()
  (interactive)
  (message "Two space indent")
  ;; use space instead of tab
  (setq indent-tabs-mode nil)
  ;; indent 2 spaces width
  (my-setup-indent 2))

;; two space indent style
(defun four-space-indent ()
  (interactive)
  (message "Four space indent")
  ;; use space instead of tab
  (setq indent-tabs-mode nil)
  ;; indent 4 spaces width
  (my-setup-indent 4))

;; call the indentation for the modes you need
;; prog-mode-hook requires emacs24+
(add-hook 'prog-mode-hook 'four-space-indent)

;; two space indent only on typescript mode
(add-hook 'typescript-mode-hook 'two-space-indent)

;; enable line number in prog-mode only
(add-hook 'prog-mode-hook 'linum-mode)

;; to avoid line number breakage when zooming in
(eval-after-load "linum"
  '(set-face-attribute 'linum nil :height 100))

;; Tide mode for typescript
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)

;; enable projectile mode
(projectile-global-mode)

;; enable caching mode
(setq projectile-enable-caching t)

;; indexing folders for fast performance
(setq projectile-indexing-method 'native)

;; install your favorite packages all at once
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(use-package evil
  :ensure t)

(use-package magit
  :ensure t)

(require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)

;; enable evil mode by default
(require 'evil)
(evil-mode t)

(require 'helm)
(require 'helm-config)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(global-set-key (kbd "C-x b") 'helm-mini)

;; To enable fuzzy matching
(setq helm-buffers-fuzzy-matching t
      helm-recentf-fuzzy-match    t)

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t
      helm-echo-input-in-header-line t)

(defun spacemacs//helm-hide-minibuffer-maybe ()
  "Hide minibuffer in Helm session if we use the header line as input field."
  (when (with-helm-buffer helm-echo-input-in-header-line)
    (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
      (overlay-put ov 'window (selected-window))
      (overlay-put ov 'face
                   (let ((bg-color (face-background 'default nil)))
                     `(:background ,bg-color :foreground ,bg-color)))
      (setq-local cursor-type nil))))


(add-hook 'helm-minibuffer-set-up-hook
          'spacemacs//helm-hide-minibuffer-maybe)

(setq helm-autoresize-max-height 0)
(setq helm-autoresize-min-height 20)
(helm-autoresize-mode 1)

(helm-mode 1)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html$" . web-mode))

;; org mode

;; show when a TODO is done
(setq org-log-done 'time)

;; keep a log file for a todo when done
(setq org-log-done 'note)

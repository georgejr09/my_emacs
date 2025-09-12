;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1. PACKAGE MANAGEMENT
;; Configure Emacs's built-in package manager to use the MELPA repository.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-startup-screen t) ; Disable the splash screen

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Automatically install 'use-package' to simplify configuration.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq initial-major-mode 'org-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; paste image to org via org-download
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'org-download)
(setq-default org-download-image-dir "./img")


;; This hook ensures the key is only bound when you are in Org mode.
(add-hook 'org-mode-hook
          (lambda ()
            (define-key org-mode-map (kbd "C-M-y") 'org-download-yank)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2. CORE LISP SETUP (SLIME via Quicklisp)
;; This method loads SLIME directly from your Quicklisp installation.
;; It ensures the Emacs Lisp code for SLIME perfectly matches the server
;; (Swank) running in SBCL.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; First, ensure Quicklisp has installed the helper for us.
;; If you haven't done this, open SBCL and run: (ql:quickload :quicklisp-slime-helper)
;; (load (expand-file-name "~/quicklisp/slime-helper.el"))
;; NOTE: Emacs correctly understands "~/quicklisp/" on Windows.


(load (expand-file-name "~/quicklisp/slime-helper.el"))
  ;; Replace "sbcl" with the path to your implementation
(setq inferior-lisp-program "sbcl")

;; Set the Lisp implementation for Windows
;; (setq inferior-lisp-program "sbcl")

;; Load useful SLIME extensions (these are contribs that come with SLIME)
(slime-setup '(slime-fancy
               slime-autodoc
               slime-xref-browser))

;; Automatically start SLIME when a .lisp file is opened
(add-hook 'lisp-mode-hook
          (lambda ()
            (unless (slime-connected-p)
              (save-excursion (slime)))))

;; Enhanced scratch buffer setup
(require 'slime-scratch)
(setq slime-scratch-file "~/.slime-scratch.lisp")  ; Persistent scratch

;; Better scratch buffer bindings
(define-key slime-scratch-mode-map (kbd "C-c C-c") 'slime-compile-defun)
(define-key slime-scratch-mode-map (kbd "C-c C-e") 'slime-eval-last-expression)
(define-key slime-scratch-mode-map (kbd "C-c C-r") 'slime-eval-region)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; COMPANY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Auto-install required packages if not present
(unless (package-installed-p 'company)
  (package-refresh-contents)
  (package-install 'company))

(unless (package-installed-p 'slime-company)
  (package-refresh-contents)
  (package-install 'slime-company))

(unless (package-installed-p 'rainbow-delimiters)
  (package-refresh-contents)
  (package-install 'rainbow-delimiters))

(require 'company)
(global-company-mode t)

;; Company-mode settings for optimal auto-completion
(setq company-idle-delay 0.1              ; Start completion after 0.1 seconds
      company-minimum-prefix-length 1     ; Start completion after 1 character
      company-selection-wrap-around t     ; Wrap around in completion list
      company-tooltip-align-annotations t ; Align annotations in tooltip
      company-tooltip-limit 10            ; Limit tooltip to 10 entries
      company-show-numbers t              ; Show numbers for quick selection
      company-require-match nil)          ; Allow input not in completion list

;; Better company-mode key bindings
(with-eval-after-load 'company
  (define-key company-active-map (kbd "TAB") 'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "M-n") 'company-select-next)
  (define-key company-active-map (kbd "M-p") 'company-select-previous)
  (define-key company-active-map (kbd "C-d") 'company-show-doc-buffer))



;; ============================================
;; SLIME CONFIGURATION
;; ============================================

(require 'slime)
(setq inferior-lisp-program "sbcl")       ; Point to your SBCL installation
(setq slime-contribs '(slime-fancy))      ; Basic SLIME setup

;; Setup slime-company for auto-completion
(require 'slime-company)
(slime-setup '(slime-fancy slime-company slime-quicklisp))

;; Enable company-mode in SLIME buffers
(add-hook 'slime-mode-hook 'company-mode)
(add-hook 'slime-repl-mode-hook 'company-mode)

;; SLIME-specific settings
(setq slime-complete-symbol*-fancy t
      slime-complete-symbol-function 'slime-fuzzy-complete-symbol)



;; ============================================
;; COMMON LISP MODE ENHANCEMENTS
;; ============================================

;; Enable rainbow delimiters for better parentheses visualization
(add-hook 'lisp-mode-hook 'rainbow-delimiters-mode)
(add-hook 'slime-mode-hook 'rainbow-delimiters-mode)
(add-hook 'slime-repl-mode-hook 'rainbow-delimiters-mode)



;; Better indentation
(setq lisp-indent-function 'common-lisp-indent-function)


;; ============================================
;; ADDITIONAL USEFUL SETTINGS
;; ============================================

;; Show matching parentheses
(show-paren-mode 1)
(setq show-paren-delay 0)

;; Line numbers (optional)
(add-hook 'lisp-mode-hook 'display-line-numbers-mode)
(add-hook 'slime-mode-hook 'display-line-numbers-mode)

;; Auto-save and backup settings
(setq make-backup-files nil)              ; No backup files
(setq auto-save-default nil)              ; No auto-save files


;; ============================================
;; CUSTOM FUNCTIONS
;; ============================================

;; Quick function to restart SLIME
(defun restart-slime ()
  "Restart SLIME."
  (interactive)
  (slime-quit-lisp)
  (sleep-for 1)
  (slime))

;; Bind restart function to a key (optional)
(global-set-key (kbd "C-c C-r") 'restart-slime)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4. GENERAL UI TWEAKS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq-default cursor-type 'bar)
(show-paren-mode 1)
(column-number-mode 1)
(global-display-line-numbers-mode t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5. Enable treesit-auto
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Tree-sitter integration for existing SLIME + Smartparens setup

;; Install treesit-auto if needed
(unless (package-installed-p 'treesit-auto)
  (package-install 'treesit-auto))

;; Configure Common Lisp grammar source
(setq treesit-language-source-alist
      '((commonlisp "https://github.com/tree-sitter-grammars/tree-sitter-commonlisp")))

;; Install the grammar if not available
(unless (treesit-language-available-p 'commonlisp)
  (treesit-install-language-grammar 'commonlisp))

;; Define enhanced lisp-ts-mode
(define-derived-mode lisp-ts-mode lisp-mode "Lisp[TS]"
  "Common Lisp mode with tree-sitter support."
  :group 'lisp
  (when (treesit-ready-p 'commonlisp)
    (treesit-parser-create 'commonlisp)
    
    ;; Enhanced syntax highlighting
    (setq-local treesit-font-lock-feature-list
                '((comment definition)
                  (keyword string type)
                  (assignment builtin constant function variable)))
    
    ;; Tree-sitter indentation rules
    (setq-local treesit-simple-indent-rules
                `((commonlisp
                   ((node-is ")") parent-bol 0)
                   ((node-is "]") parent-bol 0)
                   ((parent-is "list") parent-bol ,(+ lisp-body-indent 2)))))
    
    ;; Enable tree-sitter features
    (treesit-major-mode-setup)))

;; Use tree-sitter mode for .lisp files
(add-to-list 'auto-mode-alist '("\\.lisp\\'" . lisp-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cl\\'" . lisp-ts-mode))
(add-to-list 'auto-mode-alist '("\\.asd\\'" . lisp-ts-mode))

;; Integrate with your existing SLIME setup
(add-hook 'lisp-ts-mode-hook 'slime-mode)
(add-hook 'lisp-ts-mode-hook 'smartparens-strict-mode)

;; Enhanced navigation using tree-sitter
(with-eval-after-load 'lisp-ts-mode
  (define-key lisp-ts-mode-map (kbd "C-M-a") 'treesit-beginning-of-defun)
  (define-key lisp-ts-mode-map (kbd "C-M-e") 'treesit-end-of-defun)
  (define-key lisp-ts-mode-map (kbd "C-M-h") 'treesit-mark-defun))

;; Tree-sitter aware SLIME evaluation
(defun slime-eval-defun-ts ()
  "Evaluate defun using tree-sitter boundaries."
  (interactive)
  (if (eq major-mode 'lisp-ts-mode)
      (save-excursion
        (treesit-beginning-of-defun)
        (let ((start (point)))
          (treesit-end-of-defun)
          (slime-eval-region start (point))))
    (slime-eval-defun)))

;; Bind enhanced evaluation
(with-eval-after-load 'slime
  (define-key slime-mode-map (kbd "C-M-x") 'slime-eval-defun-ts))









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ensure draggable window dividers are always visible
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(window-divider-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete Smartparens Configuration - Paredit Replacement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Complete Smartparens Configuration - Paredit Replacement
;; Install smartparens if needed
(unless (package-installed-p 'smartparens)
  (package-refresh-contents)
  (package-install 'smartparens))

;; Load smartparens
(require 'smartparens-config)

;; Enable smartparens globally
(smartparens-global-mode 1)
(show-smartparens-global-mode 1)

;; Configure smartparens behavior
(setq sp-highlight-pair-overlay nil
      sp-highlight-wrap-overlay nil
      sp-autoinsert-pair t
      show-paren-delay 0
      show-paren-style 'expression)
(show-paren-mode 1)

;; Enable strict mode in Lisp modes
(add-hook 'emacs-lisp-mode-hook 'smartparens-strict-mode)
(add-hook 'lisp-mode-hook 'smartparens-strict-mode)
(add-hook 'lisp-interaction-mode-hook 'smartparens-strict-mode)
(add-hook 'scheme-mode-hook 'smartparens-strict-mode)
(add-hook 'ielm-mode-hook 'smartparens-strict-mode)

;; Minibuffer setup
(defun sp-minibuffer-setup ()
  (smartparens-mode 1)
  (smartparens-strict-mode 1))
(add-hook 'eval-expression-minibuffer-setup-hook 'sp-minibuffer-setup)

;; SLIME integration (if available)
(with-eval-after-load 'slime
  (add-hook 'slime-repl-mode-hook 'smartparens-strict-mode))

;; Paredit-compatible keybindings
(with-eval-after-load 'smartparens
  (define-key smartparens-mode-map (kbd "C-M-f") 'sp-forward-sexp)
  (define-key smartparens-mode-map (kbd "C-M-b") 'sp-backward-sexp)
  (define-key smartparens-mode-map (kbd "C-M-u") 'sp-backward-up-sexp)
  (define-key smartparens-mode-map (kbd "C-M-d") 'sp-down-sexp)
  (define-key smartparens-mode-map (kbd "C-M-k") 'sp-kill-sexp)
  (define-key smartparens-mode-map (kbd "M-r") 'sp-raise-sexp)
  (define-key smartparens-mode-map (kbd "C-)") 'sp-forward-slurp-sexp)
  (define-key smartparens-mode-map (kbd "C-(") 'sp-backward-slurp-sexp))




;; --- Final Message ---
(message "Emacs configuration with Quicklisp SLIME loaded successfully!")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("3d39093437469a0ae165c1813d454351b16e4534473f62bc6e3df41bb00ae558" default))
 '(package-selected-packages
   '(paredit-menu company-org-block org-download paredit rainbow-delimiters slime-company tree-sitter-langs treesit-auto undo-tree)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

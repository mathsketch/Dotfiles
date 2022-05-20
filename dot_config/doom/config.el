;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; general
(setq scroll-margin 0
      hscroll-margin 10
      scroll-conservatively 10000)
(add-to-list 'auto-mode-alist '("\\.yuck\\'" . lisp-mode))
(setq browse-url-generic-program "qutebrowser"
      browse-url-browser-function 'browse-url-generic)
;; truncation glyph
(set-display-table-slot standard-display-table 0 ?\ )

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "mathsketch"
      user-mail-address "mathsketch@163.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 20 :weight 'normal)
      doom-variable-pitch-font (font-spec :family "JetBrains Mono" :size 20 :weight 'normal)
      doom-unicode-font (font-spec :family "FiraCode Nerd Font" :size 20 :weight 'normal)
      doom-big-font (font-spec :family "FiraCode Nerd Font" :size 22 :weight 'normal)
      doom-serif-font (font-spec :family "Comic Sans MS" :size 20 :weight 'normal))

(defun init-cjk-fonts()
  (dolist (charset '(kana han cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font)
      charset (font-spec :family "Sarasa Mono SC Nerd"))))

(when (display-graphic-p)
  (add-hook 'doom-init-ui-hook #'init-cjk-fonts))
(add-hook 'server-after-make-frame-hook #'init-cjk-fonts)

(custom-set-faces!
   '(font-lock-comment-face :slant italic))
;; '(font-lock-keyword-face :family "Hack Nerd Font Mono" :slant italic))

(custom-set-faces!
  '(aw-leading-char-face
    :foreground "#f9f5d7" :background "#cc241d"
    :weight bold :height 2.4))

(add-hook! 'rainbow-mode-hook
  (hl-line-mode (if rainbow-mode -1 +1)))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)
(setq doom-themes-treemacs-theme "doom-colors")

(setq doom-modeline-buffer-encoding t
      doom-modeline-indent-info t
      doom-modeline-major-mode-icon t)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type `relative)

;; window
(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))

;; clipboard
(setq select-enable-clipboard nil)
(map! :after evil
      "C-S-c"  #'clipboard-kill-ring-save
      "C-S-v" #'clipboard-yank)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documents/notes/Org")
;; (custom-set-faces
;;   '(org-level-1 ((t (:inherit outline-1 :height 1.3))))
;;   '(org-level-2 ((t (:inherit outline-2 :height 1.2))))
;;   '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
;;   '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
;;   '(org-level-5 ((t (:inherit outline-5 :height 1.0)))))

(setq deft-directory "~/Documents/notes/deft")
(setq +org-present-text-scale 1.2)
(after! org)

;; vertico
(after! vertico
  (map! :map vertico-map
        "C-l" #'+vertico/embark-preview))

;; lsp
(after! lsp-mode
  (setq lsp-enable-file-watchers nil))

;; disable flycheck buffer when ESC key pressed
(after! flycheck
  (remove-hook! 'doom-escape-hook #'+syntax-check-buffer-h))

;; tab config
(setq x-underline-at-descent-line t
      centaur-tabs-height 32
      centaur-tabs-style "wave"
      centaur-tabs-set-bar 'under
      centaur-tabs-set-modified-marker t
      centaur-tabs-modified-marker "")
(after! centaur-tabs
  (centaur-tabs-change-fonts "FiraCode Nerd Font" 115))

;; highlight-indent-guides
(setq highlight-indent-guides-responsive 'stack
      highlight-indent-guides-method 'bitmap
      highlight-indent-guides-bitmap-function 'highlight-indent-guides--bitmap-line)

;; packages
;; (use-package! centered-cursor-mode
;;   :config
;;   (setq global-centered-cursor-mode +1))
(use-package! terminal-here
  :bind
  :config
  (setq terminal-here-linux-terminal-command 'st)
  (map! :leader
        "o RET" #'terminal-here-launch
        "o S-<return>" #'terminal-here-project-launch))

(use-package! keycast
  :config
  (map! :leader "t k" #'keycast-mode)
  (define-minor-mode keycast-mode
   "Show current command and its key binding in the mode line."
   :global t
   (if (not keycast-mode)
       (progn (setq global-mode-string (delete '("" keycast-mode-line " ") global-mode-string))
              (remove-hook 'pre-command-hook 'keycast--update)
              (message "Keycast disabled"))
       (add-to-list 'global-mode-string '("" keycast-mode-line " "))
       (add-hook 'pre-command-hook 'keycast--update t)
       (message "Keycast enabled"))))


;; vterm
(after! vterm
  (setq vterm-always-compile-module t
        vterm-ignore-blink-cursor nil
        vterm-timer-delay 0.01))

;; flycheck
(after! flycheck
  (setq flycheck-idle-change-delay 5.0))

;; company
(after! company
  (setq company-backends '(company-files)))

;; zoxide
(add-hook 'find-file-hook 'zoxide-add)
(map! :leader "zd" #'zoxide-travel-with-query)
(map! :leader "zf" #'zoxide-find-file-with-query)

;; translation
(defun gts-method ()
  (interactive)
  (gts-translator
   :picker (gts-noprompt-picker)
   :engines (list (gts-bing-engine) (gts-google-engine))
   :render (gts-posframe-pin-render)))
   ;; :render (gts-buffer-render)))
   ;; :render (gts-posframe-pop-render
   ;;          :backcolor "#32302f" :forecolor "#f9f5d7")))

(use-package! go-translate
  :config
  (setq gts-tts-try-speak-locally t
        gts-buffer-follow-p t
        gts-translate-list '(("en" "zh"))
        gts-default-translator (gts-method))
  (custom-set-faces! '(gts-pop-posframe-me-header-face :inherit default))
  (custom-set-faces! '(gts-pop-posframe-me-header-2-face :inherit default))
  (add-hook 'gts-after-buffer-render-hook
            (lambda (&rest _)
              (turn-off-evil-mode -1))))


(map! :leader "C-f" #'gts-do-translate)
(map! :leader "m C-h" #'posframe-delete-all)

;; zen
(setq +zen-text-scale 1.05)

;; sublimity
(use-package! sublimity :config
  (use-package! sublimity-scroll :config
    (setq sublimity-scroll-weight 5
          sublimity-scroll-drift-length 8)
    (add-to-list 'sublimity-disabled-major-modes 'vterm-mode)
    (add-to-list 'sublimity-disabled-major-modes 'minibuffer-mode))
  (sublimity-mode 1))


;; eaf
;; (use-package! eaf
;;   :config
;;   ;; (use-package! eaf-evil)
;;   ;; (setq eaf-evil-leader-key "SPC")
;;   (use-package! eaf-browser)
;;   (use-package! eaf-terminal))

;; func
(defun my/open-link()
  (interactive)
  (let ((link (org-element-context)))
    (when (string= (org-element-property :type link) "file")
      (let ((path (org-element-property :path link)))
        (call-process "xdg-open" nil 0 nil path)))))

(map! :map org-mode-map
      :localleader "C-o" #'my/open-link)

;; keybind
(map! :after evil-commands
      :m "H" #'evil-beginning-of-line
      :m "L" #'evil-end-of-line)
(map! :leader "t a" #'centered-cursor-mode)
;; (map! "C-q"  )
; (good-scroll-mode 1)
;; (map! :after good-scroll
;;       "M-p" #'good-scroll-down-full-screen
;;       "M-n" #'good-scroll-up-full-screen)
(map! "C-<escape>" #'doom/escape)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; custom env 
(doom-load-envvars-file "~/.config/doom/env")

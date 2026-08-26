;;; zenwriter-mode-test.el --- ERT tests for zenwriter-mode -*- lexical-binding: t; -*-

;; Not tested in batch mode (requires graphical Emacs):
;; - Font application (font-family-list returns nil)
;; - Visual line wrapping (no window, falls back to logical lines)
;; - macOS appearance changes (ns-system-appearance-change-functions)
;; - post-command-hook firing (no interactive command loop)
;; - Olivetti centering (not installed)
;; - Ivy face accumulation fix (requires ivy)

;;; Code:

(require 'ert)
(require 'zenwriter-mode)

;; Ensure theme is loadable
(add-to-list 'custom-theme-load-path
             (file-name-directory
              (directory-file-name
               (file-name-directory (or load-file-name buffer-file-name)))))


;;; --- Helper macros ---

(defmacro zenwriter-test-with-buffer (name content &rest body)
  "Create a temp buffer named NAME with CONTENT, run BODY, clean up."
  (declare (indent 2))
  `(let ((buf (generate-new-buffer ,name)))
     (unwind-protect
         (with-current-buffer buf
           (when ,content (insert ,content))
           (goto-char (point-min))
           ,@body)
       (when (buffer-live-p buf)
         (with-current-buffer buf
           (when (bound-and-true-p zenwriter-focus-mode)
             (zenwriter-focus-mode -1))
           (when (bound-and-true-p zenwriter-mode)
             (zenwriter-mode -1)))
         (kill-buffer buf)))))

(defmacro zenwriter-test-with-global-mode (&rest body)
  "Enable `global-zenwriter-mode', run BODY, disable in unwind-protect."
  (declare (indent 0))
  `(unwind-protect
       (progn
         (global-zenwriter-mode 1)
         ,@body)
     (global-zenwriter-mode -1)))

(defmacro zenwriter-test-with-global-focus (&rest body)
  "Enable `global-zenwriter-focus-mode', run BODY, disable in unwind-protect."
  (declare (indent 0))
  `(unwind-protect
       (progn
         (global-zenwriter-focus-mode 1)
         ,@body)
     (global-zenwriter-focus-mode -1)))

(defun zenwriter-test--count-focus-overlays (&optional buffer)
  "Count overlays with `zenwriter-focus' property in BUFFER or current buffer."
  (with-current-buffer (or buffer (current-buffer))
    (length (seq-filter (lambda (ov) (overlay-get ov 'zenwriter-focus))
                        (overlays-in (point-min) (point-max))))))


;;; --- A. Theme tests ---

(ert-deftest zenwriter-test-theme-loads ()
  "Theme loads without error and appears in custom-enabled-themes."
  (unwind-protect
      (progn
        (load-theme 'zenwriter t)
        (should (memq 'zenwriter custom-enabled-themes)))
    (disable-theme 'zenwriter)))

(ert-deftest zenwriter-test-theme-known ()
  "After loading, zenwriter is in custom-known-themes."
  (unwind-protect
      (progn
        (load-theme 'zenwriter t)
        (should (memq 'zenwriter custom-known-themes)))
    (disable-theme 'zenwriter)))

(ert-deftest zenwriter-test-theme-faces-defined ()
  "Key faces have theme-face property with zenwriter entry."
  (unwind-protect
      (progn
        (load-theme 'zenwriter t)
        (dolist (face '(default cursor region font-lock-comment-face
                        org-level-1 markdown-header-face-1))
          (let ((specs (get face 'theme-face)))
            (should specs)
            (should (assq 'zenwriter specs)))))
    (disable-theme 'zenwriter)))

(ert-deftest zenwriter-test-theme-light-dark-specs ()
  "Each themed face has both light and dark class variants."
  (unwind-protect
      (progn
        (load-theme 'zenwriter t)
        (dolist (face '(default cursor region fringe mode-line))
          (let* ((specs (get face 'theme-face))
                 (zenwriter-spec (cdr (assq 'zenwriter specs)))
                 (spec-str (format "%S" zenwriter-spec)))
            (should (string-match-p "background light" spec-str))
            (should (string-match-p "background dark" spec-str)))))
    (disable-theme 'zenwriter)))

(ert-deftest zenwriter-test-theme-disable-enable ()
  "Theme can be disabled and re-enabled."
  (unwind-protect
      (progn
        (load-theme 'zenwriter t)
        (should (memq 'zenwriter custom-enabled-themes))
        (disable-theme 'zenwriter)
        (should-not (memq 'zenwriter custom-enabled-themes))
        (enable-theme 'zenwriter)
        (should (memq 'zenwriter custom-enabled-themes)))
    (disable-theme 'zenwriter)))


;;; --- B. Custom variables ---

(ert-deftest zenwriter-test-custom-defaults ()
  "Custom variables have expected default values."
  (should (= zenwriter-line-spacing 8))
  (should (= zenwriter-body-width 100))
  (should (null zenwriter-focus-dimmed-color))
  (should (= zenwriter-font-size 200)))

(ert-deftest zenwriter-test-custom-types ()
  "All defcustom variables have a :type property."
  (dolist (var '(zenwriter-font-family zenwriter-font-size
                 zenwriter-line-spacing zenwriter-body-width
                 zenwriter-focus-dimmed-color))
    (should (get var 'custom-type))))


;;; --- C. zenwriter-mode (buffer-local) ---

(ert-deftest zenwriter-test-mode-enables ()
  "Enabling zenwriter-mode sets line-spacing."
  (zenwriter-test-with-buffer "test-mode" "hello"
    (zenwriter-mode 1)
    (should zenwriter-mode)
    (should (= line-spacing zenwriter-line-spacing))))

(ert-deftest zenwriter-test-mode-saves-restores-line-spacing ()
  "Mode saves and restores previous line-spacing."
  (zenwriter-test-with-buffer "test-spacing" "hello"
    (setq line-spacing 3)
    (zenwriter-mode 1)
    (should (= zenwriter--saved-line-spacing 3))
    (should (= line-spacing zenwriter-line-spacing))
    (zenwriter-mode -1)
    (should (= line-spacing 3))))

(ert-deftest zenwriter-test-mode-disables ()
  "Disabling zenwriter-mode restores state."
  (zenwriter-test-with-buffer "test-disable" "hello"
    (let ((orig line-spacing))
      (zenwriter-mode 1)
      (zenwriter-mode -1)
      (should-not zenwriter-mode)
      (should (equal line-spacing orig)))))

(ert-deftest zenwriter-test-mode-toggle-idempotent ()
  "Multiple enable/disable cycles restore original state."
  (zenwriter-test-with-buffer "test-idempotent" "hello"
    (let ((orig line-spacing))
      (dotimes (_ 5)
        (zenwriter-mode 1)
        (zenwriter-mode -1))
      (should (equal line-spacing orig)))))

(ert-deftest zenwriter-test-mode-redundant-enable-preserves-state ()
  "Enabling an active buffer mode must not replace its saved state."
  (zenwriter-test-with-buffer "test-redundant-enable" "hello"
    (setq line-spacing 3)
    (zenwriter-mode 1)
    (zenwriter-mode 1)
    (zenwriter-mode -1)
    (should (= line-spacing 3))))


;;; --- D. global-zenwriter-mode ---

(ert-deftest zenwriter-test-global-loads-theme ()
  "global-zenwriter-mode loads the zenwriter theme."
  (zenwriter-test-with-global-mode
    (should (memq 'zenwriter custom-enabled-themes))))

(ert-deftest zenwriter-test-global-hides-chrome ()
  "global-zenwriter-mode disables menu-bar, tool-bar, scroll-bar."
  (zenwriter-test-with-global-mode
    (should (null menu-bar-mode))
    (should (null tool-bar-mode))
    (should (null scroll-bar-mode))))

(ert-deftest zenwriter-test-global-sets-modeline ()
  "global-zenwriter-mode sets minimal mode-line."
  (zenwriter-test-with-global-mode
    (should (equal (default-value 'mode-line-format) '(" ")))))

(ert-deftest zenwriter-test-global-restores-state ()
  "Disabling global-zenwriter-mode restores previous state."
  (let ((orig-ml (default-value 'mode-line-format))
        (orig-menu menu-bar-mode)
        (orig-tool tool-bar-mode)
        (orig-scroll scroll-bar-mode))
    (zenwriter-test-with-global-mode
      nil)
    (should (equal (default-value 'mode-line-format) orig-ml))
    (should (eq menu-bar-mode orig-menu))
    (should (eq tool-bar-mode orig-tool))
    (should (eq scroll-bar-mode orig-scroll))))

(ert-deftest zenwriter-test-global-hooks ()
  "global-zenwriter-mode manages after-change-major-mode-hook."
  (zenwriter-test-with-global-mode
    (should (memq #'zenwriter--turn-on after-change-major-mode-hook)))
  (should-not (memq #'zenwriter--turn-on after-change-major-mode-hook)))

(ert-deftest zenwriter-test-global-toggle-twice ()
  "Two full enable/disable cycles complete without error."
  (dotimes (_ 2)
    (global-zenwriter-mode 1)
    (global-zenwriter-mode -1))
  (should (null zenwriter--global-saved-state))
  (should-not global-zenwriter-mode))

(ert-deftest zenwriter-test-global-redundant-enable-preserves-state ()
  "Enabling an active global mode must not replace its saved state."
  (let ((orig-ml (copy-tree (default-value 'mode-line-format)))
        (orig-themes (copy-sequence custom-enabled-themes)))
    (unwind-protect
        (progn
          (global-zenwriter-mode 1)
          (global-zenwriter-mode 1)
          (global-zenwriter-mode -1)
          (should-not global-zenwriter-mode)
          (should (equal (default-value 'mode-line-format) orig-ml))
          (should (equal custom-enabled-themes orig-themes))
          (should (null zenwriter--global-saved-state)))
      (when global-zenwriter-mode
        (global-zenwriter-mode -1))
      (setq-default mode-line-format orig-ml)
      (mapc #'disable-theme custom-enabled-themes)
      (dolist (theme (reverse orig-themes))
        (if (memq theme custom-known-themes)
            (enable-theme theme)
          (load-theme theme t))))))

(ert-deftest zenwriter-test-global-layers-over-existing-theme ()
  "Global mode must leave the existing theme enabled underneath Zenwriter."
  (let ((orig-themes (copy-sequence custom-enabled-themes)))
    (unwind-protect
        (progn
          (mapc #'disable-theme custom-enabled-themes)
          (load-theme 'wombat t)
          (global-zenwriter-mode 1)
          (should (equal custom-enabled-themes '(zenwriter wombat)))
          (global-zenwriter-mode -1)
          (should (equal custom-enabled-themes '(wombat))))
      (when global-zenwriter-mode
        (global-zenwriter-mode -1))
      (mapc #'disable-theme custom-enabled-themes)
      (dolist (theme (reverse orig-themes))
        (if (memq theme custom-known-themes)
            (enable-theme theme)
          (load-theme theme t))))))

(ert-deftest zenwriter-test-global-restores-nil-modeline ()
  "A nil modeline is valid pre-mode state and must be restored exactly."
  (let ((orig-ml (copy-tree (default-value 'mode-line-format))))
    (unwind-protect
        (progn
          (setq-default mode-line-format nil)
          (global-zenwriter-mode 1)
          (global-zenwriter-mode -1)
          (should-not (default-value 'mode-line-format)))
      (when global-zenwriter-mode
        (global-zenwriter-mode -1))
      (setq-default mode-line-format orig-ml))))

(ert-deftest zenwriter-test-global-disable-keeps-snapshot-on-error ()
  "An interrupted disable must restore the modeline and retain retry state."
  (let ((orig-ml (copy-tree (default-value 'mode-line-format))))
    (unwind-protect
        (progn
          (global-zenwriter-mode 1)
          (cl-letf (((symbol-function 'scroll-bar-mode)
                     (lambda (&rest _)
                       (error "simulated restoration failure"))))
            (should-error (global-zenwriter-mode -1)))
          (should (equal (default-value 'mode-line-format) orig-ml))
          (should zenwriter--global-saved-state)
          ;; The retained snapshot lets an explicit disable retry finish.
          (global-zenwriter-mode -1)
          (should (null zenwriter--global-saved-state)))
      (when zenwriter--global-saved-state
        (global-zenwriter-mode -1))
      (setq-default mode-line-format orig-ml))))


;;; --- E. custom-set protection ---

(ert-deftest zenwriter-test-custom-set-after-enable ()
  "custom-set property is restored after enabling global mode."
  (let ((orig-cs (get 'global-zenwriter-mode 'custom-set)))
    (zenwriter-test-with-global-mode
      (should (equal (get 'global-zenwriter-mode 'custom-set) orig-cs)))))

(ert-deftest zenwriter-test-custom-set-after-disable ()
  "custom-set property is restored after full enable/disable cycle."
  (let ((orig-cs (get 'global-zenwriter-mode 'custom-set)))
    (global-zenwriter-mode 1)
    (global-zenwriter-mode -1)
    (should (equal (get 'global-zenwriter-mode 'custom-set) orig-cs))))


;;; --- F. zenwriter-focus-mode (buffer-local) ---

(ert-deftest zenwriter-test-focus-creates-overlays ()
  "Focus mode creates exactly 2 tagged overlays."
  (zenwriter-test-with-buffer "test-focus" "line1\nline2\nline3\n"
    (zenwriter-focus-mode 1)
    (should (= (zenwriter-test--count-focus-overlays) 2))
    (should zenwriter--focus-before-ov)
    (should zenwriter--focus-after-ov)))

(ert-deftest zenwriter-test-focus-overlay-properties ()
  "Focus overlays have correct priority and face."
  (zenwriter-test-with-buffer "test-props" "line1\nline2\n"
    (zenwriter-focus-mode 1)
    (should (= (overlay-get zenwriter--focus-before-ov 'priority) 100))
    (should (= (overlay-get zenwriter--focus-after-ov 'priority) 100))
    (let ((face-before (overlay-get zenwriter--focus-before-ov 'face))
          (face-after (overlay-get zenwriter--focus-after-ov 'face)))
      (should (plist-get face-before :foreground))
      (should (plist-get face-after :foreground)))))

(ert-deftest zenwriter-test-focus-removes-overlays ()
  "Disabling focus mode removes all overlays."
  (zenwriter-test-with-buffer "test-remove" "line1\nline2\n"
    (zenwriter-focus-mode 1)
    (should (= (zenwriter-test--count-focus-overlays) 2))
    (zenwriter-focus-mode -1)
    (should (= (zenwriter-test--count-focus-overlays) 0))
    (should-not zenwriter--focus-before-ov)
    (should-not zenwriter--focus-after-ov)))

(ert-deftest zenwriter-test-focus-update-positions ()
  "Overlays partition the buffer around the current line after update.
In batch mode, visual line functions fall back to logical lines."
  (zenwriter-test-with-buffer "test-positions" "aaa\nbbb\nccc\n"
    (zenwriter-focus-mode 1)
    (forward-line 1)
    (zenwriter--focus-update)
    (let ((before-start (overlay-start zenwriter--focus-before-ov))
          (before-end (overlay-end zenwriter--focus-before-ov))
          (after-start (overlay-start zenwriter--focus-after-ov))
          (after-end (overlay-end zenwriter--focus-after-ov)))
      (should (= before-start (point-min)))
      (should (= after-end (point-max)))
      (should (<= before-end after-start))
      (should (<= before-end (point)))
      (should (>= after-start (point))))))

(ert-deftest zenwriter-test-focus-dimmed-color-fallback ()
  "Dimmed color returns fallback when face fg is nil."
  (let ((zenwriter-focus-dimmed-color nil))
    (let ((color (zenwriter--focus-dimmed-color)))
      (should (stringp color)))))

(ert-deftest zenwriter-test-focus-dimmed-color-custom ()
  "Custom dimmed color is respected."
  (let ((zenwriter-focus-dimmed-color "#AABBCC"))
    (should (equal (zenwriter--focus-dimmed-color) "#AABBCC"))))

(ert-deftest zenwriter-test-focus-toggle-no-leak ()
  "Repeated enable/disable cycles produce no leaked overlays."
  (zenwriter-test-with-buffer "test-leak" "line1\nline2\nline3\n"
    (dotimes (_ 10)
      (zenwriter-focus-mode 1)
      (zenwriter-focus-mode -1))
    (should (= (zenwriter-test--count-focus-overlays) 0))))


;;; --- G. Overlay leak scenarios ---

(ert-deftest zenwriter-test-focus-orphan-cleanup-by-tag ()
  "Orphaned overlays (from kill-all-local-variables) can be cleaned via tag."
  (zenwriter-test-with-buffer "test-orphan" "line1\nline2\n"
    (zenwriter-focus-mode 1)
    (should (= (zenwriter-test--count-focus-overlays) 2))
    (kill-all-local-variables)
    ;; Overlays still exist but tracking vars are gone
    (should (= (zenwriter-test--count-focus-overlays) 2))
    (should-not (bound-and-true-p zenwriter--focus-before-ov))
    ;; Tag-based cleanup works
    (remove-overlays (point-min) (point-max) 'zenwriter-focus t)
    (should (= (zenwriter-test--count-focus-overlays) 0))))

(ert-deftest zenwriter-test-focus-global-disable-after-kill-local ()
  "Global focus disable cleans up after kill-all-local-variables."
  (zenwriter-test-with-buffer "test-global-orphan" "line1\nline2\n"
    (zenwriter-test-with-global-focus
      (should (= (zenwriter-test--count-focus-overlays) 2))
      (kill-all-local-variables))
    ;; After global disable (in unwind-protect), overlays should be gone
    (should (= (zenwriter-test--count-focus-overlays) 0))))

(ert-deftest zenwriter-test-focus-reenable-after-kill-local ()
  "Re-enabling focus after kill-all-local-variables cleans orphans."
  (zenwriter-test-with-buffer "test-reenable" "line1\nline2\n"
    (zenwriter-focus-mode 1)
    (kill-all-local-variables)
    ;; 2 orphaned overlays
    (should (= (zenwriter-test--count-focus-overlays) 2))
    ;; Re-enable: defensive cleanup should remove orphans, create fresh pair
    (zenwriter-focus-mode 1)
    (should (= (zenwriter-test--count-focus-overlays) 2))
    (zenwriter-focus-mode -1)
    (should (= (zenwriter-test--count-focus-overlays) 0))))


;;; --- H. global-zenwriter-focus-mode ---

(ert-deftest zenwriter-test-global-focus-enables-all ()
  "global-zenwriter-focus-mode enables focus in multiple buffers."
  (let ((bufs (list (generate-new-buffer "focus-a")
                    (generate-new-buffer "focus-b")
                    (generate-new-buffer "focus-c"))))
    (unwind-protect
        (progn
          (dolist (buf bufs)
            (with-current-buffer buf (insert "text\n")))
          (zenwriter-test-with-global-focus
            (dolist (buf bufs)
              (with-current-buffer buf
                (should zenwriter-focus-mode)
                (should (= (zenwriter-test--count-focus-overlays) 2))))))
      (dolist (buf bufs)
        (when (buffer-live-p buf) (kill-buffer buf))))))

(ert-deftest zenwriter-test-global-focus-skips-hidden ()
  "global-zenwriter-focus-mode skips space-prefixed buffers."
  (let ((hidden (generate-new-buffer " hidden-test")))
    (unwind-protect
        (zenwriter-test-with-global-focus
          (with-current-buffer hidden
            (should-not (bound-and-true-p zenwriter-focus-mode))))
      (when (buffer-live-p hidden) (kill-buffer hidden)))))

(ert-deftest zenwriter-test-global-focus-disables-all ()
  "Disabling global focus cleans up all buffers."
  (let ((bufs (list (generate-new-buffer "cleanup-a")
                    (generate-new-buffer "cleanup-b"))))
    (unwind-protect
        (progn
          (dolist (buf bufs)
            (with-current-buffer buf (insert "text\n")))
          (zenwriter-test-with-global-focus
            nil)
          ;; After disable
          (dolist (buf bufs)
            (with-current-buffer buf
              (should-not (bound-and-true-p zenwriter-focus-mode))
              (should (= (zenwriter-test--count-focus-overlays) 0))
              (should-not (memq #'zenwriter--focus-update
                                (buffer-local-value 'post-command-hook buf))))))
      (dolist (buf bufs)
        (when (buffer-live-p buf) (kill-buffer buf))))))

(ert-deftest zenwriter-test-global-focus-hooks ()
  "global-zenwriter-focus-mode manages after-change-major-mode-hook."
  (zenwriter-test-with-global-focus
    (should (memq #'zenwriter--focus-turn-on after-change-major-mode-hook)))
  (should-not (memq #'zenwriter--focus-turn-on after-change-major-mode-hook)))


;;; --- I. State save/restore internals ---

(ert-deftest zenwriter-test-state-read-does-not-consume-snapshot ()
  "Reading saved state must leave the snapshot available for a retry."
  (let ((zenwriter--global-saved-state '((test-key . 42))))
    (should (= (zenwriter--global-state-value 'test-key) 42))
    (should (= (zenwriter--global-state-value 'test-key) 42))
    (should (equal zenwriter--global-saved-state '((test-key . 42))))))

(provide 'zenwriter-mode-test)

;;; zenwriter-mode-test.el ends here

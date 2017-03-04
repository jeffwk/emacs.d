(setq custom-frame-width 100)
(setq custom-frame-height 58)

(defun set-custom-theme ()
  (if (some #'display-graphic-p (frame-list))
      (setq custom-emacs-theme 'sanityinc-tomorrow-night)
    (setq custom-emacs-theme 'sanityinc-tomorrow-night-rxvt)))

;;(set-frame-font "Sauce Code Pro Medium:pixelsize=40")
;;(set-frame-font "Sauce Code Pro Medium:pixelsize=29")
;;(set-frame-font "Source Code Pro Medium:pixelsize=30")
;;(set-frame-font "Sauce Code Pro Semibold:pixelsize=30")
;;(set-frame-font "Inconsolata for Powerline:pixelsize=36")
;;(set-frame-font "Monaco:pixelsize=30")
;;(set-frame-font "DejaVu Sans Mono:pixelsize=30")
;;(set-frame-font "Anonymous Pro:pixelsize=38")
;;(set-frame-font "MesloLGS:pixelsize=31")
;;(set-frame-font "Roboto Mono:pixelsize=30")
;;(window-size (selected-window))
;;(window-margins (selected-window))

;;; deep-ocean-fishing.el --- Deep Ocean Fishing, a game of fishing

;;; Commentary:
;; 

;;; Code:

(require 'widget)

(defvar deep-ocean-fishing-main-buffer-name "*DOF*")

(defvar deep-ocean-fishing-inventory
  '(("shoe" . 5)))

(defvar deep-ocean-fishing-money 30)
(defvar deep-ocean-fishing-has-bait nil)
(defvar deep-ocean-fishing-has-better-fishing-rod nil)

(defvar deep-ocean-fishing-bait-widget nil)
(defvar deep-ocean-fishing-better-fishing-rod-widget nil)
(defvar deep-ocean-fishing-inventory-widgets '())

(defun deep-ocean-fishing-fish nil
  (let ((roll (random 100))
		  (amount (random (+ 3 (if deep-ocean-fishing-has-bait 3 0)
									(if deep-ocean-fishing-has-better-fishing-rod 5 0)))))
	 (cond ((< roll 20)
			  (message (format "You've fished out %d shoes." amount))
			  (dotimes (i amount)
				 (setq deep-ocean-fishing-inventory
						 (append deep-ocean-fishing-inventory '(("shoe" . (+ 5 (random 5))))))))
			 ((and (>= roll 20) (< roll 50))
			  (message (format "You've fished out %d anglerfish." amount))
			  (dotimes (i amount)
				 (setq deep-ocean-fishing-inventory
						 (append deep-ocean-fishing-inventory '(("anglerfish" . (+ 15 (random 5))))))))
			 ((and (>= roll 50) (< roll 80))
			  (message (format "You've fished out %d longfish." amount))
			  (dotimes (i amount)
				 (setq deep-ocean-fishing-inventory
						 (append deep-ocean-fishing-inventory '(("longfish" . (+ 30 (random 7))))))))
			 ((and (>= roll 50) (<= roll 80))
			  (message (format "You've fished out %d sums." amount))
			  (dotimes (i amount)
				 (setq deep-ocean-fishing-inventory
						 (append deep-ocean-fishing-inventory '(("sum" . (+ 70 (random 20)))))))))))

(defun deep-ocean-fishing-shop-sell (&rest ignore)
  (dolist (widget deep-ocean-fishing-inventory-widgets)
	 (setq deep-ocean-fishing-money (+ deep-ocean-fishing-money (cdr (plist-get widget :args))))
	 (setq deep-ocean-fishing-inventory (delq (assoc (car (plist-get widget :args)) deep-ocean-fishing-inventory) deep-ocean-fishing-inventory))
  (deep-ocean-fishing-shop)))

(defun deep-ocean-fishing-shop nil
  (with-current-buffer deep-ocean-fishing-main-buffer-name
	 (let ((inhibit-read-only t))
		(erase-buffer))
	 (widget-create 'push-button
						 :notify (lambda (&rest ignore) (deep-ocean-fishing-main))
						 "Go back")
	 (widget-insert (format "\nYour money: %d\n" deep-ocean-fishing-money))
	 (widget-insert "\nBuy:\n")
	 (setq deep-ocean-fishing-bait-widget (widget-create 'checkbox nil))
	 (widget-insert " bait ($10), lets you get better fish out of the ocean.\n")
	 (setq deep-ocean-fishing-better-fishing-rod-widget (widget-create 'checkbox nil))
	 (widget-insert " better fishing rod ($100), lets you get better fish out of the ocean.\n")
	 (widget-create 'push-button "Buy")
	 (widget-insert "\nInventory:\n")
	 (setq deep-ocean-fishing-inventory-widgets '())
	 (dolist (item deep-ocean-fishing-inventory)
		(setq deep-ocean-fishing-inventory-widgets
				(append deep-ocean-fishing-inventory-widgets (list (widget-create 'checkbox :value nil :args item))))
		(widget-insert (concat " " (car item) " ($" (number-to-string (cdr item)) ")\n")))
	 (widget-create 'push-button
						 :notify 'deep-ocean-fishing-shop-sell
						 "Sell")
	 (widget-setup)))

(defun deep-ocean-fishing-main nil
  (with-current-buffer deep-ocean-fishing-main-buffer-name
	 (let ((inhibit-read-only t))
		(erase-buffer))
	 (widget-create 'push-button
						 :notify (lambda (&rest ignore) (deep-ocean-fishing-fish))
						 "Fish a bit")
	 (widget-insert "\n")
	 (widget-create 'push-button
						 :notify (lambda (&rest ignore) (deep-ocean-fishing-shop))
						 "Go visit the shop")
	 (widget-setup)))

(defun deep-ocean-fishing nil
  "Play Deep Ocean Fishing."
  (interactive)
  (let ((buffer (get-buffer-create "*DOF*")))
	 (with-current-buffer buffer
		(deep-ocean-fishing-main)
		(deep-ocean-fishing-main-mode))
	 (switch-to-buffer buffer)))

(define-derived-mode deep-ocean-fishing-main-mode nil "DOF"
  "Deep Ocean Fishing mode for the main screen."
  (kill-all-local-variables)
  (setq-local buffer-read-only t)
  (use-local-map widget-keymap))

(provide 'deep-ocean-fishing)

;;; deep-ocean-fishing.el ends here

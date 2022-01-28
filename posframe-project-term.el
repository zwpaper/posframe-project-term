;;; posframe-project-term.el --- Posframe Terminal based on Project Root -*- lexical-binding: t -*-

;; Copyright (C) 2021-2022 kWeiZh.

;; Author: Wei Zhang <kweizh@gmail.com>
;; URL: https://github.com/kweizh/posframe-project-root
;; Version: 0.1.0
;; Package-Requires: ((posframe) (projectile) (vterm))
;; Keywords: posframe terminal

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; This package is used to manage posframe popup terminals
;; based on file's project root

;;; Code:


(require 'projectile)
(require 'posframe)
(require 'vterm)

(defvar posframe-project-term-prefix "posframe-project-term")

(defun posframe-project-term--buffer-name ()
  (format "%s<%s>"
          posframe-project-term-prefix
          (if (string= (projectile-project-name) "-")
              (buffer-file-name)
            (projectile-project-name))))

(defun posframe-project-term--bufferp ()
  (and (eq major-mode 'vterm-mode)
       (string-prefix-p posframe-project-term-prefix (buffer-name))))

;;; (when (childframe-workable-p)

(defun posframe-project-term-toggle ()
  "Toggle `vterm' child frame.
The child frame will use the project root or current directory as default-directory"
  (interactive)
  (if (posframe-project-term--bufferp)
      (posframe-delete-frame (current-buffer))
    (let ((default-directory (or (projectile-project-root)
                                 (file-name-directory buffer-file-name)))
          (ppt-buffer-name (posframe-project-term--buffer-name)))
      (let ((ppt-buffer (or (get-buffer ppt-buffer-name)
                            (vterm--internal #'ignore ppt-buffer-name)))
            (width  (max 80 (/ (frame-width) 2)))
            (height (/ (frame-height) 2)))
        (posframe-show
         ppt-buffer
         :poshandler #'posframe-poshandler-frame-center
         :left-fringe 8
         :right-fringe 8
         :width width
         :height height
         :min-width width
         :min-height height
         :internal-border-width 3
         :internal-border-color (face-foreground 'font-lock-comment-face nil t)
         ;; :background-color (face-background 'tooltip nil t)
         :accept-focus t)
        (with-current-buffer ppt-buffer
          (goto-char (point-max)))))))

(defun posframe-project-term-switch (arg)
  (interactive (list (completing-read "Terms" (buffer-list))))
  (message arg))

(defun posframe-project-term-killall ()
  "Kill all buffers created by posframe-project-term."
  (interactive)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (posframe-project-term--bufferp)
        (posframe-delete buffer)))))

(provide 'posframe-project-term)

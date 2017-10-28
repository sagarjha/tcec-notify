#!/usr/bin/emacs --script

(defun get-page (url html-file)
  (shell-command (concat "phantomjs save_page.js " url " > " html-file)))

(defun find-title (file)
  (progn
    (set-buffer file)
    (revert-buffer t t)
    (goto-char (point-min))
    (search-forward-regexp "<title>.*</title>")
    (beginning-of-line)
    (search-forward "<title>")
    (setq beg (point))
    (search-forward "- TCEC - Live Computer Chess Broadcast")
    (setq end (point))
    (setq title-line (buffer-substring-no-properties beg end))
    title-line))

(defun send-mail (subject)
  (progn
    (mail)
    (mail-to) (insert "sample-email@gmail.com")
    (mail-to) (insert ", sample-email@gmail.com")
    (mail-subject) (insert subject)
    (mail-text) (insert "")
    (mail-send)))

(defun run-tcec-notify ()
  (while 1
  (progn
    (setq if-error 1)
    (while if-error
      (condition-case nil
	  (progn
	    (setq if-error nil) 
	    (get-page tcec-url tcec-html-file)
	    (setq tcec-title (find-title tcec-html-file)))
	(error (setq if-error 1))))
    (when (not (string= tcec-title old-tcec-title))
      (progn
	(print "Sending email")
	(setq old-tcec-title tcec-title)
	(send-mail tcec-title)))
    (print "Sleeping for 5 minutes")
    (sit-for 300))))

(setq tcec-url "http://tcec.chessdom.com/live.php")
(setq tcec-html-file "tcec-live.html")
(find-file tcec-html-file)
(setq old-tcec-title "")
(custom-set-variables
 '(send-mail-function (quote smtpmail-send-it))
 '(smtpmail-smtp-server "smtp.gmail.com")
 '(smtpmail-smtp-service 25))
(run-tcec-notify)

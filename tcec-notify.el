#!/usr/bin/emacs --script

(defun get-page (url html-file)
  (shell-command (concat "phantomjs save_page.js " url " > " html-file)))

(defun write-tcec-title (title-file new-title)
  (set-buffer title-file)
  (erase-buffer)
  (insert new-title "\n")
  (save-buffer))

(defun write-log (log-file str)
  (set-buffer log-file)
  (goto-char (point-max))
  (insert (prin1-to-string str) "\n")
  (save-buffer))

(defun read-old-tcec-title (title-file)
  (find-file title-file)
  (buffer-disable-undo)
  (set-buffer title-file)
  (goto-char (point-min))
  (setq beg (point))
  (end-of-line)
  (setq end (point))
  (buffer-substring-no-properties beg end))

(defun find-title (file)
  (set-buffer file)
  (revert-buffer t t)
  (goto-char (point-min))
  (setq beg (point))
  (end-of-line)
  (setq end (point))
  (setq title-line (buffer-substring-no-properties beg end))
  (if (string-match-p (regexp-quote tcec-title-suffix) title-line)
      title-line
    (error "Title not correct")))

(defun send-mail (subject)
  (mail)
  (mail-to) (insert "sjsagarjha3@gmail.com, tcec-notify@googlegroups.com")
  (mail-subject) (insert subject)
  (mail-text) (insert "Go to " tcec-url " to view the game.")
  (mail-send))

(defun run-tcec-notify ()
  (while 1
  (progn
    (setq if-error 1)
    (while if-error
      (condition-case err
	  (progn
	    (setq if-error nil) 
	    (get-page tcec-url tcec-html-file)
	    (setq tcec-title (find-title tcec-html-file)))
	(error (progn
		 (write-log tcec-log-file err)
		 (setq if-error 1)))))
    (when (not (string= tcec-title old-tcec-title))
      (progn
	(write-log tcec-log-file "Sending email")
	(setq old-tcec-title tcec-title)
	(write-tcec-title tcec-title-file tcec-title)
	(send-mail tcec-title)))
    (write-log tcec-log-file "Sleeping for 5 minutes")
    (sit-for 300))))

(sit-for 60)
(setq tcec-log-file "tcec-notify.log")
(find-file tcec-log-file)
(buffer-disable-undo)
(set-buffer tcec-log-file)
(erase-buffer)
(save-buffer)
(write-log tcec-log-file "Starting tcec-notify")
(setq tcec-url "http://tcec.chessdom.com/live.php")
(setq tcec-html-file "tcec-live.html")
(setq tcec-title-file "tcec-title")
(setq tcec-title-suffix "- TCEC - Live Computer Chess Broadcast")
(find-file tcec-html-file)
(buffer-disable-undo)
(setq old-tcec-title (read-old-tcec-title tcec-title-file))
(write-log tcec-log-file (concat "Old TCEC title is: " old-tcec-title))
(custom-set-variables
 '(send-mail-function (quote smtpmail-send-it))
 '(smtpmail-smtp-server "smtp.gmail.com")
 '(smtpmail-smtp-service 25))
(run-tcec-notify)

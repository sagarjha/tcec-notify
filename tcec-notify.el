#!/usr/bin/emacs --script

					; Source - Stackoverflow https://stackoverflow.com/questions/251908/how-can-i-insert-current-date-and-time-into-a-file-using-emacs
(defvar current-date-time-format "%a %b %d %H:%M:%S %Z %Y")

(defun get-page (url html-file)
  (shell-command (concat "phantomjs save_page.js " url " > " html-file)))

(defun write-tcec-title (title-file new-title)
  (set-buffer title-file)
  (erase-buffer)
  (insert new-title "\n")
  (save-buffer))

(defun write-log (log-file str)
  (setq num-log-lines (1+ num-log-lines))
  (set-buffer log-file)
  (goto-char (point-max))
  (insert (format-time-string current-date-time-format (current-time)) "\t" (prin1-to-string str) "\n")
  (save-buffer)
  (when (>= num-log-lines 10000)
    (progn
      (setq num-log-lines (- num-log-lines 1000))
      (goto-char (point-min))
      (setq beg (point))
      (forward-line 1000)
      (setq end (point))
      (kill-region beg end)
      (save-buffer)
      (write-log log-file "Log purged by 1000 lines"))))

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
      (condition-case err
	  (progn 
	    (get-page tcec-url tcec-html-file)
	    (setq tcec-title (find-title tcec-html-file))
	    (when (not (string= tcec-title old-tcec-title))
	      (progn
		(write-log tcec-log-file "Sending email")
		(setq old-tcec-title tcec-title)
		(write-tcec-title tcec-title-file tcec-title)
		(send-mail tcec-title))))
	(error (write-log tcec-log-file err))) 
      (write-log tcec-log-file "Sleeping for 5 minutes")
      (sit-for 300))))

(sit-for 60)
(setq tcec-log-file "tcec-notify.log")
(find-file tcec-log-file)
(buffer-disable-undo)
(set-buffer tcec-log-file)
(erase-buffer)
(save-buffer)
(setq num-log-lines 0)
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

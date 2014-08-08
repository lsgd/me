#!/usr/bin/env python
from email.mime.text import MIMEText
from subprocess import Popen, PIPE
from config import SMTP_FROM, SMTP_TO

def send_error(subject, body):
    msg = MIMEText(body)
    msg["From"] = SMTP_FROM
    msg["To"] = SMTP_TO
    msg["Subject"] = subject
    p = Popen(["/usr/sbin/sendmail", "-t"], stdin=PIPE)
    p.communicate(msg.as_string())
    print msg

#! /usr/bin/python
# -*- coding: utf-8 -*-

from config import Config
import smtplib
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import Encoders
import os
import hashlib
import sys

reload(sys)
sys.setdefaultencoding('utf8')

# Config
dir_path = os.path.dirname(os.path.realpath(__file__))
configFileName = dir_path + '/gitBackup.cfg'
config = Config(configFileName)

backup_path = config.backup_path
backup_fileName = config.backup_fileName + '.tgz'
backup_fullFileName = '/tmp-nolimit/' + backup_fileName
backup_fullFileNameCompleted = backup_fullFileName + '.completed'

# Functions
def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

# -- MAIN --
if __name__ == '__main__':
	now = datetime.now()
	dateStr = now.strftime("%d/%m/%Y %H:%M:%S")

	print 'Git Backup - ' + dateStr + '\n'
	print '  Backup Path           : ' + backup_path
	print '  Backup Full File Name : ' + backup_fullFileName
	print '\n'

	# Tar File	
	tarCmd = 'tar -c ' + backup_path + ' | bzip2 > ' + backup_fullFileName
	print 'Backup Command : ' + tarCmd
	os.system(tarCmd)
	print 'Git Backup File ' + backup_fullFileName + ' generated'

	# Check last backup
	if os.path.exists(backup_fullFileNameCompleted):
		print 'Found previous Backup. Comparing md5'

		md5Backup = md5(backup_fullFileName)
		md5PrevBackup = md5(backup_fullFileNameCompleted)

		print 'Hash      Backup File : ' + md5Backup
		print 'Hash Prev Backup File : ' + md5PrevBackup

		if md5Backup == md5PrevBackup:	
			print 'Backup has not changes. Aborting.\n\n'
			delCmd = 'rm {}'.format(backup_fullFileName)
			os.system(delCmd)
			exit(0)

	# Send Mail
	print 'Sending mail backup ...'
	gmail_user = config.gmail_user
	gmail_pwd = config.gmail_pwd
	
	smtpserver = smtplib.SMTP("smtp.gmail.com",587)
	smtpserver.ehlo()
	smtpserver.starttls()	
	smtpserver.login(gmail_user, gmail_pwd)
	to = gmail_user
	toaddrs = to

	outer = MIMEMultipart('related')	
	outer['From'] = gmail_user
	outer['To'] = toaddrs
	outer['Subject'] = '[GIT-BACKUP]'

	msgAlternative = MIMEMultipart('alternative')
	outer.attach(msgAlternative)

	htmlMsg = '<html><body><h2>GIT BACKUP</h2><h3>Date : {}</h3><p>Automated Git Backup from Banpi</p></body></html>'.format(dateStr)
	msgText = MIMEText(htmlMsg, 'html')
	msgAlternative.attach(msgText)

	fp = open(backup_fullFileName, 'rb')
	part = MIMEBase('application', "octet-stream")
	part.set_payload(fp.read())
	Encoders.encode_base64(part)

	fp.close()
	part.add_header('Content-Disposition', 'attachment', filename=backup_fileName)
	outer.attach(part)

	composed = outer.as_string()
	smtpserver.sendmail(gmail_user, toaddrs, composed)
	smtpserver.close()
	
	print 'Backup Mail Sended to : ' + to

	mvCmd = 'mv ' + backup_fullFileName + ' ' + backup_fullFileNameCompleted
	os.system(mvCmd)
	print 'Backup Completed ' + backup_fullFileNameCompleted
	print '\n\n'



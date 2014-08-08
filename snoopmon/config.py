#!/usr/bin/env python
from time import gmtime, strftime
import platform
#import checks

TMP_DIR = 'tmp'
SMTP_TO = 'your@address.here'

SMTP_FROM = platform.node()
TIME = strftime('%Y-%m-%d %H:%M:%S', gmtime())

SUBJECT = dict()
SUBJECT['socket'] = 'ERROR connecting to %s:%s'
SUBJECT['url'] = 'ERROR getting URL %s'
SUBJECT['content'] = 'ERROR comparing content of %s'

BODY = dict()
BODY['socket'] = 'Host: %s\nDate: %s\n\nCould not connect to %s:%s\n\nError Message: %s' % (SMTP_FROM, TIME, '%s', '%s', '%s')
BODY['url'] = 'Host: %s\nDate: %s\n\nCould not open URL %s\n\nError Message: %s' % (SMTP_FROM, TIME, '%s', '%s')
BODY['content'] = 'Host: %s\nDate: %s\n\nThe content of URL %s differs too much!\n\nError Message: %s' % (SMTP_FROM, TIME, '%s', '%s')

FUNCTION = dict()
#FUNCTION['socket'] = check_socket
#FUNCTION['url'] = check_url
#FUNCTION['content'] = check_url_content

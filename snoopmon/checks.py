from config import TMP_DIR
import socket
import urllib2
# install python-levenshtein
import Levenshtein

def check_socket(arguments):
    host, port = arguments
    # SOCK_STREAM == a TCP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    #sock.setblocking(0)  # optional non-blocking
    try:
        sock.connect((host, 33))
        sock.close()
    except Exception as msg:
        return msg
    return True

def check_url(arguments):
    url = arguments
    try:
        response = urllib2.urlopen(url)
    except Exception as msg:
        return msg
    return True

def check_url_content(arguments):
    url, filename, max_diff_ratio = arguments
    try:
        file = open('%s/%s' % (TMP_DIR, filename), 'rb')
        old_content = file.read()
        file.close()
    except IOError:
        old_content = None
    
    try:
        response = urllib2.urlopen(url)
        new_content = response.read()
        
        # save new content to file
        file = open('%s/%s' % (TMP_DIR, filename), 'wb')
        file.write(new_content)
        file.close()
        
        if old_content is None:
            return True
        
        # ratio 1 if same string
        r = ratio(new_content, old_content)
        r = 1.0 - r
        if max_diff_ratio > r:
            return 'Max diff ratio: %s,   Current diff ratio: %s' % (r, max_diff_ratio)
        return True
    except Exception as msg:
        return msg

import config
import mail
import tasks

def run(check, arguments):
    result = FUNCTION[check](arguments)
    
    if result is not True and result is not False:
        subject = SUBJECT[check] % arguments
        if check == 'socket':
            body = BODY[check] % (arguments[0], arguments[1], result)
        elif check == 'url':
            body = BODY[check] % (arguments[0], result)
        elif check == 'content'
            body = BODY[check] % (arguments[0], result)
        send_error(subject, body)

for task in TASKS:
    run(task[0], task[1])

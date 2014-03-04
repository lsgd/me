#!/bin/bash

# Associative array of screens to create
#   key = session name
#   value = command which should be executed
declare -A SCREENS
SCREENS=(
  ["server"]="cd /var/dev/project/ && source bin/activate && cd django && python manage.py runserver"
  ["media"]="cd /var/dev/project/ && source bin/activate && cd django/media && python -m SimpleHTTPServer 8888"
)



# send command by "pressing" enter
# if it does not work go in write mode in vim, press ctrl+v, enter
#   -> replace ^M by your combination
ENTER="^M"
# get list of all running screens
LIST=$(screen -list)

# loop over all defined screens
for name in "${!SCREENS[@]}"
do
  # create a new screen session if no other session with
  # the given name exists
  if [ $(echo $LIST | grep -c $name) -eq 0 ]
  then
    echo "Create new session for <$name>"
    screen -dm $name
    # wait to make sure that the session is available
    sleep 1
  fi

  # execute command in screen session
  screen -S $name -p 0 -X stuff "${SCREENS[$name]}$ENTER"
done

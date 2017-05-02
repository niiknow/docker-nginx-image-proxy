#!/bin/bash

export TERM=xterm

if [ -z "`ls /app --hide='lost+found'`" ]
then
    rsync -a /app-start/* /app
fi

# save environment variables for use later
env > /root/env.txt

bash /root/bin/my-startup.sh

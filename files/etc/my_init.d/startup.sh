#!/bin/bash

export TERM=xterm

# save environment variables for use later
env > /root/env.txt

service nginx start

bash /root/bin/my-startup.sh

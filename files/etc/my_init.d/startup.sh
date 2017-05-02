#!/bin/bash

export TERM=xterm

# save environment variables for use later
env > /root/env.txt

bash /root/bin/my-startup.sh

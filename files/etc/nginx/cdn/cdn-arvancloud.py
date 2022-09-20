#!/usr/local/bin/python3
"""
Util to grab ArvanCloud Inbound addresses 
"""

import requests

ips = requests.get("https://www.arvancloud.com/fa/ips.txt").text
config = ""

for item in ips.split():
    directive = f"set_real_ip_from {item};\n"
    config += directive

with open("cdn-arvancloud.conf", "w")as f:
    f.write(config)
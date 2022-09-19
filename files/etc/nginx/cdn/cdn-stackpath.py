#!/usr/local/bin/python3
"""
Util to grab StackPath Inbound addresses 
"""
#!/usr/local/bin/python3
# coding: utf-8

import requests

ips = requests.get("https://k3t9x2h3.map2.ssl.hwcdn.net/ipblocks.txt").text
config = ""

for item in ips.split():
    directive = f"set_real_ip_from {item};\n"
    config += directive

with open("cdn-stackpath.conf", "w")as f:
    f.write(config)
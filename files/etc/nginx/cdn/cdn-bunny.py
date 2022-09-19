#!/usr/local/bin/python3
"""
Util to grab ArvanCloud Inbound addresses 
"""
#!/usr/local/bin/python3
# coding: utf-8

import requests

v4 = requests.get("https://bunnycdn.com/api/system/edgeserverlist").json()
v6 = requests.get("https://bunnycdn.com/api/system/edgeserverlist/ipv6").json()
config = ""

for item in v4:
    directive = f"set_real_ip_from {item};\n"
    config += directive
config += "\n"
for item in v6:
    directive = f"set_real_ip_from {item};\n"
    config += directive

bottom = "real_ip_header X-Real-IP;"
config += "\n" + bottom

with open("cdn-bunny.conf", "w")as f:
    f.write(config)
#!/usr/bin/env python3
"""
Util to grab BunnyCDN Inbound addresses
"""

import os

import requests


def fetch(url):
    resp = requests.get(url, timeout=30)
    resp.raise_for_status()
    return resp.json()


v4 = fetch("https://bunnycdn.com/api/system/edgeserverlist")
v6 = fetch("https://bunnycdn.com/api/system/edgeserverlist/ipv6")
config = ""

for item in v4:
    directive = f"set_real_ip_from {item};\n"
    config += directive
config += "\n"
for item in v6:
    directive = f"set_real_ip_from {item};\n"
    config += directive

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cdn-bunny.conf")
with open(out, "w") as f:
    f.write(config)

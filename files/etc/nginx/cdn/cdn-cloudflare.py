#!/usr/bin/env python3
"""
Util to grab Cloudflare Inbound addresses
"""

import os

import requests


def fetch(url):
    resp = requests.get(url, timeout=30)
    resp.raise_for_status()
    return resp.text


v4 = fetch("https://www.cloudflare.com/ips-v4")
v6 = fetch("https://www.cloudflare.com/ips-v6")
config = ""

for item in v4.split():
    directive = f"set_real_ip_from {item};\n"
    config += directive
config += "\n"
for item in v6.split():
    directive = f"set_real_ip_from {item};\n"
    config += directive

# real_ip_header is already set in cdn-ips.conf (nginx rejects duplicates),
# so only suggest the CDN-specific header here
bottom = "# real_ip_header CF-Connecting-IP;"
config += "\n" + bottom

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cdn-cloudflare.conf")
with open(out, "w") as f:
    f.write(config)

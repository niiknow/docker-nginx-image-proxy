#!/usr/bin/env python3
"""
Util to grab Fastly Inbound addresses
"""

import os

import requests

resp = requests.get("https://api.fastly.com/public-ip-list", timeout=30)
resp.raise_for_status()
data = resp.json()
config = ""

for item in data["addresses"]:
    directive = f"set_real_ip_from {item};\n"
    config += directive
config += "\n"
for item in data.get("ipv6_addresses", []):
    directive = f"set_real_ip_from {item};\n"
    config += directive

# real_ip_header is already set in cdn-ips.conf (nginx rejects duplicates),
# so only suggest the CDN-specific header here
bottom = "# real_ip_header Fastly-Client-IP;"
config += "\n" + bottom

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cdn-fastly.conf")
with open(out, "w") as f:
    f.write(config)

#!/usr/local/bin/python3
"""
Util to grab Fastly Inbound addresses 
"""
import requests

url = 'https://api.fastly.com/public-ip-list'
json = requests.get(url).json()

config = "set_real_ip_from "
config += "\nset_real_ip_from ".join(json["addresses"])

bottom = "real_ip_header Fastly-Client-IP;"
config += "\n\n" + bottom

with open("cdn-fastly.conf", "w")as f:
    f.write(config)
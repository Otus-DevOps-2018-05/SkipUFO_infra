#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json

#import urllib
#import requests

# Network 
# Здесь нужно разюираться с авторизацией для доступа на bucket
#TERRAFORM_STATE_FILE = 'https://storage.cloud.google.com/organic-diode-207603-storage-bucket-stage/terraform/state/default.tfstate'
#r = requests.get(TERRAFORM_STATE_FILE) 
#print (r.url)
#f = urllib.urlopen(r.url)
#content = f.read()
#print(content)

# Структура json
#{
#    "app": {
#        "hosts": ["35.233.44.229"]
#    }, 
#    "db": { 
#        "hosts": ["35.190.210.191"]
#    }
#}

TERRAFORM_STATE_FILE = '../../../terraform/prod/.terraform/terraform.tfstate'
# Local
with open(TERRAFORM_STATE_FILE) as f:
    data = json.load(f)

#print (data['modules']['resources']['google_compute_instance.app'])

result = json.loads('{"app": { "hosts": [] }, "db": { "hosts": [] }}')

for module in data['modules']:  
  for key, value in module['resources'].items():
    if key == "google_compute_instance.app": 
      for key2, value2 in value.items():
        if (key2 == "primary"):
          for key3, value3 in value2.items():
            if (key3 == "attributes"):
              for key4, value4 in value3.items():
                if (key4 == 'network_interface.0.access_config.0.assigned_nat_ip'):
                  result['app']['hosts'].append(value4)
    if key == "google_compute_instance.db": 
      for key2, value2 in value.items():
        if (key2 == "primary"):
          for key3, value3 in value2.items():
            if (key3 == "attributes"):
              for key4, value4 in value3.items():
                if (key4 == 'network_interface.0.access_config.0.assigned_nat_ip'):
                  result['db']['hosts'].append(value4)

print (json.dumps(result))


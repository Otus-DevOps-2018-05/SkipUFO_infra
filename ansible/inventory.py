#!/usr/bin/env python
import sys

if sys.argv[1] == "--list":
    print """{ "app": { "hosts": ["35.233.44.229"] }, "db": { "hosts": ["35.190.210.191"] } }"""
else:
    print ""

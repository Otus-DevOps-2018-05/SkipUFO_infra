#!/usr/bin/env python
import sys

if sys.argv[1] == "--list":
    with open ("inventory.json") as f:
        print f.read()
else:
    print ""

#!/usr/bin/env python3
from libqtile.command.client import InteractiveCommandClient
import sys
import subprocess
c = InteractiveCommandClient()
if c.status() == 'OK':
    win_id = c.window.info()['id']
    c.window[win_id].toggle_minimize()
    if len(sys.argv) > 1:
        subprocess.run(sys.argv[1:])
    c.window[win_id].toggle_minimize()

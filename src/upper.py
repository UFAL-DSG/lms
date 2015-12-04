#!/usr/bin/env python3
import sys

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE,SIG_DFL)

for line in sys.stdin:
    line = line.upper()
    for c in '.,:?!¡':
        line = line.replace(c, ' ')

    sys.stdout.write(line)
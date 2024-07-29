#!/usr/bin/env python3

# Convert TM990 OBJ file to BIN
# Scott Baker, https://www.smbaker.com/
#
# Syntax:
#    obj2bin.py < object_file > bin_file
#
# Options
#    -S <address> ... start outputting at address

import sys
from optparse import OptionParser

addr = 0
data = bytearray()

def emit(val):
    while len(data) < addr+2:
        data.append(0)
    high = val >> 8
    low = (val & 0xFF)
    data[addr] = low
    data[addr+1] = high

def proctag(tag):
    global addr

    if (tag[0]=='F'):
        val = 0
    else:
        val = int(tag[1:], 16)

    if tag[0] == '9':
        addr = val
    elif tag[0] =='B':
        emit(val)
        addr += 2
    elif tag[0] =='7':
        pass # checksum
    elif tag[0] =='F':
        pass # EOL
    else:
        print("unknown tag: %s" % tag, file=sys.stderr)
        sys.exit(-1)


def procline(line):
    while line:
        if line.startswith(":"):
            # end of object
            return

        tag = line[:5]
        line = line[5:]
        proctag(tag)

def main():
    global data

    parser = OptionParser(usage="supervisor [options] command",
            description="Commands: ...")

    parser.add_option("-S", "--start", dest="start",
         help="starting address in hex", metavar="START", type="string", default="0000")

    (options, args) = parser.parse_args(sys.argv[1:])

    startAddr = int(options.start, 16)

    n=0
    for line in sys.stdin.readlines():
        line = line.strip()
        if n==0:
            line = line[13:]
        line = line.split()[0]
        procline(line)
        n += 1

    data = data[startAddr:]
    sys.stdout.buffer.write(data)

if __name__ == "__main__":
    main()

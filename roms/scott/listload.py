import sys

lines = open("basicw.lst").readlines()

out = bytearray()

addr = -2

for line in lines:
    line = line.strip()
    if not line:
        continue

    if line.startswith("*"):
        continue

    if not (line[0] in ["0","1","2","3","4","5","6","7","8","9"]):
        print("skip line %s" % line)
        continue

    parts = line.split()

    try:
       thisAddr = int(parts[1], 16)
    except:
        print("bad line %s" % line)
        continue

    try:
        val = int(parts[2], 16)
    except:
        print("bad line %s" % line)
        continue    

    if thisAddr != addr+2:
        print("Bad addr %s" % line)
        continue

    addr = thisAddr

    out.append(val & 0xFF)
    out.append(val >> 8)

open("build/listload.bin","wb").write(out)
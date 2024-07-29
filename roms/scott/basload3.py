import sys

lines = open("../zzAll EPROMs.txt").readlines()

out = bytearray()

n=0

for line in lines:
    line = line.strip()
    if "***" in line:
        parts = line.split(">")
        parts = parts[1].split(" ")
        offs = int(parts[0], 16)
        print("offset %x to %x" % (len(out), offs))

        while len(out) < offs:
            out.append(0x00)
        continue

    if "DATA" not in line:
        print("Skipping: %s" % line)
        continue
    parts = line.split(">")
    if len(parts)!=2:
        print("Bad line: %s" % line)
        continue

    if not parts[1]:
        print("Bad line: %s" % line)
        continue

    n+=1
    if (n%17)==0:
        continue

    x = int(parts[1], 16)
    out.append(x>>8)
    out.append(x & 0xFF)

open("build/basload3.bin","wb").write(out)
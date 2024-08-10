import sys

def cdig(x):
    digs = 0
    for c in x:
        if c in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
            digs += 1
        else:
            return digs;

for line in sys.stdin.readlines():
        if line.strip().startswith("Asm994a TMS99000 Assembler"):
            continue

        origline = line

        if cdig(line)>=5:
            line = line[17:]
        else:
            line = line[16:]

        if (not line.strip()) and origline[6:].strip():
                continue

        print(line.rstrip())

        if line.strip() == "END":
                break

#    if line.strip().startswith("*":
#        print(line)
#        continue

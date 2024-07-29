import sys
low = open(sys.argv[1], "rb" ).read()
high = open(sys.argv[2], "rb" ).read()

interleaved = bytearray()
for i in range(0,len(low)):
    interleaved.append(low[i])
    interleaved.append(high[i])
sys.stdout.buffer.write( interleaved )

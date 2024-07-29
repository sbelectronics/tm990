import sys
even = open(sys.argv[1], "rb" ).read()
odd = open(sys.argv[2], "rb" ).read()

interleaved = bytearray()
for i in range(0,len(even)):
    interleaved.append(even[i])
    interleaved.append(odd[i])
sys.stdout.buffer.write( interleaved )

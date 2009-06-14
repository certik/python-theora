#! /usr/bin/env python
from theora import Theora, TheoraEncoder

#a = Theora("video.ogv")
a = Theora("bbb_theora_325kbit.ogv")
print a
b = TheoraEncoder("a.ogv", 400, 226)
print b
a.seek(time=10)
while a.read_frame() and a.time < 12:
    print a.frame, a.time
    A = a.get_frame_array()
    b.write_frame(A)
a.read_frame()
A = a.get_frame_array()
b.write_frame(A, last=True)
b.flush()

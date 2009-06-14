#! /usr/bin/env python
from theora import Theora, TheoraEncoder

#a = Theora("video.ogv")
a = Theora("bbb_theora_325kbit.ogv")
print a
b = TheoraEncoder("a.ogv", 400, 226)
print b
while a.read_frame() and a.frame < 10:
    print a.frame, a.time
    A = a.YCbCr_tuple2array(a.get_frame_data())
    b.write_frame(A)
a.read_frame()
A = a.YCbCr_tuple2array(a.get_frame_data())
b.write_frame(A, last=True)
b.flush()

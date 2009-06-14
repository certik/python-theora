#! /usr/bin/env python
from theora import Theora, TheoraEncoder

#a = Theora("video.ogv")
a = Theora("bbb_theora_325kbit.ogv")
print a
print "seeking"
a.seek(time=10)
print a.time, a.frame

A = a.YCbCr_tuple2array(a.get_frame_data())

b = TheoraEncoder("a.ogv", 400, 226)
print b
b.write_frame(A)

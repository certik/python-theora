#! /usr/bin/env python

from theora import Theora
from pylab import imshow, show
#import IPython
#IPython.Shell.IPShell(user_ns=dict(globals(), **locals())).mainloop()

f = open("video.ogv")
o = Theora(f)
while o.read_frame():
    print o.frame, o.time
print "frame:", o.frame
print "time:", o.time
img = o.get_frame_image()
img.save("frame.png")

imshow(img, origin="lower")
show()

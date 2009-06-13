#! /usr/bin/env python

from theora import Ogg
from numpy import concatenate, zeros_like, array, dot, round
from scipy.misc import toimage
from scipy.linalg import inv
#import IPython
#IPython.Shell.IPShell(user_ns=dict(globals(), **locals())).mainloop()

f = open("video.ogv")
o = Ogg(f)
A = o.YCbCr_tuple2array(o.test())

#img = toimage(A, mode="YCbCr", channel_axis=2)
#img.convert("RGB").save("frame.png")
img = toimage(o.YCbCr2RGB(A), channel_axis=2)
img.save("frame.png")

from pylab import imshow, show
from matplotlib import cm
imshow(img, origin="lower")
show()

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

print "converting to RGB"
A = o.YCbCr2RGB(A)
B1, B2, B3 = A[0, :, :], A[1, :, :], A[2, :, :]
w, h = B1.shape
B1 = B1.reshape((w, h, 1))
B2 = B2.reshape((w, h, 1))
B3 = B3.reshape((w, h, 1))
B = concatenate((B1, B2, B3), axis=2)
print A[:, 100, 100]
#img = toimage(A, mode="YCbCr", channel_axis=0)
img = toimage(B, channel_axis=2)
img.convert("RGB").save("frame.png")

from pylab import imshow, show
from matplotlib import cm
#imshow(B)#, cmap=cm.gray, origin="lower")
imshow(img, origin="lower")
show()

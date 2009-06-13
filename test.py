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
# this fixes the colors, I don't know why:
#A += 2

print "converting to RGB"
A = o.YCbCr2RGB(A)
print A[:, 100, 100]
#img = toimage(A, mode="YCbCr", channel_axis=0)
img = toimage(A, channel_axis=0)
img.convert("RGB").save("frame.png")

from pylab import imshow, show
from matplotlib import cm
B1, B2, B3 = A[0, :, :], A[1, :, :], A[2, :, :]
w, h = B1.shape
B1 = B1.reshape((w, h, 1))
B2 = B2.reshape((w, h, 1))
B3 = B3.reshape((w, h, 1))
B = concatenate((B1, B2, B3), axis=2)
#imshow(B)#, cmap=cm.gray, origin="lower")
imshow(img, origin="lower")
show()

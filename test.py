#! /usr/bin/env python

from theora import Ogg
from numpy import concatenate, zeros_like
from scipy.misc import toimage

f = open("video.ogv")
o = Ogg(f)
Y, Cb, Cr = o.test()
Cb2 = zeros_like(Y)
for i in range(Cb2.shape[0]):
    for j in range(Cb2.shape[1]):
        Cb2[i, j] = Cb[i/2, j/2]
Cr2 = zeros_like(Y)
for i in range(Cr2.shape[0]):
    for j in range(Cr2.shape[1]):
        Cr2[i, j] = Cr[i/2, j/2]

w, h = Y.shape
Y = Y.reshape((1, w, h))
Cb = Cb2.reshape((1, w, h))
Cr = Cr2.reshape((1, w, h))
A = concatenate((Y, Cb, Cr))
img = toimage(A, mode="YCbCr", channel_axis=0)
print img

from pylab import imshow, show
from matplotlib import cm
imshow(img, origin="lower")
show()

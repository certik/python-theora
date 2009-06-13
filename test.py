#! /usr/bin/env python

from theora import Ogg
from numpy import zeros

f = open("video.ogv")
o = Ogg(f)
A = o.test()
w = 672
h = 464
stride = 704

B = zeros((w, h))
for j in range(h):
    for i in range(w):
        B[i, j] = A[j*stride+i]

from pylab import imshow, show
imshow(B)
show()

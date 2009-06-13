#! /usr/bin/env python

from theora import Ogg

f = open("video.ogv")
o = Ogg(f)
A = o.test()
w = 672
h = 464
stride = 704

B = A.reshape((h, stride))

from pylab import imshow, show
from matplotlib import cm
imshow(B, cmap=cm.gray)
show()

#! /usr/bin/env python

from theora import Ogg

f = open("video.ogv")
o = Ogg(f)
A = o.test()

from pylab import imshow, show
from matplotlib import cm
imshow(A, cmap=cm.gray)
show()

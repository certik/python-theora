#! /usr/bin/env python

from theora import Ogg

f = open("video.ogv")
o = Ogg(f)
o.test()

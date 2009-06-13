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

def YCbCr2RGB(A):
    # parameters both Rec. 470M and Rec. 470BG:
    offset = array([16, 128, 128])
    excursion = array([219, 224, 224])
    Kr = 0.299
    Kb = 0.114
    M = array([
        [1, 0, 2*(1-Kr)],
        [1, -2*(1-Kb)*Kb/(1-Kb-Kr), -2*(1-Kr)*Kr/(1-Kb-Kr)],
        [1, 2*(1-Kb), 0]
        ])
    M_inv = inv(M)

    def YCbCr2YPbPr(YCbCr):
        YCbCr = array(YCbCr)
        return (YCbCr - offset)*1.0/excursion

    def YPbPr2YCbCr(YPbPr):
        YPbPr = array(YPbPr)
        return array(round(YPbPr*excursion + offset), dtype="uint8")

    def YPbPr2RGB(YPbPr):
        YPbPr = array(YPbPr)
        return dot(M, YPbPr)

    def RGB2YPbPr(RGB):
        RGB = array(RGB)
        return dot(M_inv, RGB)

    n, w, h = A.shape
    B = array(A.copy(), dtype="double")
    for i in range(w):
        for j in range(h):
            YCbCr = A[:, i, j]
            B[:, i, j] = YPbPr2RGB(YCbCr2YPbPr(YCbCr))
            #print "from:", YCbCr, "to:", B[:, i, j]
    return B

A = YCbCr2RGB(A)
print A[:, 100, 100]
#img = toimage(A, mode="YCbCr", channel_axis=0)
#img = toimage(A, channel_axis=0)
#img.convert("RGB").save("frame.png")

# parameters both Rec. 470M and Rec. 470BG:
offset = array([16, 128, 128])
excursion = array([219, 224, 224])
Kr = 0.299
Kb = 0.114
M = array([
    [1, 0, 2*(1-Kr)],
    [1, -2*(1-Kb)*Kb/(1-Kb-Kr), -2*(1-Kr)*Kr/(1-Kb-Kr)],
    [1, 2*(1-Kb), 0]
    ])
M_inv = inv(M)

def YCbCr2YPbPr(YCbCr):
    YCbCr = array(YCbCr)
    return (YCbCr - offset)*1.0/excursion

def YPbPr2YCbCr(YPbPr):
    YPbPr = array(YPbPr)
    return array(round(YPbPr*excursion + offset), dtype="uint8")

def YPbPr2RGB(YPbPr):
    YPbPr = array(YPbPr)
    return dot(M, YPbPr)

def RGB2YPbPr(RGB):
    RGB = array(RGB)
    return dot(M_inv, RGB)

Y = A[0]
print  Y[100, 100]
print Y.min()
print Y.max()
YCbCr = (A[0, 100, 100], A[1, 100, 100], A[2, 100, 100])
#YCbCr = array(YCbCr)+2
YPbPr = YCbCr2YPbPr(YCbCr)
RGB = YPbPr2RGB(YPbPr)
print "YCbCr", YCbCr
print "YPbPr:", YPbPr
print "RGB:", RGB
RGB = (1, 1, 1)
print "YPbPr again:", RGB2YPbPr(RGB)
print "YCbCr again:", YPbPr2YCbCr(RGB2YPbPr(RGB))
#stop

from pylab import imshow, show
from matplotlib import cm
B1, B2, B3 = A[0, :, :], A[1, :, :], A[2, :, :]
w, h = B1.shape
B1 = B1.reshape((w, h, 1))
B2 = B2.reshape((w, h, 1))
B3 = B3.reshape((w, h, 1))
B = concatenate((B1, B2, B3), axis=2)
imshow(B)#, cmap=cm.gray, origin="lower")
show()

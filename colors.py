"""
Module for converting between YCbCr, YPbPr and RGB_float and RGB.

YCbCr ....... 0 - 255
YPbPr ....... 0.0 - 1.0
RGB_float ... 0.0 - 1.0
RGB ......... 0 - 255

Well, in fact:

Y' is 16...235, and Cb and Cr are 16...240.

This is implemented in pure Python and numpy matrices, so it's slow, but simple
and readable, so it serves as a reference implementation.

"""

from numpy import array, dot, vectorize
from scipy.linalg import inv

def round_int(a):
    return int(a+0.5)

vround_int = vectorize(round_int)

def round(A):
    return vround_int(A)


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

def YPbPr2RGB_float(YPbPr):
    YPbPr = array(YPbPr)
    return dot(M, YPbPr)

def RGB_float2YPbPr(RGB_float):
    RGB_float = array(RGB_float)
    return dot(M_inv, RGB_float)

def clip2(a):
    if a > 255:
        return 255
    elif a < 0:
        return 0
    return a

def clip(a):
    #print a
    b = a.copy()
    b[0] = clip2(a[0])
    b[1] = clip2(a[1])
    b[2] = clip2(a[2])
    #print b
    return b

def RGB_float2RGB(RGB_float):
    RGB_float = array(RGB_float)
    return array(clip(round(RGB_float*255)), dtype="uint8")

def RGB2RGB_float(RGB):
    RGB = array(RGB)
    return RGB/255.

def YCbCr2RGB_precise(YCrCb):
    """
    This is a precise, but slow version.
    """
    return RGB_float2RGB(YPbPr2RGB_float(YCbCr2YPbPr(YCrCb)))

def RGB2YCbCr_precise(RGB):
    """
    This is a precise, but slow version.
    """
    return YPbPr2YCbCr(RGB_float2YPbPr(RGB2RGB_float(RGB)))

def YCbCr2RGB(YCbCr):
    """
    This is a fast version, that sometimes differes by 1.

    It can be easily cythonized.
    """
    Y, Cb, Cr = YCbCr
    C = Y - 16
    D = Cb - 128
    E = Cr - 128

    R = clip2((298*C + 409*E + 128) >> 8)
    G = clip2((298*C - 100*D - 208*E + 128) >> 8)
    B = clip2((298*C + 516*D + 128) >> 8)
    return array([R, G, B])

def RGB2YCbCr(RGB):
    """
    This is a fast version, that sometimes differes by 1.

    It can be easily cythonized.
    """
    R, G, B = RGB
    Y = ( (  66 * R + 129 * G +  25 * B + 128) >> 8) +  16
    Cb = ( ( -38 * R -  74 * G + 112 * B + 128) >> 8) + 128
    Cr = ( ( 112 * R -  94 * G -  18 * B + 128) >> 8) + 128
    return Y, Cb, Cr

"""
Module for converting between YCbCr, YPbPr and RGB_float and RGB.

YCbCr ....... 0 - 255
YPbPr ....... 0.0 - 1.0
RGB_float ... 0.0 - 1.0
RGB ......... 0 - 255

This is implemented in pure Python and numpy matrices, so it's slow, but simple
and readable, so it serves as a reference implementation.
"""

from numpy import array, dot, round
from scipy.linalg import inv

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

def RGB_float2RGB(RGB_float):
    RGB_float = array(RGB_float)
    return array(round(RGB_float*255), dtype="uint8")

def RGB2RGB_float(RGB):
    RGB = array(RGB)
    return RGB/255.
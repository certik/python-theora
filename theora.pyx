cdef extern from "theora/theoradec.h":

    ctypedef struct ogg_sync_state:
        pass

    ctypedef struct th_comment:
        pass

    ctypedef struct th_info:
        pass

    int ogg_sync_init(ogg_sync_state *oy)
    void th_comment_init(th_comment *_tc)
    void th_info_init(th_info *_info)

cdef class Ogg:
    cdef object _f

    def __init__(self, f):
        self._f = f

    def test(self):
        cdef ogg_sync_state oy
        cdef th_comment tc
        cdef th_info ti
        ogg_sync_init(&oy)
        th_comment_init(&tc)
        th_info_init(&ti)
        print self._f

cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void *malloc (size_t size)
    void free(void *mem)
    void *memcpy(void *dst, void *src, long n)

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
    char *ogg_sync_buffer(ogg_sync_state *oy, long size)
    int ogg_sync_wrote(ogg_sync_state *oy, long bytes)

cdef class Ogg:
    cdef object _infile
    cdef ogg_sync_state _oy
    cdef th_comment _tc
    cdef th_info _ti

    def __init__(self, f):
        self._infile = f
        ogg_sync_init(&self._oy)
        th_comment_init(&self._tc)
        th_info_init(&self._ti)

    cdef int buffer_data(self, ogg_sync_state *oy, int n=4096):
        s = self._infile.read(n)
        cdef int bytes=len(s)
        cdef char *buffer=ogg_sync_buffer(oy, n)
        cdef char *m=s
        memcpy(buffer, m, n)
        ogg_sync_wrote(oy, bytes)
        return bytes
        return len(buffer)

    def test(self):
        self.buffer_data(&self._oy);
        print "ok"

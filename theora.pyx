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
    ctypedef struct ogg_stream_state:
        pass
    ctypedef struct ogg_page:
        pass
    ctypedef struct ogg_packet:
        pass
    ctypedef struct th_setup_info:
        pass

    int ogg_sync_init(ogg_sync_state *oy)
    void th_comment_init(th_comment *_tc)
    void th_info_init(th_info *_info)
    char *ogg_sync_buffer(ogg_sync_state *oy, long size)
    int ogg_sync_wrote(ogg_sync_state *oy, long bytes)
    int ogg_sync_pageout(ogg_sync_state *oy, ogg_page *og)
    int ogg_page_bos(ogg_page *og)
    int ogg_stream_pagein(ogg_stream_state *os, ogg_page *og)
    int ogg_page_serialno(ogg_page *og)
    int ogg_stream_init(ogg_stream_state *os, int serialno)
    int ogg_stream_packetout(ogg_stream_state *os, ogg_packet *op)
    int th_decode_headerin(th_info *_info,th_comment *_tc,
             th_setup_info **_setup,ogg_packet *_op)
    int ogg_stream_clear(ogg_stream_state *os)

cdef class Ogg:
    cdef object _infile
    cdef ogg_sync_state _oy
    cdef th_comment _tc
    cdef th_info _ti
    cdef ogg_page _og
    cdef ogg_stream_state _to
    cdef ogg_packet _op
    cdef th_setup_info *_setup

    def __init__(self, f):
        self._infile = f
        ogg_sync_init(&self._oy)
        th_comment_init(&self._tc)
        th_info_init(&self._ti)

    cdef int buffer_data(self, ogg_sync_state *oy, int n=4096):
        """
        Reads "n" bytes from self._infile into the ogg_sync_state "oy".
        """
        s = self._infile.read(n)
        cdef int bytes=len(s)
        cdef char *buffer=ogg_sync_buffer(oy, n)
        cdef char *m=s
        memcpy(buffer, m, n)
        ogg_sync_wrote(oy, bytes)
        return bytes
        return len(buffer)

    def test(self):
        cdef ogg_stream_state test
        stateflag = True
        theora_p = False
        while stateflag:
            ret = self.buffer_data(&self._oy);
            if ret == 0:
                print "done"
                return
            while ogg_sync_pageout(&self._oy, &self._og) > 0:
                if ogg_page_bos(&self._og) != 0:
                    if theora_p:
                        ogg_stream_pagein(&self._to, &self._og)
                    stateflag = False
                    break
                ogg_stream_init(&test, ogg_page_serialno(&self._og))
                ogg_stream_pagein(&test, &self._og)
                ogg_stream_packetout(&test, &self._op)
                if not theora_p and \
                        th_decode_headerin(&self._ti, &self._tc,
                            &self._setup, &self._op) >= 0:
                    memcpy(&self._to, &test, sizeof(test))
                    theora_p = True
                else:
                    ogg_stream_clear(&test)
        print "ok"

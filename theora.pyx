cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void *malloc (size_t size)
    void free(void *mem)
    void *memcpy(void *dst, void *src, long n)

cdef extern from "theora/theoradec.h":

    ctypedef unsigned int ogg_uint32_t
    ctypedef long long ogg_int64_t

    ctypedef struct ogg_sync_state:
        pass
    ctypedef struct th_comment:
        pass
    ctypedef struct th_info:
        ogg_uint32_t  frame_width
        ogg_uint32_t  frame_height
        ogg_uint32_t  pic_width
        ogg_uint32_t  pic_height
        ogg_uint32_t  pic_x
        ogg_uint32_t  pic_y
        ogg_uint32_t  fps_numerator
        ogg_uint32_t  fps_denominator
        ogg_uint32_t  aspect_numerator
        ogg_uint32_t  aspect_denominator
    ctypedef struct ogg_stream_state:
        long serialno
    ctypedef struct ogg_page:
        pass
    ctypedef struct ogg_packet:
        pass
    ctypedef struct th_setup_info:
        pass
    ctypedef struct th_dec_ctx:
        pass
    ctypedef struct th_ycbcr_buffer:
        pass
    ctypedef struct th_img_plane:
        int width
        int height
        int stride
        unsigned char *data
    ctypedef th_img_plane th_ycbcr_buffer[3]

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
    th_dec_ctx *th_decode_alloc(th_info *_info, th_setup_info *_setup)
    double th_granule_time(void *_encdec, ogg_int64_t _granpos)
    int th_decode_packetin(th_dec_ctx *_dec, ogg_packet *_op,
             ogg_int64_t *_granpos)
    void th_decode_free(th_dec_ctx *_dec)
    int ogg_sync_clear(ogg_sync_state *oy)
    void th_info_clear(th_info *_info)
    void th_comment_clear(th_comment *_tc)
    int th_decode_ycbcr_out(th_dec_ctx *_dec, th_ycbcr_buffer _ycbcr)

cdef class Ogg:
    cdef object _infile
    cdef ogg_sync_state _oy
    cdef th_comment _tc
    cdef th_info _ti
    cdef ogg_page _og
    cdef ogg_stream_state _to
    cdef ogg_packet _op
    cdef th_setup_info *_setup
    cdef th_dec_ctx *_td

    def __init__(self, f):
        self._infile = f
        ogg_sync_init(&self._oy)
        th_comment_init(&self._tc)
        th_info_init(&self._ti)

    def __del__(self):
        th_comment_clear(&self._tc)
        th_info_clear(&self._ti)
        ogg_sync_clear(&self._oy)

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

    cdef void video_write(self, th_dec_ctx *td):
        cdef th_ycbcr_buffer ycbcr
        #th_decode_ycbcr_out(self._td, ycbcr)
        if th_decode_ycbcr_out(td, ycbcr) != 0:
            raise Exception("th_decode_ycbcr_out failed\n")
        print "w: %d, h: %d, stride: %d" % (ycbcr[0].width, ycbcr[0].height,
                ycbcr[0].stride)
        print "w: %d, h: %d, stride: %d" % (ycbcr[1].width, ycbcr[1].height,
                ycbcr[1].stride)
        print "w: %d, h: %d, stride: %d" % (ycbcr[2].width, ycbcr[2].height,
                ycbcr[2].stride)

    def test(self):
        cdef ogg_stream_state test
        cdef ogg_int64_t videobuf_granulepos = -1
        stateflag = True
        theora_p = False
        while stateflag:
            ret = self.buffer_data(&self._oy);
            if ret == 0:
                print "done"
                return
            while ogg_sync_pageout(&self._oy, &self._og) > 0:
                if ogg_page_bos(&self._og) == 0:
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
        while theora_p > 0 and (theora_p < 3):
            ret = ogg_stream_packetout(&self._to, &self._op)
            while theora_p > 0 and (theora_p < 3) and ret != 0:
                if ret < 0:
                    print "Error parsing headers 1"
                    return
                if th_decode_headerin(&self._ti, &self._tc,
                        &self._setup, &self._op) < 0:
                    print "Error parsing headers 2"
                theora_p += 1
                if theora_p == 3: break
            if ogg_sync_pageout(&self._oy, &self._og) > 0:
                if theora_p > 0: ogg_stream_pagein(&self._to, &self._og)
            else:
                ret = self.buffer_data(&self._oy)
                if ret == 0:
                    print "End of file while searching for headers"
                    return
        if self._ti.fps_denominator == 0:
            raise Exception("fps_denominator is zero")
        print "Ogg logical stream %lx is Theora %dx%d %.02f fps video\n" \
            "Encoded frame content is %dx%d with %dx%d offset\n" \
            "Aspect: %d:%d\n" % (
            self._to.serialno, self._ti.pic_width, self._ti.pic_height,
            float(self._ti.fps_numerator)/self._ti.fps_denominator,
            self._ti.frame_width, self._ti.frame_height,
            self._ti.pic_x, self._ti.pic_y,
            self._ti.aspect_numerator, self._ti.aspect_denominator)

        self._td = th_decode_alloc(&self._ti, self._setup)
        if self._td == NULL:
            raise Exception("th_decode_alloc failed")
        stateflag = 0
        while ogg_sync_pageout(&self._oy, &self._og) > 0:
            ogg_stream_pagein(&self._to, &self._og)
        videobuf_ready = False
        frames = 0
        while frames < 100:
            while not videobuf_ready:
                if ogg_stream_packetout(&self._to, &self._op) > 0:
                    th_decode_packetin(self._td, &self._op,
                            &videobuf_granulepos)
                    videobuf_time = th_granule_time(self._td,
                            videobuf_granulepos)
                    print videobuf_time
                    videobuf_ready = True
                    frames += 1
                else:
                    break
            print "\rframe:%d" % frames
            if not videobuf_ready:
                self.buffer_data(&self._oy)
                while ogg_sync_pageout(&self._oy, &self._og) > 0:
                    ogg_stream_pagein(&self._to, &self._og)
            else:
                self.video_write(self._td)
            videobuf_ready = False

        ogg_stream_clear(&self._to)
        th_decode_free(self._td)
        print "ok"

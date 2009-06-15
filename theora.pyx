cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void *malloc (size_t size)
    void free(void *mem)
    void *memcpy(void *dst, void *src, long n)

cdef extern from "Python.h":
    object PyString_FromStringAndSize(char *v, int len)
    int PyString_AsStringAndSize(object obj, char **buffer, Py_ssize_t* length) except -1

cdef extern from "arrayobject.h":

    ctypedef int intp

    ctypedef extern class numpy.ndarray [object PyArrayObject]:
        cdef char *data
        cdef int nd
        cdef intp *dimensions
        cdef intp *strides
        cdef int flags

cdef extern from "ogg/ogg.h":
    ctypedef unsigned int ogg_uint32_t
    ctypedef long long ogg_int64_t

    ctypedef struct ogg_sync_state:
        pass
    ctypedef struct ogg_stream_state:
        long serialno
    ctypedef struct ogg_page:
        unsigned char *header
        long header_len
        unsigned char *body
        long body_len
    ctypedef struct ogg_packet:
        pass
    int ogg_stream_packetin(ogg_stream_state *os, ogg_packet *op)
    int ogg_stream_pageout(ogg_stream_state *os, ogg_page *og)
    int ogg_stream_flush(ogg_stream_state *os, ogg_page *og)
    int ogg_sync_init(ogg_sync_state *oy)
    char *ogg_sync_buffer(ogg_sync_state *oy, long size)
    int ogg_sync_wrote(ogg_sync_state *oy, long bytes)
    int ogg_sync_pageout(ogg_sync_state *oy, ogg_page *og)
    int ogg_page_bos(ogg_page *og)
    int ogg_stream_pagein(ogg_stream_state *os, ogg_page *og)
    int ogg_page_serialno(ogg_page *og)
    int ogg_stream_init(ogg_stream_state *os, int serialno)
    int ogg_stream_packetout(ogg_stream_state *os, ogg_packet *op)
    int ogg_stream_clear(ogg_stream_state *os)
    int ogg_sync_clear(ogg_sync_state *oy)


cdef extern from "theora/theoradec.h":

    ctypedef unsigned int th_pixel_fmt
    ctypedef struct th_comment:
        pass
    ctypedef struct th_info:
        ogg_uint32_t  frame_width
        ogg_uint32_t  frame_height
        ogg_uint32_t  pic_width
        ogg_uint32_t  pic_height
        ogg_uint32_t  pic_x
        ogg_uint32_t  pic_y
        th_pixel_fmt  pixel_fmt
        ogg_uint32_t  fps_numerator
        ogg_uint32_t  fps_denominator
        ogg_uint32_t  aspect_numerator
        ogg_uint32_t  aspect_denominator
        int     target_bitrate
        int     quality
        int     keyframe_granule_shift
    int TH_PF_420
    int TH_PF_RSVD
    int TH_PF_422
    int TH_PF_444
    int TH_PF_NFORMATS
    ctypedef struct th_setup_info:
        pass
    ctypedef struct th_dec_ctx:
        pass
    ctypedef struct th_img_plane:
        int width
        int height
        int stride
        unsigned char *data
    ctypedef th_img_plane th_ycbcr_buffer[3]

    void th_comment_init(th_comment *_tc)
    void th_info_init(th_info *_info)
    int th_decode_headerin(th_info *_info,th_comment *_tc,
             th_setup_info **_setup,ogg_packet *_op)
    th_dec_ctx *th_decode_alloc(th_info *_info, th_setup_info *_setup)
    double th_granule_time(void *_encdec, ogg_int64_t _granpos)
    int th_decode_packetin(th_dec_ctx *_dec, ogg_packet *_op,
             ogg_int64_t *_granpos)
    void th_decode_free(th_dec_ctx *_dec)
    void th_info_clear(th_info *_info)
    void th_comment_clear(th_comment *_tc)
    int th_decode_ycbcr_out(th_dec_ctx *_dec, th_ycbcr_buffer _ycbcr)


cdef extern from "theora/theoraenc.h":
    ctypedef struct th_enc_ctx:
        pass
    int TH_EFAULT
    int TH_EINVAL
    int TH_EBADHEADER
    int TH_ENOTFORMAT
    int TH_EVERSION
    int TH_EIMPL
    int TH_EBADPACKET
    int TH_DUPFRAME
    th_enc_ctx* th_encode_alloc(th_info *_info)
    int th_encode_flushheader(th_enc_ctx *_enc, th_comment *_comments,
            ogg_packet *_op)
    int th_encode_ycbcr_in(th_enc_ctx *_enc, th_ycbcr_buffer _ycbcr)
    int th_encode_packetout(th_enc_ctx *_enc, int _last, ogg_packet *_op)
    void th_encode_free(th_enc_ctx *_enc)

cimport numpy as np

# The VIDEO_DIR below point to the directory with test files and the test_files
# dictionary points to the particular test files (we use a dictionary with
# numbers pointing to the files, so that if we deprecate some test file in the
# future, we can simply comment it out below and change just those tests, as
# opposed to renumbering all tests). This is used in both regular tests and
# doctests (that's why it has to be here).
VIDEO_DIR = "tests/videos"
test_files = {
        1: VIDEO_DIR + "/320x240.ogg",
        2: VIDEO_DIR + "/videotestsrc-720x576-16-15.ogg",
        3: VIDEO_DIR + "/offset_test.ogv",
        }


class TheoraException(Exception):
    pass

cdef class Theora:
    """
    Provides a nice high level Python interface to a theora video stream.

    It can read frames as numpy arrays or PIL images.

    Example of usage:
    -----------------

    >>> from theora import Theora, test_files, VIDEO_DIR
    >>> t = Theora(test_files[2])
    >>> print t
    <Ogg logical stream 11f68f2c is Theora 720x576 25.00 fps video, encoded frame
    content is 720x576 with 0x0 offset, aspect is 16:15>
    >>> t.read_frame()
    True
    >>> t.read_frame()
    True
    >>> t.get_frame_data()
    [array([[254, 254, 254, ...,  28,  28,  28],
           [254, 254, 254, ...,  28,  28,  28],
           [254, 254, 254, ...,  28,  28,  28],
           ..., 
           [ 16,  16,  16, ..., 169,  97,  88],
           [ 16,  16,  16, ..., 125,  70, 169],
           [ 16,  16,  16, ...,  19,  94, 161]], dtype=uint8), array([[128, 128, 128, ..., 255, 255, 255],
           [128, 128, 128, ..., 255, 255, 255],
           [128, 128, 128, ..., 255, 255, 255],
           ..., 
           [197, 197, 197, ..., 128, 128, 128],
           [197, 197, 197, ..., 128, 128, 128],
           [197, 197, 197, ..., 128, 128, 128]], dtype=uint8), array([[128, 128, 128, ..., 107, 107, 107],
           [128, 128, 128, ..., 107, 107, 107],
           [128, 128, 128, ..., 107, 107, 107],
           ..., 
           [ 21,  21,  21, ..., 128, 128, 128],
           [ 21,  21,  21, ..., 128, 128, 128],
           [ 21,  21,  21, ..., 128, 128, 128]], dtype=uint8)]
    >>> img = t.get_frame_image()
    >>> img.save(VIDEO_DIR+"c.png")

    """
    cdef object _infile
    cdef ogg_sync_state _oy
    cdef th_comment _tc
    cdef th_info _ti
    cdef ogg_page _og
    cdef ogg_stream_state _to
    cdef ogg_packet _op
    cdef th_setup_info *_setup
    cdef th_dec_ctx *_td
    cdef int _frame
    cdef double _time

    def __init__(self, f):
        """
        Opens the file "f" and read the headers.

        f .... either the filename or an open stream, that supports the .read()
               method

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> t.read_frame()
        True

        """
        if isinstance(f, (str, unicode)):
            self._infile = open(f)
        else:
            self._infile = f
        ogg_sync_init(&self._oy)
        th_comment_init(&self._tc)
        th_info_init(&self._ti)
        self._setup = NULL
        self._frame = 0
        self._time = 0.
        self.read_headers()

    def __del__(self):
        th_comment_clear(&self._tc)
        th_info_clear(&self._ti)
        ogg_sync_clear(&self._oy)
        ogg_stream_clear(&self._to)
        th_decode_free(self._td)


    @property
    def frame(self):
        """
        Returns the current frame number.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> t.read_frame()
        True
        >>> t.frame
        1
        >>> t.read_frame()
        True
        >>> t.frame
        2

        """
        return self._frame

    @property
    def time(self):
        """
        Returns the current video time of the frame.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> print t.time
        0.0
        >>> t.read_frame()
        True
        >>> print t.time
        0.04
        >>> t.read_frame()
        True
        >>> print t.time
        0.08

        """
        return self._time

    @property
    def width(self):
        """
        Returns the width of the video.

        This property can be used immediately after creating the instance.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> print t.width
        720
        >>> print t.height
        576
        >>> assert t.aspect_ratio == (16, 15)
        >>> t.serialno
        301371180
        >>> assert t.fps_ratio == (250000000, 10000000)

        """
        return self._ti.pic_width

    @property
    def height(self):
        """
        Returns the height of the video.

        This property can be used immediately after creating the instance.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> print t.width
        720
        >>> print t.height
        576
        >>> assert t.aspect_ratio == (16, 15)
        >>> t.serialno
        301371180
        >>> assert t.fps_ratio == (250000000, 10000000)

        """
        return self._ti.pic_height

    @property
    def aspect_ratio(self):
        """
        Returns the aspect_ratio of the video.

        This property can be used immediately after creating the instance.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> print t.width
        720
        >>> print t.height
        576
        >>> assert t.aspect_ratio == (16, 15)
        >>> t.serialno
        301371180
        >>> assert t.fps_ratio == (250000000, 10000000)

        """
        return self._ti.aspect_numerator, self._ti.aspect_denominator

    @property
    def serialno(self):
        """
        Returns the serial number of the video.

        This property can be used immediately after creating the instance.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> print t.width
        720
        >>> print t.height
        576
        >>> assert t.aspect_ratio == (16, 15)
        >>> t.serialno
        301371180
        >>> assert t.fps_ratio == (250000000, 10000000)

        """
        return self._to.serialno

    @property
    def fps_ratio(self):
        """
        Returns the fps ratio of the video.

        If you divide the two numbers, you get the fps.

        This property can be used immediately after creating the instance.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> print t.width
        720
        >>> print t.height
        576
        >>> assert t.aspect_ratio == (16, 15)
        >>> t.serialno
        301371180
        >>> assert t.fps_ratio == (250000000, 10000000)

        """
        return self._ti.fps_numerator, self._ti.fps_denominator

    cdef int buffer_data(self, int n=4096):
        """
        Reads "n" bytes from self._infile into the ogg_sync_state "oy".
        """
        s = self._infile.read(n)
        cdef int bytes=len(s)
        cdef char *buffer=ogg_sync_buffer(&self._oy, n)
        cdef char *m=s
        memcpy(buffer, m, n)
        ogg_sync_wrote(&self._oy, bytes)
        return bytes

    def fix_size(self, np.ndarray[np.uint8_t, ndim=2] A, int w, int h):
        """
        Enlarges the matrix A to fit into the (w, h) shape.

        Currently it can only double each dimension.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> from numpy import array
        >>> A = array([[1, 2], [3, 4]], dtype="uint8")
        >>> A
        array([[1, 2],
               [3, 4]], dtype=uint8)
        >>> t.fix_size(A, 2, 2)
        array([[1, 2],
               [3, 4]], dtype=uint8)
        >>> t.fix_size(A, 4, 4)
        array([[1, 1, 2, 2],
               [1, 1, 2, 2],
               [3, 3, 4, 4],
               [3, 3, 4, 4]], dtype=uint8)
        >>> t.fix_size(A, 4, 2)
        array([[1, 2],
               [1, 2],
               [3, 4],
               [3, 4]], dtype=uint8)
        >>> t.fix_size(A, 2, 4)
        Traceback (most recent call last):
        ...
        Exception: Can't enlarge the matrix.

        """
        cdef int i, j
        from numpy import zeros
        cdef np.ndarray[np.uint8_t, ndim=2] B = zeros((w, h), dtype="uint8")
        if A.shape[0] * 2 == w and A.shape[1] * 2 == h:
            for i in range(w):
                for j in range(h):
                    B[i, j] = A[i//2, j//2]
        elif A.shape[0] * 2 == w and A.shape[1] == h:
            for i in range(w):
                for j in range(h):
                    B[i, j] = A[i//2, j]
        elif A.shape[0] == w and A.shape[1] == h:
            for i in range(w):
                for j in range(h):
                    B[i, j] = A[i, j]
        else:
            raise Exception("Can't enlarge the matrix.")
        return B

    def trim_offset(self, np.ndarray[np.uint8_t, ndim=2] A):
        """
        Trims the theora offset.

        It uses self._ti.pic_x/pic_y/pic_width/pic_height to crop the image.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[3])
        >>> print t.width
        512
        >>> print t.height
        512
        >>> t.read_frame()
        True
        >>> Y, Cb, Cr = t.get_frame_data()
        >>> Y.shape
        (784, 768)
        >>> Y_trimmed = t.trim_offset(Y)
        >>> Y_trimmed.shape
        (512, 512)

        """
        return A[self._ti.pic_y:self._ti.pic_y+self._ti.pic_height,
                self._ti.pic_x:self._ti.pic_x+self._ti.pic_width]

    def YCbCr_tuple2array(self, YCbCr):
        """
        Converts the YCbCr tuple to one numpy (w, h, 3) array.

        It also implements the theora offset and also automatically rescales Cb
        and Cr if necessary (Theora encoder sometimes reduces their
        width/height twice compared to Y).
        """
        from numpy import concatenate
        Y, Cb, Cr = YCbCr
        w, h = Y.shape
        # enlarge Cb and Cr if necessary:
        Cb = self.fix_size(Cb, w, h)
        Cr = self.fix_size(Cr, w, h)
        # implement the theora offset:
        Y = self.trim_offset(Y)
        Cb = self.trim_offset(Cb)
        Cr = self.trim_offset(Cr)
        w, h = Y.shape
        Y = Y.reshape((w, h, 1))
        Cb = Cb.reshape((w, h, 1))
        Cr = Cr.reshape((w, h, 1))
        A = concatenate((Y, Cb, Cr), axis=2)
        return A

    def YCbCr2RGB(self, np.ndarray[np.uint8_t, ndim=3] A):
        """
        Converts the the (w, h, 3) array from YCbCr into RGB.
        """
        cdef int w, h, i, j
        cdef int Y, Cb, Cr
        cdef unsigned char R, G, B
        w = A.shape[0]
        h = A.shape[1]
        cdef np.ndarray[np.uint8_t, ndim=3] A_out = A.copy()
        for i in range(w):
            for j in range(h):
                Y = A[i, j, 0]
                Cb = A[i, j, 1]
                Cr = A[i, j, 2]
                YCbCr2RGB_fast_c(Y, Cb, Cr, &R, &G, &B)
                A_out[i, j, 0] = <int>R
                A_out[i, j, 1] = <int>G
                A_out[i, j, 2] = <int>B
        return A_out

    def get_frame_data(self):
        """
        Reads the image data and returns a tuple (Y, Cb, Cr).

        This is the lowest level API. Note that Cb and Cr may have twice lower
        dimensions than Y (the higher level API takes care of that) and also
        remember that this is the whole frame, so there might be some unused
        areas, see self._ti.pic_x/pic_y/pic_width/pic_height (padding is
        stripped though).
        """
        from numpy import zeros
        cdef th_ycbcr_buffer ycbcr
        if th_decode_ycbcr_out(self._td, ycbcr) != 0:
            raise Exception("th_decode_ycbcr_out failed\n")
        cdef int n
        cdef ndarray Y
        cdef char *Yp
        r = []
        for i in range(3):
            n = ycbcr[i].stride*ycbcr[i].height
            Y = zeros(n, dtype = "uint8")
            Yp = <char *>Y.data
            memcpy(Yp, ycbcr[i].data, n)
            Y = Y.reshape((ycbcr[i].height, ycbcr[i].stride))
            # strip the padding:
            Y = Y[:, :ycbcr[i].width]
            r.append(Y)
        return r

    def get_frame_array(self):
        """
        Returns the frame image data as a numpy (h, w, 3) array.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> t.read_frame()
        True
        >>> t.get_frame_array()
        array([[[254, 128, 128],
                [254, 128, 128],
                [254, 128, 128],
                ..., 
                [ 28, 255, 107],
                [ 28, 255, 107],
                [ 28, 255, 107]],
        <BLANKLINE>
               [[254, 128, 128],
                [254, 128, 128],
                [254, 128, 128],
                ..., 
                [ 28, 255, 107],
                [ 28, 255, 107],
                [ 28, 255, 107]],
        <BLANKLINE>
               [[254, 128, 128],
                [254, 128, 128],
                [254, 128, 128],
                ..., 
                [ 28, 255, 107],
                [ 28, 255, 107],
                [ 28, 255, 107]],
        <BLANKLINE>
               ..., 
               [[ 16, 197,  21],
                [ 16, 197,  21],
                [ 16, 197,  21],
                ..., 
                [ 84, 128, 128],
                [ 90, 128, 128],
                [205, 128, 128]],
        <BLANKLINE>
               [[ 16, 197,  21],
                [ 16, 197,  21],
                [ 16, 197,  21],
                ..., 
                [227, 128, 128],
                [201, 128, 128],
                [214, 128, 128]],
        <BLANKLINE>
               [[ 16, 197,  21],
                [ 16, 197,  21],
                [ 16, 197,  21],
                ..., 
                [165, 128, 128],
                [214, 128, 128],
                [246, 128, 128]]], dtype=uint8)


        This performs Cb and Cr components enlarging, as well as offset
        cropping.

        For accessing raw data, use get_frame_data().
        """
        return self.YCbCr_tuple2array(self.get_frame_data())

    def get_frame_image(self):
        """
        Returns the frame image data as a PIL image.

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> t.read_frame()
        True
        >>> img = t.get_frame_image()
        >>> img
        <Image.Image instance at 0x...>

        """
        from scipy.misc import toimage
        return toimage(self.YCbCr2RGB(self.get_frame_array()), channel_axis=2)

    def read_headers(self):
        """
        Reads headers of the theora file.

        This is called from the __init__() automatically.
        """
        cdef ogg_stream_state test
        stateflag = True
        theora_p = False
        while stateflag:
            ret = self.buffer_data();
            if ret == 0:
                raise Exception("End of file while searching for headers 1")
            while ogg_sync_pageout(&self._oy, &self._og) > 0:
                if ogg_page_bos(&self._og) == 0:
                    if theora_p:
                        ogg_stream_pagein(&self._to, &self._og)
                    stateflag = False
                    break
                ogg_stream_init(&test, ogg_page_serialno(&self._og))
                ogg_stream_pagein(&test, &self._og)
                ogg_stream_packetout(&test, &self._op)
                # is this the first theora stream?
                if not theora_p and \
                        th_decode_headerin(&self._ti, &self._tc,
                            &self._setup, &self._op) >= 0:
                    # yes, read it to self._to
                    memcpy(&self._to, &test, sizeof(test))
                    theora_p = True
                else:
                    # no, skip it
                    ogg_stream_clear(&test)
        while theora_p > 0 and (theora_p < 3):
            ret = ogg_stream_packetout(&self._to, &self._op)
            while theora_p > 0 and (theora_p < 3) and ret != 0:
                if ret < 0:
                    raise Exception("Error parsing headers 1")
                if th_decode_headerin(&self._ti, &self._tc,
                        &self._setup, &self._op) < 0:
                    raise Exception("Error parsing headers 2")
                theora_p += 1
                if theora_p == 3: break
                ret = ogg_stream_packetout(&self._to, &self._op)
            if ogg_sync_pageout(&self._oy, &self._og) > 0:
                if theora_p > 0: ogg_stream_pagein(&self._to, &self._og)
            else:
                ret = self.buffer_data()
                if ret == 0:
                    raise Exception("End of file while searching for headers 2")
        if self._ti.fps_denominator == 0:
            raise Exception("fps_denominator is zero")

        self._td = th_decode_alloc(&self._ti, self._setup)
        if self._td == NULL:
            raise Exception("th_decode_alloc failed: the decoding parameters are invalid")

    def __str__(self):
        return "<Ogg logical stream %lx is Theora %dx%d %.02f fps video, " \
            "encoded frame\ncontent is %dx%d with %dx%d offset, " \
            "aspect is %d:%d>" % (
            self._to.serialno, self._ti.pic_width, self._ti.pic_height,
            float(self._ti.fps_numerator)/self._ti.fps_denominator,
            self._ti.frame_width, self._ti.frame_height,
            self._ti.pic_x, self._ti.pic_y,
            self._ti.aspect_numerator, self._ti.aspect_denominator)

    def read_frame(self):
        """
        Reads the next frame.

        Returns True if the next frame was read, otherwise False (which means
        the EOF was reached).

        Example:

        >>> from theora import Theora, test_files
        >>> t = Theora(test_files[2])
        >>> t.read_frame()
        True
        >>> t.read_frame()
        True

        """
        cdef ogg_int64_t videobuf_granulepos = -1
        while 1:
            # do we have enough data to form a packet?
            if ogg_stream_packetout(&self._to, &self._op) > 0:
                # yes, decode it using theora and return
                th_decode_packetin(self._td, &self._op,
                        &videobuf_granulepos)
                self._time = th_granule_time(self._td, videobuf_granulepos)
                self._frame += 1
                return True
            else:
                # no, we need to read more data
                if self.buffer_data() == 0:
                    # EOF reached
                    return False
                while ogg_sync_pageout(&self._oy, &self._og) > 0:
                    ogg_stream_pagein(&self._to, &self._og)

    def seek(self, time=None, frame=None):
        """
        Seeks to the specified time or frame.

        Currently it can only seek forward.

        Example:
        >>> from theora import Theora, test_files
        >>> a = Theora(test_files[1])
        >>> a.seek(1)  # seeks to 1s
        >>> a.seek(frame=520) # seeks to the frame 520

        """
        if time is not None:
            while self.read_frame() and self.time < time:
                pass
        elif frame is not None:
            while self.read_frame() and self.frame < frame:
                pass
        else:
            raise ValueError("You must specify either the time or frame kwargs")

cdef inline unsigned char clip(int a):
    if a > 255:
        return 255
    elif a < 0:
        return 0
    else:
        return a

cdef void YCbCr2RGB_fast_c(unsigned char Y, unsigned char Cb, unsigned char
        Cr, unsigned char *R, unsigned char *G, unsigned char* B):
    """
    Converts from YCbCr to RGB using a very fast C integer arithmetics.

    Assumes both YCbCr and RGB are between 0..255

    This is a C version of the function. If you are in Python, use
    YCbCr2RGB_fast.
    """
    cdef int C, D, E
    C = Y - 16
    D = Cb - 128
    E = Cr - 128

    R[0] = clip((298*C + 409*E + 128) >> 8)
    G[0] = clip((298*C - 100*D - 208*E + 128) >> 8)
    B[0] = clip((298*C + 516*D + 128) >> 8)

def YCbCr2RGB_fast(YCbCr):
    """
    Converts from YCbCr to RGB using a very fast C integer arithmetics.

    Assumes both YCbCr and RGB are between 0..255
    """
    from numpy import array
    cdef unsigned char R, G, B
    Y, Cb, Cr = YCbCr
    YCbCr2RGB_fast_c(Y, Cb, Cr, &R, &G, &B)
    return array([R, G, B], dtype="uint8")

err_messages = {
        TH_EFAULT: "An invalid pointer was provided.",
        TH_EINVAL: "An invalid argument was provided.",
        TH_EBADHEADER: "The contents of the header were incomplete, invalid, or unexpected.",
        TH_ENOTFORMAT: "The header does not belong to a Theora stream.",
        TH_EVERSION: "The bitstream version is too high.",
        TH_EIMPL: "The specified function is not implemented.",
        TH_EBADPACKET: "There were errors in the video data packet.",
        TH_DUPFRAME: "The decoded packet represented a dropped frame.",
        }

def th_check(int r, char *function):
    if r < 0:
        if r in err_messages:
            raise TheoraException("%s: %s" % (function, err_messages[r]))
        else:
            raise TheoraException("%s returned: %d" % (function, r))

cdef class TheoraEncoder:
    cdef object _outfile
    #cdef ogg_sync_state _oy
    #cdef th_comment _tc
    cdef th_info _ti
    cdef th_enc_ctx *_te
    cdef ogg_page _og
    cdef ogg_stream_state _os
    cdef ogg_packet _op
    #cdef th_setup_info *_setup
    #cdef int _frame
    #cdef double _time

    def __init__(self, f, width, height, bitrate=None, quality=None):
        if isinstance(f, (str, unicode)):
            self._outfile = open(f, "w")
        else:
            self._outfile = f
        th_info_init(&self._ti)
        # TODO: make the below thing not increment 16 if w is exactly divisible
        # by 16:
        self._ti.frame_width = (width // 16 + 1) * 16
        self._ti.frame_height = (height // 16 + 1) * 16
        self._ti.pic_width = width
        self._ti.pic_height = height
        self._ti.pic_x = 0
        self._ti.pic_y = 0
        # the encoder doesn't support anything else besides 4:2:0 currently
        self._ti.pixel_fmt = TH_PF_420
        self._ti.fps_numerator = 25
        self._ti.fps_denominator = 1
        if bitrate is not None:
            self._ti.target_bitrate = bitrate
        if quality is not None:
            self._ti.quality = quality

        self._te = th_encode_alloc(&self._ti)
        if self._te == NULL:
            raise TheoraException("th_encode_alloc returned NULL.")
        self.write_headers()

    def __del__(self):
        th_encode_free(self._te)

    def __str__(self):
        return "<Ogg logical stream is Theora %dx%d %.02f fps video, " \
            "encoded frame\ncontent is %dx%d with %dx%d offset, " \
            "aspect is %d:%d>" % (
            self._ti.pic_width, self._ti.pic_height,
            float(self._ti.fps_numerator)/self._ti.fps_denominator,
            self._ti.frame_width, self._ti.frame_height,
            self._ti.pic_x, self._ti.pic_y,
            self._ti.aspect_numerator, self._ti.aspect_denominator)

    def write_headers(self):
        cdef th_comment comments
        th_comment_init(&comments)
        while self.th_encode_flushheader(&comments):
            self.ogg_stream_packetin()
            if self.ogg_stream_pageout():
                self.write_buffer()
        th_comment_clear(&comments)

    def fix_size(self, np.ndarray[np.uint8_t, ndim=2] A, int h, int w):
        """
        Compresses the matrix A to fit into the (w, h) shape.

        Currently it can only half each dimension.
        """
        cdef int i, j
        from numpy import zeros
        cdef np.ndarray[np.uint8_t, ndim=2] B = zeros((w, h), dtype="uint8")
        if A.shape[0] == w*2 and A.shape[1] == h*2:
            for i in range(w):
                for j in range(h):
                    B[i, j] = A[i*2, j*2]
        elif A.shape[0] == w*2 and A.shape[1] == h:
            for i in range(w):
                for j in range(h):
                    B[i, j] = A[i*2, j]
        elif A.shape[0] == w and A.shape[1] == h:
            for i in range(w):
                for j in range(h):
                    B[i, j] = A[i, j]
        else:
            raise Exception("Can't compress the matrix.")
        return B

    def write_frame_array(self, A, last=False):
        """
        Writes another frame to outfile.

        last .... Set it to true for the last frame, so that the proper EOS
                  flag is set on the last packet
        """
        cdef int r
        cdef int i
        cdef th_ycbcr_buffer ycbcr
        cdef ndarray B
        cdef int n
        h, w, n = A.shape
        n2 = w*h

        L = []
        for i in range(3):
            if i == 0:
                ycbcr[i].width = self._ti.frame_width
                ycbcr[i].height = self._ti.frame_height
                ycbcr[i].stride = w
                L.append(A[:, :, i].reshape(n2).copy())
            else:
                ycbcr[i].width = self._ti.frame_width // 2
                ycbcr[i].height = self._ti.frame_height // 2
                ycbcr[i].stride = w // 2
                B = self.fix_size(A[:, :, i], w//2, h//2)
                n = n2//4
                L.append(B.reshape(n).copy())
            B = L[i]
            ycbcr[i].data = <unsigned char*>(B.data)
        r = th_encode_ycbcr_in(self._te, ycbcr)
        th_check(r, "th_encode_ycbcr_in")

        while self.th_encode_packetout(last):
            self.ogg_stream_packetin()
            if self.ogg_stream_pageout():
                self.write_buffer()

        # I think this is not necessary:
        if last:
            self.flush()

    def flush(self):
        """
        Flushes any remaining data to the outfile.
        """
        if self.ogg_stream_flush():
            if self.ogg_stream_pageout():
                self.write_buffer()
        self._outfile.flush()

    cdef th_encode_flushheader(self, th_comment *comments):
        """
        Tries to retrieve a header packet from the theora encoder.

        Returns True if a packet was retrieved, otherwise False.
        """
        cdef int r
        r = th_encode_flushheader(self._te, comments, &self._op)
        th_check(r, "th_encode_flushheader")
        return r > 0

    cdef th_encode_packetout(self, last=False):
        """
        Tries to retrieve a raw packet from the theora encoder.

        Returns True if a packet was retrieved, otherwise False.
        """
        cdef int r
        cdef int _last
        if last:
            _last = 1
        else:
            _last = 0
        r = th_encode_packetout(self._te, _last, &self._op)
        th_check(r, "th_encode_packetout")
        return r > 0

    cdef ogg_stream_packetin(self):
        """
        Submits a raw packet to the stream.
        """
        if ogg_stream_packetin(&self._os, &self._op) != 0:
            raise Exception("ogg_stream_packetin: internal error")

    cdef ogg_stream_pageout(self):
        """
        Tries to retrieve a page from the stream.

        Returns True if a page was retrieved (e.g. enough data has accumulated
        to form a page), False otherwise.
        """
        return ogg_stream_pageout(&self._os, &self._og) != 0

    cdef ogg_stream_flush(self):
        """
        Flushes all remaining packets to the stream.

        Returns True if anything was pushed, False otherwise.
        """
        return ogg_stream_flush(&self._os, &self._og) != 0

    cdef write_buffer(self):
        """
        Write the ogg page to the outfile.
        """
        self._outfile.write(PyString_FromStringAndSize(<char*>(self._og.header),
            self._og.header_len))
        self._outfile.write(PyString_FromStringAndSize(<char*>(self._og.body),
            self._og.body_len))

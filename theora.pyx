cdef class Ogg:
    cdef object _f

    def __init__(self, f):
        self._f = f

    def test(self):
        print self._f

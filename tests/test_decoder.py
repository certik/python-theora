from theora import Theora

VIDEO_DIR = "tests/videos"
test_file1 = VIDEO_DIR + "/320x240.ogg"
test_file2 = VIDEO_DIR + "/videotestsrc-720x576-16-15.ogg"
test_file3 = VIDEO_DIR + "/offset_test.ogv"

def test_open1():
    t = Theora(test_file1)
    assert t.width == 320
    assert t.height == 240
    assert t.aspect_ratio == (0, 0)
    assert t.fps_ratio == (30000299, 1000000)
    assert t.serialno == 1032923656

def test_open2():
    t = Theora(test_file2)
    assert t.width == 720
    assert t.height == 576
    assert t.aspect_ratio == (16, 15)
    assert t.fps_ratio == (250000000, 10000000)
    assert t.serialno == 301371180

def test_open3():
    t = Theora(test_file3)
    assert t.width == 512
    assert t.height == 512
    assert t.aspect_ratio == (0, 0)
    assert t.fps_ratio == (1, 1)
    assert t.serialno == 1804289383

def test_read_frame():
    t = Theora(test_file1)
    t.read_frame()

def test_get_frame_data():
    t = Theora(test_file1)
    t.read_frame()
    data = t.get_frame_data()
    assert isinstance(data, (list, tuple))
    assert len(data) == 3
    Y, Cb, Cr = data
    assert Y.shape == (240, 320)
    assert Cb.shape == (120, 160)
    assert Cr.shape == (120, 160)

def test_PIL_image():
    t = Theora(test_file1)
    t.read_frame()
    img = t.get_frame_image()
    img.save(VIDEO_DIR + "/a.png")

def test_mpl():
    t = Theora(test_file1)
    t.read_frame()
    A = t.get_frame_array()
    import pylab
    pylab.imshow(t.YCbCr2RGB(A))
    pylab.savefig(VIDEO_DIR + "/b.png")

def test_seek1():
    t = Theora(test_file1)
    t.seek(0.75)
    assert t.time > 0.75
    assert t.frame == 23

def test_seek2():
    t = Theora(test_file1)
    t.seek(time=0.75)
    assert t.time > 0.75
    assert t.frame == 23

def test_seek3():
    t = Theora(test_file1)
    t.seek(frame=23)
    assert t.time > 0.75
    assert t.frame == 23

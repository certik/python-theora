from theora import Theora

test_file1 = "tests/videos/320x240.ogg"
test_file2 = "tests/videos/videotestsrc-720x576-16-15.ogg"
test_file3 = "tests/videos/offset_test.ogv"

def test_open1():
    t = Theora(test_file1)
    assert t.width == 320
    assert t.height == 240
    assert t.aspect_ratio == (0, 0)
    assert t.fps_ratio == (30000299, 1000000)

def test_open2():
    t = Theora(test_file2)
    assert t.width == 720
    assert t.height == 576
    assert t.aspect_ratio == (16, 15)
    assert t.fps_ratio == (250000000, 10000000)

def test_open3():
    t = Theora(test_file3)
    assert t.width == 512
    assert t.height == 512
    assert t.aspect_ratio == (0, 0)
    assert t.fps_ratio == (1, 1)

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

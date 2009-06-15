from theora import Theora

test_file1 = "tests/videos/320x240.ogg"
test_file2 = "tests/videos/320x240.ogv"

def test_open1():
    t = Theora(test_file1)

def test_open2():
    t = Theora(test_file2)

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

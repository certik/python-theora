from theora import Theora

test_file1 = "tests/videos/320x240.ogg"
test_file2 = "tests/videos/320x240.ogv"

def test_open1():
    t = Theora(test_file1)

def test_open2():
    t = Theora(test_file2)

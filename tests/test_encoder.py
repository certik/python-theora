from theora import Theora, TheoraEncoder

VIDEO_DIR = "tests/videos"
test_file1 = VIDEO_DIR + "/320x240.ogg"
test_file2 = VIDEO_DIR + "/videotestsrc-720x576-16-15.ogg"
test_file3 = VIDEO_DIR + "/offset_test.ogv"

def test_recoding1():
    a = Theora(test_file1)
    b = TheoraEncoder(VIDEO_DIR+"/a.ogv", a.width, a.height)
    a.seek(time=0.75)
    while a.read_frame() and a.time < 0.90:
        A = a.get_frame_array()
        b.write_frame_array(A)

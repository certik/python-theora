from theora import Theora, TheoraEncoder, test_files, VIDEO_DIR

def test_recoding1():
    a = Theora(test_files[1])
    b = TheoraEncoder(VIDEO_DIR+"/a.ogv", a.width, a.height)
    a.seek(time=0.75)
    while a.read_frame() and a.time < 0.90:
        A = a.get_frame_array()
        b.write_frame_array(A)

def test_recoding2():
    a = Theora(test_files[1])
    b = TheoraEncoder(VIDEO_DIR+"/b.ogv", a.width, a.height)
    a.seek(time=0.75)
    while a.read_frame() and a.time < 0.90:
        data = a.get_frame_data()
        b.write_frame_data(data)

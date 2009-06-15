#! /usr/bin/env python
"""
Analog to the oggz-chop program.

Example:

examples/chop.py -o s.ogv -s 20 -e 30 video.ogv

See "./chop.py -h" for help.

"""

from optparse import OptionParser
from theora import Theora, TheoraEncoder

def convert(infile, outfile, start, end):
    print "converting %s to %s, between the times %d:%d" % \
            (infile, outfile, start, end)
    a = Theora(infile)
    b = TheoraEncoder(outfile, a.width, a.height, quality=63)
    a.seek(time=start)
    while a.read_frame() and a.time < end:
        print "frame: %d, time=%f" % (a.frame, a.time)
        A = a.get_frame_array()
        b.write_frame_array(A)

usage = """\
%prog [options] file_in
Extract the part of a Theora video file between start and/or end times.
"""
def main():
    parser = OptionParser(usage=usage)
    parser.add_option("-o", "--output", dest="filename",
            help="Specify output filename")
    parser.add_option("-s", "--start", dest="start_time", type="int",
            help="Specify start time")
    parser.add_option("-e", "--end", dest="end_time", type="int",
            help="Specify end time")
    options, args = parser.parse_args()

    if options.filename and options.start_time and options.end_time and \
            len(args) == 1:
        convert(args[0], options.filename, options.start_time, options.end_time)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()

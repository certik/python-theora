#! /usr/bin/env python

from distutils.core import setup, Command
from distutils.extension import Extension
from Cython.Distutils import build_ext
import os
import sys

__version__ = '0.1'

class test_theora(Command):
    """
    Runs all tests under tests/ and all doctests.
    """

    description = "Runs all tests under tests/ and all doctests."
    user_options = []

    def __init__(self, *args):
        self.args = args[0]
        Command.__init__(self, *args)

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        import py
        import doctest
        py.test.cmdline.main(["tests/"])
        # if there was a test failure, the py.test calls sys.exit(), so the
        # code below is not executed:
        print "\nRunning doctests:"
        print "Testing the file 'theora.pyx'"
        print "Failed %s, tested %s" % doctest.testfile("theora.pyx", module_relative=False)


# write default shout.pc path into environment if PKG_CONFIG_PATH is unset
if not os.environ.has_key('PKG_CONFIG_PATH'):
    os.environ['PKG_CONFIG_PATH'] = '/usr/local/lib/pkgconfig'

# Find shout compiler/linker flag via pkgconfig or shout-config
if os.system('pkg-config --exists theoraenc theoradec 2> /dev/null') == 0:
    pkgcfg = os.popen('pkg-config --cflags theoraenc theoradec')
    cflags = pkgcfg.readline().strip()
    pkgcfg.close()
    pkgcfg = os.popen('pkg-config --libs theoraenc theoradec')
    libs = pkgcfg.readline().strip()
    pkgcfg.close()

else:
    if os.system('pkg-config --usage 2> /dev/null') == 0:
        print "pkg-config could not find theoraenc theoradec: check PKG_CONFIG_PATH"
    else:
        print "pkg-config unavailable, build terminated"
    sys.exit(1)

# there must be an easier way to set up these flags!
iflags = [x[2:] for x in cflags.split() if x[0:2] == '-I']
extra_cflags = [x for x in cflags.split() if x[0:2] != '-I']
libdirs = [x[2:] for x in libs.split() if x[0:2] == '-L']
libsonly = [x[2:] for x in libs.split() if x[0:2] == '-l']

# numpy
iflags += ['/usr/include/numpy', ]

theora = Extension('theora', sources = ['theora.pyx'],
                   include_dirs = iflags,
                   extra_compile_args = extra_cflags,
                   library_dirs = libdirs,
                   libraries = libsonly)

setup(
    name = 'theora',
    version = __version__,
    cmdclass = {
        'build_ext': build_ext,
        'test': test_theora,
        },
    ext_modules = [theora],
    description = 'Bindings for libtheora',
    url = 'http://github.com/certik/python-theora',
    author = 'Ondrej Certik',
    author_email = 'ondrej@certik.cz',
    classifiers = [
        'Development Status :: 3 - Alpha',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        'Programming Language :: C',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
)

#! /bin/sh
# Downloads the official theora test files, that we use for testing the python
# wrappers and running doctests:

WGET="wget -nc"

# ROOT points to the tests directory:
ROOT=`readlink -nf "$0" 2> /dev/null` || \
ROOT=`readlink -n "$0" 2> /dev/null` || \
ROOT=`realpath    "$0" 2> /dev/null` || \
ROOT="$0"
ROOT="${ROOT%/*}/"

cd $ROOT
mkdir -p videos
cd videos
$WGET http://v2v.cc/~j/theora_testsuite/320x240.ogg
#$WGET http://v2v.cc/~j/theora_testsuite/320x240.ogv
$WGET http://v2v.cc/~j/theora_testsuite/videotestsrc-720x576-16-15.ogg
$WGET http://v2v.cc/~j/theora_testsuite/offset_test.ogv

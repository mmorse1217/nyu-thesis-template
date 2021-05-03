#!/bin/bash
#
# check all tex files and the figure directory periodically and remake
# the pdf file. The combination of emacs, this script, the makefile
# (with proper reporting of warning) and texshop for preview is the
# most convenient set up for the time being.
#

if [ "$#" -eq 0 ]; then
    mflags="-B"
else
    mflags=$@
fi

# try -m kqueue_monitor for fswatch if the default is not working
fswatch -m poll_monitor -to -l 0.5 -E '#*' hedgehog/*.tex bloodflow/*.tex *.tex ./figs | while read e; do echo "building ..." `date`; make PROJ=thesis ${mflags}; done

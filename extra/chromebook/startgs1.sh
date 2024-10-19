#!/bin/bash -x
#
# Designed to run in the Linux subsystem of a Chromebook
#
# Prerequisites
#    sudo apt install xserver-xephyr
#    sudo apt install wmaker
#    git clone https://github.com/onflapp/gs-terminal
#
# Start an Xephyr session with WMaker and a GNUstep Terminal
# (a minimal GS environment)


unset DISPLAY_LOW_DENSITY
unset WAYLAND_DISPLAY_LOW_DENSITY
unset WAYLAND_DISPLAY
# unset XDG_RUNTIME_DIR # so apps in GS do not find the wayland socket

DISP2=:2

# Note: the -dpi option helps some apps (like Emacs) size the font

Xephyr -dpi 162 -fullscreen -noreset ${DISP2} &
XM_PID="$!"
echo "Xephyr is running on $XM_PID"
DISPLAY=${DISP2}   # later commands will use this DISPLAY

sleep 0.1
wmaker &
WM_PID="$!"
echo "Wmaker is running on $WM_PID"

sleep 0.1
openapp Terminal &
TERM_PID="$!"
echo "Terminal is running on $TERM_PID"

# Now wait for the WM to exit and shut down the Xserver and Terminal
wait $WM_PID
kill -9 $TERM_PID
kill -9 $XM_PID

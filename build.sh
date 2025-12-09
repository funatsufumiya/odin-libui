#!/bin/bash

cd $(dirname $0)

mkdir bin 1>/dev/null 2>/dev/null

# CC=clang
# $CC -lui -I. -L bin -o "bin/calender" "examples/calender/main.c" 
# $CC -lui -I. -L bin -o "bin/widgets" "examples/widgets/main.c" 
# $CC -lui -I. -L bin -o "bin/graph" "examples/graph/main.c" 
# $CC -lui -I. -L bin -o "bin/label" "examples/label/main.c" 
# $CC -lui -I. -L bin -o "bin/timer" "examples/timer/main.c" 
# $CC -lui -I. -L bin -o "bin/minimal" "examples/minimal/main.c" 

odin build "examples/minimal" -out:"bin/minimal"
odin build "examples/timer" -out:"bin/timer"
odin build "examples/calendar" -out:"bin/calendar"
# v -enable-globals examples/calendar/main.v -o bin/calendar
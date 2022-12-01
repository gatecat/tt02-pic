#!/usr/bin/env bash
set -ex
iverilog -s tb -o pic_tb.vvp pic.v tb.v
vvp pic_tb.vvp

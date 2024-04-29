#!/bin/bash

ffmpeg -r 60 -i zoom/zoom-%05d.png -pix_fmt yuv420p zoom/zoom.mp4


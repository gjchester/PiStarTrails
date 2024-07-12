#!/bin/bash
DATE=$(date +"%Y-%m-%d_%H%M%S") 
/usr/bin/raspistill -vf -hf -w 1920 -h 1080 -ISO 800 -ss 6000000 -br 80 -co 100 -t 57600000 -tl 50000 -o /home/pi/camera/$DATE%05d.jpg

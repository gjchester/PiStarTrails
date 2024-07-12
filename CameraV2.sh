#!/bin/bash

#RPICam/LibCamera has more options, this needs a newer version of the OS than V1, but at least it not so obselete.
#Tested on 32Bit Raspbian Release  5.2 March 2024
#
#This script should take an image, and then sleep for 30 second and take another bwefore exiting.   A Cron Job is set to run this script every minute rather than leaving this running this script.
#


DATE=$(date +"%Y-%m-%d_%H%M")
rpicam-still -o /home/pi/camera/$DATE.jpg
sleep 30s # Waits 30 seconds.
DATE=$(date +"%Y-%m-%d_%H%M")
rpicam-still -o /home/pi/camera/$DATE.jpg

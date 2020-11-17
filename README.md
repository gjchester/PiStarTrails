# PiStarTrails

Taking time lapse star trails with a Raspberry Pi and Pi Camera

This project is not original work, its taking snippets from here and there to make sopmethign that works for me.  This is mainly so i I have a record for the future.

The starting point was https://www.tring-web-design.co.uk/2020/04/raspberry-pi-camera-timelapse-tutorial/


My goal was to be able to plug a Pi in to battery back and leave it outside to capture timelapse star trails. Thats simple enough but after a holiday where my laptop failed I realsied it needed a little more work to make it somethign I could just put out side day in and day out without needding a computer to change file or folder names.  I also want ed to have a safe showdown options rather than yank the plug, mainly to avoid corrupting the SD card image.

Project requrirements

Raspberry Pi I have this running on a 2 and a 3.  Its actualy best to be using a A or Zero if you can, simply becvasue they dont have WiFi or Ethernet so its one less thing to draw power.

Rapberry Pi Camera  - Can be a clone but should be conencted by the ribbon cable for power saving reasons, NoIR is a good options too.

Real Time Clock - I'm using a DS3231 type chip (cheap on Ebay/Amazon /Chinese drop shippers)

Battery Pack - I use a 10,000 pack I got at a trade show, mainly as it was close by, this shoud give me 20+ hours use.   However differnt Pi versions (say a 4) may have higher draws.  If you u8se a stnadard camera we also turn the LED off to save a little bit of power too.

Waterproof Box - Anything, Currently I have one in a takaway food carton and the other in a Ferrero Rocche Box (Other chocolates are availabe) both use BlueTac and Masking Tape,  I problaby should do a better job.



Step 1:  Setting up the RTC on the Pi.

Withthe power off install RTC module and two flying leads for the Software Power Off, The RTC goes on bottom row far left (pins 1,3,5,7,9)

The Flying leads I use the last two pins on the Pi 2, ie nearest composite connector, (Ground and GPIO7) or on the Pi 3 I used ping 37 and 39 ie last two bottom row (Grnd and GPIO26). It does not matter what are used as long as we know for the script.


Burn fresh image to the SD, and allow to boot.  Enable the Camera and I2C interfaces and set it to boot to the command line (again thiking saving power).  Connect a network leads (so we can set the RTC from NTP time) and allow to reboot expanding file sysytem if required.

https://thepihut.com/blogs/raspberry-pi-tutorials/17209332-adding-a-real-time-clock-to-your-raspberry-pi

This suggests you need to install I2C but my image (Nov 2020) had it installed.

Testing I2C - Issue the command

  sudo i2cdetect -y 1

The Clock should be present at postion 68


Issue the following commands

  sudo modprobe rtc-ds1307
  sudo bash
  echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device
  exit
  sudo hwclock -r

If the time is correct we cna skip hte next step, but in case its a new module we will get a 2000 date.

Issue the command 

  date

This will display the current Pi time, if its correct  we issue the folling to write it to the RTC chip.

  sudo hwclock -w 


We can check the new time by issuing a 

  sudo hwclock -r

This set up the RTC but the Pi needs to be told to use it on boot.

Edit /etc/modules (Needs to be done under sudo) and add the following line

  rtc-ds1307

Close and save

Edit /etc/rc.local (again under sudo) and add the following lines before the exit 0

  echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device
  sudo hwclock -s
  date

Save and exit, these lines probe the RTC for the clock value,rest the Pi's clock form the RTC and then echo the date to screne on boot up.

Disconnect the LAN lead, and power down the Pi, Disconnect the Power for a few seconds so the Pi is fully off then power up.  ON powering up the Pi should be set to the the current time and date.


Step 2 - Setting up safe shutdown

I use two flying leads but a switch would be better.   Either way when we pull the selected GPIO pin to ground we trigger a script to shut the Pi down.

The script came from   https://core-electronics.com.au/tutorials/how-to-make-a-safe-shutdown-button-for-raspberry-pi.html

Create a script called SafeShut.py in the /home/pi directory with this content

SEE piShutdown.py file

Replace Button(26) with 7 for the Pi 2 (or whatever GPIO line is in use)

Issue the command 

  sudo python /home/pi/piShutdown.py
  
to start the script, and press the button / short the flying leads to test it.  The Pi Should shutdown, if it fails check the "" have not been manged by cutting /pasting.




Assuimg this work we need to edit /etc/rc.local to tell it to run (sudo nano to edit the file), add the following line AFTER the lines to make the Pi set its real time clock,  

  sudo python /home/pi/piShutdown.py &
  
The & makes the Pi background the script and move on so the scripot stays running.



Step 3 - Setting up the Camera

Taking the Tring Web disign scrpt Create a file called camera.sh in a foilder called camera under the PI home area.


Create a script called camera.sh and enter the following lines.

  #!/bin/bash
  DATE=$(date +"%Y-%m-%d_%H%M%S")
  /usr/bin/raspistill -vf -hf -w 1920 -h 1080 -ISO 800 -ss 6000000 -br 80 -co 100 -t 57600000 -tl 50000 -o /home/pi/camera/$DATE%05d.jpg


This calls the date into a variable DATE that we then use to be the root of our file name.   This allows the system to shotdown and restart and a new file name root should be generated each time, so files will not be overwritten.

A pair of sample file name will be 2020-11-17-20-20-2000001.jpg and 2020-11-17-20-20-2000002.jpb

the -vf and -hf Flip the axies (does not matter ) -w -h specify the image size (1920 x 1080) -ISO sets the ISO, -ss shutter speed in microseconds (ie 6 seconds), -Br and -Co sets contrast / brightness, -t is how long to run for in this case 16 hours so I cna put it oput in the UK at 4pm and have it runto 8am when dawn breaks. -tl is timelapse,it take a shot every 5 seconds, and -o tells it where to put the file withthe suitable prefix.


We need to make this executable with a

sudo chmod u+x /home/pi/camera/camera.sh

And finally edit /etc/rc.local to tell it to run,add the following line AFTER the lines to make the Pi set its real time clock and do set up the SafeShutdown, we need to  set the Pi's clock  before we tell  it what to use for the file name, and we need the safe shutdown script running so it cna shut the Pi down on demand.

  /home/pi/camera/camera.sh & 




Step 4 - Next date (when every you are ready) 

Put rhe SD card into another computer and pull the files off.  If needed seperate them by time / date in to seperate folders, as the collowing command builds all the frames it finds into one movie.

Run the following command to create a movie from the images


  mencoder mf://*.jpg -mf fps=15:type=jpeg -noskip -of lavf -lavfopts format=mov -ovc lavc -lavcopts vglobal=1:coder=0:vcodec=mpeg4:vbitrate=5000 -vf eq2=1.2:0.9:0.0:1.0,scale=1280:-2 -o lapse.avi















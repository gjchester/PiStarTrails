# PiStarTrails

Taking time lapse star trails with a Raspberry Pi and Pi Camera

This project is not original work, its taking snippets from here and there to make something that works for me.  This is mainly so I have a record for the future.

The starting point was https://www.tring-web-design.co.uk/2020/04/raspberry-pi-camera-timelapse-tutorial/


My goal was to be able to plug a Pi in to battery back and leave it outside to capture timelapse star trails. Thats simple enough but after a holiday where my laptop failed I realised it needed a little more work to make it something I could just put outside day in and day out without needing a computer to change file or folder names.  I also wanted to have a safe showdown options rather than yank the power, mainly to avoid corrupting the SD card image.

## Project requrirements

Raspberry Pi's I have this running on are a 2B and a 3B.  Its actualy best to be using a A or Zero if you can, simply because they don't have WiFi or Ethernet so its less things to draw power.  The Pi4 uses on average six time the power of a A or Zero for the same task .  Its on two as one has the standard camera and the other a NoIR camera.

Rapberry Pi Camera  - Can be a clone but should be connected by the ribbon cable for power saving reasons, NoIR is a good options too.

Real Time Clock - I'm using a DS3231 type chip (cheap and cheerful, via Ebay/Amazon /Chinese drop shippers)

Battery Pack - I use a 10,000mah pack I got at a trade show, mainly as it was close by, this shoud give me 20+ hours use.   However differnt Pi versions (say a 4) may have higher power draws.  If you use a standard camera we also turn the LED off to save a little bit of power too.

Waterproof Box - Anything, currently I have one in a take-away food carton and the other in a plastic Ferrero Roche box (other chocolates are available) both use BlueTac and Duct Tape,  I probably should do a better job, these were mainly what I had to hand and could use to make something to keep off light rain/drizzle/fog,  I don't put them out if it looks cloudy or might rain, but a night is a long time for the weather to change.  Its on the to do list to make one enclosure to hold both Pi's out of something with more space for the battery and leads, maybe I can even use the 20000Mah pack I have to power both. The clear choc box is also rather brittle and ideally needs replacing, I've used duct tape to cover cracks.

![Image of One of the Boxes](https://github.com/gjchester/PiStarTrails/blob/main/449082E6-6475-4E5F-A2FB-40CE26B0C6D1.jpeg)

![Image of Other Box](https://github.com/gjchester/PiStarTrails/blob/main/3F0D1C6C-D086-4C86-AFC1-F0C03C01DAA9.jpeg)




## Step 1:  Setting up the RTC on the Pi.

With the power off install RTC module and two flying leads for the Software Power Off. The RTC goes on bottom row far left (pins 1,3,5,7,9)

The Flying leads I use the last two pins on the Pi 2, ie nearest composite connector, (Ground and GPIO7) or on the Pi 3 I used pins 37 and 39 ie last two bottom row (Grnd and GPIO26). It does not matter what are used as long as we know for the script.

![FlyLeadsand RTC Clock](https://github.com/gjchester/PiStarTrails/blob/main/E2B2E0BB-CF9C-4C51-BF71-99B5CE7607E1.jpeg)


Burn fresh Raspian image to the SD, and allow to boot and setup.  Enable the Camera and I2C interfaces and set it to boot to the command line (again the thinking is saving power).  Connect a network leads (so we can set the RTC from NTP time) and allow to rebootm  expanding file sysytem if required.

OPTIONAL: Depending on your power pack you can try and save more power to extend use time, turing off the HDMI, LED's and only install and run services you need cna help.  My 10,000Mah one last all night so it wasn't an issue. 

https://thepihut.com/blogs/raspberry-pi-tutorials/17209332-adding-a-real-time-clock-to-your-raspberry-pi

This suggests you need to install I2C but my Rasbian image (Nov 2020) had it installed.

Testing I2C - Issue the command

    sudo i2cdetect -y 1

The Clock unit should appear present at postion 68 on the screen


Issue the following commands

    sudo modprobe rtc-ds1307
    sudo bash
    echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device
    exit
    sudo hwclock -r

If the RTC has bene used before the time are problaby correct so we can skip the next few step, but in case its a new module we will problaby get a 2000 date. Worse case is a few extra commands are typed..

Issue the command
    date

This will display the current Pi time, if its correct we issue the following to write it to the RTC chip.
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

Save and exit, these lines probe the RTC for the clock value,set the Pi's clock from the RTC and then echo the date to screen on boot up (mainly for human use!)

Disconnect the LAN lead, and power down the Pi, Disconnect the Power for a few seconds so the Pi is fully off then power up.  On powering up the Pi should be set to the the current time and date.


## Step 2 - Setting up safe shutdown

I use two flying leads but a switch would be better.   Either way when we connect them (or press the switch) we pull the selected GPIO pin to ground and we trigger a script to shut the Pi down.

The script came from   https://core-electronics.com.au/tutorials/how-to-make-a-safe-shutdown-button-for-raspberry-pi.html

Create a script called SafeShut.py in the /home/pi directory with this content

SEE piShutdown.py file

In my case I replace Button(26) with Button(7) for the Pi 2 (or whatever GPIO line is in use).  You may have differnet GPIO's

Issue the command 

    sudo python /home/pi/piShutdown.py
  
to start the script, and press the button / short the flying leads to test it.  The Pi Should shutdown, if it fails check the "" in the script have not been mangled by cutting /pasting.




Assumimg this works we need to edit /etc/rc.local to tell it to run on startup  (sudo nano to edit the file), add the following line AFTER the lines to make the Pi set its real time clock,  
    sudo python /home/pi/piShutdown.py &
  
The & makes the Pi background the script and move on so the script stays running.



## Step 3 - Setting up the Camera

Taking the Tring Web design scrpt create a file called camera.sh in a foilder called camera under the PI home area.


Create a script called camera.sh and enter the following lines.

SEE camera.sh file

This calls the date into a variable DATE that we then use to be the root of our file name.   This allows the system to shutdown and restart and a new file name root should be generated each time, so files will not be overwritten.

A pair of sample file name will be 2020-11-17-20-20-2000001.jpg and 2020-11-17-20-20-2000002.jpb

the -vf and -hf Flip the axies (does not matter ) -w -h specify the image size (1920 x 1080) -ISO sets the ISO, -ss shutter speed in microseconds (ie 6 seconds), -Br and -Co sets contrast / brightness, -t is how long to run for in this case 16 hours so I cna put it oput in the UK at 4pm and have it runto 8am when dawn breaks. -tl is timelapse,it take a shot every 5 seconds, and -o tells it where to put the file withthe suitable prefix.


We need to make this executable with a
    sudo chmod u+x /home/pi/camera/camera.sh

And finally edit /etc/rc.local to tell it to run,add the following line AFTER the lines to make the Pi set its real time clock and do set up the SafeShutdown, we need to  set the Pi's clock  before we tell  it what to use for the file name, and we need the safe shutdown script running so it can shut the Pi down on demand.
    /home/pi/camera/camera.sh & 


OPTIONAL: To disable the red LED you simply need to add the following line to your config.txt file 
    disable_camera_led=1
    
To edit the config.txt file you can use Nano :
    sudo nano /boot/config.txt

This takes effect on next reboot.

OPTIONAL 2:   Consider duct taping over the LED's on your case if they may be causing any stray light to get to  the camera.   This depends on how your set up, it it a clear of solid case, which way the Pi Board is facing (try to point the LED's down and away from the camera if the ribbon cables and your setup allows) 


## Step 4 - Day after the capture (whenever you are ready) 

Put the SD card into another computer and pull the files off.  If needed seperate them by time / date in to seperate folders, as the collowing command builds all the frames it finds into one movie.

Run the following command to create a movie from the images

    mencoder mf://*.jpg -mf fps=15:type=jpeg -noskip -of lavf -lavfopts format=mov -ovc lavc -lavcopts vglobal=1:coder=0:vcodec=mpeg4:vbitrate=5000 -vf eq2=1.2:0.9:0.0:1.0,scale=1280:-2 -o lapse.avi















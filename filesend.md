# Extracting and sending files from simh to PDP-11/73 #

Solution for getting the compiled kernel with the correct settings that was made in simh to the 11/73.

The PDP-11/73 is now running 2.11BSD UNIX. But the RD52 31MB MFM drive is not big enough to hold all user level commands and source files. So compiling the kernel with the wanted configuration is not possible.

What is possible is to compile the kernel using an emulated PDP-11/73 within simh. The root file system with all the files can then be extracted from the simulator and then sent to the PDP-11/73. The process for this is described below.

- On simh:

        attach ts root.tap

- Start simulation
- Within simh-unix copy required files to a folder named dump
- Within simh-unix do:

        mt rewind
        tar cvf /dev/rmt12 dump

- End simulation
- On simh do:

        detach ts

- Quit simh
- Within terminal do:

        perl tapcat.pl root.tap 0 > root.tar
        tar xvf root.tar

## Step 2 - Sending 2.11BSD VTserver client to PDP-11/73 ##

- Compile vtc on simh-unix:

        cc vtc.c -o vtc

- Get vtc binary off simh-unix using the previous method
- Compile "hexify":

        gcc hexify.c -o hexify

- Hexify vtc binary (converts the vtc binary to a plaintext hex)

        ./hexify vtc > vtc.hex

- Transfer vtc.hex, cphex.c and stdio.h to PDP-11 using Kermit TRANSMIT

        set transmit echo on
        set transmit EOF \4
        set transmit pause 100
        set modem type none
        set line /dev/tty.usbserial
        set speed 9600
        set parity even
        set stop-bits 1

- Compile cphex.c on 11/73

        cc cphex.c -o cphex

- Use cphex to convert vtc.hex to vtc

        ./cphex vtc.hex > vtc

- Make vtc executable

        chmod a+x vtc


## Step 3 - Sending files to PDP-11/73

- Connect PDP-11 to serial port
- Start VTserver on computer

        ./vtserver 9600 -odt

- Boot 2.11BSD UNIX using VTserver

        ra(0,0)unix

- Once UNIX is booted do (assuming its the 2nd item on the tape):

        ./vtc 2 > file.tar

- To extract the files in the tar do:

        tar xpf file.tar


tapcat.pl found [here](https://github.com/eunuchs/unix-archive/tree/master/PDP-11/Boot_Images/2.11_on_Simh)

vtc 2.11BSD client [here](http://home.windstream.net/engdahl/vtc.htm)

Simulator used [simh](http://simh.trailing-edge.com/)
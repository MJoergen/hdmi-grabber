# hdmi-grabber
A HDMI grabber for the Digilent Zybo Z7 ZYNQ-7020 board. This board is based on the xc7z020clg400-1.

Docs (downloaded from Digilent):
* [Zybo Z7 Reference manual](doc/zybo-z7_rm.pdf)
* [Zybo Z7 Schematic](doc/zybo_z7_sch-public.pdf)
* [Zynq-7000 SoC Technical Reference Manual](doc/ug585-Zynq-7000-TRM.pdf)

Digilent has a demo project here (branch: 20/HDMI/master):
[https://github.com/Digilent/Zybo-Z7](https://github.com/Digilent/Zybo-Z7/tree/20/HDMI/master)

Resources:
Vivado 2020.2

The xc7z020 has 6 clock regons (X0Y0 to X1Y2).  The Programmable System takes a
significant portion of the area of X0Y1 and X0Y2, meaning that these two clock
regions have significantly fewer CLBs than the other 4 regions.

Clock Regions:
X0Y0 contains I/O bank 13.
X1Y1 contains I/O bank 34.
X1Y2 contains I/O banks 0 and 35.

Input clock (on pin K17, I/O bank 35) is 125 MHz, and is delivered by the Ethernet PHY.
This pin is MRCC and is in clock region X1Y2.

The HDMI clock input (pins U18 and U19, I/O bank 34) is in clock region X1Y1.

The HDMI data input (pins V20/W20, T20/U20, and N20/P20) are all in I/O bank 34 and clock region X1Y1.


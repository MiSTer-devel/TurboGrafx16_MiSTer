# TruboGrafx 16 / PC Engine for [MiSTer Board](https://github.com/MiSTer-devel/Main_MiSTer/wiki) 

### This is the port of Gregory Estrade's [FPGAPCE](https://github.com/Torlus/FPGAPCE) with some tweaks from MiST's port.

This version is optimized for MiSTer:
  * Uses BRAM for main and graphics memory (reduces graphics glitches)
  * Uses DDR3 for cartridge's ROM

## Installation:
Copy the *.rbf file at the root of the SD card. Copy roms (*PCE,*BIN) to **TGFX16** folder. You may rename ROM of your favorite game to **boot.rom** - it will be automatically loaded upon core loading.

## Save file
Some games support saves. Place an empty file with size 2048 bytes and name the same as ROM file with extension .sav
It will be automatically loaded with ROM.


### Notes:
* Do not forget to assign joystick buttons on keyboard in order to play on keyboard.
* Both headerless ROMs and ROMs with header (512b) are supported and automatically distinguished by file size.

## Download precompiled binaries
Go to [releases](https://github.com/MiSTer-devel/TurboGrafx16_MiSTer/tree/master/releases) folder. 

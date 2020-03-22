# TurboGrafx 16 / PC Engine for [MiSTer Board](https://github.com/MiSTer-devel/Main_MiSTer/wiki) 

### This is the port of Gregory Estrade's [FPGAPCE](https://github.com/Torlus/FPGAPCE) with some tweaks from MiST's port.

## Features
 * SuperGrafx mode
 * Support saves for some games.
 * Uses BRAM for main and graphics memory (reduces graphics glitches)
 * Uses DDR3/SDRAM for cartridge's ROM
 * 6(8)-buttons joystick support
 * Turbotap(multiple joysticks)
 * Support for Street Fighter II and Populous mappers
 * Option of 64 sprites per line (reduces the flickering in some games)

## Installation:
Copy the *.rbf file at the root of the SD card. Copy roms (*PCE,*BIN) to **TGFX16** folder. You may rename ROM of your favorite game to **boot.rom** - it will be automatically loaded upon core loading.
Use SGX file extension for SuperGrafx games.

## Save file
Some games support saves. Place an empty file with size 2048 bytes and name the same as ROM file with extension .sav
It will be automatically loaded with ROM.

## Joystick
Both Turbotap and 6-button are for games explicitly supporting these features.
Do not enable these features for games not supporting it, otherwise game will work incorrectly.

## Reset
Tap the Start + Select buttons together quickly to reset.  The PC Engine/Turbografx-16 did not have a hardware reset button, and instead relies on this button combination.  The timing needs to be exact to trigger this, and sometimes it will take a couple tries.  With this method, in-game options will remain if you have changed them, whereas the MiSTer OSD reset will revert them.

### Notes:
* Do not forget to assign joystick buttons on keyboard in order to play on keyboard.
* Both headerless ROMs and ROMs with header (512b) are supported and automatically distinguished by file size.
* 64 sprites per line may improve the game look by reducing the flickering, but may introduce glitches in some games.

## Download precompiled binaries
Go to [releases](https://github.com/MiSTer-devel/TurboGrafx16_MiSTer/tree/master/releases) folder. 

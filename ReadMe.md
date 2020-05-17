# TurboGrafx 16 / PC Engine for [MiSTer Board](https://github.com/MiSTer-devel/Main_MiSTer/wiki) 

### This is the port of Gregory Estrade's [FPGAPCE](https://github.com/Torlus/FPGAPCE)

## Features
 * SuperGrafx mode
 * Support saves
 * Completely rewritten CPU and VDC for cycle accuracy
 * Uses DDR3 and SDRAM for cartridge's ROM (SDRAM is recommended for accuracy)
 * 6(8)-buttons joystick support
 * Turbotap(multiple joysticks)
 * Support for Street Fighter II and Populous mappers
 * Support CD-ROM games
 * Support Arcade Card games
 * Cheat engine

## Installation:
Copy the *.rbf file at the root of the SD card. Copy roms (*PCE,*BIN) to **TGFX16** folder. You may rename ROM of your favorite game to **boot.rom** - it will be automatically loaded upon core loading.
Use SGX file extension for SuperGrafx games.

## CD-ROM games
CD-ROM images must be in BIN/CUE format, and must be located in the **TGFX16-CD** folder. Each CD-ROM image must have its own folder.
**cd_bios.rom** must be placed in the same TGFX16-CD folder as the images mentioned above. **Japanese Super CD-ROM v3.00 is recomended for maximum compatibility**. 
Additionally you can use a different bios for specific games (for example from Games Express) by placing cd_bios.rom inside the game image's folder.

**Do not zip CD-ROM images! It won't work correctly.**

## Cheat engine
Standard cheats location is supported for HuCard games. For CD-ROM game all cheats must be zipped into a single zip file and placed inside game's CD-ROM folder.

## Joystick
Both Turbotap and 6-button joysticks are supported.
Do not enable these features for games not supporting it, otherwise game will work incorrectly.

## Reset
Tap the Start + Select buttons together quickly to reset. The PC Engine/Turbografx-16 did not have a hardware reset button, and instead relies on this button combination.  The timing needs to be exact to trigger this, and sometimes it will take a couple tries.  With this method, in-game options will remain if you have changed them, whereas the MiSTer OSD reset will revert them.

## SDRAM
This core may work without SDRAM (using on-board DDR3), but it may have different kinds of issues/glitches due to high latency of DDR3 memory. Thus SDRAM module is highly recommended for maximum accuracy.

### Notes:
* Both headerless ROMs and ROMs with header (512b) are supported and automatically distinguished by file size.

## Download precompiled binaries
Go to [releases](https://github.com/MiSTer-devel/TurboGrafx16_MiSTer/tree/master/releases) folder. 

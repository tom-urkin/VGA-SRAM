# Pseudo-random number generation and visualization 

> SystemVerilog Pseudo-random number generation and visualization    

This repository includes source files in SystemVerilog of the required sub-modules for generating pseudo-random numbers by cellular-automaton, storing them on an external SRAM IC and visualizaing them on a monitor via a VGA controller. Altera DE-115 development board is used here for practical verification since it includes both VGA connector and external SRAM IC.

## VGA Driver
To drive a [VGA](https://en.wikipedia.org/wiki/Video_Graphics_Array) screen, you need to manipulate two digital synchronization pins, HSYNC and VSYNC, and three analog color pins, namely RED, GREEN, and BLUE. The HSYNC pin informs the screen about moving to the next row of pixels, while the VSYNC pin signals the start of a new frame.
Here,VGA 640X480@60 Hz industry standard is used which indicates pixel clock of 25.175MHz. Timing information and row/colomn segmentation to different time intervals can be found in the following [link](http://tinyvga.com/vga-timing). An illustrative figure indicating these sections is also attached:

![VGA](./docs/VGA.jpg) 

The source files are located at the repository root:
- [VGA Driver](./VGA_Driver.sv)
- [VGA Driver Verification](./High_arch_VGA_verification.sv)

Verification is carried by continiously trasmitting constant horizontal data, resulting in vertical color pattern as shown in the attached picture. Please refer to the DE-115 user manual to determine pin locations. 

![VGA Verification](./docs/VGA_Verification.jpg) 


## SRAM controller
In progress

## CA-PRNGs, SRAM and VGA controller integration
In progress

![SPI_High_ARCH](./docs/RTL.JPG) 


## Support

I will be happy to answer any questions.  
Approach me here using GitHub Issues or at tom.urkin@gmail.com
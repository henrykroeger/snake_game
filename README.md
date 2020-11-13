# Snake
Henry Kroeger & Sarah Chow
EE 364 Final Project

### Overview
Snake is a remake of the classic snake video game for the Nexys 4 family of FPGAs. It is written entirely in Verilog. The game is controlled by the on-board buttons and switches and the game state is shown on an attached monitor by the FPGA's VGA output.

### To Play
Either clone the repo and generate a bitstream using Vivado/other appropriate software or download the pre-generated bitstream and upload it to your FPGA.

The directional buttons make the snake move in that direction. The center button serves as an ACK signal to start the game after a win or loss. Switch 0 acts as a reset. The objective of the game is to eat 16 pieces of food without having the snake run into itself. The current length of the snake is shown on the on-board SSDs.
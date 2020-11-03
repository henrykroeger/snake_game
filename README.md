# Snake
Henry Kroeger & Sarah Chow
EE 364 Final Project

#### Assumptions / Notes
16x16 gameboard, represented as 256 individual squares
every location is a byte / [7:0]
win after getting 15 bites
lose if you eat yourself
havent figured out the edges of the board (do we wrap or do we lose?)

to get the actual value on the grid
row = loc / 16
col = loc % 16
^this is c code, dont know if it works in verilog

7 states + a default/unknown

board outputted on vga monitor
ssd to display length of snake
leds to display state

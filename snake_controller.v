`timescale 1ns / 1ps

module snake_controller(
	input Clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input Bright,
	input Reset,
	input Qw, Ql,
	input [9:0] hCount, vCount,
	input [7:0] Food,
	input [3:0] Length,
	input [15:0] Locations [7:0],
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire snake_fill;
	wire food_fill;
	
	//these two values dictate the center of each block of the snake
	reg [15:0] xpos [9:0]; 
	reg [15:0] ypos [9:0];
	//these two values dictate the center of the block of food
	reg [9:0] f_xpos, f_ypos;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter YELLOW = 12'b1111_1111_0000;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (snake_fill) 
			rgb = YELLOW; 
		else if (food_fill)
			rgb = 12'b1111_1111_1111;
		else	
			rgb=background;
	end

	// Calculate snake positions, top left corner (144, 35)
	always@ (posedge clk) begin
	int i;
	for (i = 0; i < Length; i++)
		begin
			xpos[i] <= (Locations[i] % 16)*30 + 144 + 15;
			ypos[i] <= (Locations[i] / 16)*30 + 35 + 15;
		end
	if (Qc)
		f_xpos <= (Locations[i] % 16)*30 + 144 + 15;
		f_ypos <= (Locations[i] / 16)*30 + 35 + 15;
	end

	/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
	
	//the +-15 for the positions give the dimension of the block (i.e. it will be 30x30 pixels)
	int j;
	for (j = 0; j < Length; j++)
		begin
			assign snake_fill = vCount>=(ypos[j]-15) && vCount<=(ypos[j]+15) && hCount>=(xpos[j]-15) && hCount<=(xpos[j]+15);
		end
	assign food_fill = vCount>=(f_ypos-15) && vCount<=(f_ypos+15) && hCount>=(f_xpos-15) && hCount<=(f_xpos+15);
	
	
	
	//the background color reflects the state of the game
	always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b0000_0000_0000;
		else 
			if(Ql) // Turn red if lose
				background <= 12'b1111_0000_0000;
			else if(Qw) // Turn green if win
				background <= 12'b0000_1111_0000;
			else
				background <= 12'b0000_0000_0000;
	end

	
	
endmodule

`timescale 1ns / 1ps

module snake_controller(
	input Clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input Bright,
	input Reset,
	input Qw, Ql, Qc,
	input [9:0] hCount, vCount,
	input [7:0] Food,
	input [3:0] Length,
	input [127:0] Locations_Flat,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire snake_fill;
	wire food_fill;
	wire [7:0] locations [15:0];

	assign {locations[0], locations[1], locations[2], locations[3],
			locations[4], locations[5], locations[6], locations[7],
			locations[8], locations[9], locations[10], locations[11],
			locations[12], locations[13], locations[14], locations[15]} = Locations_Flat;
	
	//these two values dictate the center of each block of the snake
	reg [9:0] xpos [15:0]; 
	reg [9:0] ypos [15:0];
	//these two values dictate the center of the block of food
	reg [9:0] f_xpos, f_ypos;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter YELLOW = 12'b1111_1111_0000;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~Bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (snake_fill0 || snake_fill1 || snake_fill2 || snake_fill3 
				|| snake_fill4 || snake_fill5 || snake_fill6 || snake_fill7 
				|| snake_fill8 || snake_fill9 || snake_fill10 || snake_fill11 
				|| snake_fill12 || snake_fill13 || snake_fill14 || snake_fill15) 
			rgb = YELLOW; 
		else if (food_fill)
			rgb = 12'b1111_1111_1111;
		else	
			rgb = background;
	end

	// Calculate snake positions, top left corner (144, 35)
	integer i;
	always@ (posedge Clk) begin
	for (i = 0; i < Length; i = i + 1)
		begin
			xpos[i] <= (locations[i] % 16)*30 + 144 + 15;
			ypos[i] <= (locations[i] / 16)*30 + 35 + 15;
		end
	if (Qc) begin
		f_xpos <= (Food % 16)*30 + 144 + 15;
		f_ypos <= (Food / 16)*30 + 35 + 15;
	end
	end

	/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
	
	//the +-15 for the positions give the dimension of the block (i.e. it will be 30x30 pixels)
	assign snake_fill0 = vCount>=(ypos[0]-15) && vCount<=(ypos[0]+15) && hCount>=(xpos[0]-15) && hCount<=(xpos[0]+15);
	assign snake_fill1 = vCount>=(ypos[1]-15) && vCount<=(ypos[1]+15) && hCount>=(xpos[1]-15) && hCount<=(xpos[1]+15);
	assign snake_fill2 = vCount>=(ypos[2]-15) && vCount<=(ypos[2]+15) && hCount>=(xpos[2]-15) && hCount<=(xpos[2]+15);
	assign snake_fill3 = vCount>=(ypos[3]-15) && vCount<=(ypos[3]+15) && hCount>=(xpos[3]-15) && hCount<=(xpos[3]+15);
	assign snake_fill4 = vCount>=(ypos[4]-15) && vCount<=(ypos[4]+15) && hCount>=(xpos[4]-15) && hCount<=(xpos[4]+15);
	assign snake_fill5 = vCount>=(ypos[5]-15) && vCount<=(ypos[5]+15) && hCount>=(xpos[5]-15) && hCount<=(xpos[5]+15);
	assign snake_fill6 = vCount>=(ypos[6]-15) && vCount<=(ypos[6]+15) && hCount>=(xpos[6]-15) && hCount<=(xpos[6]+15);
	assign snake_fill7 = vCount>=(ypos[7]-15) && vCount<=(ypos[7]+15) && hCount>=(xpos[7]-15) && hCount<=(xpos[7]+15);
	assign snake_fill8 = vCount>=(ypos[8]-15) && vCount<=(ypos[8]+15) && hCount>=(xpos[8]-15) && hCount<=(xpos[8]+15);
	assign snake_fill9 = vCount>=(ypos[9]-15) && vCount<=(ypos[9]+15) && hCount>=(xpos[9]-15) && hCount<=(xpos[9]+15);
	assign snake_fill10 = vCount>=(ypos[10]-15) && vCount<=(ypos[10]+15) && hCount>=(xpos[10]-15) && hCount<=(xpos[10]+15);
	assign snake_fill11 = vCount>=(ypos[11]-15) && vCount<=(ypos[11]+15) && hCount>=(xpos[11]-15) && hCount<=(xpos[11]+15);
	assign snake_fill12 = vCount>=(ypos[12]-15) && vCount<=(ypos[12]+15) && hCount>=(xpos[12]-15) && hCount<=(xpos[12]+15);
	assign snake_fill13 = vCount>=(ypos[13]-15) && vCount<=(ypos[13]+15) && hCount>=(xpos[13]-15) && hCount<=(xpos[13]+15);
	assign snake_fill14 = vCount>=(ypos[14]-15) && vCount<=(ypos[14]+15) && hCount>=(xpos[14]-15) && hCount<=(xpos[14]+15);
	assign snake_fill15 = vCount>=(ypos[15]-15) && vCount<=(ypos[15]+15) && hCount>=(xpos[15]-15) && hCount<=(xpos[15]+15);
	
	assign food_fill = vCount>=(f_ypos-15) && vCount<=(f_ypos+15) && hCount>=(f_xpos-15) && hCount<=(f_xpos+15);
	
	
	
	//the background color reflects the state of the game
	always@(posedge Clk, posedge Reset) begin
		if(Reset)
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

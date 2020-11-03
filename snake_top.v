/*
 * snake_top.v
 * 
 * Henry Kroeger & Sarah Chow
 * EE 364 Final Project
 * 
 * Core state machine for the snake game.
 */

module snake_top (// TODO)

// Inputs
input ClkPort;
input BtnL, BtnR, BtnU, BtnD, BtnC;
input Sw0;

// Outputs
output Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0;
output Dp, Cg, Cf, Ce, Cd, Cc, Cb, Ca;
output An7, An6, An5, An4, An3, An2, An1, An0;
// TODO: VGA OUTPUT & VGA CLOCK TIMING

// Clock Signals
wire ClkPort;

wire board_clk, game_clk;
wire [1:0] ssd_clk;
reg [32:0] div_clk;

// Other
wire reset;


assign reset = Sw0;

// Clock Division
BUFGP BUFGP1 (board_clk, ClkPort);
always @(posedge board_clk, posedge reset)
begin
	if (reset) begin
		div_clk <= 0;
	end
	else begin
		div_clk <= div_clk + 1'b1;
	end
end

assign game_clk = div_clk[32] // TODO: Check this timing!

// TODO: Button debouncing

// TODO: LED asignments

// TODO: SSDs
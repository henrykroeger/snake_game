/*
 * snake_top.v
 * 
 * Henry Kroeger & Sarah Chow
 * EE 364 Final Project
 * 
 * Core state machine for the snake game.
 */

module snake_top (MemOE, MemWR, RamCS, QuadSpiFlashCS,
				ClkPort, BtnL, BtnR, BtnU, BtnD, BtnC, Sw0,
				Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0,
				Dp, Cg, Cf, Ce, Cd, Cc, Cb, Ca,
				An7, An6, An5, An4, An3, An2, An1, An0,
				hSync, vSync, vgaR, vgaG, vgaB);

// Inputs
input ClkPort;
input BtnL, BtnR, BtnU, BtnD, BtnC;
input Sw0;

// Outputs

output 	MemOE, MemWR, RamCS, QuadSpiFlashCS;

output Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0;
output Dp, Cg, Cf, Ce, Cd, Cc, Cb, Ca;
output An7, An6, An5, An4, An3, An2, An1, An0;
// TODO: VGA OUTPUT & VGA CLOCK TIMING
output hSync, vSync;
output [3:0] vgaR, vgaG, vgaB;

// Clock Signals
wire ClkPort;

wire board_clk, game_clk, ssd_clk;
reg [32:0] div_clk;

// Other
wire reset;
wire Qi, Qm, Qc, Qh, Qe, Qw, Ql, Qu;
reg [15:0] locations [7:0];
reg [7:0] food;
reg [3:0] length;


wire [127:0] locations_flat;
assign locations_flat = {locations[0], locations[1], locations[2], locations[3],
						locations[4], locations[5], locations[6], locations[7],
						locations[8], locations[9], locations[10], locations[11],
						locations[12], locations[13], locations[14], locations[15]};

// SSD
reg [7:0] ssd;
wire [7:0] ssd1, ssd0;


assign reset = Sw0;

assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

// Clock Division
BUFGP BUFGP1 (board_clk, ClkPort);
always @(posedge board_clk, reset)
begin
	if (reset) begin
		div_clk <= 0;
	end
	else begin
		div_clk <= div_clk + 1'b1;
	end
end

assign game_clk = div_clk[26]; // TODO: Check this timing!
assign vga_clk = div_clk[19];

// TODO: Button debouncing
ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
        (.CLK(board_clk), .RESET(Reset), .PB(BtnL), .DPB( ), .SCEN(BtnL_SCEN), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_2 
        (.CLK(board_clk), .RESET(Reset), .PB(BtnR), .DPB( ), .SCEN(BtnR_SCEN), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_3 
        (.CLK(board_clk), .RESET(Reset), .PB(BtnU), .DPB( ), .SCEN(BtnU_SCEN), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_4 
        (.CLK(board_clk), .RESET(Reset), .PB(BtnD), .DPB( ), .SCEN(BtnD_SCEN), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_5 
        (.CLK(board_clk), .RESET(Reset), .PB(BtnC), .DPB( ), .SCEN(Start_Ack_SCEN), .MCEN( ), .CCEN( ));
// Use SCEN in determining next_dir (do this in top or core?)

snake_core snake_core1 (.Left(BtnL_SCEN), .Right(BtnR_SCEN), .Up(BtnU_SCEN), .Down(BtnD_SCEN), .Ack(Start_Ack_SCEN), .Reset(reset), .CLK(game_clk), .Qi(Qi), .Qm(Qm), .Qc(Qc), .Qh(Qh), .Qe(Qe), 
					.Qw(Qw), .Ql(Ql), .Qu(Qu), .Food(food), .Length(length), .Locations(locations));

display_controller dc(.clk(board_clk), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
block_controller sc(.clk(vga_clk), .bright(bright), .rst(BtnC), .up(BtnU), .down(BtnD),.left(BtnL),.right(BtnR),.hCount(hc), .vCount(vc), .rgb(rgb), .background(background));
	

// TODO: LED asignments
assign {Ld7, Ld6, Ld5, Ld4} = {Qi, Qm, Qc, Qh};
assign {Ld3, Ld2, Ld1, Ld0} = {Qe, Qw, Ql, Qu};

// TODO: SSDs
assign ssd_clk = div_clk[18];

assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {ssd};

integer conv;
always @( length )
begin
	conv = length;
	ssd1 = (conv >= 10) ? 8'b10011111 : 8'b11111111;
	case (conv % 10)
		0: ssd0 = 8'b00000010; // 0
		1: ssd0 = 8'b10011110; // 1
		2: ssd0 = 8'b00100100; // 2
		3: ssd0 = 8'b00001100; // 3
		4: ssd0 = 8'b10011000; // 4
		5: ssd0 = 8'b01001000; // 5
		6: ssd0 = 8'b01000000; // 6
		7: ssd0 = 8'b00011110; // 7
		8: ssd0 = 8'b00000000; // 8
		9: ssd0 = 8'b00001000; // 9
		endcase
end

assign An7 = 1'b1;
assign An6 = 1'b1;
assign An5 = 1'b1;
assign An4 = 1'b1;
assign An3 = 1'b1;
assign An2 = 1'b1;
assign An1 = ~ssd_clk;
assign An0 = ssd_clk;

always @ (ssd_clk, ssd1, ssd0)
begin
	case (ssd_clk) 
		1'b1: ssd = ssd1;
		1'b0: ssd = ssd0;
	endcase 
end
endmodule
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

wire board_clk, game_clk, ssd_clk;
reg [32:0] div_clk;

// Other
wire reset;
output Qi, Qm, Qc, Qh, Qe, Qw, Ql, Qu;
reg [3:0] length;

// SSD
reg [7:0] ssd;
wire [7:0] ssd1, ssd0;


assign reset = Sw0;

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

assign game_clk = div_clk[32] // TODO: Check this timing!

// TODO: Button debouncing
ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnL), .DPB( ), .SCEN(BtnL_SCEN), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_2 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB( ), .SCEN(BtnR_SCEN), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_3 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB( ), .SCEN(BtnU_SCEN), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_4 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnD), .DPB( ), .SCEN(BtnD_SCEN), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_5 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnC), .DPB( ), .SCEN(Start_Ack_SCEN), .MCEN( ), .CCEN( ));
// Use SCEN in determining next_dir (do this in top or core?)

// TODO: Instantiation of core
snake_core snake_core1 (0, .SCEN(Start_Ack_SCEN), .Reset(Reset), .CLK(sys_clk), .Qi(Qi), .Qm(Qm), .Qc(Qc), .Qh(Qh), .Qe(Qe), 
					.Qw(Qw), .Ql(Ql), .Qu(Qu), .Food(Food), .Length(Length), .Locations(Locations)));

// TODO: LED asignments
assign {Ld7, Ld6, Ld5, Ld4} = {Qi, Qm, Qc, Qh};
assign {Ld3, Ld2, Ld1, Ld0} = {Qe, Qw, Ql, Qu};

// TODO: SSDs
assign ssd_clk = div_clk[18];

assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {ssd};

int conv;
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
		1'b1: ssd = ssd0;
	endcase 
end
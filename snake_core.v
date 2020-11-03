/*
 * snake_core.v
 * 
 * Henry Kroeger & Sarah Chow
 * EE 364 Final Project
 * 
 * Core state machine for the snake game.
 */
module snake_core (Next_Dir, Ack, Reset, Clk, Qi, Qm, Qc, Qh, Qe, 
					Qw, Ql, Qu, Food, Length, Locations);

input [1:0] Next_Dir;
input Ack, Reset, Clk;

output Qi, Qm, Qc, Qh, Qe, Qw, Ql, Qu;
output [7:0] Food;
output [3:0] Length;
output [15:0] Locations [7:0]; // 16 locations

reg [7:0] Food;
reg [3:0] Length;
reg [15:0] Locations [7:0];

reg [8:0] state;

// one-hot state machine
localparam
	INIT  = 8'b00000001,
	MOVE  = 8'b00000010,
	CHECK = 8'b00000100,
	HOLD  = 8'b00001000,
	EAT   = 8'b00010000,
	WIN   = 8'b00100000,
	LOSE  = 8'b01000000,
	UNKN  = 8'b10000000;

assign {Qu, Ql, Qw, Qe, Qh, Qc, Qm, Qi} = state;

// Next_Dir assignments
localparam
	LEFT = 2'b00,
	RIGHT = 2'b01,
	UP = 2'b10,
	DOWN = 2'b11;


always @(posedge Clk, Reset) // asynchronous high-active reset
begin
	if (Reset) begin
		state <= INIT;
	end

	else begin
		case (state)
			INIT: // when ack is received, start moving
			begin
				if (Ack) begin
					state <= MOVE;
				end
			end

			MOVE: // update the byte array of positions
			begin
				for (i = Length - 1; i >= 0; i = i + 1) begin
					Locations[i + 1] <= Locations[i];
				end

				if (Next_Dir == LEFT) begin
					Locations[0] <= Locations[0] - 1;
				end

				else if (Next_Dir == RIGHT) begin
					Locations[0] <= Locations[0] + 1;
				end

				else if (Next_Dir == UP) begin
					Locations[0] <= Locations[0] - 16;
				end

				else if (Next_Dir == DOWN) begin
					Locations[0] <= Locations[0] + 16;
				end

				state <= CHECK;
			end

			CHECK: // check if we grow or if we lost
			begin
				if (Locations[0] == Food) begin
					state <= EAT;
				end

				// TODO: Check edges?

				else begin
					state <= HOLD;
					for (i = 0; i < Length; i = i + 1) begin
						for (j = i; j < Length; j = j + 1) begin
							if (Locations[i] == Locations[j]) begin
								state <= LOSE;
							end
						end
					end
				end
			end

			EAT: // grow bigger - weird implementation, may not work
			begin
				state <= MOVE;
				Length <= Length + 1;
				Food <= $urandom_range(255);
				// potential bug...food could generate under snake
				if (Length == 14) begin
					state <= WIN;
				end
			end

			HOLD: // ensure constant gamespeed
			begin
				state <= MOVE;
			end

			WIN:
			begin
				if (Ack) begin
					state <= INIT;
				end
			end

			LOSE:
			begin
				if (Ack) begin
					state <= INIT;
				end
			end

			default:
			begin
				state <= UNKN;
			end
		endcase // state
	end
end

endmodule
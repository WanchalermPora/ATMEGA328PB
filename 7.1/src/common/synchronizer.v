`timescale 1 ns / 1 ns
module synchronizer (clk,
					d_sync,
					d_in);
	
	parameter   p_width   = 8;

	input 					clk;
	input [p_width-1:0]  d_in;
	output [p_width-1:0] d_sync;
	
	reg [p_width-1:0]	d_latch; 
	reg [p_width-1:0]	d_sync_int;
	
	always @( clk or d_in)
	begin:latch
		if(clk)begin
			d_latch <= d_in;
		end
	end
	
	always @(posedge clk)
	begin:flip_flop
		d_sync_int <= d_latch;
	end
	
	assign d_sync = d_sync_int;
endmodule
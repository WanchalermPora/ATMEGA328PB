// Initializing Block RAM (Single-Port Block RAM)
// File: sram
module sram (clk, we, addr, di, dout,re);
	input clk;
	input we;
	input re;
	input [11:0] addr;
	input [7:0] di;
	output [7:0] dout;

	reg [7:0] ram [256:2303];
	reg [7:0] d_out;
    reg [7:0] r_din ;
	integer i;
	initial
	begin 
		for (i=256; i<2304; i=i+1) begin 
			ram[i] = 8'b00000000;
		end
	end

    always @(posedge clk)
    begin
        r_din <= di;
    end
    
	// always @(posedge clk)
    always @(negedge clk)
	// always @(*)
	begin
		if (we) begin
			if (256<=addr<2304) begin
				ram[addr] <= r_din;
			end
		end
    end
    always @(*) 
    begin
		if (re) begin
			if (256<=addr<2304) begin
				d_out <= ram[addr];
			end else begin
				d_out <= 8'b00000000;
			end
		end else begin
			d_out <= 8'b00000000;
		end
	end
	assign dout = d_out;
endmodule
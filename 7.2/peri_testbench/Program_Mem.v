// Initializing Block RAM from external data file
// Binary data
// File: Program_Mem.v

module Program_Mem (clk, we, addr, din, dout);
	input clk;
	input we;
	input [13:0] addr;
	input [15:0] din;
	output [15:0] dout;

	reg [15:0] ram [0:16383];
	reg [15:0] d_out;

	initial begin
		// $readmemb("imem_1.mem",ram);
		$readmemb("imem_2.mem",ram);
	end

	always @(posedge clk)
	// always @(*)
	begin
		if (we) begin
			ram[addr] <= din;
		end 
		d_out <= ram[addr];
	end
	assign dout = d_out;
endmodule

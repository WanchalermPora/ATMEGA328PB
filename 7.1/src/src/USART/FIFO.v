`timescale 1 ns / 1 ns
module FIFO 
	#(
	parameter DEPTH    = 2,
	parameter WIDTH    = 8,
	parameter SYNC_OUT = 0 
	) 
	(
	input  wire            	ireset,
	input  wire            	cp2,
	// FIFO control
	input  wire[WIDTH-1:0] 	din,					 
	input  wire            	we,
	input  wire            	re, 
	input  wire            	flush,
	  //~~~~~~~~~~~
	output wire[WIDTH-1:0] 	dout,
	output wire            	full,
	// output wire            almost_full,
	output wire            	empty
	);
	
	function integer fn_clog2;
		input integer arg;
		integer i;
		integer result;
		begin
			if(arg == 1) begin 
				fn_clog2 = 0; 
			end	else begin
				for (i = 0; 2 ** i < arg; i = i + 1) begin
					result = i + 1;
				end
				fn_clog2 = result; 
			end
		// return result;
		end 
	endfunction // fn_clog2	

	// localparam LP_CNT_WIDTH = fn_clog2(DEPTH)+1;
	localparam LP_CNT_WIDTH = 2;

	reg [LP_CNT_WIDTH-1:0] 	w_pnt  ;
	reg [LP_CNT_WIDTH-1:0] 	r_pnt  ;
	reg [WIDTH-1:0]			dout_sync ;
	wire          			we_int ;
	wire          			re_int ;
	wire					full_int ;
	reg						full_int_sync ;
	wire					empty_int ;
	reg						empty_int_sync ;
	
	reg [WIDTH-1:0] 		fifo_mem[0:DEPTH-1] ;
	reg [WIDTH-1:0]			fifo_buf ;
	
	integer	i;
	
	assign re_int = (re && (empty_int == 1'b0)) ;
	assign we_int = (we && (full_int == 1'b0)) ;
	
	always @(negedge ireset or posedge cp2)
	begin : pointer_update
		if (!ireset) begin		// Reset
			w_pnt <= {LP_CNT_WIDTH{1'b0}};  
			r_pnt <= {LP_CNT_WIDTH{1'b0}};  
		end else begin		// Clock
			if(flush)begin	// Clear Read/Write counters
				w_pnt <= {LP_CNT_WIDTH{1'b0}};
				r_pnt <= {LP_CNT_WIDTH{1'b0}};
			end else begin	
				if(we_int) w_pnt <= w_pnt + 1;
				if(re_int) r_pnt <= r_pnt + 1;
			end 	
		end
	end
	
	always @(negedge ireset or posedge cp2)
	begin : fifo_wr
		if (!ireset) begin		// Reset
			for(i=0;i<DEPTH;i=i+1) begin
				fifo_mem[i] <= {WIDTH{1'b0}};
			end
			fifo_buf <= {WIDTH{1'b0}};
		end else begin		// Clock
			if(we_int)begin
				if (DEPTH==1) begin
					fifo_buf <= din;
				end else begin
					fifo_mem[w_pnt[LP_CNT_WIDTH-2:0]] <= din;
				end
			end
		end
	end 
	
	always @(negedge ireset or posedge cp2)
	begin : sync_dout
		if (!ireset) begin		// Reset
			dout_sync <= {WIDTH{1'b0}};
		end else begin		// Clock
			if (DEPTH==1) begin
				dout_sync <= fifo_buf ;
			end else begin
				dout_sync <= fifo_mem[r_pnt[LP_CNT_WIDTH-2:0]]; 	
			end
		end
	end
	
	assign dout  = 	(SYNC_OUT == 1) ? dout_sync : 
					(DEPTH==1) ? fifo_buf : 
					fifo_mem[r_pnt[LP_CNT_WIDTH-2:0]];
	
	// generate
	// 	if (DEPTH==1) begin
	// 		assign full_int = (w_pnt != r_pnt)? 1'b1 : 1'b0 ; 	
	// 	end else begin
	assign full_int = (w_pnt[LP_CNT_WIDTH-1] != r_pnt[LP_CNT_WIDTH-1] && w_pnt[LP_CNT_WIDTH-2:0] == r_pnt[LP_CNT_WIDTH-2:0]) ? 1'b1 : 1'b0;
	// 	end	
	// endgenerate
	
	// assign full_int = (w_pnt[LP_CNT_WIDTH-1] != r_pnt[LP_CNT_WIDTH-1] && w_pnt[LP_CNT_WIDTH-2:0] == r_pnt[LP_CNT_WIDTH-2:0]) ? 1'b1 : 1'b0;
	
	assign empty_int = (w_pnt == r_pnt)? 1'b1 : 1'b0 ; 	

	always @(negedge ireset or posedge cp2)
	begin : sync_status
		if (!ireset) begin		// Reset
			full_int_sync <= 1'b0 ;
			empty_int_sync <= 1'b1 ;
		end else begin		// Clock
			full_int_sync <= full_int ;
			empty_int_sync <= empty_int ;
		end
	end

	assign full = (SYNC_OUT == 1) ? full_int_sync : full_int ;
	assign empty = (SYNC_OUT == 1) ? empty_int_sync : empty_int ;
			  
endmodule
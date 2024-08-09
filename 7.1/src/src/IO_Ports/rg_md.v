`timescale 1 ns / 1 ns

module rg_md (clk,
				nrst,
				wdata,
				wbe,
				rdata,
				tog);
				
	parameter              	p_width     = 8;  
    parameter[7:0] 			p_init_val  = {8{1'b0}};
	parameter[7:0] 			p_impl_mask = {8{1'b1}};
				
	input      		       		clk;
	input	            		nrst;
	input wire[7:0]    			wdata;					   
	input 					 	wbe;
	input                       tog;
	output wire[7:0]   	        rdata;					
				
	reg [7:0] 			rg_current;					  
	reg [7:0] 			rg_next;			
				
	integer i;			
				
	always@(posedge clk or negedge nrst)
	begin : main_alw_seq
		if(!nrst) begin
			// for (i=0;i<8;i=i+1) begin
				// rg_current[i] <= p_init_val[i];
			// end
			rg_current <= p_init_val;
		end else begin
			// for (i=0;i<8;i=i+1) begin
				// rg_current[i] <= rg_next[i];
			// end
			rg_current <= rg_next;
		end // main_alw_seq_clk
	end	// main_alw_seq	   

	always@(*) 
	// begin : main_alw_comb
		for (i=0;i<8;i=i+1) begin
			if(p_impl_mask[i] == 1'b1) begin 
				rg_next[i] <= rg_current[i];
				if((wbe==1'b1) || (tog==1'b1 && wdata[i]==1'b1)) begin
					if(tog==1'b1 && wdata[i]==1'b1)begin
						rg_next[i] <= ~rg_next[i]; 	
					end else begin
						rg_next[i] <= wdata[i]; 
					end
				end
			end 
			// else begin
			// 	rg_next[i]    =  rg_current[i]; // Avoid "x" TBD
			// 	rg_current[i] = p_init_val[i];
			// 	rg_next[i]    = 1'b0;
			// end
		end
	// end // main_alw_comb	
	
	assign rdata = rg_current;
endmodule
`timescale 1 ns / 1 ns
module mux_after_prescaler0 // no mux for clock enable selection
  (
    clk,
    clk8en,
    clk64en,
    clk256en,
    clk1024en,
    t0,
	t1,
	t3,
	t4,
    cs0,
	cs1,
	cs3,
	cs4,    
    clk_en_0,
	clk_en_1,
	clk_en_3,
	clk_en_4);
    // io clock
    input clk;
 
    // output from prescaler0
    input clk8en, clk64en, clk256en, clk1024en;

    // output from the synchronizer of the Tn input pins
    input t0;
	input t1;
	input t3;
	input t4;

    // clock seletion of TCn, n=0, 1, 3, 4
    input [2:0] cs0;
	input [2:0] cs1;
	input [2:0] cs3;
	input [2:0] cs4;
	
    // output of the prescaler with mux 
    output clk_en_0;
	output clk_en_1;
	output clk_en_3;
	output clk_en_4;

    wire t0_negedge,t0_posedge; 
	wire t1_negedge,t1_posedge; 
	wire t3_negedge,t3_posedge; 
	wire t4_negedge,t4_posedge; 
    reg t0_sync_delay,t0_n_sync_delay;
	reg t1_sync_delay,t1_n_sync_delay;
	reg t3_sync_delay,t3_n_sync_delay;
	reg t4_sync_delay,t4_n_sync_delay;
    reg clk_en_0_i,clk_en_1_i,clk_en_3_i,clk_en_4_i;
    wire t0_sync;
	wire t1_sync;
	wire t3_sync;
	wire t4_sync;
	
	synchronizer #(
		.p_width     (1)
	)
	synchronizer_tn0_inst(
		.clk   (clk),
		.d_in  (t0),
		.d_sync(t0_sync)
	);
	
	synchronizer #(
		.p_width     (1)
	)
	synchronizer_tn1_inst(
		.clk   (clk),
		.d_in  (t1),
		.d_sync(t1_sync)
	);
	
	synchronizer #(
		.p_width     (1)
	)
	synchronizer_tn3_inst(
		.clk   (clk),
		.d_in  (t3),
		.d_sync(t3_sync)
	);
	
	synchronizer #(
		.p_width     (1)
	)
	synchronizer_tn4_inst(
		.clk   (clk),
		.d_in  (t4),
		.d_sync(t4_sync)
	);
	
	// assign t0_sync = t0 ;
	// assign t1_sync = t1 ;
	// assign t3_sync = t3 ;
	// assign t4_sync = t4 ;
	
    // csn[0] is used to select the negative or positive endge of Tn 
    // The tn_sync_buffer will be sent to the negative edge detector circuit 
    // So if it is inverted here, output of the edge detector circuit corresponds to 
    // the detection of the positive edge instead. 
    // assign tn_sync_buffer = (csn[0]==1'b0) ? tn_sync : ~tn_sync; //  non-inverting or inverting

    // delay tn_sync for one clock
    always @(posedge(clk)) //csn[0]== 0
        t0_sync_delay <= t0_sync;
		
	always @(posedge(clk)) //csn[0]== 1
        t0_n_sync_delay <= ~t0_sync;	
		
	always @(posedge(clk)) //csn[0]== 0
        t1_sync_delay <= t1_sync;
		
	always @(posedge(clk)) //csn[0]== 1
        t1_n_sync_delay <= ~t1_sync;	
		
	always @(posedge(clk)) //csn[0]== 0
        t3_sync_delay <= t3_sync;
		
	always @(posedge(clk)) //csn[0]== 1
        t3_n_sync_delay <= ~t3_sync;	
		
	always @(posedge(clk)) //csn[0]== 0
        t4_sync_delay <= t4_sync;
		
	always @(posedge(clk)) //csn[0]== 1
        t4_n_sync_delay <= ~t4_sync;	

    // negedge detector (it will become posedge detector if csn[0]== 1)
    assign t0_negedge = t0_sync_delay & ~t0_sync; //csn[0]== 0
	assign t0_posedge = t0_n_sync_delay & t0_sync; //csn[0]== 1
	assign t1_negedge = t1_sync_delay & ~t1_sync; //csn[0]== 0
	assign t1_posedge = t1_n_sync_delay & t1_sync; //csn[0]== 1
	assign t3_negedge = t3_sync_delay & ~t3_sync; //csn[0]== 0
	assign t3_posedge = t3_n_sync_delay & t3_sync; //csn[0]== 1
	assign t4_negedge = t4_sync_delay & ~t4_sync; //csn[0]== 0
	assign t4_posedge = t4_n_sync_delay & t4_sync; //csn[0]== 1

    always@(*) begin: select_divider
      (* parallel_case *) case (cs0)  // synthesis parallel_case
        3'b000 : clk_en_0_i = 0;
        3'b001 : clk_en_0_i = 1;
        3'b010 : clk_en_0_i = clk8en;
        3'b011 : clk_en_0_i = clk64en;
        3'b100 : clk_en_0_i = clk256en;
        3'b101 : clk_en_0_i = clk1024en;
        3'b110 : clk_en_0_i = t0_negedge; // negative edge
        3'b111 : clk_en_0_i = t0_posedge; //positive edge
        default: clk_en_0_i = 0;
      endcase
	  (* parallel_case *) case (cs1)  // synthesis parallel_case
        3'b000 : clk_en_1_i = 0;
        3'b001 : clk_en_1_i = 1;
        3'b010 : clk_en_1_i = clk8en;
        3'b011 : clk_en_1_i = clk64en;
        3'b100 : clk_en_1_i = clk256en;
        3'b101 : clk_en_1_i = clk1024en;
        3'b110 : clk_en_1_i = t1_negedge; // negative edge
        3'b111 : clk_en_1_i = t1_posedge; //positive edge
        default: clk_en_1_i = 0;
      endcase
	  (* parallel_case *) case (cs3)  // synthesis parallel_case
        3'b000 : clk_en_3_i = 0;
        3'b001 : clk_en_3_i = 1;
        3'b010 : clk_en_3_i = clk8en;
        3'b011 : clk_en_3_i = clk64en;
        3'b100 : clk_en_3_i = clk256en;
        3'b101 : clk_en_3_i = clk1024en;
        3'b110 : clk_en_3_i = t3_negedge; // negative edge
        3'b111 : clk_en_3_i = t3_posedge; //positive edge
        default: clk_en_3_i = 0;
      endcase
	  (* parallel_case *) case (cs4)  // synthesis parallel_case
        3'b000 : clk_en_4_i = 0;
        3'b001 : clk_en_4_i = 1;
        3'b010 : clk_en_4_i = clk8en;
        3'b011 : clk_en_4_i = clk64en;
        3'b100 : clk_en_4_i = clk256en;
        3'b101 : clk_en_4_i = clk1024en;
        3'b110 : clk_en_4_i = t4_negedge; // negative edge
        3'b111 : clk_en_4_i = t4_posedge; //positive edge
        default: clk_en_4_i = 0;
      endcase
    end

    assign clk_en_0 = clk_en_0_i;
	assign clk_en_1 = clk_en_1_i;
	assign clk_en_3 = clk_en_3_i;
	assign clk_en_4 = clk_en_4_i;

endmodule
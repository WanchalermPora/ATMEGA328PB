`timescale 1 ns/1 ps  // time-unit = 1 ns, precision = 10 ps

module testbench;

// signal declaration
logic clk; 
logic ireset;
logic clk_en;

byte pinB_val = 0;
// integer k=0;
integer cycles = 10000; //135750
// integer cycles = 750000 + 5; //135750
integer cycles_cnt ;
parameter period = 50 ;

logic[7:0] MOSI;
logic SS ;
logic [3:0] pinE;
logic [7:0] pinB;
logic [7:0] pinC;
logic [7:0] pinD;
logic ext_int;

logic clk_N;
logic we_N;
logic ce_N;
logic [10:0] Addr;
logic w_ramre;
logic w_ramwe;
logic [11:0] w_ramadr;
logic [15:0] Program_Mem_dout;
logic [13:0] pc;

logic [7:0] sram_dout;
logic [7:0] sram_din;

logic [15:0]spm_out;

logic stop = 0;

ATmega328pb DUT(

    .sram_we(w_ramwe)  ,
    .sram_re(w_ramre) ,
    .sramadr(w_ramadr) ,
	.sram_din(sram_din) ,// assign SRAM_dbus = core_dbusout;

	.sram_dout(sram_dout) ,

	.pc(pc),
    .Program_Mem_dout(Program_Mem_dout),
	// .spm_out(spm_out),

	
	// .pu_B(),
	// .dd_B(),
	// .pv_B(MOSI),
	// .die_B(),
	// .PINB_i(pinB),

	// .PINC_i(pinC),
	// .PIND_i(pinD),
	// .PINE_i(pinE),

	.clk(clk),
	.clk_en(clk_en),
	.ireset(ireset)
);

Program_Mem Program_Mem
       (.addr(pc),
        .clk(clk),
        .din(spm_out),
        .dout(Program_Mem_dout),
        .we(1'b0));

S013LLLPSP_X256Y8D8 Data_Mem
        (
            .Q(sram_dout),
			.CLK(clk_N),
			.CEN(ce_N),
			.WEN(we_N),
			.A(Addr),
			.D(sram_din)
);



defparam testbench.Program_Mem.use_bin = 1;
defparam testbench.Program_Mem.use_crc = 0;
defparam testbench.Program_Mem.use_peri = 0;

// defparam testbench.DUT.Program_Mem.use_bin = 1;
// defparam testbench.DUT.Program_Mem.use_crc = 0;
// defparam testbench.DUT.Program_Mem.use_peri = 0;

assign pinE[3] = MOSI[3];
assign pinE[2] = SS;
assign pinE[0] = 0;

assign pinC[1] = MOSI[5];
assign pinC[7:2] = 0; 
assign pinC[0] = 0; 

assign pinD[3] = ext_int;
assign pinD[5] = 1;
assign clk_en = 1'b1;
assign pinB = pinB_val;
assign clk_N = !(clk) ;
assign we_N = !w_ramwe ;
assign ce_N = !((w_ramre | w_ramwe) & (w_ramadr >= 256));
assign Addr = w_ramadr - 256 ;

// assign
// assign SRAM_dbus = core_dbusout;
// file swapping macro 

// Others variable
// string h_filename = "test";

// // include files 
// `include "../testbench_v2/assignment_v2.sv"
// // `include "../testbench_v2/test_CALL.sv"
// `include "../testbench_v2/test_rand.sv"

always begin
    if (cycles_cnt == 0) begin
        repeat(1)@(posedge ireset);
		// #(4);
		clk = 0;
    end

    #(period/2) clk = !clk ;
    cycles_cnt = cycles_cnt + 1;	
    #(period/2) clk = !clk ;
    
// for insert test function
    // run_test_CALL();
    // run_test_random();
	// fork
		// begin
			// if (INST == 0 && stop == 0) begin
			// 	repeat(3)@(posedge clk);
			// 	if (INST == 0 && stop == 0) begin
			// 		repeat(10)@(posedge clk)
			// 		if (INST == 0 && stop == 0) begin
			// 			$display("bandgap cycle cnt: %08d" , cycles_cnt );
			// 			stop = 1;
			// 		end
			// 	end
			// 	// @(posedge clk) ; pinB_val = pinB_val - 1; 
			// end
			
		// end
	// join_none


end  

always @(posedge clk) begin
	// if (INST == 0 && PREV_INST == 0 && stop == 0) begin
		// repeat(3)@(posedge clk);
		// if (INST == 0 && PREV_INST == 0 && stop == 0) begin
		// 	// repeat(10)@(posedge clk)
		// 	// if (INST == 0 && stop == 0) begin
		// 		$display("bandgap cycle cnt: %06d" , cycles_cnt - 5 );
		// 		dump_sram_in_hex_end( 16'h463 , 1180  , "dumpall_DUT");
		// 		stop = 1;
		// 	// end
		// end
		// @(posedge clk) ; pinB_val = pinB_val - 1; 
	// end
end

initial 
begin
	ireset = 0;
    // #(4);
	#(period);
	ireset = 1;
	#(cycles * period);
	// #(50 * 5000);
	// $$display("Cyclrs");
	$finish;
end	



initial begin
   	if ($test$plusargs("vpd")) begin
   	  $vcdplusdeltacycleon();
   	  $display("Dumping VPD");
   	  $vcdplusfile("./wave.vpd");
   	  $vcdpluson();
   	  $vcdplusmemon();
   	end
end

endmodule
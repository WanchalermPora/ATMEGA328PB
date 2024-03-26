`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module testbench;

// signal declaration
reg cp2_0; 
reg ireset_0;
reg cp2en_0;

integer k=0;
integer cycles = 1222 + 5; //135750
integer cycles_cnt ;
parameter period = 50 ;

// DUT declaration
design_1_wrapper uut(
	.cp2_0(cp2_0),
	.ireset_0(ireset_0),
	.cp2en_0(cp2en_0)
);
// file swapping macro
defparam testbench.uut.design_1_i.Program_Mem_0.inst.use_bin = 1;
defparam testbench.uut.design_1_i.Program_Mem_0.inst.use_crc = 1;

// Others variable
string h_filename = "test";

// include files 
`include "../testbench_core/assignment.sv"
`include "../testbench_core/test_CALL.sv"
`include "../testbench_core/test_rand.sv"


always begin
    if (cycles_cnt == 0) begin
        #(3);
    end
    #(period/2) cp2_0 =1'b1 ;
    cycles_cnt = cycles_cnt + 1;	
    #(period/2) cp2_0 =1'b0 ;
    
// for insert test function
    run_test_CALL();
    // run_test_random();


end  

initial 
begin 
	ireset_0 = 0;
    #(4);
	// #(period);
	ireset_0 = 1;


end

initial 
begin
	cp2en_0 = 1'b1;
	#(cycles * period);
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
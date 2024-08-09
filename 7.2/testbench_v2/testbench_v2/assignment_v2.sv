logic JMP ;
logic IJMP ;
logic RJMP ;
logic CALL ;
logic ICALL ;
logic RCALL ;

logic[7:0] SREG;
logic[7:0] GPREG [0:31];

logic[15:0] PC;

logic [7:0] SRAM [2047:0];

logic [7:0] SPL ; 
logic [7:0] SPH ;
logic [15:0] SP  ;

logic[15:0] INST ;
logic[15:0] PREV_INST ;

// Core  -------------------------
// assign SREG = testbench.DUT.CPU_core.IORegs_Inst.sreg_current;
// assign GPREG = testbench.DUT.CPU_core.GPRF_Inst.gprf_current;

// assign JMP = testbench.DUT.CPU_core.pm_fetch_dec_Inst.idc_jmp ;
// assign IJMP = testbench.DUT.CPU_core.pm_fetch_dec_Inst.idc_ijmp ;
// assign RJMP = testbench.DUT.CPU_core.pm_fetch_dec_Inst.idc_rjmp ;
// assign CALL = testbench.DUT.CPU_core.pm_fetch_dec_Inst.idc_call ;
// assign ICALL = testbench.DUT.CPU_core.pm_fetch_dec_Inst.idc_icall ;
// assign RCALL = testbench.DUT.CPU_core.pm_fetch_dec_Inst.idc_rcall ;

assign PC = testbench.DUT.CPU_core.pm_fetch_dec_Inst.pc;

// assign SPL = testbench.DUT.CPU_core.IORegs_Inst.spl_current;
// assign SPH = testbench.DUT.CPU_core.IORegs_Inst.sph_current;
// assign SP[15:0] = {testbench.DUT.CPU_core.IORegs_Inst.sph_current[7:0] , testbench.DUT.CPU_core.IORegs_Inst.spl_current[7:0]};

// Data mem ---------------------
assign SRAM[2047:0] = testbench.Data_Mem.mem_array[2047:0];

// Prog mem ---------------------
assign INST = testbench.DUT.CPU_core.instruction;

always @(posedge clk) begin
	#(5) PREV_INST <= INST;
end

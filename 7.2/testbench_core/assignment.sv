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

assign SREG = testbench.uut.design_1_i.avr_core_0.inst.IORegs_Inst.sreg_current;
assign GPREG = testbench.uut.design_1_i.avr_core_0.inst.GPRF_Inst.gprf_current;

assign JMP = testbench.uut.design_1_i.avr_core_0.inst.pm_fetch_dec_Inst.idc_jmp ;
assign IJMP = testbench.uut.design_1_i.avr_core_0.inst.pm_fetch_dec_Inst.idc_ijmp ;
assign RJMP = testbench.uut.design_1_i.avr_core_0.inst.pm_fetch_dec_Inst.idc_rjmp ;
assign CALL = testbench.uut.design_1_i.avr_core_0.inst.pm_fetch_dec_Inst.idc_call ;
assign ICALL = testbench.uut.design_1_i.avr_core_0.inst.pm_fetch_dec_Inst.idc_icall ;
assign RCALL = testbench.uut.design_1_i.avr_core_0.inst.pm_fetch_dec_Inst.idc_rcall ;

assign PC = testbench.uut.design_1_i.avr_core_0.inst.pm_fetch_dec_Inst.pc;

assign SRAM[2047:0] = testbench.uut.design_1_i.sram_0.inst.mem_array[2047:0];
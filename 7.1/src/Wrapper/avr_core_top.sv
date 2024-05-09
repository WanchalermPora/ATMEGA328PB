module avr_core_top #(   		 
	parameter		impl_mul    = 1,
	 parameter		use_rst     = 1,
	 parameter		pc22b       = 0, 
	//  parameter		eind_width  = 1,
	//  parameter		rampz_width = 1,
	 parameter		eind_width  = 0,
	 parameter		ram_depth  = 12,
	 parameter		rampz_width = 0,
	//  parameter		irqs_width  = 23
	 parameter		irqs_width  = 45)   
   (adr, 
    cp2,
    cp2en,
    iore,
    iowe,
    ireset,
	irqlines,
	irqack,
	irqackad);

  output[5:0]	adr;
  input 		cp2;
  input 		cp2en;
  output 		iore;
  output 		iowe;
  input 		ireset;
  input[44:0]	irqlines;
  output		irqack;
  output[5:0]	irqackad;

  wire [15:0]	Program_Mem_dout;
  wire [5:0]	avr_core_adr;
  wire [7:0]	avr_core_dbusout;
  wire 			avr_core_iore;
  wire 			avr_core_iowe;
  wire [13:0]	avr_core_pc;
  wire [11:0]	avr_core_ramadr;
  wire 			avr_core_ramre;
  wire 			avr_core_ramwe;
//   wire 			cp2;
//   wire 			cp2en;
  wire 			ireset;
  wire [7:0]	sram_dout;

//   wire 			irqack;
//   wire [4:0] 	irqackad;

  assign adr[5:0] = avr_core_adr;
//   assign cp2 = cp2;
//   assign cp2en = cp2en;
  assign iore = avr_core_iore;
  assign iowe = avr_core_iowe;
//   assign ireset = ireset;

  Program_Mem Program_Mem
       (.addr(avr_core_pc),
        .clk(cp2),
        .din({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dout(Program_Mem_dout),
        .we(1'b0));

  avr_core CPU_core
       (
        .cp2(cp2),
        .cp2en(cp2en),		
        .ireset(ireset),		
		
		.valid_instr(),
		.insert_nop(1'b0),
		.block_irq(1'b0),
		.change_flow(),

		.pc(avr_core_pc), 
		.instruction(Program_Mem_dout),

		.adr(avr_core_adr),
		.iore(avr_core_iore),
        .iowe(avr_core_iowe),

        .ramadr(avr_core_ramadr),
        .ramre(avr_core_ramre),
        .ramwe(avr_core_ramwe),        

		.cpuwait(1'b0),

        .dbusin(sram_dout),
        .dbusout(avr_core_dbusout),

        // .irqlines(irqlines),
   		// .irqack(irqack),
   		// .irqackad(irqackad),

		.irqlines(0),
   		.irqack(irqack),
   		.irqackad(irqackad),

		.sleepi(),
		.irqok(),
		.globint(),

		.wdri(),

		.spm_out(),
		.spm_inst(),
        .spm_wait(1'b0));

    wire clk_N;
    wire we_N;
    wire ce_N;
    wire [10:0] A;

    assign clk_N = !(cp2) ;
    assign we_N = !avr_core_ramwe ;
    assign ce_N = !((avr_core_ramre | avr_core_ramwe) & (avr_core_ramadr >= 256));
    assign A = avr_core_ramadr - 256 ;

  S013LLLPSP_X256Y8D8 Data_Mem
    //    (.addr(avr_core_ramadr),
    //     .clk(cp2),
    //     .di(avr_core_dbusout),
    //     .dout(sram_dout),
    //     .re(avr_core_ramre),
    //     .we(avr_core_ramwe));
        (
            .Q(sram_dout),
			.CLK(clk_N),
			.CEN(ce_N),
			.WEN(we_N),
			.A(A),
			.D(avr_core_dbusout));

endmodule
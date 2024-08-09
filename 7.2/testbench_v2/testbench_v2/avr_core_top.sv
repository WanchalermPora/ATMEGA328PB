module avr_core_top   
   (adr_0,
    cp2_0,
    cp2en_0,
    iore_0,
    iowe_0,
    ireset_0);
  output [5:0]adr_0;
  input cp2_0;
  input cp2en_0;
  output iore_0;
  output iowe_0;
  input ireset_0;

  wire [15:0]Program_Mem_0_dout;
  wire [5:0]avr_core_0_adr;
  wire [7:0]avr_core_0_dbusout;
  wire avr_core_0_iore;
  wire avr_core_0_iowe;
  wire [13:0]avr_core_0_pc;
  wire [11:0]avr_core_0_ramadr;
  wire avr_core_0_ramre;
  wire avr_core_0_ramwe;
  wire cp2_0_1;
  wire cp2en_0_1;
  wire ireset_0_1;
  wire [7:0]sram_0_dout;

  assign adr_0[5:0] = avr_core_0_adr;
  assign cp2_0_1 = cp2_0;
  assign cp2en_0_1 = cp2en_0;
  assign iore_0 = avr_core_0_iore;
  assign iowe_0 = avr_core_0_iowe;
  assign ireset_0_1 = ireset_0;

  Program_Mem Program_Mem
       (.addr(avr_core_0_pc),
        .clk(cp2_0_1),
        .din({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dout(Program_Mem_0_dout),
        .we(1'b0));

  avr_core CPU_core
       (.adr(avr_core_0_adr),
        .block_irq(1'b0),
        .cp2(cp2_0_1),
        .cp2en(cp2en_0_1),
        .cpuwait(1'b0),
        .dbusin(sram_0_dout),
        .dbusout(avr_core_0_dbusout),
        .insert_nop(1'b0),
        .instruction(Program_Mem_0_dout),
        .iore(avr_core_0_iore),
        .iowe(avr_core_0_iowe),
        .ireset(ireset_0_1),
        .irqlines({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .pc(avr_core_0_pc),
        .ramadr(avr_core_0_ramadr),
        .ramre(avr_core_0_ramre),
        .ramwe(avr_core_0_ramwe),
        .spm_wait(1'b0));

    wire clk_N;
    wire we_N;
    wire ce_N;
    wire [10:0] A;

    assign clk_N = !(cp2_0_1) ;
    assign we_N = !avr_core_0_ramwe ;
    assign ce_N = !((avr_core_0_ramre | avr_core_0_ramwe) & (avr_core_0_ramadr >= 256));
    assign A = avr_core_0_ramadr - 256 ;

  S013LLLPSP_X256Y8D8 Data_Mem
    //    (.addr(avr_core_0_ramadr),
    //     .clk(cp2_0_1),
    //     .di(avr_core_0_dbusout),
    //     .dout(sram_0_dout),
    //     .re(avr_core_0_ramre),
    //     .we(avr_core_0_ramwe));
        (
            .Q(sram_0_dout),
			.CLK(clk_N),
			.CEN(ce_N),
			.WEN(we_N),
			.A(A),
			.D(avr_core_0_dbusout));

endmodule
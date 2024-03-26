//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
//Date        : Wed Oct 18 05:11:14 2023
//Host        : LAPTOP-VLJOJ3SM running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

// (* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=3,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
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

  design_1_Program_Mem_0_1 Program_Mem_0
       (.addr(avr_core_0_pc),
        .clk(cp2_0_1),
        .din({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dout(Program_Mem_0_dout),
        .we(1'b0));
  design_1_avr_core_0_0 avr_core_0
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
  design_1_sram_0_0 sram_0
       (.addr(avr_core_0_ramadr),
        .clk(cp2_0_1),
        .di(avr_core_0_dbusout),
        .dout(sram_0_dout),
        .re(avr_core_0_ramre),
        .we(avr_core_0_ramwe));
endmodule

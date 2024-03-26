//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
//Date        : Wed Oct 18 05:11:14 2023
//Host        : LAPTOP-VLJOJ3SM running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
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

  wire [5:0]adr_0;
  wire cp2_0;
  wire cp2en_0;
  wire iore_0;
  wire iowe_0;
  wire ireset_0;

  design_1 design_1_i
       (.adr_0(adr_0),
        .cp2_0(cp2_0),
        .cp2en_0(cp2en_0),
        .iore_0(iore_0),
        .iowe_0(iowe_0),
        .ireset_0(ireset_0));
endmodule

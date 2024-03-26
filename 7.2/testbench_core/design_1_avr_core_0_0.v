// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:avr_core:1.0
// IP Revision: 1

// (* X_CORE_INFO = "avr_core,Vivado 2019.1" *)
// (* CHECK_LICENSE_TYPE = "design_1_avr_core_0_0,avr_core,{}" *)
// (* CORE_GENERATION_INFO = "design_1_avr_core_0_0,avr_core,{x_ipProduct=Vivado 2019.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=avr_core,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,impl_mul=1,use_rst=1,pc22b=0,eind_width=0,ram_depth=12,rampz_width=0,irqs_width=45}" *)
// (* IP_DEFINITION_SOURCE = "module_ref" *)
// (* DowngradeIPIdentifiedWarnings = "yes" *)
// `timescale 1 ps / 1 ps

module design_1_avr_core_0_0 (
  cp2,
  cp2en,
  ireset,
  valid_instr,
  insert_nop,
  block_irq,
  change_flow,
  pc,
  instruction,
  adr,
  iore,
  iowe,
  ramadr,
  ramre,
  ramwe,
  cpuwait,
  dbusin,
  dbusout,
  irqlines,
  irqack,
  irqackad,
  sleepi,
  irqok,
  globint,
  wdri,
  spm_out,
  spm_inst,
  spm_wait
);

input wire cp2;
input wire cp2en;
input wire ireset;
output wire valid_instr;
input wire insert_nop;
// (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME block_irq, SENSITIVITY LEVEL_HIGH, PortWidth 1" *)
// (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 block_irq INTERRUPT" *)
input wire block_irq;
output wire change_flow;
output wire [13 : 0] pc;
input wire [15 : 0] instruction;
output wire [5 : 0] adr;
output wire iore;
output wire iowe;
output wire [11 : 0] ramadr;
output wire ramre;
output wire ramwe;
input wire cpuwait;
input wire [7 : 0] dbusin;
output wire [7 : 0] dbusout;
input wire [44 : 0] irqlines;
output wire irqack;
output wire [4 : 0] irqackad;
output wire sleepi;
output wire irqok;
output wire globint;
output wire wdri;
output wire [15 : 0] spm_out;
output wire spm_inst;
input wire spm_wait;

  avr_core #(
    .impl_mul(1),
    .use_rst(1),
    .pc22b(0),
    .eind_width(0),
    .ram_depth(12),
    .rampz_width(0),
    .irqs_width(45)
  ) inst (
    .cp2(cp2),
    .cp2en(cp2en),
    .ireset(ireset),
    .valid_instr(valid_instr),
    .insert_nop(insert_nop),
    .block_irq(block_irq),
    .change_flow(change_flow),
    .pc(pc),
    .instruction(instruction),
    .adr(adr),
    .iore(iore),
    .iowe(iowe),
    .ramadr(ramadr),
    .ramre(ramre),
    .ramwe(ramwe),
    .cpuwait(cpuwait),
    .dbusin(dbusin),
    .dbusout(dbusout),
    .irqlines(irqlines),
    .irqack(irqack),
    .irqackad(irqackad),
    .sleepi(sleepi),
    .irqok(irqok),
    .globint(globint),
    .wdri(wdri),
    .spm_out(spm_out),
    .spm_inst(spm_inst),
    .spm_wait(spm_wait)
  );
endmodule

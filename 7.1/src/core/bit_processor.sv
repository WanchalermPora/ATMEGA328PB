//************************************************************************************************
// "Bit processor" for AVR core
// Version 1.41(Special version for the JTAG OCD)
// Designed by Ruslan Lepetenok
// Modified 07.11.2011
// Unused inputs(sreg_bit_num[2..0],idc_sbi,idc_cbi,idc_bld) was removed.
// std_library was added
// Converted to Verilog
// Modified 18.08.12
//************************************************************************************************

`timescale 1 ns / 1 ns

module bit_processor(
   		     //Clock and reset
   		     input  logic        cp2,
   		     input  logic        cp2en,
   		     input  logic        ireset,
   		     
   		     input  logic [2:0]  bit_num_r_io,	  // BIT NUMBER FOR CBI/SBI/BLD/BST/SBRS/SBRC/SBIC/SBIS INSTRUCTIONS
   		     input  logic [7:0]  dbusin,  	  // SBI/CBI/SBIS/SBIC  IN
   		     output logic [7:0]  bitpr_io_out,	  // SBI/CBI OUT	
   		     input  logic [7:0]  sreg_out,	  // BRBS/BRBC/BLD IN 
   		     input  logic [2:0]  branch,  	  // NUMBER (0..7) OF BRANCH CONDITION FOR BRBS/BRBC INSTRUCTION
   		     output logic [7:0]  bit_pr_sreg_out,  // BCLR/BSET/BST(T-FLAG ONLY) 	    
   		     output logic [7:0]  bld_op_out,	  // BLD OUT (T FLAG)
   		     input  logic [7:0]  reg_rd_out,	  // BST/SBRS/SBRC IN	 
   		     output logic        bit_test_op_out,  // output logic OF SBIC/SBIS/SBRS/SBRC/BRBC/BRBS
   		     // Instructions and states
   		     input  logic        sbi_st,
   		     input  logic        cbi_st,
   		     input  logic        idc_bst,
   		     input  logic        idc_bset,
   		     input  logic        idc_bclr,
   		     input  logic        idc_sbic,
   		     input  logic        idc_sbis,
   		     input  logic        idc_sbrs,
   		     input  logic        idc_sbrc,
   		     input  logic        idc_brbs,
   		     input  logic        idc_brbc,
   		     input  logic        idc_reti 	       
   		     );
 
 //####################################################################################################		     
    
   localparam LP_SYNC_RST = 0; // Reserved for the future use
    
   logic         sreg_t_flag;		//  For  bld instruction
   
   logic [7:0]    temp_in_data_current;
   logic[7:0]    temp_in_data_next;
   
   logic [7:0]   sreg_t_temp;
   logic [7:0]   bit_num_decode;
   logic [7:0]   bit_pr_sreg_out_int;
   
   // SBIS/SBIC/SBRS/SBRC signals
   logic [7:0]   bit_test_in;
   logic [7:0]   bit_test_mux_out;
   
   // BRBS/BRBC signals
   logic [7:0]   branch_decode;
   logic [7:0]   branch_mux;
   
function[7:0] fn_bit_num_dcd;
 input[2:0]    arg;
 logic[7:0]      res;    
 integer       i;
  begin
   res = {8{1'b0}};
   for(i=0;i<8;i=i+1) begin
    res[i] = (i[2:0] == arg) ? 1'b1 : 1'b0;
   end // for
  fn_bit_num_dcd = res; 
  end
endfunction // fn_bit_num_dcd   
   
 //####################################################################################################  
   
   assign sreg_t_flag = sreg_out[6];
   
   // SBI/CBI store register
   always_ff @(posedge cp2 or negedge ireset)
   begin: main_seq
      if (!ireset)
       temp_in_data_current <= {8{1'b0}};
      else 
      begin
       temp_in_data_current <= temp_in_data_next;
      end
   end // main_seq
      
// ########################################################################################

// assign sreg_t_temp[0]   = (bit_num_decode[0]) ? reg_rd_out[0] : 1'b0;
// assign sreg_t_temp[7:1] = (bit_num_decode[7:1] & reg_rd_out[7:1]) | (~bit_num_decode[7:1] & sreg_t_temp[6:0]);
assign sreg_t_temp[0]   = (bit_num_decode[0]) ? reg_rd_out[0] : 1'b0;
assign sreg_t_temp[1] = (bit_num_decode[1] & reg_rd_out[1]) | (~bit_num_decode[1] & sreg_t_temp[0]);
assign sreg_t_temp[2] = (bit_num_decode[2] & reg_rd_out[2]) | (~bit_num_decode[2] & sreg_t_temp[1]);
assign sreg_t_temp[3] = (bit_num_decode[3] & reg_rd_out[3]) | (~bit_num_decode[3] & sreg_t_temp[2]);
assign sreg_t_temp[4] = (bit_num_decode[4] & reg_rd_out[4]) | (~bit_num_decode[4] & sreg_t_temp[3]);
assign sreg_t_temp[5] = (bit_num_decode[5] & reg_rd_out[5]) | (~bit_num_decode[5] & sreg_t_temp[4]);
assign sreg_t_temp[6] = (bit_num_decode[6] & reg_rd_out[6]) | (~bit_num_decode[6] & sreg_t_temp[5]);
assign sreg_t_temp[7] = (bit_num_decode[7] & reg_rd_out[7]) | (~bit_num_decode[7] & sreg_t_temp[6]);
      
// ########################################################################################
  
// BCLR/BSET/BST/RETI logic
assign bit_pr_sreg_out_int[6:0] = ({7{idc_bset}} & (~reg_rd_out[6:0])) | ((~{7{idc_bclr}}) & reg_rd_out[6:0]);

// SREG register bit 7 - interrupt enable flag
assign bit_pr_sreg_out_int[7] = (idc_bset & (~reg_rd_out[7])) | ((~idc_bclr) & reg_rd_out[7]) | idc_reti;

assign bit_pr_sreg_out = (idc_bst) ? {bit_pr_sreg_out_int[7], sreg_t_temp[7], bit_pr_sreg_out_int[5:0]} : bit_pr_sreg_out_int;
   			 

// SBIC/SBIS/SBRS/SBRC logic
assign bit_test_in = (idc_sbis || idc_sbic) ? dbusin : reg_rd_out;

// assign bit_test_mux_out[0] = (bit_num_decode[0]) ? bit_test_in[0] : 1'b0;
// assign bit_test_mux_out[7:1] = (bit_num_decode[7:1] & bit_test_in[7:1]) | (~bit_num_decode[7:1] & bit_test_mux_out[6:0]);
assign bit_test_mux_out[0] = (bit_num_decode[0]) ? bit_test_in[0] : 1'b0;
assign bit_test_mux_out[1] = (bit_num_decode[1] & bit_test_in[1]) | (~bit_num_decode[1] & bit_test_mux_out[0]);	
assign bit_test_mux_out[2] = (bit_num_decode[2] & bit_test_in[2]) | (~bit_num_decode[2] & bit_test_mux_out[1]);
assign bit_test_mux_out[3] = (bit_num_decode[3] & bit_test_in[3]) | (~bit_num_decode[3] & bit_test_mux_out[2]);
assign bit_test_mux_out[4] = (bit_num_decode[4] & bit_test_in[4]) | (~bit_num_decode[4] & bit_test_mux_out[3]);
assign bit_test_mux_out[5] = (bit_num_decode[5] & bit_test_in[5]) | (~bit_num_decode[5] & bit_test_mux_out[4]);
assign bit_test_mux_out[6] = (bit_num_decode[6] & bit_test_in[6]) | (~bit_num_decode[6] & bit_test_mux_out[5]);
assign bit_test_mux_out[7] = (bit_num_decode[7] & bit_test_in[7]) | (~bit_num_decode[7] & bit_test_mux_out[6]);					     

assign bit_test_op_out = (bit_test_mux_out[7] & (idc_sbis | idc_sbrs)) | ((~bit_test_mux_out[7]) & (idc_sbic | idc_sbrc)) | (branch_mux[7] & idc_brbs) | ((~branch_mux[7]) & idc_brbc);

// assign branch_mux[0] = (branch_decode[0]) ? sreg_out[0] : 1'b0;
// assign branch_mux[7:1] = (branch_decode[7:1] & sreg_out[7:1]) | (~branch_decode[7:1] & branch_mux[6:0]);
assign branch_mux[0] = (branch_decode[0]) ? sreg_out[0] : 1'b0;
assign branch_mux[1] = (branch_decode[1] & sreg_out[1]) | (~branch_decode[1] & branch_mux[0]);	
assign branch_mux[2] = (branch_decode[2] & sreg_out[2]) | (~branch_decode[2] & branch_mux[1]);	
assign branch_mux[3] = (branch_decode[3] & sreg_out[3]) | (~branch_decode[3] & branch_mux[2]);
assign branch_mux[4] = (branch_decode[4] & sreg_out[4]) | (~branch_decode[4] & branch_mux[3]);
assign branch_mux[5] = (branch_decode[5] & sreg_out[5]) | (~branch_decode[5] & branch_mux[4]);
assign branch_mux[6] = (branch_decode[6] & sreg_out[6]) | (~branch_decode[6] & branch_mux[5]);
assign branch_mux[7] = (branch_decode[7] & sreg_out[7]) | (~branch_decode[7] & branch_mux[6]);
	 
// BLD logic (bld_inst)
assign bld_op_out = (fn_bit_num_dcd(bit_num_r_io) & {8{sreg_t_flag}}) | (~fn_bit_num_dcd(bit_num_r_io) & reg_rd_out);

// BRBS/BRBC LOGIC (branch_decode_logic)
assign branch_decode = fn_bit_num_dcd(branch); 

// BST part (load T bit of SREG from the general purpose register)
assign bit_num_decode = fn_bit_num_dcd(bit_num_r_io); 

 generate
  genvar       i;
   for (i = 0; i < 8; i = i + 1)
    begin : sbi_cbi_dcd_gen

      // (SBI/CBI logic)
      assign bitpr_io_out[i] = (sbi_st && bit_num_decode[i]) ? 1'b1 :  // SBI
                               (cbi_st && bit_num_decode[i]) ? 1'b0 :  // CBI
                               temp_in_data_current[i];		      // ???

    end // sbi_cbi_dcd_gen

   // Synchronous reset support
   if(LP_SYNC_RST) begin : sync_rst
    assign temp_in_data_next = (!ireset) ? {8{1'b0}} : ((cp2en) ? dbusin : temp_in_data_current);
   end // sync_rst
   else begin : async_rst
    assign temp_in_data_next = (cp2en) ? dbusin : temp_in_data_current;
   end // async_rst

 endgenerate


			   
endmodule // bit_processor


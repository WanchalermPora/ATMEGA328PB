`timescale 1 ns / 1 ns

module mcu_cs (ireset,
				cp2,
				IO_Addr,
				dbus_in,
				dbus_out,
				iore,
				iowe,
				out_en,
				BODS_o,
				BODSE_o,
				PUD_o,
				IVSEL_o,
				IVCE_o);
 
	// `include "bit_def_pack.vh"
 
	parameter [5:0] MCUCR_Address = 6'h35;

	// Clock and Reset
	input        ireset;
	input        cp2;
	// AVR Control
	input [5:0]  adr;
	input [7:0]  dbus_in;
	output [7:0] dbus_out;
	input        iore;
	input        iowe;
	output       out_en;
	// Control/Status lines
	output       BODS_o;
	output       BODSE_o;
	output       PUD_o;
	output       IVSEL_o;
	output       IVCE_o;
   
	reg [7:0]    mcucr_current;
	reg [7:0]    mcucr_next;
   
	always @(negedge ireset or posedge cp2)
	begin: seq_prc
		if (!ireset) begin		//Reset
			mcucr_current <= {8{1'b0}};
		end else begin		// Clock
			mcucr_current <= mcucr_next;
		end
	end
   
	always @(IO_Addr or dbus_in or iore or iowe)
	begin: comb_prc
		// mcucr_next = mcucr_current;
		if (IO_Addr == MCUCR_Address && iowe) begin
			mcucr_next = dbus_in;
		end else begin
			mcucr_next = mcucr_current;
		end
	end
   
	assign out_en = (IO_Addr == MCUCR_Address && iore ) ? 1'b1 : 1'b0;
	assign dbus_out = mcucr_current;
   
	assign BODS_o = mcucr_current[6];
	assign BODSE_o = mcucr_current[5];
	assign PUD_o = mcucr_current[4];
	assign IVSEL_o = mcucr_current[1];
	assign IVCE_o = mcucr_current[0];

endmodule
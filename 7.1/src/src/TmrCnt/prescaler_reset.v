`timescale 1 ns / 1 ns
module prescaler_reset (ireset,cp2,cp2en,iore,iowe,adr,dbus_in,dbus_out,out_en,prescaler0_reset,prescaler1_reset);
    input ireset;
    input cp2;
    input cp2en;
    input iore;
    input iowe;
    input [5:0]      adr;
    input [7:0]      dbus_in;
	output out_en;
    output [7:0] dbus_out;
    output prescaler0_reset;
    output prescaler1_reset;
	// output TSM ;

//`include "avr_adr_pack.vh"
    reg [7:0] GTCCR;
    wire PSRSYNC, PSRASYNC, TSM;
    reg [7:0] dbus_out_int;
    reg out_en_int;

    // always_comb begin : convenient
	assign PSRSYNC = GTCCR[0];
	assign PSRASYNC = GTCCR[1];  
	assign TSM = GTCCR[7];
    // end
 
    always @(*) begin : GTCCR_Reg_Read
      if(adr == 6'h23) begin
            dbus_out_int = GTCCR;
            out_en_int = iore;
        end
        else begin
            dbus_out_int = {8{1'b0}};
            out_en_int = 1'b0;
        end
    end
    
    always @(posedge cp2 or negedge ireset)
    begin: GTCCR_Reg_Write
        if (ireset == 0)  // Reset
            GTCCR <= {8{1'b0}};
        else   // Clock
        begin
            if (cp2en)  // Clock Enable 
            begin
                if (adr == 6'h23 && iowe) begin
                  GTCCR[7] <= dbus_in[7];
                  GTCCR[1:0]  <= dbus_in[1:0];
                end
                else if (TSM==0) begin
                  GTCCR[1:0] <= 2'b00;
                end
            end
        end
    end  

    assign dbus_out = dbus_out_int;
    assign out_en = out_en_int;
    assign prescaler0_reset = PSRSYNC;
    assign prescaler1_reset = PSRASYNC;

endmodule
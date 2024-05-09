`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 1 ns

module Timer_Counter_Tb;



reg cp2_0; 
reg ireset_0;
// reg tmr_cp2en;
// reg cp2en;
// reg cp2;
reg [5:0] IO_Addr_0;
reg [7:0] dbus_in_0;
reg iore_0;
reg iowe_0;
reg tn_0;
reg [11:0] ram_Addr_0;
reg ramre_0;
reg ramwe_0;
reg TCnOvfIRQ_Ack_0;
reg TCnCmpAIRQ_Ack_0;
reg TCnCmpBIRQ_Ack_0;

wire OCnA_0;
wire OCnB_0;
wire TCnOvfIRQ_0;
wire TCnCmpAIRQ_0;
wire TCnCmpBIRQ_0;


design_1_wrapper uut(
	.cp2_0(cp2_0),
	.ireset_0(ireset_0),
	.IO_Addr_0(IO_Addr_0),
	.dbus_in_0(dbus_in_0),
	.iore_0(iore_0),
	.iowe_0(iowe_0),
	.tn_0(tn_0),
	.ram_Addr_0(ram_Addr_0),
	.ramre_0(ramre_0),
	.ramwe_0(ramwe_0),
	// .TCnOvfIRQ_Ack_0(TCnOvfIRQ_Ack_0),
	// .TCnCmpAIRQ_Ack_0(TCnCmpAIRQ_Ack_0),
	// .TCnCmpBIRQ_Ack_0(TCnCmpBIRQ_Ack_0),
	
	.OCnA_0(OCnA_0),
	.OCnB_0(OCnB_0),
	// .TCnOvfIRQ_0(TCnOvfIRQ_0),
	// .TCnCmpAIRQ_0(TCnCmpAIRQ_0),
	// .TCnCmpBIRQ_0(TCnCmpBIRQ_0)
);

integer k=0;
parameter period = 50 ;

always begin
    #(period/2) cp2_0 =1'b1 ;
	#(period/2) cp2_0 =1'b0 ;
end 

initial 
begin 
	ireset_0 = 0;
	#(period);
	ireset_0 = 1;
end

initial 
begin
	#(period);
	IO_Addr_0 = 6'h26; // TCNTn
	dbus_in_0 = 8'h00 ;
	iowe_0 = 1'b1 ;
	#(period);
	iowe_0 = 1'b0 ;
	#(period);
	IO_Addr_0 = 6'h27; // OCRnA
	dbus_in_0 = 8'h7F ;
	iowe_0 = 1'b1 ;
	#(period);
	iowe_0 = 1'b0 ;
	#(period);
	IO_Addr_0 = 6'h24; // TCCRnA
	dbus_in_0 = 8'b11000001 ;
	iowe_0 = 1'b1 ;
	#(period);
	iowe_0 = 1'b0 ;
	#(period);
	IO_Addr_0 = 6'h25; // TCCRnB
	dbus_in_0 = 8'b00000010 ;
	iowe_0 = 1'b1 ;
	#(period);
	iowe_0 = 1'b0 ;
	#(5000*period);
	$finish;
end	
endmodule
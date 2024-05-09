`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module design_1_wrapper_tb;



reg cp2_0; 
reg ireset_0;
// reg cp2en_0;
// reg tn_0;
// reg TCnOvfIRQ_Ack_0;
// reg TCnCmpAIRQ_Ack_0;
// reg TCnCmpBIRQ_Ack_0;
wire DDR_XCKn_0 ;
wire DDR_XCKn_1 ;
// wire irqack_0;
// wire [5:0] irqackad_0;
// wire irqok_0;
// wire globint_0;
// wire OCnA_0;
// wire OCnB_0;
// wire ICPn_in_0;

design_1_wrapper uut(
	.cp2_0(cp2_0),
	.ireset_0(ireset_0),
	.DDR_XCKn_0(DDR_XCKn_0),
	.DDR_XCKn_1(DDR_XCKn_1)
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
	#(6000*period);
	$finish;
end	
endmodule
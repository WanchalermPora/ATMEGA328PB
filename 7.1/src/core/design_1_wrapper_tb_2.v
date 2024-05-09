`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module design_1_wrapper_tb;



reg cp2_0; 
reg ireset_0;
reg cp2en_0;

design_1_wrapper uut(
	.cp2_0(cp2_0),
	.ireset_0(ireset_0),
	.cp2en_0(cp2en_0)
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
	cp2en_0 = 1'b1;
	#(500*period);
	$finish;
end	
endmodule
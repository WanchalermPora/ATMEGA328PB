`timescale 1 ns / 1 ns

module Port_D 
	// #(
	// parameter              p_width     = 8   	
	// )
	(
	input wire            	cp2,
	input wire            	ireset,
	input [5:0]      		IO_Addr ,
	input            		iore ,
	input            		iowe ,		
	output           		out_en ,
	input [7:0]      		dbus_in ,
	output wire [7:0] 		dbus_out ,
	// output [7:0]   			portx,
	// output [7:0]   			ddrx,
	input [7:0]    			pinD_i,
	output wire [7:0] 		DID_o,
	output 					DDR_XCK0,
	
	output [7:0] 			pu_D,
	output [7:0] 			dd_D,
	output [7:0]   			pv_D,
	output [7:0]        	die_D,
	
	input                 	PUD	,
	input 					SLEEP,
	input 					RXEN0,
	input 					TXEN0,
	input                   OC0A_EN,
	input           		OC0B_EN,
	input 					OC2B_EN,
	input 					OC3B_EN,
	input 					OC4B_EN,
	input 					OC4A_EN,
	input 					OC3A_EN,
	input                   XCK0_OUT,
	input                   OC0A,
	input           		OC0B,
	input 					OC2B,
	input 					OC3B,
	input 					OC4B,
	input 					OC4A,
	input 					OC3A,
	input                 	UMSEL,
	input					TXD0,
	input [7:0]             PCINT, //pcint[23:16]
	input                   INT1_EN,
	input                   INT0_EN,
	input					PCIE2
	);
			  

	wire[7:0] portD;
	wire[7:0] ddrD; 
	// wire[7:0] pinx;
	
	wire[7:0] PUOED ;
	wire[7:0] PUOVD	;
	wire[7:0] DDOED	;
	wire[7:0] DDOVD	;
	wire[7:0] PVOED	;
	wire[7:0] PVOVD	;
	wire[7:0] DIEOED;
	wire[7:0] DIEOVD;
	wire[7:0] DID;
//	wire[7:0] AIOD;
	
	assign PUOED[7] = 1'b0;
    assign PUOED[6]	= 1'b0;
	assign PUOED[5] = 1'b0;
	assign PUOED[4] = 1'b0;
	assign PUOED[3] = 1'b0;
	assign PUOED[2] = 1'b0;
	assign PUOED[1] = TXEN0;
	assign PUOED[0] = RXEN0;

	assign PUOVD[7] = 1'b0;
	assign PUOVD[6] = 1'b0;
	assign PUOVD[5] = 1'b0;
	assign PUOVD[4] = 1'b0;
	assign PUOVD[3] = 1'b0;
	assign PUOVD[2] = 1'b0;
	assign PUOVD[1] = 1'b0;
	assign PUOVD[0] = portD[0]&&(!PUD); 
	
	assign DDOED[7] = 1'b0;
	assign DDOED[6] = 1'b0;
	assign DDOED[5] = 1'b0;
	assign DDOED[4] = 1'b0;
	assign DDOED[3] = 1'b0;
	assign DDOED[2] = 1'b0;
	assign DDOED[1] = TXEN0;
	assign DDOED[0] = RXEN0;
	
	assign DDOVD = 8'b00000010;
	
	assign PVOED[7] = 1'b0;
	assign PVOED[6] = OC0A_EN;
	assign PVOED[5] = OC0B_EN;
	assign PVOED[4] = UMSEL ;
	assign PVOED[3] = OC2B_EN ;
	assign PVOED[2] = OC3B_EN||OC4B_EN;
	assign PVOED[1] = OC4A_EN||TXEN0;
	assign PVOED[0] = OC3A_EN;
	
	assign PVOVD[7] = 1'b0;
	assign PVOVD[6] = OC0A;
	assign PVOVD[5] = OC0B;
	assign PVOVD[4] = XCK0_OUT;
	assign PVOVD[3] = OC2B;
	assign PVOVD[2] = portD[2] ? (OC3B||OC4B) : (OC3B&&OC4B);
	assign PVOVD[1] = OC4A||TXD0;
	assign PVOVD[0] = OC3A;
	
	assign DIEOED[7]= (PCINT[7]&&PCIE2) ;
	assign DIEOED[6]= (PCINT[6]&&PCIE2) ;
	assign DIEOED[5]= (PCINT[5]&&PCIE2) ;
	assign DIEOED[4]= (PCINT[4]&&PCIE2) ;
	assign DIEOED[3]= INT1_EN||(PCINT[3]&&PCIE2) ;
	assign DIEOED[2]= INT0_EN||(PCINT[2]&&PCIE2) ;
	assign DIEOED[1]= (PCINT[1]&&PCIE2) ;
	assign DIEOED[0]= (PCINT[0]&&PCIE2) ;
	
	assign DIEOVD[7]= 8'b11111111 ;
	
	assign DID  = pinD_i ;
	assign DID_o= DID;
	assign DDR_XCK0 = ddrD[4] ;
	
	// assign AIOD[7] = ; 
	// assign AIOD[6] = ;
	
	IO_Port #(
		.port_width    (8),
		.PINx_Address  (6'h09),
		.DDRx_Address  (6'h0a),
		.PORTx_Address (6'h0b)
	) 
	IO_Port_D_inst(
		.cp2   		(cp2),
		.ireset  	(ireset),
		.IO_Addr 	(IO_Addr),
		.iore 		(iore),
		.iowe 		(iowe),		
		.out_en		(out_en),
		.dbus_in    (dbus_in),
		.dbus_out 	(dbus_out),
		.portx		(portD),
		.ddrx       (ddrD),
		.pinx       (pinD_i)
	);
	
	wire [7:0] pu_D_int ;

	assign pu_D_int[7] = (PUOED[7]) ? (PUOVD[7]) : (portD[7]&&(!ddrD[7])&&(!PUD)) ;
	assign pu_D_int[6] = (PUOED[6]) ? (PUOVD[6]) : (portD[6]&&(!ddrD[6])&&(!PUD)) ;
	assign pu_D_int[5] = (PUOED[5]) ? (PUOVD[5]) : (portD[5]&&(!ddrD[5])&&(!PUD)) ;
	assign pu_D_int[4] = (PUOED[4]) ? (PUOVD[4]) : (portD[4]&&(!ddrD[4])&&(!PUD)) ;
	assign pu_D_int[3] = (PUOED[3]) ? (PUOVD[3]) : (portD[3]&&(!ddrD[3])&&(!PUD)) ;
	assign pu_D_int[2] = (PUOED[2]) ? (PUOVD[2]) : (portD[2]&&(!ddrD[2])&&(!PUD)) ;
	assign pu_D_int[1] = (PUOED[1]) ? (PUOVD[1]) : (portD[1]&&(!ddrD[1])&&(!PUD)) ;
	assign pu_D_int[0] = (PUOED[0]) ? (PUOVD[0]) : (portD[0]&&(!ddrD[0])&&(!PUD)) ;

	assign pu_D = !pu_D_int;
	
	assign dd_D[7] = (DDOED[7]) ? (DDOVD[7]) : ddrD[7] ;
	assign dd_D[6] = (DDOED[6]) ? (DDOVD[6]) : ddrD[6] ;
	assign dd_D[5] = (DDOED[5]) ? (DDOVD[5]) : ddrD[5] ;
	assign dd_D[4] = (DDOED[4]) ? (DDOVD[4]) : ddrD[4] ;
	assign dd_D[3] = (DDOED[3]) ? (DDOVD[3]) : ddrD[3] ;
	assign dd_D[2] = (DDOED[2]) ? (DDOVD[2]) : ddrD[2] ;
	assign dd_D[1] = (DDOED[1]) ? (DDOVD[1]) : ddrD[1] ;
	assign dd_D[0] = (DDOED[0]) ? (DDOVD[0]) : ddrD[0] ;
	
	assign pv_D[7] = (PVOED[7]) ? (PVOVD[7]) : portD[7] ;
	assign pv_D[6] = (PVOED[6]) ? (PVOVD[6]) : portD[6] ;
	assign pv_D[5] = (PVOED[5]) ? (PVOVD[5]) : portD[5] ;
	assign pv_D[4] = (PVOED[4]) ? (PVOVD[4]) : portD[4] ;
	assign pv_D[3] = (PVOED[3]) ? (PVOVD[3]) : portD[3] ;
	assign pv_D[2] = (PVOED[2]) ? (PVOVD[2]) : portD[2] ;
	assign pv_D[1] = (PVOED[1]) ? (PVOVD[1]) : portD[1] ;
	assign pv_D[0] = (PVOED[0]) ? (PVOVD[0]) : portD[0] ;
	
	assign die_D[7] = (DIEOED[7]) ? (!DIEOVD[7]) : SLEEP ;
	assign die_D[6] = (DIEOED[6]) ? (!DIEOVD[6]) : SLEEP ;
	assign die_D[5] = (DIEOED[5]) ? (!DIEOVD[5]) : SLEEP ;
	assign die_D[4] = (DIEOED[4]) ? (!DIEOVD[4]) : SLEEP ;
	assign die_D[3] = (DIEOED[3]) ? (!DIEOVD[3]) : SLEEP ;
	assign die_D[2] = (DIEOED[2]) ? (!DIEOVD[2]) : SLEEP ;
	assign die_D[1] = (DIEOED[1]) ? (!DIEOVD[1]) : SLEEP ;
	assign die_D[0] = (DIEOED[0]) ? (!DIEOVD[0]) : SLEEP ;
	
endmodule 
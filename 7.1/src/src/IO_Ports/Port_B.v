`timescale 1 ns / 1 ns

module Port_B 
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
	input [7:0]    			pinB_i,
	output wire [7:0] 		DIB_o,
	output 					DDR_XCK1,
	
	output [7:0] 			pu_B,
	output [7:0] 			dd_B,
	output [7:0]   			pv_B,
	output [7:0]        	die_B,
	
	input                 	PUD	,
	input 					SLEEP,
	input					INTRC,
	input					EXTCK,
	input					AS2,
	input					SPE0,
	input					MSTR,
	input 					RXEN1,
	input 					TXEN1,
	input                   OC2A_EN,
	input           		OC1B_EN,
	input 					OC1A_EN,
	input                   SCK0_OUT,
	input                   XCK1_OUT,
	input                   SPI0_SL_OUT,
	input                   OC2A,
	input               	OC1B,
	input					OC1A,
	input                 	SPI0_MT_OUT,
	input                 	UMSEL,
	input					TXD1,
	input [7:0]             PCINT, //pcint[7:0]
	input					PCIE0
	);
			  
    wire[7:0] portB;
	wire[7:0] ddrB; 
	// wire[7:0] pinx;

	wire[7:0] PUOEB ;
	wire[7:0] PUOVB	;
	wire[7:0] DDOEB	;
	wire[7:0] DDOVB	;
	wire[7:0] PVOEB	;
	wire[7:0] PVOVB	;
	wire[7:0] DIEOEB;
	wire[7:0] DIEOVB;
	wire[7:0] DIB;
//	wire[7:0] AIOB;
	
	assign PUOEB[7] = ((!INTRC)&&(!EXTCK))||AS2  ;
    assign PUOEB[6]	= INTRC||AS2 ;
	assign PUOEB[5] = SPE0&&(!MSTR);
	assign PUOEB[4] = (SPE0&&MSTR)||RXEN1;
	assign PUOEB[3] = (SPE0&&(!MSTR))||TXEN1;
	assign PUOEB[2] = SPE0&&(!MSTR);
	assign PUOEB[1] = 1'b0;
	assign PUOEB[0] = 1'b0;

	assign PUOVB[7] = 1'b0;
	assign PUOVB[6] = 1'b0;
	assign PUOVB[5] = portB[5]&&(!PUD); 
	assign PUOVB[4] = portB[4]&&(!PUD); 
	assign PUOVB[3] = portB[3]&&(!PUD); 
	assign PUOVB[2] = portB[2]&&(!PUD); 
	assign PUOVB[1] = 1'b0;
	assign PUOVB[0] = 1'b0;
	
	assign DDOEB[7] = ((!INTRC)&&(!EXTCK))||AS2  ;
	assign DDOEB[6] = INTRC||AS2 ;
	assign DDOEB[5] = SPE0&&(!MSTR);
	assign DDOEB[4] = (SPE0&&MSTR)||RXEN1;
	assign DDOEB[3] = (SPE0&&(!MSTR))||TXEN1;
	assign DDOEB[2] = SPE0&&(!MSTR);
	assign DDOEB[1] = 1'b0;
	assign DDOEB[0] = 1'b0;
	
	assign DDOVB = 8'b00000000;
	
	assign PVOEB[7] = 1'b0;
	assign PVOEB[6] = 1'b0;
	assign PVOEB[5] = (SPE0&&MSTR)||UMSEL;
	assign PVOEB[4] = SPE0&&(!MSTR);
	assign PVOEB[3] = (SPE0&&MSTR)||OC2A_EN;
	assign PVOEB[2] = OC1B_EN;
	assign PVOEB[1] = OC1A_EN;
	assign PVOEB[0] = 1'b0;
	
	assign PVOVB[7] = 1'b0;
	assign PVOVB[6] = 1'b0;
	assign PVOVB[5] = SCK0_OUT||XCK1_OUT;
	assign PVOVB[4] = SPI0_SL_OUT;
	assign PVOVB[3] = SPI0_MT_OUT||OC2A||TXD1;
	assign PVOVB[2] = OC1B;
	assign PVOVB[1] = OC1A;
	assign PVOVB[0] = 1'b0;
	
	assign DIEOEB[7]= ((!INTRC)&&(!EXTCK))||AS2||(PCINT[7]&&PCIE0) ;
	assign DIEOEB[6]= (!INTRC)||AS2||(PCINT[6]&&PCIE0) ;
	assign DIEOEB[5]= (PCINT[5]&&PCIE0) ;
	assign DIEOEB[4]= (PCINT[4]&&PCIE0) ;
	assign DIEOEB[3]= (PCINT[3]&&PCIE0) ;
	assign DIEOEB[2]= (PCINT[2]&&PCIE0) ;
	assign DIEOEB[1]= (PCINT[1]&&PCIE0) ;
	assign DIEOEB[0]= (PCINT[0]&&PCIE0) ;
	
	assign DIEOVB[7]= (INTRC||EXTCK)&&(!AS2) ;
	assign DIEOVB[6]= INTRC&&(!AS2) ;
	assign DIEOVB[5]= 1'b1;
	assign DIEOVB[4]= 1'b1;
	assign DIEOVB[3]= 1'b1;
	assign DIEOVB[2]= 1'b1;
	assign DIEOVB[1]= 1'b1;
	assign DIEOVB[0]= 1'b1;
	
	assign DIB  = pinB_i ;
	assign DIB_o= DIB;
	assign DDR_XCK1 = ddrB[5] ;
	
	// assign AIOB[7] = ; 
	// assign AIOB[6] = ;
	
	IO_Port #(
		.port_width    (8),
		.PINx_Address  (6'h03),
		.DDRx_Address  (6'h04),
		.PORTx_Address (6'h05)
	) 
	IO_Port_B_inst(
		.cp2   		(cp2),
		.ireset  	(ireset),
		.IO_Addr 	(IO_Addr),
		.iore 		(iore),
		.iowe 		(iowe),		
		.out_en		(out_en),
		.dbus_in    (dbus_in),
		.dbus_out 	(dbus_out),
		.portx		(portB),
		.ddrx       (ddrB),
		.pinx       (pinB_i)
	);
	
	wire [7:0] pu_B_int;

	assign pu_B_int[7] = (PUOEB[7]) ? (PUOVB[7]) : (portB[7]&&(!ddrB[7])&&(!PUD)) ;
	assign pu_B_int[6] = (PUOEB[6]) ? (PUOVB[6]) : (portB[6]&&(!ddrB[6])&&(!PUD)) ;
	assign pu_B_int[5] = (PUOEB[5]) ? (PUOVB[5]) : (portB[5]&&(!ddrB[5])&&(!PUD)) ;
	assign pu_B_int[4] = (PUOEB[4]) ? (PUOVB[4]) : (portB[4]&&(!ddrB[4])&&(!PUD)) ;
	assign pu_B_int[3] = (PUOEB[3]) ? (PUOVB[3]) : (portB[3]&&(!ddrB[3])&&(!PUD)) ;
	assign pu_B_int[2] = (PUOEB[2]) ? (PUOVB[2]) : (portB[2]&&(!ddrB[2])&&(!PUD)) ;
	assign pu_B_int[1] = (PUOEB[1]) ? (PUOVB[1]) : (portB[1]&&(!ddrB[1])&&(!PUD)) ;
	assign pu_B_int[0] = (PUOEB[0]) ? (PUOVB[0]) : (portB[0]&&(!ddrB[0])&&(!PUD)) ;

	assign pu_B = !(pu_B_int);
	
	assign dd_B[7] = (DDOEB[7]) ? (DDOVB[7]) : ddrB[7] ;
	assign dd_B[6] = (DDOEB[6]) ? (DDOVB[6]) : ddrB[6] ;
	assign dd_B[5] = (DDOEB[5]) ? (DDOVB[5]) : ddrB[5] ;
	assign dd_B[4] = (DDOEB[4]) ? (DDOVB[4]) : ddrB[4] ;
	assign dd_B[3] = (DDOEB[3]) ? (DDOVB[3]) : ddrB[3] ;
	assign dd_B[2] = (DDOEB[2]) ? (DDOVB[2]) : ddrB[2] ;
	assign dd_B[1] = (DDOEB[1]) ? (DDOVB[1]) : ddrB[1] ;
	assign dd_B[0] = (DDOEB[0]) ? (DDOVB[0]) : ddrB[0] ;
	
	assign pv_B[7] = (PVOEB[7]) ? (PVOVB[7]) : portB[7] ;
	assign pv_B[6] = (PVOEB[6]) ? (PVOVB[6]) : portB[6] ;
	assign pv_B[5] = (PVOEB[5]) ? (PVOVB[5]) : portB[5] ;
	assign pv_B[4] = (PVOEB[4]) ? (PVOVB[4]) : portB[4] ;
	assign pv_B[3] = (PVOEB[3]) ? (PVOVB[3]) : portB[3] ;
	assign pv_B[2] = (PVOEB[2]) ? (PVOVB[2]) : portB[2] ;
	assign pv_B[1] = (PVOEB[1]) ? (PVOVB[1]) : portB[1] ;
	assign pv_B[0] = (PVOEB[0]) ? (PVOVB[0]) : portB[0] ;
	
	assign die_B[7] = (DIEOEB[7]) ? (!DIEOVB[7]) : SLEEP ;
	assign die_B[6] = (DIEOEB[6]) ? (!DIEOVB[6]) : SLEEP ;
	assign die_B[5] = (DIEOEB[5]) ? (!DIEOVB[5]) : SLEEP ;
	assign die_B[4] = (DIEOEB[4]) ? (!DIEOVB[4]) : SLEEP ;
	assign die_B[3] = (DIEOEB[3]) ? (!DIEOVB[3]) : SLEEP ;
	assign die_B[2] = (DIEOEB[2]) ? (!DIEOVB[2]) : SLEEP ;
	assign die_B[1] = (DIEOEB[1]) ? (!DIEOVB[1]) : SLEEP ;
	assign die_B[0] = (DIEOEB[0]) ? (!DIEOVB[0]) : SLEEP ;
	
endmodule 
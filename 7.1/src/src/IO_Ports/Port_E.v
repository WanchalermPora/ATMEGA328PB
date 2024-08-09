`timescale 1 ns / 1 ns

module Port_E 
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
	input [3:0]    			pinE_i,
	output wire [3:0] 		DIE_o,
	
	output [3:0] 			pu_E,
	output [3:0] 			dd_E,
	output [3:0]   			pv_E,
	output [3:0]        	die_E,
	
	input                 	PUD	,
	input 					SLEEP,
	input					RSTDISBL,
	input					TWEN1,
	input					SPE1,
	input					MSTR,
	input                   SCK1_OUT,
	input                   SPI1_MT_OUT,
	input           		SCL1_OUT,
	input					SDA1_OUT,
	input [1:0]				ADCxD, //ADCxD[7:6]
	input [3:0]             PCINT, //pcint[27:24]
	input					PCIE3,
	input                   aco_oe,
	input                   acompout
	);
			  

	wire[3:0] portE;
	wire[3:0] ddrE; 
	// wire[7:0] pinx;
	
	wire[3:0] PUOEE ;
	wire[3:0] PUOVE	;
	wire[3:0] DDOEE	;
	wire[3:0] DDOVE	;
	wire[3:0] PVOEE	;
	wire[3:0] PVOVE	;
	wire[3:0] DIEOEE;
	wire[3:0] DIEOVE;
	wire[3:0] DIE;
	wire[3:0] AIOE;
	
	assign PUOEE[3] = SPE1 && (!MSTR);
	assign PUOEE[2] = SPE1 && (!MSTR);
	assign PUOEE[1] = TWEN1 ;
	assign PUOEE[0] = TWEN1||aco_oe;

	assign PUOVE[3] = portE[3]&&(!PUD);
	assign PUOVE[2] = portE[2]&&(!PUD);
	assign PUOVE[1] = portE[1]&&(!PUD);
	assign PUOVE[0] = portE[0]&&(!PUD);
	
	assign DDOEE[3] = SPE1 && (!MSTR);
	assign DDOEE[2] = SPE1 && (!MSTR);
	assign DDOEE[1] = TWEN1 ;
	assign DDOEE[0] = TWEN1||aco_oe;
	
	assign DDOVE = 4'b0000;
	
	assign PVOEE[3] = SPE1 && MSTR;
	assign PVOEE[2] = 1'b0;
	assign PVOEE[1] = SCL1_OUT;
	assign PVOEE[0] = SDA1_OUT||aco_oe;
	
	assign PVOVE[3] = SPI1_MT_OUT;
	assign PVOVE[2] = 1'b0;
	assign PVOVE[1] = TWEN1 ;
	assign PVOVE[0] = acompout||TWEN1 ;
	
	assign DIEOEE[3]= (PCINT[3]&&PCIE3)||ADCxD[1] ;
	assign DIEOEE[2]= (PCINT[2]&&PCIE3)||ADCxD[0] ;
	assign DIEOEE[1]= (PCINT[1]&&PCIE3) ;
	assign DIEOEE[0]= (PCINT[0]&&PCIE3) ;
	
	assign DIEOVE[3]= (PCINT[3]&&PCIE3);
	assign DIEOVE[2]= (PCINT[2]&&PCIE3);
	assign DIEOVE[1]= (PCINT[1]&&PCIE3);
	assign DIEOVE[0]= (PCINT[0]&&PCIE3);
	
	assign DIE  = pinE_i ;
	assign DIE_o= DIE;
	
	// assign AIOE[6] = ;
	
	IO_Port #(
		.port_width    (4),
		.PINx_Address  (6'h0c),
		.DDRx_Address  (6'h0d),
		.PORTx_Address (6'h0e)
	) 
	IO_Port_E_inst(
		.cp2   		(cp2),
		.ireset  	(ireset),
		.IO_Addr 	(IO_Addr),
		.iore 		(iore),
		.iowe 		(iowe),		
		.out_en		(out_en),
		.dbus_in    (dbus_in),
		.dbus_out 	(dbus_out),
		.portx		(portE),
		.ddrx       (ddrE),
		.pinx       (pinE_i)
	);
	
	wire [3:0] pu_E_int;

	assign pu_E_int[3] = (PUOEE[3]) ? (PUOVE[3]) : (portE[3]&&(!ddrE[3])&&(!PUD)) ;
	assign pu_E_int[2] = (PUOEE[2]) ? (PUOVE[2]) : (portE[2]&&(!ddrE[2])&&(!PUD)) ;
	assign pu_E_int[1] = (PUOEE[1]) ? (PUOVE[1]) : (portE[1]&&(!ddrE[1])&&(!PUD)) ;
	assign pu_E_int[0] = (PUOEE[0]) ? (PUOVE[0]) : (portE[0]&&(!ddrE[0])&&(!PUD)) ;

	assign pu_E = !pu_E_int;
	
	assign dd_E[3] = (DDOEE[3]) ? (DDOVE[3]) : ddrE[3] ;
	assign dd_E[2] = (DDOEE[2]) ? (DDOVE[2]) : ddrE[2] ;
	assign dd_E[1] = (DDOEE[1]) ? (DDOVE[1]) : ddrE[1] ;
	assign dd_E[0] = (DDOEE[0]) ? (DDOVE[0]) : ddrE[0] ;
	
	assign pv_E[3] = (PVOEE[3]) ? (PVOVE[3]) : portE[3] ;
	assign pv_E[2] = (PVOEE[2]) ? (PVOVE[2]) : portE[2] ;
	assign pv_E[1] = (PVOEE[1]) ? (PVOVE[1]) : portE[1] ;
	assign pv_E[0] = (PVOEE[0]) ? (PVOVE[0]) : portE[0] ;
	
	assign die_E[3] = (DIEOEE[3]) ? (!DIEOVE[3]) : SLEEP ;
	assign die_E[2] = (DIEOEE[2]) ? (!DIEOVE[2]) : SLEEP ;
	assign die_E[1] = (DIEOEE[1]) ? (!DIEOVE[1]) : SLEEP ;
	assign die_E[0] = (DIEOEE[0]) ? (!DIEOVE[0]) : SLEEP ;
	
endmodule 
`timescale 1 ns / 1 ns

module Port_C 
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
	input [6:0]    			pinC_i,
	output wire [6:0] 		DIC_o,
	
	output [6:0] 			pu_C,
	output [6:0] 			dd_C,
	output [6:0]   			pv_C,
	output [6:0]        	die_C,
	
	input                 	PUD	,
	input 					SLEEP,
	input					RSTDISBL,
	input					TWEN0,
	input					SPE1,
	input					MSTR,
	input                   SCK1_OUT,
	input                   SPI1_SL_OUT,
	input           		SCL0_OUT,
	input					SDA0_OUT,
	input [5:0]				ADCxD, //ADCxD[5:0]
	input [6:0]             PCINT, //pcint[14:8]
	input					PCIE1
	);

	wire[6:0] portC;
	wire[6:0] ddrC; 
	// wire[7:0] pinx;			  

	wire[6:0] PUOEC ;
	wire[6:0] PUOVC	;
	wire[6:0] DDOEC	;
	wire[6:0] DDOVC	;
	wire[6:0] PVOEC	;
	wire[6:0] PVOVC	;
	wire[6:0] DIEOEC;
	wire[6:0] DIEOVC;
	wire[6:0] DIC;
//	wire[6:0] AIOC;
	
    assign PUOEC[6]	= RSTDISBL ;
	assign PUOEC[5] = TWEN0;
	assign PUOEC[4] = TWEN0;
	assign PUOEC[3] = 1'b0;
	assign PUOEC[2] = 1'b0;
	assign PUOEC[1] = SPE1 && (!MSTR);
	assign PUOEC[0] = SPE1 && MSTR;

	assign PUOVC[6] = 1'b1;
	assign PUOVC[5] = portC[5]&&(!PUD); 
	assign PUOVC[4] = portC[4]&&(!PUD); 
	assign PUOVC[3] = 1'b0;
	assign PUOVC[2] = 1'b0;
	assign PUOVC[1] = portC[1]&&(!PUD);
	assign PUOVC[0] = portC[0]&&(!PUD);
	
	assign DDOEC[6] = RSTDISBL ;
	assign DDOEC[5] = TWEN0;
	assign DDOEC[4] = TWEN0;
	assign DDOEC[3] = 1'b0;
	assign DDOEC[2] = 1'b0;
	assign DDOEC[1] = SPE1 && (!MSTR);
	assign DDOEC[0] = SPE1 && MSTR;
	
	assign DDOVC[6] = 1'b0;
	assign DDOVC[5] = SCL0_OUT;
	assign DDOVC[4] = SDA0_OUT;
	assign DDOVC[3] = 1'b0;
	assign DDOVC[2] = 1'b0;
	assign DDOVC[1] = 1'b0;
	assign DDOVC[0] = 1'b0;
	
	assign PVOEC[6] = 1'b0;
	assign PVOEC[5] = TWEN0;
	assign PVOEC[4] = TWEN0;
	assign PVOEC[3] = 1'b0;
	assign PVOEC[2] = 1'b0;
	assign PVOEC[1] = SPE1 && MSTR;
	assign PVOEC[0] = SPE1 && (!MSTR);
	
	assign PVOVC[6] = 1'b0;
	assign PVOVC[5] = 1'b0;
	assign PVOVC[4] = 1'b0;
	assign PVOVC[3] = 1'b0;
	assign PVOVC[2] = 1'b0;
	assign PVOVC[1] = SCK1_OUT ;
	assign PVOVC[0] = SPI1_SL_OUT ;
	
	assign DIEOEC[6]= RSTDISBL||(PCINT[6]&&PCIE1) ;
	assign DIEOEC[5]= (PCINT[5]&&PCIE1)||ADCxD[5] ;
	assign DIEOEC[4]= (PCINT[4]&&PCIE1)||ADCxD[4] ;
	assign DIEOEC[3]= (PCINT[3]&&PCIE1)||ADCxD[3] ;
	assign DIEOEC[2]= (PCINT[2]&&PCIE1)||ADCxD[2] ;
	assign DIEOEC[1]= (PCINT[1]&&PCIE1)||ADCxD[1] ;
	assign DIEOEC[0]= (PCINT[0]&&PCIE1)||ADCxD[0] ;
	
	assign DIEOVC[6]= RSTDISBL ;
	assign DIEOVC[5]= (PCINT[5]&&PCIE1);
	assign DIEOVC[4]= (PCINT[4]&&PCIE1);
	assign DIEOVC[3]= (PCINT[3]&&PCIE1);
	assign DIEOVC[2]= (PCINT[2]&&PCIE1);
	assign DIEOVC[1]= (PCINT[1]&&PCIE1);
	assign DIEOVC[0]= (PCINT[0]&&PCIE1);
	
	assign DIC  = pinC_i ;
	assign DIC_o= DIC;
	
	// assign AIOC[6] = ;
	
	IO_Port #(
		.port_width    (7),
		.PINx_Address  (6'h06),
		.DDRx_Address  (6'h07),
		.PORTx_Address (6'h08)
	) 
	IO_Port_C_inst(
		.cp2   		(cp2),
		.ireset  	(ireset),
		.IO_Addr 	(IO_Addr),
		.iore 		(iore),
		.iowe 		(iowe),		
		.out_en		(out_en),
		.dbus_in    (dbus_in),
		.dbus_out 	(dbus_out),
		.portx		(portC),
		.ddrx       (ddrC),
		.pinx       (pinC_i)
	);
	
	wire [6:0] pu_C_int ;

	assign pu_C_int[6] = (PUOEC[6]) ? (PUOVC[6]) : (portC[6]&&(!ddrC[6])&&(!PUD)) ;
	assign pu_C_int[5] = (PUOEC[5]) ? (PUOVC[5]) : (portC[5]&&(!ddrC[5])&&(!PUD)) ;
	assign pu_C_int[4] = (PUOEC[4]) ? (PUOVC[4]) : (portC[4]&&(!ddrC[4])&&(!PUD)) ;
	assign pu_C_int[3] = (PUOEC[3]) ? (PUOVC[3]) : (portC[3]&&(!ddrC[3])&&(!PUD)) ;
	assign pu_C_int[2] = (PUOEC[2]) ? (PUOVC[2]) : (portC[2]&&(!ddrC[2])&&(!PUD)) ;
	assign pu_C_int[1] = (PUOEC[1]) ? (PUOVC[1]) : (portC[1]&&(!ddrC[1])&&(!PUD)) ;
	assign pu_C_int[0] = (PUOEC[0]) ? (PUOVC[0]) : (portC[0]&&(!ddrC[0])&&(!PUD)) ;

	assign pu_C = !pu_C_int;
	
	assign dd_C[6] = (DDOEC[6]) ? (DDOVC[6]) : ddrC[6] ;
	assign dd_C[5] = (DDOEC[5]) ? (DDOVC[5]) : ddrC[5] ;
	assign dd_C[4] = (DDOEC[4]) ? (DDOVC[4]) : ddrC[4] ;
	assign dd_C[3] = (DDOEC[3]) ? (DDOVC[3]) : ddrC[3] ;
	assign dd_C[2] = (DDOEC[2]) ? (DDOVC[2]) : ddrC[2] ;
	assign dd_C[1] = (DDOEC[1]) ? (DDOVC[1]) : ddrC[1] ;
	assign dd_C[0] = (DDOEC[0]) ? (DDOVC[0]) : ddrC[0] ;
	
	assign pv_C[6] = (PVOEC[6]) ? (PVOVC[6]) : portC[6] ;
	assign pv_C[5] = (PVOEC[5]) ? (PVOVC[5]) : portC[5] ;
	assign pv_C[4] = (PVOEC[4]) ? (PVOVC[4]) : portC[4] ;
	assign pv_C[3] = (PVOEC[3]) ? (PVOVC[3]) : portC[3] ;
	assign pv_C[2] = (PVOEC[2]) ? (PVOVC[2]) : portC[2] ;
	assign pv_C[1] = (PVOEC[1]) ? (PVOVC[1]) : portC[1] ;
	assign pv_C[0] = (PVOEC[0]) ? (PVOVC[0]) : portC[0] ;
	
	assign die_C[6] = (DIEOEC[6]) ? (!DIEOVC[6]) : SLEEP ;
	assign die_C[5] = (DIEOEC[5]) ? (!DIEOVC[5]) : SLEEP ;
	assign die_C[4] = (DIEOEC[4]) ? (!DIEOVC[4]) : SLEEP ;
	assign die_C[3] = (DIEOEC[3]) ? (!DIEOVC[3]) : SLEEP ;
	assign die_C[2] = (DIEOEC[2]) ? (!DIEOVC[2]) : SLEEP ;
	assign die_C[1] = (DIEOEC[1]) ? (!DIEOVC[1]) : SLEEP ;
	assign die_C[0] = (DIEOEC[0]) ? (!DIEOVC[0]) : SLEEP ;
	
endmodule 
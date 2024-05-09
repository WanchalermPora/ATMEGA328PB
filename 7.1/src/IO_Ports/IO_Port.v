`timescale 1 ns / 1 ns

module IO_Port (ireset,
				cp2,
				IO_Addr,
				dbus_in,
				dbus_out,
				iore,
				iowe,
				out_en,
				// resync_out,
				portx,
				ddrx,
				pinx);
	
	parameter [5:0] PINx_Address  = 6'h03;
	parameter [5:0] DDRx_Address  = 6'h04;				
	parameter [5:0] PORTx_Address = 6'h05;
	parameter       port_width    = 8;	
					
	input            ireset ;
	input            cp2 ;			
					
	input [5:0]      IO_Addr ;
	input            iore ;
	input            iowe ;		
	output reg       out_en;
	input [7:0]      dbus_in ;
	output reg [7:0] dbus_out ;						
	
	// External connection
	output [port_width-1:0]   portx;
	output [port_width-1:0]   ddrx;
	input [port_width-1:0]    pinx;
	//
	// output [port_width-1:0]   resync_out;				
	
	wire[7:0] portx_reg;
	wire[7:0] ddrx_reg; 
	wire[7:0] pinx_reg;
	
	// reg [7:0]  portx_reg;
	// reg [7:0]  ddrx_reg; 
	// reg [7:0]  pinx_reg;
	
	wire we_portx;
	wire we_ddrx;
	wire we_pinx;
	
	// reg we_portx;
	// reg we_ddrx;
	// reg we_pinx;
 
	localparam LP_PORT_IMPL_MASK = (port_width == 1) ? 8'b00000001 : 
									(port_width == 2) ? 8'b00000011 :
									(port_width == 3) ? 8'b00000111 :
									(port_width == 4) ? 8'b00001111 :
									(port_width == 5) ? 8'b00011111 :
									(port_width == 6) ? 8'b00111111 :
									(port_width == 7) ? 8'b01111111 :
									(port_width == 8) ? 8'b11111111 : 8'b00000000;			  
	
	assign we_portx = iowe && (IO_Addr == PORTx_Address);
	assign we_ddrx  = iowe && (IO_Addr == DDRx_Address); 	
	assign we_pinx	= iowe && (IO_Addr == PINx_Address);		
					
	rg_md #(
		.p_width     (port_width),   
		.p_init_val  (8'b00000000),
		.p_impl_mask (LP_PORT_IMPL_MASK)
	)
	rg_md_portx_inst(
		.clk   (cp2),
		.nrst  (ireset),
		.wdata (dbus_in),  				     
		.wbe   (we_portx),
		.tog   (we_pinx),
		.rdata (portx_reg)										     
	);				
	
	rg_md #(
		.p_width     (port_width),   
		.p_init_val  (8'b00000000),
		.p_impl_mask (LP_PORT_IMPL_MASK)
	)
	rg_md_ddrx_inst(
		.clk   (cp2),
		.nrst  (ireset),
		.wdata (dbus_in),  				     
		.wbe   (we_ddrx),
		.tog   (1'b0),
		.rdata (ddrx_reg)										     
	);					
					
	assign ddrx[port_width-1:0]  =  ddrx_reg[port_width-1:0];
	assign portx[port_width-1:0] =  portx_reg[port_width-1:0];				
					
	synchronizer #(
		.p_width     (port_width)
	)
	synchronizer_pinx_inst(
		.clk   (cp2),
		.d_in  (pinx),
		.d_sync(pinx_reg[port_width-1:0])
	);							
	
	// assign pinx_reg[port_width - 1 : 7] = 0;
	
	assign pinx_reg[port_width - 1] = 0;

	always @(*)
	begin: OutMuxComb
		// if (iore) begin
			case (IO_Addr)
				PORTx_Address :
					begin
						dbus_out <= portx_reg;
						out_en <= iore;
					end
				DDRx_Address :
					begin
						dbus_out <= ddrx_reg;
						out_en <= iore;
					end	
				PINx_Address :
					begin
						dbus_out <= pinx_reg;
						out_en <= iore;
					end	
				default :
					begin
						dbus_out <= {8{1'b0}};
						out_en <= 1'b0;
					end
			endcase
		// end else if (ramre) begin
			// case (ram_Addr)
				// default :
					// begin
						// dbus_out <= {8{1'b0}};
						// out_en <= 1'b0;
					// end
			// endcase
		// end else begin
			// dbus_out <= {8{1'b0}};
			// out_en <= 1'b0;
		// end 
    end
		
endmodule
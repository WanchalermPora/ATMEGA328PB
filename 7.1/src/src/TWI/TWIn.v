`timescale 1 ns / 1 ns
module TWIn	
	#(
	parameter [11:0] TWBRn_Address = 12'h0B8 , // TWBR0
	parameter [11:0] TWSRn_Address = 12'h0B9 , // TWSR0
	parameter [11:0] TWARn_Address = 12'h0BA , // TWAR0
	parameter [11:0] TWDRn_Address = 12'h0BB , // TWDR0
	parameter [11:0] TWCRn_Address = 12'h0BC , // TWCR0
	parameter [11:0] TWAMRn_Address = 12'h0BD , // TWAMR0
	parameter [5:0] TwiIRQ_Address = 6'h18
	)
	(
	input 					ireset,
	input					cp2,
	// input [5:0]      		IO_Addr ,
	// input            		iore ,
	// input            		iowe ,	
	input [11:0]      		ram_Addr ,
	input            		ramre ,
	input            		ramwe ,	
	output reg          	out_en ,
	input [7:0]      		dbus_in ,
	output reg [7:0] 		dbus_out ,
	
	// IRQ
	output wire             TwiIRQ,
	input [5:0]		 		irqack_addr,
	input			 		irqack,
	
	output 					TWEN ,
						
	input					sda_i,
	output					sda_o,
	input					scl_i,
	output					scl_o
	
	);
	localparam 	Ms_Md   = 1'b0,
				Sl_Md   = 1'b1;
	
	// reg [7:0]	TWBRn = 8'b00000000;
	// reg [7:0]	TWSRn = 8'b11111000;	
	// reg [7:0]	TWARn = 8'b00000010;
	// reg [7:0]	TWDRn = 8'b00000000;
	// reg [7:0]	TWCRn = 8'b00000000;
	// reg [7:0]	TWAMRn= 8'b00000000;

	reg [7:0]	TWBRn; 
	reg [7:0]	TWSRn; 
	reg [7:0]	TWARn; 
	reg [7:0]	TWDRn; 
	reg [7:0]	TWCRn; 
	reg [7:0]	TWAMRn;

	reg [14:0]	clk_cnt ;
	wire[14:0]	clk_div ;
	wire[7:0]   status ;
	reg			clk_tick ;
	reg	[1:0]	clk_phase ;
	reg			scl_int ;
	reg			sda_int ;
	reg [3:0]	bit_cnt ;
	reg [3:0]	Sl_bit_cnt ;
	reg 		str_fl ;
	reg 		wr_twd ;
	reg     	ack ;
	reg			TWI_Mode;// reg			TWI_Mode = Ms_Md;
	reg	[2:0]	TWI_state_delay;
	// wire		TWI_Mode;
	reg 		sda_i_sync ;
	reg 		scl_i_sync ;
	reg 		match_addr ;
	wire [6:0]	addr_match ;	
	
	wire		TwiIRQ_Ack;
	
	localparam 	IDLE    = 3'b000,
				START   = 3'b001,
				ADDR    = 3'b010,
				DATA  	= 3'b011,
				STOP	= 3'b100;  
				
	// localparam 	Ms_Tr_Md    = 2'b00,
				// Ms_Rc_Md   	= 2'b01,
				// Sl_Tr_Md    = 2'b10,
				// Sl_Tr_Md  	= 2'b11;
			

	
	reg	[2:0]	TWI_state ;
	
	assign TWEN = TWCRn[2] ;
	assign TwiIRQ_Ack = (irqack_addr == TwiIRQ_Address) && irqack ;
	
	assign addr_match[6] = !((TWARn[7]&&(!TWDRn[7]))||((!TWARn[7])&&TWDRn[7]))||TWAMRn[7];
	assign addr_match[5] = !((TWARn[6]&&(!TWDRn[6]))||((!TWARn[6])&&TWDRn[6]))||TWAMRn[6];
	assign addr_match[4] = !((TWARn[5]&&(!TWDRn[5]))||((!TWARn[5])&&TWDRn[5]))||TWAMRn[5];
	assign addr_match[3] = !((TWARn[4]&&(!TWDRn[4]))||((!TWARn[4])&&TWDRn[4]))||TWAMRn[4];
	assign addr_match[2] = !((TWARn[3]&&(!TWDRn[3]))||((!TWARn[3])&&TWDRn[3]))||TWAMRn[3];
	assign addr_match[1] = !((TWARn[2]&&(!TWDRn[2]))||((!TWARn[2])&&TWDRn[2]))||TWAMRn[2];
	assign addr_match[0] = !((TWARn[1]&&(!TWDRn[1]))||((!TWARn[1])&&TWDRn[1]))||TWAMRn[1];
	
	assign status = {TWSRn[7:3],3'b000} ;
	
	always @(posedge cp2 or negedge ireset)
	begin : TWBRn_REG
		if (!ireset) begin		// Reset
			TWBRn <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == TWBRn_Address && ramwe) begin
				TWBRn <= dbus_in;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : TWPS_REG
		if (!ireset) begin		// Reset
			TWSRn[1:0] <= {2{1'b0}};
		end else begin		// Clock
			if (ram_Addr == TWSRn_Address && ramwe) begin
				TWSRn[1:0] <= dbus_in[1:0];
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : Address_Match_Unit
		if (!ireset) begin		// Reset
			match_addr <= 1'b0;
		end else begin		// Clock
			if (TWI_Mode == Sl_Md) begin
				if (TWI_state == ADDR) begin
					if(!scl_i&&scl_i_sync)begin
						if(Sl_bit_cnt== 4'b0111)begin
							// if()begin
								// TWSRn[7:3] <= 5'b10101 ;
							// end else begin
							
							// end
							if((status == 8'hC0
							||status == 8'hC8
							||status == 8'h88
							||status == 8'h98
							||status == 8'hA0)&&(!TWCRn[6]))begin
								match_addr <= 1'b0;
							end else begin
								match_addr <= (addr_match[6]&&addr_match[5]&&addr_match[4]&&addr_match[3]&&addr_match[2]&&addr_match[1]&&addr_match[0])||(TWDRn[7:1] == 7'b0000000 && TWARn[0]) ;
							end
						end
					end
				end	else if (TWI_state == IDLE) begin
					if(status == 8'hC0
					||status == 8'hC8
					||status == 8'h88
					||status == 8'h98
					||status == 8'hA0)begin
						match_addr <= 1'b0;
					end
				end
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : TWS_REG
		if (!ireset) begin		// Reset
			TWSRn[7:3] <= {5{1'b1}};
			TWSRn[2] <= 1'b0;
			// TWSRn[2:0] <= {3{1'b0}};

		end else begin		// Clock
			if(TWCRn[2])begin
				case(status)
					8'h00 :
						if((ramwe&&(ram_Addr == TWCRn_Address)&&dbus_in[4]))begin
							TWSRn[7:3] <= {5{1'b1}};
						end
					8'h08 :
						if (TWI_Mode == Ms_Md) begin
							if(TWI_state == ADDR)begin
								if(TWDRn[0])begin	// read
									if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
										TWSRn[7:3] <= 5'b00111 ;
									end else if ((bit_cnt == 4'b1000)) begin
										if(ack)begin
											if((clk_cnt == clk_div))begin
												TWSRn[7:3] <= 5'b01000 ;
											end
										end else begin
											if ((!sda_i && sda_o) && (scl_int)) begin
												TWSRn[7:3] <= 5'b00111 ;
											end else if((clk_cnt == clk_div)) begin
												TWSRn[7:3] <= 5'b01001 ;
											end
										end
									end
								end else if(!TWDRn[0]) begin // write
									if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
										TWSRn[7:3] <= 5'b00111 ;
									end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
										if(ack)begin
											TWSRn[7:3] <= 5'b00011 ;
										end else begin
											TWSRn[7:3] <= 5'b00100 ;
										end
									end
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							if (TWI_state == ADDR) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(match_addr)begin
											if(TWDRn[0])begin	// read
												TWSRn[7:3] <= 5'b10110 ;
											end else if(!TWDRn[0]) begin // write
												if(TWDRn[7:1] == 7'b0000000)begin
													TWSRn[7:3] <= 5'b01111 ;
												end else begin
													TWSRn[7:3] <= 5'b01101 ;
												end
											end
										end 
									end
								end
							end	else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'h10 :
						if (TWI_Mode == Ms_Md) begin
							if(TWI_state == ADDR)begin
								if(TWDRn[0])begin	// read
									if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
										TWSRn[7:3] <= 5'b00111 ;
									end else if ((bit_cnt == 4'b1000)) begin
										if(ack)begin
											if((clk_cnt == clk_div))begin
												TWSRn[7:3] <= 5'b01000 ;
											end
										end else begin
											if ((!sda_i && sda_o) && (scl_int)) begin
												TWSRn[7:3] <= 5'b00111 ;
											end else if((clk_cnt == clk_div)) begin
												TWSRn[7:3] <= 5'b01001 ;
											end
										end
									end
								end else if(!TWDRn[0]) begin // write
									if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
										TWSRn[7:3] <= 5'b00111 ;
									end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
										if(ack)begin
											TWSRn[7:3] <= 5'b00011 ;
										end else begin
											TWSRn[7:3] <= 5'b00100 ;
										end
									end
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							if (TWI_state == ADDR) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(match_addr)begin
											if(TWDRn[0])begin	// read
												TWSRn[7:3] <= 5'b10110 ;
											end else if(!TWDRn[0]) begin // write
												if(TWDRn[7:1] == 7'b0000000)begin
													TWSRn[7:3] <= 5'b01111 ;
												end else begin
													TWSRn[7:3] <= 5'b01101 ;
												end
											end
										end 
									end
								end
							end	else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end 
					8'h18 :
						if (TWI_Mode == Ms_Md) begin
							if(TWI_state == DATA)begin
								if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
									TWSRn[7:3] <= 5'b00111 ;
								end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
									if(ack)begin
										TWSRn[7:3] <= 5'b00101 ;
									end else begin
										TWSRn[7:3] <= 5'b00110 ;
									end
								end
							end else if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00010;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							
						end
					8'h20 :
						if (TWI_Mode == Ms_Md) begin
							if(TWI_state == DATA)begin
								if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
									TWSRn[7:3] <= 5'b00111 ;
								end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
									if(ack)begin
										TWSRn[7:3] <= 5'b00101 ;
									end else begin
										TWSRn[7:3] <= 5'b00110 ;
									end
								end
							end else if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00010;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							
						end
					8'h28 :
						if (TWI_Mode == Ms_Md) begin
							if(TWI_state == DATA)begin
								if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
									TWSRn[7:3] <= 5'b00111 ;
								end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
									if(ack)begin
										TWSRn[7:3] <= 5'b00101 ;
									end else begin
										TWSRn[7:3] <= 5'b00110 ;
									end
								end
							end else if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00010;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							
						end
					8'h30 :
						if (TWI_Mode == Ms_Md) begin
							if(TWI_state == DATA)begin
								if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
									TWSRn[7:3] <= 5'b00111 ;
								end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
									if(ack)begin
										TWSRn[7:3] <= 5'b00101 ;
									end else begin
										TWSRn[7:3] <= 5'b00110 ;
									end
								end
							end else if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00010;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							
						end
					8'h38 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == START) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00001;
								end
							end
						end else begin
							if (TWI_state == ADDR) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(match_addr)begin
											if(TWDRn[0])begin	// read
												TWSRn[7:3] <= 5'b10110 ;
											end else if(!TWDRn[0]) begin // write
												if(TWDRn[7:1] == 7'b0000000)begin
													TWSRn[7:3] <= 5'b01111 ;
												end else begin
													TWSRn[7:3] <= 5'b01101 ;
												end
											end
										end 
									end
								end
							end	else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'h40 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == DATA) begin
								if ((bit_cnt == 4'b1000)&& (clk_cnt == clk_div)) begin
									if(TWCRn[6])begin
										TWSRn[7:3] <= 5'b01010;
									end else begin
										if ((!sda_i && sda_o) && (scl_int)) begin
											TWSRn[7:3] <= 5'b00111 ;
										end else begin
											TWSRn[7:3] <= 5'b01011;
										end
									end
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							
						end
					8'h48 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == START) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00010;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							
						end
					8'h50 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == DATA) begin
								if ((bit_cnt == 4'b1000)&& (clk_cnt == clk_div)) begin
									if(TWCRn[6])begin
										TWSRn[7:3] <= 5'b01010;
									end else begin
										if ((!sda_i && sda_o) && (scl_int)) begin
											TWSRn[7:3] <= 5'b00111 ;
										end else begin
											TWSRn[7:3] <= 5'b01011;
										end
									end
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							
						end
					8'h58 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == START) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00010;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							
						end
					8'hA8 :
						if (TWI_Mode == Ms_Md) begin
							
						end else begin
							if (TWI_state == DATA) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(TWCRn[6])begin
											if(sda_i_sync == 1'b0)begin // ACK
												TWSRn[7:3] <= 5'b10111;
											end else begin // NOT ACK
												TWSRn[7:3] <= 5'b11000;
											end
										end else begin
											if(sda_i_sync == 1'b0)begin // ACK
												TWSRn[7:3] <= 5'b11001;
											end else begin // NOT ACK
												TWSRn[7:3] <= 5'b11000;
											end
										end
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'hB0 :
						if (TWI_Mode == Ms_Md) begin
							
						end else begin
							if (TWI_state == DATA) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(TWCRn[6])begin
											if(sda_i_sync == 1'b0)begin // ACK
												TWSRn[7:3] <= 5'b10111;
											end else begin // NOT ACK
												TWSRn[7:3] <= 5'b11000;
											end
										end else begin
											if(sda_i_sync == 1'b0)begin // ACK
												TWSRn[7:3] <= 5'b11001;
											end else begin // NOT ACK
												TWSRn[7:3] <= 5'b11000;
											end
										end
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'hB8 :
						if (TWI_Mode == Ms_Md) begin
							
						end else begin
							if (TWI_state == DATA) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(TWCRn[6])begin
											if(sda_i_sync == 1'b0)begin // ACK
												TWSRn[7:3] <= 5'b10111;
											end else begin // NOT ACK
												TWSRn[7:3] <= 5'b11000;
											end
										end else begin
											if(sda_i_sync == 1'b0)begin // ACK
												TWSRn[7:3] <= 5'b11001;
											end else begin // NOT ACK
												TWSRn[7:3] <= 5'b11000;
											end
										end
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'hC0 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00001;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							if (TWI_state == ADDR) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(match_addr)begin
											if(TWDRn[0])begin	// read
												TWSRn[7:3] <= 5'b10101 ;
											end else if(!TWDRn[0]) begin // write
												TWSRn[7:3] <= 5'b01100 ;
											end
										end 
									end
								end
							end	else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'hC8 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00001;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							if (TWI_state == ADDR) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(match_addr)begin
											if(TWDRn[0])begin	// read
												TWSRn[7:3] <= 5'b10101 ;
											end else if(!TWDRn[0]) begin // write
												TWSRn[7:3] <= 5'b01100 ;
											end
										end 
									end
								end
							end	else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'h60 :
						if (TWI_Mode == Ms_Md) begin
							
						end else begin
							if (TWI_state == DATA) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(TWCRn[6])begin
											TWSRn[7:3] <= 5'b10000;
										end else begin
											TWSRn[7:3] <= 5'b10001;
										end
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'h68 :
						if (TWI_Mode == Ms_Md) begin
							
						end else begin
							if (TWI_state == DATA) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(TWCRn[6])begin
											TWSRn[7:3] <= 5'b10000;
										end else begin
											TWSRn[7:3] <= 5'b10001;
										end
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'h70 :
						if (TWI_Mode == Ms_Md) begin
							
						end else begin
							if (TWI_state == DATA) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(TWCRn[6])begin
											TWSRn[7:3] <= 5'b10010;
										end else begin
											TWSRn[7:3] <= 5'b10011;
										end
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'h78 :
						if (TWI_Mode == Ms_Md) begin
							
						end else begin
							if (TWI_state == DATA) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(TWCRn[6])begin
											TWSRn[7:3] <= 5'b10010;
										end else begin
											TWSRn[7:3] <= 5'b10011;
										end
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'h80 :
						if (TWI_Mode == Ms_Md) begin
							
						end else begin
							if (TWI_state == DATA) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync)) && !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(TWCRn[6])begin
											TWSRn[7:3] <= 5'b10000;
										end else begin
											TWSRn[7:3] <= 5'b10001;
										end
									end
								end
							end else if(TWI_state == START) begin
								if(!scl_i&&scl_i_sync)begin
									TWSRn[7:3] <= 5'b10100;
								end 
							end else if(TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b10100;
							end
						end
					8'h88 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00001;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							if (TWI_state == ADDR) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(match_addr)begin
											if(TWDRn[0])begin	// read
												TWSRn[7:3] <= 5'b10101 ;
											end else if(!TWDRn[0]) begin // write
												TWSRn[7:3] <= 5'b01100 ;
											end
										end 
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'h90 :
						if (TWI_Mode == Ms_Md) begin
							
						end else begin
							if (TWI_state == DATA) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(TWCRn[6])begin
											TWSRn[7:3] <= 5'b10010;
										end else begin
											TWSRn[7:3] <= 5'b10011;
										end
									end
								end
							end else if(TWI_state == START) begin
								if(!scl_i&&scl_i_sync)begin
									TWSRn[7:3] <= 5'b10100;
								end 
							end else if(TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b10100;
							end
						end
					8'h98 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00001;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							if (TWI_state == ADDR) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(match_addr)begin
											if(TWDRn[0])begin	// read
												TWSRn[7:3] <= 5'b10101 ;
											end else if(!TWDRn[0]) begin // write
												TWSRn[7:3] <= 5'b01100 ;
											end
										end 
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end	
						end
					8'hA0 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00001;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							if (TWI_state == ADDR) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(match_addr)begin
											if(TWDRn[0])begin	// read
												TWSRn[7:3] <= 5'b10101 ;
											end else if(!TWDRn[0]) begin // write
												TWSRn[7:3] <= 5'b01100 ;
											end
										end 
									end
								end
							end	else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end
						end
					8'hF8 :
						if (TWI_Mode == Ms_Md) begin
							if (TWI_state == START) begin
								if (scl_i && ((sda_i && !sda_i_sync))) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b00001;
								end
							end else if (TWI_state == STOP) begin
								if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
									TWSRn[7:3] <= 5'b11111 ;
								end
							end
						end else begin
							if (TWI_state == ADDR) begin
								if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
									TWSRn[7:3] <= 5'b00000 ;
								end else if(!scl_i&&scl_i_sync)begin
									if(Sl_bit_cnt== 4'b1000)begin
										if(match_addr)begin
											if(TWDRn[0])begin	// read
												TWSRn[7:3] <= 5'b10101 ;
											end else if(!TWDRn[0]) begin // write
												TWSRn[7:3] <= 5'b01100 ;
											end
										end 
									end
								end
							end else if (TWI_state == STOP) begin
								TWSRn[7:3] <= 5'b11111 ;
							end	
						end
					default :
						TWSRn[7:3] <= {5{1'b0}};
				endcase
			end else begin
				TWSRn[7:3] <= {5{1'b1}};
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : twi_engine
		if (!ireset) begin		// Reset
			TWI_state <= IDLE ;
		end else begin		// Clock
			case(TWI_state)
				IDLE:
					if (!(status==8'h00))begin
						if((ramwe&&(ram_Addr == TWCRn_Address)&&dbus_in[2])||TWCRn[2])begin
							if (scl_i && (!sda_i && sda_i_sync)) begin
								TWI_state <= START ;
								ack <= 1'b0 ;
							end else if (TWI_Mode == Ms_Md) begin
								if(ramwe||str_fl||wr_twd)begin
									if ((ram_Addr == TWCRn_Address&&ramwe)||str_fl) begin
										// if((dbus_in[2])||(TWCRn[2])||str_fl) begin
										if (dbus_in[4] == 1'b1) begin // Stop_Con
											if (dbus_in[5] == 1'b1) begin
												str_fl<= 1'b1 ;
												TWI_state <= STOP ;
												ack <= 1'b0 ;
											end else begin
												TWI_state <= STOP ;
												ack <= 1'b0 ;
											end 
										end else if ((dbus_in[5] == 1'b1)||(str_fl)) begin	// Start_Con
											str_fl<= 1'b0 ;
											TWI_state <= START ;
											ack <= 1'b0 ;
										end else begin
											ack <= 1'b0 ;
										end
										// end
									end else if ((ram_Addr == TWDRn_Address&&ramwe )|| (wr_twd) ) begin
										if(!TWCRn[7]&&wr_twd)begin
											if((status==8'h08)||(status==8'h10))begin
												wr_twd <= 1'b0 ;
												TWI_state <= ADDR ;
												ack <= 1'b0 ;
											end else if ((status==8'h18)
											||(status==8'h20)
											||(status==8'h28)
											||(status==8'h30)) begin
												wr_twd <= 1'b0 ;
												TWI_state <= DATA ;
												ack <= 1'b0 ;
											end else begin
												ack <= 1'b0 ;
											end
										end else begin
											wr_twd <= 1'b1 ;
											ack <= 1'b0 ;
										end 
									end else begin
										ack <= 1'b0 ;
									end 
								end else if ((status==8'h40)
								||(status==8'h50)) begin
									if (!TWCRn[7]) begin
										TWI_state <= DATA ;
										ack <= 1'b0 ;
									end else begin
										ack <= 1'b0 ;
									end
								end else begin
									ack <= 1'b0 ;
								end
							end else if (TWI_Mode == Sl_Md) begin
								if(ramwe||wr_twd)begin
									if (ram_Addr == TWCRn_Address) begin
										// if((dbus_in[2])||(TWCRn[2])) begin
										if ((dbus_in[5] == 1'b1)) begin	// Start_Con
											ack <= 1'b0 ;
											str_fl<= 1'b1 ;
										end else begin
											ack <= 1'b0 ;
										end
										// end
									end else if ((ram_Addr == TWDRn_Address)||wr_twd) begin	
										if(!TWCRn[7]&&wr_twd)begin
											if((status==8'hA8)
											||(status==8'hB0)
											||(status==8'hB8))begin
												wr_twd <= 1'b0 ;
												TWI_state <= DATA ;	
												ack <= 1'b0 ;
											end else begin
												ack <= 1'b0 ;
											end
										end else begin
											wr_twd <= 1'b1 ;
											ack <= 1'b0 ;
										end 
									end
								end else if((status==8'h60)
								||(status==8'h68)
								||(status==8'h70)
								||(status==8'h78)
								||(status==8'h80)
								||(status==8'h90)) begin
									// if(!TWCRn[7])begin
										TWI_state <= DATA ;
										ack <= 1'b0 ;										
									// end else begin
										// ack <= 1'b0 ;
									// end
								end else if ((status==8'hA8)
								||(status==8'hB0)
								||(status==8'hB8))begin
									if (scl_i && (sda_i && !sda_i_sync)) begin
										TWI_state <= STOP ;
										ack <= 1'b0 ;
									end else begin
										ack <= 1'b0 ;
									end
								end else begin
									ack <= 1'b0 ;
								end
							end else begin
								ack <= 1'b0 ;
							end
						end else begin
							ack <= 1'b0 ;
						end
					end	else begin
						ack <= 1'b0 ;
					end
				START:
					if(TWI_Mode == Ms_Md)begin
						if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
							TWI_state <= IDLE ;
						end
					end else begin
						if(!scl_i&&scl_i_sync)begin
							TWI_state <= ADDR ;
						end 
					end
				ADDR:
					if(TWI_Mode == Ms_Md)begin
						if((clk_phase == 2'b10) && (clk_cnt == ({1'b0,clk_div[14:1]}+{2'b00,clk_div[14:2]})))begin
							if(bit_cnt == 4'b1000)begin
								if( sda_i == 1'b0) begin
									ack <= 1'b1 ;
								end else begin
									ack <= 1'b0 ;
								end
							end
						end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
							if (bit_cnt == 4'b1000)begin
								TWI_state <= IDLE ;
							end
						end else if (status==8'h00)begin
							TWI_state <= IDLE ;
						end
					end else begin
						if (scl_i && (sda_i && !sda_i_sync)) begin
							TWI_state <= STOP ;
						end else if(!scl_i&& scl_i_sync)begin
							if(Sl_bit_cnt== 4'b1000)begin
								TWI_state <= IDLE ;
							end
						end else if (status==8'h00)begin
							TWI_state <= IDLE ;
						end
					end
				DATA:
					if(TWI_Mode == Ms_Md)begin
						if((clk_phase == 2'b10) && (clk_cnt == ({1'b0,clk_div[14:1]}+{2'b00,clk_div[14:2]})))begin
							if(bit_cnt == 4'b1000)begin
								if( sda_i == 1'b0) begin
									ack <= 1'b1 ;
								end else begin
									ack <= 1'b0 ;
								end
							end
						end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
							if (bit_cnt == 4'b1000) begin
								TWI_state <= IDLE ;
							end
						end	else if (status==8'h00)begin
							TWI_state <= IDLE ;
						end
					end else begin
						// if(TWCRn[6])begin
						if (scl_i && (sda_i && !sda_i_sync)) begin
							TWI_state <= STOP ;
						end else if(!scl_i&& scl_i_sync)begin
							if(Sl_bit_cnt== 4'b1000)begin
								TWI_state <= IDLE ;
							end
						end else if (status==8'h00)begin
							TWI_state <= IDLE ;
						end
						// end
					end
				STOP:
					if(TWI_Mode == Ms_Md)begin
						if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
							// if(str_fl)begin
								// TWI_state <= START ;
								// str_fl <= 1'b0 ;
							// end else begin
								TWI_state <= IDLE ;
							// end
						end
					end else begin
						TWI_state <= IDLE ;
					end
				default :
					TWI_state <= IDLE ;
			endcase
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : TWARn_REG
		if (!ireset) begin		// Reset
			TWARn <= 8'b00000010;
		end else begin		// Clock
			if (ram_Addr == TWARn_Address && ramwe) begin
				TWARn <= dbus_in;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : TWDRn_REG
		if (!ireset) begin		// Reset
			TWDRn <= 8'b00000001;
		end else begin		// Clock
			if (TWI_state==IDLE) begin
				if(ram_Addr == TWDRn_Address && ramwe)begin
					TWDRn <= dbus_in;
				end
			end	else if(TWI_state==ADDR) begin
				if(TWI_Mode==Ms_Md)begin
					if((clk_cnt == clk_div)&&(scl_i)&& !(bit_cnt== 4'b1000))begin
						TWDRn <= {TWDRn[6:0],TWDRn[0]};
					end
				end else begin
					if(scl_i&&!scl_i_sync&& !(Sl_bit_cnt== 4'b1000))begin
						TWDRn <= {TWDRn[6:0],sda_i};
					end
				end
			end else if(TWI_state==DATA) begin
				if(TWI_Mode==Ms_Md)begin
					if((status==8'h18)
					||(status==8'h20)
					||(status==8'h28)
					||(status==8'h30))begin
						if((clk_cnt == clk_div)&&(scl_i)&& !(bit_cnt== 4'b1000))begin
							TWDRn <= {TWDRn[6:0],TWDRn[0]};
						end
					end else if ((status==8'h40)
					||(status==8'h50))begin
						if((clk_cnt == ({1'b0,clk_div[14:1]}+{2'b00,clk_div[14:2]}))&& !(bit_cnt== 4'b1000))begin
							TWDRn <= {TWDRn[6:0],sda_i};
						end
					end
				end else begin
					if((status==8'hA8)
					||(status==8'hB0)
					||(status==8'hB8))begin
						if(!scl_i&&scl_i_sync && !(Sl_bit_cnt== 4'b1000))begin
							TWDRn <= {TWDRn[6:0],TWDRn[0]};
						end
					end else if ((status==8'h60)
					||(status==8'h68)
					||(status==8'h70)
					||(status==8'h78)
					||(status==8'h80)
					||(status==8'h90))begin
						if(scl_i&&!scl_i_sync&& !(Sl_bit_cnt== 4'b1000))begin
							TWDRn <= {TWDRn[6:0],sda_i};
						end
					end
				end
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : TWCRn_REG
		if (!ireset) begin		// Reset
			TWCRn[7:2] <= 6'b000000;
			TWCRn[0] <= 1'b0;
		end else begin		// Clock
			if (ram_Addr == TWCRn_Address && ramwe) begin
				TWCRn[6:5] <= dbus_in[6:5];
				TWCRn[2] <= dbus_in[2];
				TWCRn[0] <= dbus_in[0];
			end
			case(TWCRn[7]) // TWINTn
				1'b0 :
					case(status)
						8'h00 :
							if((ramwe&&(ram_Addr == TWCRn_Address)&&dbus_in[4]))begin
								TWCRn[7] <= 1'b1;
							end
						8'h08 :
							if (TWI_Mode == Ms_Md) begin
								if(TWI_state == ADDR)begin
									if(TWDRn[0])begin	// read
										if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
											TWCRn[7] <= 1'b1;
										end else if ((bit_cnt == 4'b1000)) begin
											if(ack)begin
												if((clk_cnt == clk_div))begin
													TWCRn[7] <= 1'b1;
												end
											end else begin
												if ((!sda_i && sda_o) && (scl_int)) begin
													TWCRn[7] <= 1'b1;
												end else if((clk_cnt == clk_div)) begin
													TWCRn[7] <= 1'b1;
												end
											end
										end
									end else if(!TWDRn[0]) begin // write
										if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
											TWCRn[7] <= 1'b1;
										end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
											if(ack)begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								if (TWI_state == ADDR) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(match_addr)begin
												if(TWDRn[0])begin	// read
													TWCRn[7] <= 1'b1;
												end else if(!TWDRn[0]) begin // write
													if(TWDRn[7:1] == 7'b0000000)begin
														TWCRn[7] <= 1'b1;
													end else begin
														TWCRn[7] <= 1'b1;
													end
												end
											end 
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'h10 :
							if (TWI_Mode == Ms_Md) begin
								if(TWI_state == ADDR)begin
									if(TWDRn[0])begin	// read
										if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
											TWCRn[7] <= 1'b1;
										end else if ((bit_cnt == 4'b1000)) begin
											if(ack)begin
												if((clk_cnt == clk_div))begin
													TWCRn[7] <= 1'b1;
												end
											end else begin
												if ((!sda_i && sda_o) && (scl_int)) begin
													TWCRn[7] <= 1'b1;
												end else if((clk_cnt == clk_div)) begin
													TWCRn[7] <= 1'b1;
												end
											end
										end
									end else if(!TWDRn[0]) begin // write
										if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
											TWCRn[7] <= 1'b1;
										end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
											if(ack)begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								if (TWI_state == ADDR) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(match_addr)begin
												if(TWDRn[0])begin	// read
													TWCRn[7] <= 1'b1;
												end else if(!TWDRn[0]) begin // write
													if(TWDRn[7:1] == 7'b0000000)begin
														TWCRn[7] <= 1'b1;
													end else begin
														TWCRn[7] <= 1'b1;
													end
												end
											end 
										end
									end
								end	else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'h18 :
							if (TWI_Mode == Ms_Md) begin
								if(TWI_state == DATA)begin
									if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
										TWCRn[7] <= 1'b1;
									end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
										if(ack)begin
											TWCRn[7] <= 1'b1;
										end else begin
											TWCRn[7] <= 1'b1;
										end
									end
								end else if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								
							end
						8'h20 :
							if (TWI_Mode == Ms_Md) begin
								if(TWI_state == DATA)begin 
									if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
										TWCRn[7] <= 1'b1;
									end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
										if(ack)begin
											TWCRn[7] <= 1'b1;
										end else begin
											TWCRn[7] <= 1'b1;
										end
									end
								end else if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								
							end
						8'h28 :
							if (TWI_Mode == Ms_Md) begin
								if(TWI_state == DATA)begin
									if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
										TWCRn[7] <= 1'b1;
									end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
										if(ack)begin
											TWCRn[7] <= 1'b1;
										end else begin
											TWCRn[7] <= 1'b1;
										end
									end
								end else if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								
							end
						8'h30 :
							if (TWI_Mode == Ms_Md) begin
								if(TWI_state == DATA)begin
									if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
										TWCRn[7] <= 1'b1;
									end else if((bit_cnt == 4'b1000) && (clk_cnt == clk_div)) begin
										if(ack)begin
											TWCRn[7] <= 1'b1;
										end else begin
											TWCRn[7] <= 1'b1;
										end
									end
								end else if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								
							end
						8'h38 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == START) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								if (TWI_state == ADDR) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(match_addr)begin
												if(TWDRn[0])begin	// read
													TWCRn[7] <= 1'b1;
												end else if(!TWDRn[0]) begin // write
													if(TWDRn[7:1] == 7'b0000000)begin
														TWCRn[7] <= 1'b1;
													end else begin
														TWCRn[7] <= 1'b1;
													end
												end
											end 
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end		
							end
						8'h40 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == DATA) begin
									if ((bit_cnt == 4'b1000)&& (clk_cnt == clk_div)) begin
										if(TWCRn[6])begin
											TWCRn[7] <= 1'b1;
										end else begin
											if ((!sda_i && sda_o) && (scl_int)) begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								
							end
						8'h48 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == START) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end 
							end else begin
								
							end
						8'h50 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == DATA) begin
									if ((bit_cnt == 4'b1000)&& (clk_cnt == clk_div)) begin
										if(TWCRn[6])begin
											TWCRn[7] <= 1'b1;
										end else begin
											if ((!sda_i && sda_o) && (scl_int)) begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								
							end
						8'h58 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == START) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								
							end
						8'hA8 :
							if (TWI_Mode == Ms_Md) begin
								
							end else begin
								if (TWI_state == DATA) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(TWCRn[6])begin
												if(sda_i_sync == 1'b0)begin // ACK
													TWCRn[7] <= 1'b1;
												end else begin // NOT ACK
													TWCRn[7] <= 1'b1;
												end
											end else begin
												if(sda_i_sync == 1'b0)begin // ACK
													TWCRn[7] <= 1'b1;
												end else begin // NOT ACK
													TWCRn[7] <= 1'b1;
												end
											end
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'hB0 :
							if (TWI_Mode == Ms_Md) begin
								
							end else begin
								if (TWI_state == DATA) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(TWCRn[6])begin
												if(sda_i_sync == 1'b0)begin // ACK
													TWCRn[7] <= 1'b1;
												end else begin // NOT ACK
													TWCRn[7] <= 1'b1;
												end
											end else begin
												if(sda_i_sync == 1'b0)begin // ACK
													TWCRn[7] <= 1'b1;
												end else begin // NOT ACK
													TWCRn[7] <= 1'b1;
												end
											end
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'hB8 :
							if (TWI_Mode == Ms_Md) begin
								
							end else begin
								if (TWI_state == DATA) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(TWCRn[6])begin
												if(sda_i_sync == 1'b0)begin // ACK
													TWCRn[7] <= 1'b1;
												end else begin // NOT ACK
													TWCRn[7] <= 1'b1;
												end
											end else begin
												if(sda_i_sync == 1'b0)begin // ACK
													TWCRn[7] <= 1'b1;
												end else begin // NOT ACK
													TWCRn[7] <= 1'b1;
												end
											end
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'hC0 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								if (TWI_state == ADDR) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(match_addr)begin
												if(TWDRn[0])begin	// read
													TWCRn[7] <= 1'b1;
												end else if(!TWDRn[0]) begin // write
													TWCRn[7] <= 1'b1;
												end
											end 
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'hC8 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								if (TWI_state == ADDR) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(match_addr)begin
												if(TWDRn[0])begin	// read
													TWCRn[7] <= 1'b1;
												end else if(!TWDRn[0]) begin // write
													TWCRn[7] <= 1'b1;
												end
											end 
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end		
							end
						8'h60 :
							if (TWI_Mode == Ms_Md) begin
								
							end else begin
								if (TWI_state == DATA) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(TWCRn[6])begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'h68 :
							if (TWI_Mode == Ms_Md) begin
								
							end else begin
								if (TWI_state == DATA) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(TWCRn[6])begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'h70 :
							if (TWI_Mode == Ms_Md) begin
								
							end else begin
								if (TWI_state == DATA) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(TWCRn[6])begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'h78 :
							if (TWI_Mode == Ms_Md) begin
								
							end else begin
								if (TWI_state == DATA) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(TWCRn[6])begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'h80 :
							if (TWI_Mode == Ms_Md) begin
								
							end else begin
								if (TWI_state == DATA) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync)) && !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(TWCRn[6])begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if(TWI_state == START) begin
									if(!scl_i&&scl_i_sync)begin
										TWCRn[7] <= 1'b1;
									end 
								end else if(TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end
							end
						8'h88 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								if (TWI_state == ADDR) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(match_addr)begin
												if(TWDRn[0])begin	// read
													TWCRn[7] <= 1'b1;
												end else if(!TWDRn[0]) begin // write
													TWCRn[7] <= 1'b1;
												end
											end 
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end		
							end
						8'h90 :
							if (TWI_Mode == Ms_Md) begin
								
							end else begin
								if (TWI_state == DATA) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(TWCRn[6])begin
												TWCRn[7] <= 1'b1;
											end else begin
												TWCRn[7] <= 1'b1;
											end
										end
									end
								end else if(TWI_state == START) begin
									if(!scl_i&&scl_i_sync)begin
										TWCRn[7] <= 1'b1;
									end 
								end else if(TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end
							end
						8'h98 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								if (TWI_state == ADDR) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(match_addr)begin
												if(TWDRn[0])begin	// read
													TWCRn[7] <= 1'b1;
												end else if(!TWDRn[0]) begin // write
													TWCRn[7] <= 1'b1;
												end
											end 
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end		
							end
						8'hA0 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								if (TWI_state == ADDR) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(match_addr)begin
												if(TWDRn[0])begin	// read
													TWCRn[7] <= 1'b1;
												end else if(!TWDRn[0]) begin // write
													TWCRn[7] <= 1'b1;
												end
											end 
										end
									end
								end	else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end	
							end
						8'hF8 :
							if (TWI_Mode == Ms_Md) begin
								if (TWI_state == START) begin
									if (scl_i && ((sda_i && !sda_i_sync))) begin
										TWCRn[7] <= 1'b1;
									end else if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end else if (TWI_state == STOP) begin
									if((clk_phase == 2'b11) && (clk_cnt == clk_div))begin
										TWCRn[7] <= 1'b1;
									end
								end
							end else begin
								if (TWI_state == ADDR) begin
									if (scl_i && ((!sda_i && sda_i_sync)||(sda_i && !sda_i_sync))&& !(Sl_bit_cnt==4'b0000)) begin
										TWCRn[7] <= 1'b1;
									end else if(!scl_i&&scl_i_sync)begin
										if(Sl_bit_cnt== 4'b1000)begin
											if(match_addr)begin
												if(TWDRn[0])begin	// read
													TWCRn[7] <= 1'b1;
												end else if(!TWDRn[0]) begin // write
													TWCRn[7] <= 1'b1;
												end
											end 
										end
									end
								end else if (TWI_state == STOP) begin
									TWCRn[7] <= 1'b1;
								end		
							end
						default :
							;
					endcase
					
					// if((status==8'h08 && TWI_state_delay ==START )
					// ||(status==8'h10 && TWI_state_delay ==START )
					// ||(status==8'h18 && TWI_state_delay ==ADDR )
					// ||(status==8'h20 && TWI_state_delay ==ADDR ) 
					// ||(status==8'h28 && TWI_state_delay ==DATA )
					// ||(status==8'h30 && TWI_state_delay ==DATA )
					// ||(status==8'h38 && TWI_state_delay ==ADDR )
					// ||(status==8'h38 && TWI_state_delay ==DATA )
					// ||(status==8'h40 && TWI_state_delay ==ADDR )
					// ||(status==8'h48 && TWI_state_delay ==ADDR )
					// ||(status==8'h50 && TWI_state_delay ==DATA )
					// ||(status==8'h58 && TWI_state_delay ==DATA )
					// ||(status==8'hA8 && TWI_state_delay ==ADDR )
					// ||(status==8'hB0 && TWI_state_delay ==ADDR )
					// ||(status==8'hB8 && TWI_state_delay ==DATA )
					// ||(status==8'hC0 && TWI_state_delay ==DATA )
					// ||(status==8'hC8 && TWI_state_delay ==DATA )
					// ||(status==8'h60 && TWI_state_delay ==ADDR )
					// ||(status==8'h68 && TWI_state_delay ==ADDR )
					// ||(status==8'h70 && TWI_state_delay ==ADDR )
					// ||(status==8'h78 && TWI_state_delay ==ADDR )
					// ||(status==8'h80 && TWI_state_delay ==DATA )
					// ||(status==8'h88 && TWI_state_delay ==DATA )
					// ||(status==8'h90 && TWI_state_delay ==DATA )
					// ||(status==8'h98 && TWI_state_delay ==DATA )
					// ||(status==8'hA0 && TWI_state_delay ==START )
					// ||(status==8'hA0 && TWI_state_delay ==STOP )
					// ||(status==8'h00 && !(TWI_state_delay ==IDLE) ))begin
						// TWCRn[7] <= 1'b1;
					// end 
				1'b1 :
					if (TwiIRQ_Ack == 1'b1 | ((ram_Addr == TWCRn_Address) && ramwe & (dbus_in[7] == 1'b1))) begin
						TWCRn[7] <= 1'b0;
					end
				default :
				;
			endcase
			
			case(TWCRn[4]) // TWSTOn
				1'b0 :
					if (((ram_Addr == TWCRn_Address) && ramwe & (dbus_in[4] == 1'b1))) begin
						TWCRn[4] <= 1'b1;
					end
				1'b1 :
					if (TWI_Mode==Ms_Md) begin
						if(TWI_state == STOP||status==8'h00)begin
							TWCRn[4] <= 1'b0;
						end
					end else begin
						if(status==8'h00)begin
							TWCRn[4] <= 1'b0;
						end
					end
				default :
				;
			endcase	
			
			case(TWCRn[3]) // TWWCn
				1'b0 :
					if (((ram_Addr == TWDRn_Address) && ramwe && !TWCRn[7])) begin
						TWCRn[3] <= 1'b1;
					end
				1'b1 :
					if (((ram_Addr == TWDRn_Address) && ramwe && !TWCRn[7])) begin
						TWCRn[3] <= 1'b0;
					end
				default :
				;
			endcase	
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : TWAMRn_REG
		if (!ireset) begin		// Reset
			// TWAMRn[7:1] <= 7'b0000000;
			TWAMRn <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == TWAMRn_Address && ramwe) begin
				TWAMRn[7:1] <= dbus_in[7:1];
			end
		end
	end
	
	assign clk_div =( TWSRn[1:0]== 2'b00) ? (15'h000F + {7'b0000000,TWBRn,1'b0}):
					( TWSRn[1:0]== 2'b01) ? (15'h000F + {5'b00000,TWBRn,3'b000}):
					( TWSRn[1:0]== 2'b10) ? (15'h000F + {3'b000,TWBRn,5'b00000}):
					(15'h0010 + {TWBRn,7'b0000000});
	
	always @(posedge cp2 or negedge ireset)
	begin : Clock_Cnt
		if (!ireset) begin		// Reset
			clk_cnt <= {15{1'b0}};
		end else begin		// Clock
			if(TWCRn[2])begin
				if(TWI_state==IDLE||TWI_Mode == Sl_Md)begin
					clk_cnt <= {15{1'b0}};
				end else begin 
					if(clk_cnt == clk_div)begin
						clk_cnt <= {15{1'b0}} ;
					end else begin
						clk_cnt <= clk_cnt + 1 ;
					end
				end
			end else begin
				clk_cnt <= {15{1'b0}};
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : phase_generator
		if (!ireset) begin		// Reset
			clk_tick <= 1'b0;
			clk_phase <= 2'b00;
		end else begin		// Clock
			if(TWCRn[2])begin
				if(TWI_state==IDLE)begin
					clk_tick <= 1'b0;
					clk_phase <= 2'b00;
				end else begin 
					if(TWI_Mode== Ms_Md)begin
						if((clk_cnt == {2'b00,clk_div[14:2]})||(clk_cnt == ({1'b0,clk_div[14:1]}))||(clk_cnt == ({1'b0,clk_div[14:1]}+{2'b00,clk_div[14:2]}))||(clk_cnt == clk_div))begin
							clk_tick <= 1'b1; 
							clk_phase <= clk_phase + 2'b01;
						end else begin
							clk_tick <= 1'b0;
							clk_phase <= clk_phase ;
						end
					end else begin
						clk_tick <= 1'b0;
						clk_phase <= 2'b00;
					end
				end
			end else begin
				clk_tick <= 1'b0;
				clk_phase <= 2'b00;
			end
		end
	end
	
	always @(*)
	begin : Clock_Gen
		if(TWCRn[2])begin
			case(TWI_state)
				IDLE:
					scl_int <= 1'b0;
				START: 
					scl_int <= 1'b1;
				ADDR:
					if(TWI_Mode== Ms_Md)begin
						if((clk_phase[1]==1'b1)&&(scl_i))begin
							scl_int <= 1'b1;
						end else begin
							scl_int <= 1'b0;
						end
					end else begin
						scl_int <= 1'b1;
					end
				DATA:
					if(TWI_Mode== Ms_Md)begin
						if((clk_phase[1]==1'b1)&&(scl_i))begin
							scl_int <= 1'b1;
						end else begin
							scl_int <= 1'b0;
						end
					end else begin
						scl_int <= 1'b1;
					end
				STOP:
					scl_int <= 1'b1;
				default :
					scl_int <= 1'b1;
			endcase
		end else begin
			scl_int <= 1'b1;
		end
	end
	
	assign scl_o = scl_int ; 
	
	always @(posedge cp2 or negedge ireset)
	begin : bit_count
		if (!ireset) begin		// Reset
			bit_cnt <= 4'b0000;
		end else begin		// Clock
			if(TWI_state==IDLE || TWI_state==START || TWI_Mode ==  Sl_Md)begin
				bit_cnt <= 4'b0000;
			end else begin
				if(clk_cnt == clk_div && bit_cnt == 4'b1000) begin
					bit_cnt <= 4'b0000;
				end else if((clk_cnt == clk_div)&&(scl_i))begin
					bit_cnt <= bit_cnt + 4'b0001;
				end else begin
					bit_cnt <= bit_cnt ;
				end
			end
		end
	end
	
	always @(*)
	begin : SDA_Gen
		if(TWCRn[2])begin
			case(TWI_state)
				IDLE:
					sda_int <= 1'b0;
				START: 
					if(TWI_Mode== Ms_Md)begin
						if((clk_phase==2'b11))begin
							sda_int <= 1'b0;
						end else begin
							sda_int <= 1'b1;
						end
					end else begin
						sda_int <= sda_i;
					end
				ADDR:
					if(TWI_Mode== Ms_Md)begin
						if(!(bit_cnt == 4'b1000))begin
							sda_int <= TWDRn[7];
						end else begin
							sda_int <= sda_i;
						end
					end else begin
						if(!(Sl_bit_cnt == 4'b1000))begin
							sda_int <= sda_i;
						end else begin
							sda_int <= !match_addr;
						end
					end
				DATA:
					if(TWI_Mode== Ms_Md)begin
						if((status==8'h18)
						||(status==8'h20)
						||(status==8'h28)
						||(status==8'h30))begin
							if(!(bit_cnt == 4'b1000))begin
								sda_int <= TWDRn[7];
							end else begin
								sda_int <= sda_i;
							end
						end else if((status==8'h40)
						||(status==8'h50))begin
							if(!(bit_cnt == 4'b1000))begin
								sda_int <= sda_i;
							end else begin
								sda_int <= !TWCRn[6];
							end
						end
					end else begin
						if((status==8'hA8)
						||(status==8'hB0)
						||(status==8'hB8))begin
							if(!(Sl_bit_cnt == 4'b1000))begin
								if(TWCRn[6])begin
									sda_int <= TWDRn[7];
								end else begin
									sda_int <= TWDRn[0];
								end
							end else begin
								sda_int <= sda_i;
							end
						end else if((status==8'h60)
						||(status==8'h68)
						||(status==8'h70)
						||(status==8'h78)
						||(status==8'h80)
						||(status==8'h90))begin
							if(!(Sl_bit_cnt == 4'b1000))begin
								sda_int <= sda_i;
							end else begin
								sda_int <= !TWCRn[6];
							end
						end
					end
				STOP:
					if(TWI_Mode== Ms_Md)begin
						if((clk_phase==2'b11))begin
							sda_int <= 1'b1;
						end else begin
							sda_int <= 1'b0;
						end
					end else begin
						sda_int <= sda_i;
					end
				default :
					sda_int <= 1'b1;
			endcase
		end else begin
			sda_int <= 1'b1;
		end
	end
	
	assign sda_o = sda_int ; 
	
	always @(posedge cp2)
	begin
		sda_i_sync <= sda_i;
		scl_i_sync <= scl_i;
		TWI_state_delay <= TWI_state ;
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : Slave_bit_count
		if (!ireset) begin		// Reset
			Sl_bit_cnt <= 4'b0000;
		end else begin		// Clock
			if(TWI_state==IDLE || TWI_state==START || TWI_Mode ==  Ms_Md)begin
				Sl_bit_cnt <= 4'b0000;
			end else begin
				if(!scl_i&&scl_i_sync && Sl_bit_cnt == 4'b1000) begin
					Sl_bit_cnt <= 4'b0000;
				end else if(!scl_i&&scl_i_sync)begin
					Sl_bit_cnt <= Sl_bit_cnt + 4'b0001;
				end else begin
					Sl_bit_cnt <= Sl_bit_cnt ;
				end
			end
		end
	end
	
	// assign TWI_Mode = (TWCRn[7:2]==6'b010001) ? Sl_Md : Ms_Md ;
	
	// always @(*)
	always @(posedge cp2 or negedge ireset)	
	begin : TWI_mode
		if (!ireset) begin		// Reset
			TWI_Mode <= Ms_Md ;	
		end else begin		// Clock
			if(TWCRn[2])begin
				case(TWI_state)
					IDLE:
						if(scl_i && (!sda_i && sda_i_sync))begin
							TWI_Mode <= Sl_Md ;
						end 
					START: 
						// if(TWI_Mode == Sl_Md)begin
							// TWI_Mode <= Ms_Md ;	
						// end
						;
					ADDR:
						if(TWI_Mode ==  Ms_Md)begin
							if((!sda_i && sda_o) && (scl_int) && (!(bit_cnt == 4'b1000)))begin
								TWI_Mode <= Sl_Md ;
							end
						end	
					DATA:
						// if(TWI_Mode == Sl_Md)begin
							// TWI_Mode <= Ms_Md ;	
						// end
						;
					STOP:
						if(TWI_Mode == Sl_Md)begin
							TWI_Mode <= Ms_Md ;	
						end 
					default :
						TWI_Mode <= Ms_Md ;	
				endcase
			end else begin
				TWI_Mode <= Ms_Md ;	
			end
		end
	end
	
	assign TwiIRQ = TWCRn[7] & TWCRn[0];
	
	always @(*) // ***********************************
	begin: OutMuxComb
		case (ram_Addr)
			TWBRn_Address :
				begin
					dbus_out <= TWBRn;
					out_en <= ramre;
				end
			TWSRn_Address :
				begin
					dbus_out <= TWSRn;
					out_en <= ramre;
				end
			TWARn_Address :
				begin
					dbus_out <= TWARn;
					out_en <= ramre;
				end
			TWDRn_Address :
				begin
					dbus_out <= TWDRn;
					out_en <= ramre;
				end
			TWCRn_Address :
				begin
					dbus_out <= TWCRn;
					out_en <= ramre;
				end
			TWAMRn_Address :
				begin
					dbus_out <= TWAMRn;
					out_en <= ramre;
				end
			default :
				begin
					dbus_out <= {8{1'b0}};
					out_en <= 1'b0;
				end
		endcase
	end
	
endmodule
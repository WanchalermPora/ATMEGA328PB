`timescale 1 ns / 1 ns
module USARTn
	#(
	parameter [11:0] UDRn_Address 	= 12'h0C6 ,
	parameter [11:0] UCSRnA_Address = 12'h0C0 ,
	parameter [11:0] UCSRnB_Address = 12'h0C1 ,
	parameter [11:0] UCSRnC_Address = 12'h0C2 ,
	parameter [11:0] UBRRnH_Address = 12'h0C5 ,
	parameter [11:0] UBRRnL_Address = 12'h0C4 ,
	parameter [5:0] RxcIRQ_Address = 6'h12 ,
	parameter [5:0] UdreIRQ_Address = 6'h13 ,
	parameter [5:0] TxcIRQ_Address = 6'h14 ,
	parameter [5:0] UStBIRQ_Address = 6'h1A
	)
	(
	input 					ireset,
	input					cp2,
	input [11:0]      		ram_Addr ,
	input            		ramre ,
	input            		ramwe ,	
	output reg          	out_en ,
	input [7:0]      		dbus_in ,
	output reg [7:0] 		dbus_out ,
	
	input  					DDR_XCKn ,
	output					UMSEL ,
	input 					XCKn_i ,
	output					XCKn_o ,
	
	input					RxDn_i ,
	output                  TxDn_o ,
	
	output wire				RXENn ,
	output wire				TXENn ,
	
	output wire      		TxcIRQ ,
	output wire      		RxcIRQ ,
	output wire      		UdreIRQ, 
	output wire      		UStBIRQ,
	
	input [5:0]		 		irqack_addr,
	input			 		irqack
	// input wire      		TxcIRQ_Ack ,
	// input wire      		RxcIRQ_Ack ,
	// input wire      		UdreIRQ_Ack 
	
	);
	
	reg [7:0]	UDRn ;
	reg [7:0]   UCSRnA ;
	reg [7:0] 	UCSRnB ;
	reg [7:0]	UCSRnC ;
	reg [11:0] 	UBRRn ;
	reg [3:0]	Temp ;
	reg 		XCK_int ;
	
	wire [2:0]	UCSZn ;
	reg 		rst_status ;
	
	localparam LP_SHIFTER_LEN = 9+1+1; 
	localparam LP_TX_SHIFTER_WIDTH = 10;
	
	reg [2:0]	rx_sync ;
	reg [3:0]	rx_bitcnt ;
	reg [LP_SHIFTER_LEN-1:0]	rx_sh_reg ;
	reg [LP_SHIFTER_LEN-1:0]	rx_sh_reg_mux ;
	wire		rx_filt ;
	reg [3:0] 	rx_baud_cnt ;
	wire 		rx_clk_en ;
	wire		rx_samp ;
	reg			rc_done ;
	wire 		rx_parity ;
	wire		disable_receiver;
	wire 		mpcm_adr_fl ;
	wire		rx_fifo_wr ;
	wire		rx_fifo_re ;
	wire[10:0]	rx_fifo_out ;
	wire		rx_fifo_empty;
	wire		rx_fifo_full;
	
	reg [3:0] 	tx_baud_cnt ;
	reg [3:0]	tx_bitcnt ;
	wire 		tx_clk_en ;
	wire		tx_samp ;
	reg         tx_samp_delay ;
	wire		tx_fal_e ;
	wire		tx_ris_e ;
	wire 		tx_fifo_wr ;
	wire		tx_fifo_re ;
	wire [LP_TX_SHIFTER_WIDTH-1:0]	tx_fifo_out;
	wire 		tx_parity ;
	reg [LP_TX_SHIFTER_WIDTH:0]		tx_sh_reg ;
	reg [LP_TX_SHIFTER_WIDTH-1:0] 	tx_reg_mux ;
	wire		tx_fifo_empty;
	wire		tx_fifo_full;
	reg        	tr_done ;
	reg 		tx_en_clk;
	
	wire 		rxb_txb_re ;
	wire		rxb_txb_we ;
	
	wire 		TxcIRQ_Ack ;
	wire 		RxcIRQ_Ack ;
	wire 		UdreIRQ_Ack ;
	wire 		UStBIRQ_Ack ;
	// localparam 	RC_ST_IDLE   = 4'h0,
				// RC_ST_START  = 4'h1,  // Start (ST)
				// RC_ST_B0     = 4'h2,  // Bit 0 
				// RC_ST_B1     = 4'h3,  // Bit 1
				// RC_ST_B2     = 4'h4,  // Bit 2
				// RC_ST_B3     = 4'h5,  // Bit 3
				// RC_ST_B4     = 4'h6,  // Bit 4
				// RC_ST_B5     = 4'h7,  // Bit 5				   
				// RC_ST_B6     = 4'h8,  // Bit [6]
				// RC_ST_B7     = 4'hA,  // Bit [7]
				// RC_ST_B8     = 4'hB,  // Bit [8]
				// RC_ST_P      = 4'hC,  // Bit [P]
				// RC_ST_SP     = 4'hD;  // Stop 1  	
	
	localparam 	RC_ST_IDLE   	= 2'b00,
				RC_ST_START  	= 2'b01,  // Start (ST)
				RC_ST_RECEIVE	= 2'b10;   // RECEIVE	

	reg	[1:0]	rc_state ;
	
	// localparam 	TR_ST_IDLE         = 4'h0,
				// TR_ST_START        = 4'h1,  // Start (ST)
				// TR_ST_B0           = 4'h2,  // Bit 0 
				// TR_ST_B1           = 4'h3,  // Bit 1
				// TR_ST_B2           = 4'h4,  // Bit 2
				// TR_ST_B3           = 4'h5,  // Bit 3
				// TR_ST_B4           = 4'h6,  // Bit 4
				// TR_ST_B5           = 4'h7,  // Bit 5				 
				// TR_ST_B6           = 4'h8,  // Bit [6]
				// TR_ST_B7           = 4'hA,  // Bit [7]
				// TR_ST_B8           = 4'hB,  // Bit [8]
				// TR_ST_P            = 4'hC,  // Bit [P]
				// TR_ST_SP1          = 4'hD,  // Stop 1  				 
				// TR_ST_SP2          = 4'hE,  // Stop 2	
				// TR_ST_WAIT_FOR_CTS = 4'hF;  // Wait for CTS (HW flow control support)
				
	localparam 	TR_ST_IDLE         = 1'b0,
				TR_ST_TRANSMIT     = 1'b1;  // Start (ST)
	
	reg  		tr_state ;

	assign RXENn = UCSRnB[4];
	assign TXENn = UCSRnB[3];
	assign UCSZn = {UCSRnB[2],UCSRnC[2:1]} ;
	assign UMSEL = UCSRnC[6];
	
	assign TxcIRQ_Ack = (irqack_addr == TxcIRQ_Address) && irqack ;
	assign RxcIRQ_Ack = (irqack_addr == RxcIRQ_Address) && irqack ;
	assign UdreIRQ_Ack = (irqack_addr == UdreIRQ_Address) && irqack ;
	assign UStBIRQ_Ack = (irqack_addr == UStBIRQ_Address) && irqack ;
	
	always @(negedge ireset or posedge cp2)
	begin : WR_UCSRnA_REG
		if (!ireset) begin		// Reset
			UCSRnA[6] <= 1'b0 ;
			UCSRnA[1:0] <= 2'b00 ;
		end else begin
			case(UCSRnA[6]) // TXCn
				1'b0 :
					if(tx_bitcnt == 4'b0000)begin
						UCSRnA[6] <= 1'b1;
					end
				1'b1 :
					if (TxcIRQ_Ack == 1'b1 | ((ram_Addr == UCSRnA_Address) && ramwe & (dbus_in[6] == 1'b1))) begin
						UCSRnA[6] <= 1'b0;
					end
				// default :
				// ;
			endcase
			case(UCSRnA[3]) // DORn
				1'b0 : 
					if(rc_done && rx_fifo_full && ((rc_state == RC_ST_START) && rx_samp && (rx_filt==2'b0))) begin
						UCSRnA[3] <= 1'b1; // <<<<<<<
					end
				1'b1 : 
					if(rx_fifo_re || ram_Addr == UCSRnA_Address && ramwe) begin
						UCSRnA[3] <= 1'b0; // Read of data register
					end
				// default : 
				// 	UCSRnA[3] <= 1'b0;
			endcase
			if (ram_Addr == UCSRnA_Address && ramwe) begin
				UCSRnA[1:0] <= dbus_in[1:0];
				rst_status <= 1'b1 ;
			end else if (ram_Addr == UCSRnA_Address && ramre) begin
			// end else begin
				rst_status <= 1'b0 ;
			end
		end	
	end
	
	always @(*)
	begin : STATUS
		if (!ireset) begin	// Reset
			UCSRnA[7] <= 1'b0 ; // RXCn
			UCSRnA[5] <= 1'b1 ; // UDREn
			UCSRnA[4] <= 1'b0 ; // FEn
			UCSRnA[2] <= 1'b0 ; // UPEn
		end else begin
			UCSRnA[7] <= ~rx_fifo_empty; // RXCn
			UCSRnA[5] <= ~tx_fifo_full; // UDREn
			if(rst_status)begin
				UCSRnA[4] <= 1'b0; // FEn
				UCSRnA[2] <= 1'b0; //UPEn
			end else begin
				UCSRnA[4] <= rx_fifo_out[10]; // FEn
				UCSRnA[2] <= rx_fifo_out[9]; //UPEn
			end
		end
	end
	
	always @(*)
	begin : Data_Register
		if (!ireset) begin	// Reset
			UDRn <= 8'b00000000 ;
		end else begin
			if ((ram_Addr == UDRn_Address) && ramre)begin
				UDRn <= UDRn ;
			end else begin
				UDRn <= rx_fifo_out[7:0] ;
			end
		end
	end
	
	always @(negedge ireset or posedge cp2)
	begin : WR_UCSRnB_REG
		if (!ireset) begin		// Reset
			UCSRnB[7:2] <= 6'b000000 ;
			UCSRnB[0] <= 1'b0 ;
		end else begin
			if (ram_Addr == UCSRnB_Address && ramwe) begin
				UCSRnB[7:2] <= dbus_in[7:2];
				UCSRnB[0] <= dbus_in[0];
			end
		end	
	end
	
	always @(negedge ireset or posedge cp2)
	begin : WR_UCSRnC_REG
		if (!ireset) begin		// Reset
			UCSRnC[7:0] <= 8'b00000110 ;
		end else begin
			if (ram_Addr == UCSRnC_Address && ramwe) begin
				UCSRnC[7:0] <= dbus_in[7:0];
			end
		end	
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : Temp_reg
		if (!ireset) begin		// Reset 
			Temp <= {4{1'b0}};
		end else begin
			if(ram_Addr == UBRRnH_Address && ramwe) begin
				Temp[3:0] <= dbus_in[3:0];
			end 
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : WR_USART_Baud_Rate
		if (!ireset) begin		// Reset
			UBRRn <= {12{1'b0}};
		end else begin
			if(ram_Addr == UBRRnL_Address && ramwe) begin
				UBRRn[7:0] <= dbus_in;
				UBRRn[11:8] <= Temp;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : Receive_State
		if (!ireset) begin		// Reset
			rc_state <= RC_ST_IDLE ;
		end else begin
			case(rc_state)
				RC_ST_IDLE :
					if(UCSRnC[7]==1'b0)begin
						if(rx_sync[1:0] == 2'b01)begin
							rc_state <= RC_ST_START ;
						end
					end else if (UCSRnC[7:6] == 2'b11) begin
						if(tx_fifo_empty == 1'b0)begin
							rc_state <= RC_ST_RECEIVE ;
						end
					end
				RC_ST_START : 
					if(rx_samp)begin
						if (rx_filt) begin
							rc_state <= RC_ST_IDLE ;
						end else begin
							rc_state <= RC_ST_RECEIVE ;
						end
					end
				RC_ST_RECEIVE :
					if(rx_bitcnt == 4'b0000)begin
						// rc_state <= RC_ST_STP ;
						rc_state <= RC_ST_IDLE ;
					end
				// RC_ST_STP :
					// if (UCSRnB[4] == 1'b0) begin
						// rc_state <= RC_ST_DISABLE ;
					// end	else if(rx_samp)begin
						// rc_state <= RC_ST_IDLE ;
						// // if(rx_filt)begin
							// // rc_state <= RC_ST_IDLE ;
						// // end else begin
							// // rc_state <= RC_ST_START ;
						// // end
					// end
				default :
					rc_state <= RC_ST_IDLE ;
			endcase
 		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : Receive_Done
		if (!ireset) begin	// Reset
			rc_done <= 1'b0;
		end else begin
			if (rc_state == RC_ST_RECEIVE) begin
				if(rx_bitcnt == 4'b0000)begin
					rc_done <= 1'b1;
				end else if (!tx_fifo_full) begin
					rc_done <= 1'b0;
				end
			end else begin
				if (!tx_fifo_full) begin
					rc_done <= 1'b0;
				end
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : Rx_sync_reg
		if (!ireset) begin	// Reset
			rx_sync <= {3{1'b1}};  
		end else begin // clock
			rx_sync[2] <=  RxDn_i ;
			if (rx_clk_en) begin
				rx_sync[1] <= rx_sync[2] ;
				rx_sync[0] <= rx_sync[1] ;
			end
		end
	end
	
	assign rx_filt = (rx_sync[1] & rx_sync[0]) | 
					 (rx_sync[2] & rx_sync[0]) | 
					 (rx_sync[2] & rx_sync[1]);
	
	always @(posedge cp2 or negedge ireset)
	begin : rx_baud_rate_gen
		if (!ireset) begin		// Reset
			rx_baud_cnt <= 4'b0000 ;
		end else begin
			if (rc_state == RC_ST_IDLE) begin
				rx_baud_cnt <= 4'b0000 ;
			end else begin
				if (rx_clk_en) begin
					rx_baud_cnt <= rx_baud_cnt + 4'b0001 ;
				end
			end
		end
	end
	
	assign rx_samp = (UCSRnA[1] && (UCSRnC[7:6] == 2'b00)) ? ((rx_baud_cnt[2:0] == 3'b101) && rx_clk_en):
					(!UCSRnA[1] && (UCSRnC[7:6] == 2'b00)) ? ((rx_baud_cnt == 4'b1001) && rx_clk_en):
					(DDR_XCKn && (UCSRnC[7:6] == 2'b01)) ? ((rx_baud_cnt[0] == 1'b0) && rx_clk_en) :
					1'b0 ;
	
	// always @(posedge cp2 or negedge ireset)
	always @(posedge cp2)
	begin : Receive_BitCnt
		if (rc_state == RC_ST_RECEIVE) begin
			if (UCSRnC[7]==1'b0) begin
				if(UCSRnC[6]==1'b0)begin
					if(rx_samp)begin
						rx_bitcnt <= rx_bitcnt - 4'b0001 ;
					end
				end else begin
					if(UCSRnC[0])begin
						if(tx_ris_e)begin
							rx_bitcnt <= rx_bitcnt - 4'b0001 ;
						end
					end else begin
						if(tx_fal_e)begin
							rx_bitcnt <= rx_bitcnt - 4'b0001 ;
						end
					end
				end
			end else begin
				case(UCSRnC[1:0])
					2'b00 :
						if(tx_ris_e)begin
							rx_bitcnt <= rx_bitcnt - 4'b0001 ;
						end
					2'b01 :
						if(tx_fal_e)begin
							rx_bitcnt <= rx_bitcnt - 4'b0001 ;
						end
					2'b10 :
						if(tx_fal_e)begin
							rx_bitcnt <= rx_bitcnt - 4'b0001 ;
						end
					2'b11 :
						if(tx_ris_e)begin
							rx_bitcnt <= rx_bitcnt - 4'b0001 ;
						end
					// default :
					// 	;
				endcase
			end
		end else begin
			if (UCSRnC[7]==1'b0) begin
				case(UCSZn)
					3'b000 :
						if (UCSRnC[5]) begin // Parity Mode
							rx_bitcnt <= 4'b0101 + 4'b0001 + 4'b0001; // 5b + Parity + Stop 
						end else begin
							rx_bitcnt <= 4'b0101 + 4'b0001; // 5b + Stop
						end
					3'b001 :
						if (UCSRnC[5]) begin // Parity Mode
							rx_bitcnt <= 4'b0110 + 4'b0001 + 4'b0001;  // 6b + Parity + Stop
						end else begin
							rx_bitcnt <= 4'b0110 + 4'b0001; // 6b + Stop
						end
					3'b010 :
						if (UCSRnC[5]) begin // Parity Mode
							rx_bitcnt <= 4'b0111 + 4'b0001 + 4'b0001; // 7b + Parity + Stop
						end else begin
							rx_bitcnt <= 4'b0111 + 4'b0001; // 7b + Stop
						end
					3'b011 :
						if (UCSRnC[5]) begin // Parity Mode
							rx_bitcnt <= 4'b1000 + 4'b0001 + 4'b0001; // 8b + Parity + Stop
						end else begin
							rx_bitcnt <= 4'b1000 + 4'b0001; // 8b + Stop
						end
					3'b111 :
						if (UCSRnC[5]) begin // Parity Mode
							rx_bitcnt <= 4'b1001 + 4'b0001 + 4'b0001; // 9b + Parity + Stop
						end else begin
							rx_bitcnt <= 4'b1001 + 4'b0001; // 9b + Stop
						end
					default :
						rx_bitcnt <= 4'b0000;
				endcase
			end else begin
				rx_bitcnt <= 4'b1000 ;
			end 
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : rx_shift_register
		if (!ireset) begin		// Reset
			rx_sh_reg <= 11'b00000000000 ;
		end else begin	// clock
			// if ((rc_state == RC_ST_RECEIVE) || (rc_state == RC_ST_STP)) begin
			if (rc_state == RC_ST_RECEIVE) begin
				if(UCSRnC[7]==1'b0)begin
					if(UCSRnC[6]==1'b0)begin
						if(rx_samp)begin
							rx_sh_reg <= {rx_filt,rx_sh_reg[10:1]} ;
						end else begin
							rx_sh_reg <= rx_sh_reg ;
						end
					end else begin
						if(UCSRnC[0])begin
							if(tx_ris_e)begin
								rx_sh_reg <= {rx_sync[2],rx_sh_reg[10:1]} ;
							end else begin
								rx_sh_reg <= rx_sh_reg ;
							end
						end else begin
							if(tx_fal_e)begin
								rx_sh_reg <= {rx_sync[2],rx_sh_reg[10:1]} ;
							end else begin
								rx_sh_reg <= rx_sh_reg ;
							end
						end
					end
				end else begin
					case(UCSRnC[1:0])
						2'b00 :
							if(tx_ris_e)begin
								rx_sh_reg <= {rx_sync[2],rx_sh_reg[10:1]} ;
							end else begin
								rx_sh_reg <= rx_sh_reg ;
							end
						2'b01 :
							if(tx_fal_e)begin
								rx_sh_reg <= {rx_sync[2],rx_sh_reg[10:1]} ;
							end else begin
								rx_sh_reg <= rx_sh_reg ;
							end
						2'b10 :
							if(tx_fal_e)begin
								rx_sh_reg <= {rx_sync[2],rx_sh_reg[10:1]} ;
							end else begin
								rx_sh_reg <= rx_sh_reg ;
							end
						2'b11 :
							if(tx_ris_e)begin
								rx_sh_reg <= {rx_sync[2],rx_sh_reg[10:1]} ;
							end else begin
								rx_sh_reg <= rx_sh_reg ;
							end
						// default :
						// 	;
					endcase
				end
			end
		end
	end
	
	xor(rx_parity,rx_sh_reg_mux[8],rx_sh_reg_mux[7],rx_sh_reg_mux[6],rx_sh_reg_mux[5],rx_sh_reg_mux[4],rx_sh_reg_mux[3],rx_sh_reg_mux[2],rx_sh_reg_mux[1],rx_sh_reg_mux[0],UCSRnC[4]);
	
	always@(*)
	begin : rx_mux_register
		// Shifter output
		//                10 9 8 7 6 5 4 3 2 1 0
		// 5b              S 4 3 2 1 0 x x x x x
		// 5b + P          S P 4 3 2 1 0 x x x x          
		// 6b              S 5 4 3 2 1 0 x x x x
		// 6b + P          S P 5 4 3 2 1 0 x x x
		// 7b              S 6 5 4 3 2 1 0 x x x
		// 7b + P          S P 6 5 4 3 2 1 0 x x
		// 8b              S 7 6 5 4 3 2 1 0 x x 
		// 8b + P          S P 7 6 5 4 3 2 1 0 x 
		// 9b              S 8 7 6 5 4 3 2 1 0 x 
		// 9b + P          S P 8 7 6 5 4 3 2 1 0
		
		if (UCSRnC[7]==1'b0) begin
			rx_sh_reg_mux[10]  <= ~rx_sh_reg[10]; // Frame Error
			
			case(UCSRnC[5:4])
				2'b00 :
					rx_sh_reg_mux[9] <= 1'b0 ;
				2'b01 :
					rx_sh_reg_mux[9] <= 1'b0 ;
				2'b10 :
					rx_sh_reg_mux[9] <= ~(rx_parity==rx_sh_reg[9]) ;
				2'b11 :
					rx_sh_reg_mux[9] <= ~(rx_parity==rx_sh_reg[9]) ;
				// default :
				//  ;
			endcase
			
			case(UCSZn)
				3'b000 :
					if (UCSRnC[5]) begin // Parity Mode
						rx_sh_reg_mux[4:0] <= rx_sh_reg[8:4];  // 5b + Parity + Stop
						rx_sh_reg_mux[8:5] <= {4{1'b0}};				
					end else begin
						rx_sh_reg_mux[4:0] <= rx_sh_reg[9:5];  // 5b + Stop
						rx_sh_reg_mux[8:5] <= {4{1'b0}};	
					end
				3'b001 :
					if (UCSRnC[5]) begin // Parity Mode
						rx_sh_reg_mux[5:0] <= rx_sh_reg[8:3];  // 6b + Parity + Stop
						rx_sh_reg_mux[8:6] <= {3{1'b0}};	
					end else begin
						rx_sh_reg_mux[5:0] <= rx_sh_reg[9:4];  // 6b + Stop
						rx_sh_reg_mux[8:6] <= {3{1'b0}};	
					end
				3'b010 :
					if (UCSRnC[5]) begin // Parity Mode
						rx_sh_reg_mux[6:0] <= rx_sh_reg[8:2];  // 7b + Parity + Stop
						rx_sh_reg_mux[8:7] <= {2{1'b0}};	
					end else begin
						rx_sh_reg_mux[6:0] <= rx_sh_reg[9:3];  // 7b + Stop
						rx_sh_reg_mux[8:7] <= {2{1'b0}};	
					end
				3'b011 :
					if (UCSRnC[5]) begin // Parity Mode
						rx_sh_reg_mux[7:0] <= rx_sh_reg[8:1]; // 8b + Parity + Stop
						rx_sh_reg_mux[8] <= 1'b0;	
					end else begin
						rx_sh_reg_mux[7:0] <= rx_sh_reg[9:2]; // 8b + Stop
						rx_sh_reg_mux[8] <= 1'b0;	
					end
				3'b111 :
					if (UCSRnC[5]) begin // Parity Mode
						rx_sh_reg_mux[8:0] <= rx_sh_reg[8:0]; // 9b + Parity + Stop
					end else begin
						rx_sh_reg_mux[8:0] <= rx_sh_reg[9:1]; // 9b + Stop
					end
				default :
					rx_sh_reg_mux[8:0] <= 9'b000000000;
			endcase
		end else begin
			if(UCSRnC[2])begin
				rx_sh_reg_mux[7:0] <= rx_sh_reg[10:3] ;
				rx_sh_reg_mux[10:8] <= 3'b000;
			end else begin
				rx_sh_reg_mux[7:0] <= {rx_sh_reg[3],rx_sh_reg[4],rx_sh_reg[5],rx_sh_reg[6],rx_sh_reg[7],rx_sh_reg[8],rx_sh_reg[9],rx_sh_reg[10]} ;
				rx_sh_reg_mux[10:8] <= 3'b000;
			end
		end
	end
	
	always@(posedge cp2 or negedge ireset)
	begin : rx_comb
		if (!ireset) begin		// Reset
			UCSRnB[1] <=  0 ;
		end else begin
			// UDRn <= rx_fifo_out[7:0] ;
			UCSRnB[1] <= rx_fifo_out[8] ;
		end
	end 
	
	// Allows write data to the RX FIFO in two cases
	// 1. MPCM is zero.  
	// 2. MPCM is high and the last received data bit is one (address frame) 
	assign mpcm_adr_fl = (UCSRnA[0]) ? ((UCSRnC[5]) ? rx_sh_reg[8] : rx_sh_reg[9]) : 1'b1;
	assign disable_receiver = UCSRnB[4] & ((ram_Addr == UCSRnA_Address) && ramwe & (dbus_in[4] == 1'b0));
	assign rx_fifo_wr = (tx_fifo_full == 1'b0) && mpcm_adr_fl && rc_done ;
	assign rxb_txb_re = ((ram_Addr == UDRn_Address) && ramre) ;
	
	USART_Clk #(
		.SYNC_RST ( 0 )
		) 
	USART_Clk_inst(
		.nrst       	(ireset),
		.clk        	(cp2),
		.bsel       	(UBRRn),
		// .bscale     (baudctrlb_dout[7:4]),
		.change_cfg 	(((ram_Addr == UBRRnL_Address) && ramwe)),
		.rxen       	(UCSRnB[4]),
		.txen       	((tx_en_clk)||(UCSRnB[4]&&UCSRnC[6])),
		.clr_tx_cnt 	((tr_state == TR_ST_IDLE)), 
		.rx_clk_en_o  	(rx_clk_en),
		.tx_clk_en_o  	(tx_clk_en)
		);
	
	assign rx_fifo_re = rxb_txb_re & UCSRnB[4]; // Read enable for RX FIFO
	
	FIFO #(
		.DEPTH    ( 2 ),
		.WIDTH    ( LP_SHIFTER_LEN),
		.SYNC_OUT ( 0 )
		) 
	FIFO_rx_inst(
		.ireset	       	(ireset),
		.cp2	       	(cp2),
		.din	       	(rx_sh_reg_mux), 
		.we	       		(rx_fifo_wr), // ????
		.re	       		(rx_fifo_re), 
		.flush         	(disable_receiver), // Flush FIFO
		.dout	       	(rx_fifo_out),
		.full        	(rx_fifo_full),
		// .almost_full 	(rx_fifo_almost_full),
		.empty       	(rx_fifo_empty)
		);
	
	always @(posedge cp2 or negedge ireset)
	begin : Transmit_State
		if (!ireset) begin		// Reset
			tr_state <= TR_ST_IDLE ;
		end else begin
			case(tr_state)
				TR_ST_IDLE :
					if(tx_fifo_empty == 1'b0)begin
						// tr_state <= TR_ST_START ;
						tr_state <= TR_ST_TRANSMIT;
					end
				// TR_ST_START : 
					// if () begin
						// tr_state <= TR_ST_TRANSMIT;
					// end
				TR_ST_TRANSMIT :
					if(tx_bitcnt == 4'b0000)begin
						// rc_state <= RC_ST_STP ;
						tr_state <= TR_ST_IDLE ;
					end
				// RC_ST_STP :
					// if (UCSRnB[4] == 1'b0) begin
						// rc_state <= RC_ST_DISABLE ;
					// end	else if(rx_samp)begin
						// rc_state <= RC_ST_IDLE ;
						// // if(rx_filt)begin
							// // rc_state <= RC_ST_IDLE ;
						// // end else begin
							// // rc_state <= RC_ST_START ;
						// // end
					// end
				// default :
				// 	tr_state <= TR_ST_IDLE ;
			endcase
 		end
	end
	
	always@(*)
	begin : tx_enable_clk
		if (UCSRnB[3]) begin
			tx_en_clk <=  1'b1;
		end else if (tx_fifo_empty) begin
			tx_en_clk <=  1'b0;
		end else begin
			tx_en_clk <= tx_en_clk ;
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : Transmit_Done
		if (!ireset) begin	// Reset
			tr_done <= 1'b0;
		end else begin
			if (tr_state == TR_ST_TRANSMIT) begin
				if(tx_bitcnt == 4'b0000)begin
					tr_done <= 1'b1;
				end else begin
					tr_done <= 1'b0;
				end
			end else begin
				tr_done <= 1'b0;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : tx_shift_register
		if (!ireset) begin		// Reset
			tx_sh_reg <= 11'b11111111111 ;
		end else begin	// clock
			// if ((rc_state == RC_ST_RECEIVE) || (rc_state == RC_ST_STP)) begin
			if (tr_state == TR_ST_IDLE) begin
				if (UCSRnC[7]==1'b0) begin
					tx_sh_reg <= {tx_fifo_out,1'b0} ;
				end else begin 
					tx_sh_reg <= {1'b1,tx_fifo_out} ;
				end
			end else if (tr_state == TR_ST_TRANSMIT) begin
				if (UCSRnC[7]==1'b0) begin
					if(UCSRnC[6]==1'b0)begin
						if (tx_samp) begin
							tx_sh_reg <= {1'b1,tx_sh_reg[10:1]};
						end else begin
							tx_sh_reg <= tx_sh_reg ;
						end
					end else begin
						if(UCSRnC[0])begin
							if(tx_fal_e)begin
								tx_sh_reg <= {1'b1,tx_sh_reg[10:1]};
							end else begin
								tx_sh_reg <= tx_sh_reg ;
							end
						end else begin
							if(tx_ris_e)begin
								tx_sh_reg <= {1'b1,tx_sh_reg[10:1]};
							end else begin
								tx_sh_reg <= tx_sh_reg ;
							end
						end
					end
				end else begin
					case(UCSRnC[1:0])
						2'b00 :
							if(tx_fal_e)begin
								tx_sh_reg <= {1'b1,tx_sh_reg[10:1]};
							end else begin
								tx_sh_reg <= tx_sh_reg ;
							end
						2'b01 :
							if(tx_ris_e)begin
								tx_sh_reg <= {1'b1,tx_sh_reg[10:1]};
							end else begin
								tx_sh_reg <= tx_sh_reg ;
							end
						2'b10 :
							if(tx_ris_e)begin
								tx_sh_reg <= {1'b1,tx_sh_reg[10:1]};
							end else begin
								tx_sh_reg <= tx_sh_reg ;
							end
						2'b11 :
							if(tx_fal_e)begin
								tx_sh_reg <= {1'b1,tx_sh_reg[10:1]};
							end else begin
								tx_sh_reg <= tx_sh_reg ;
							end
						// default :
						// 	;
					endcase
				end
			end
		end
	end
	
	// assign TxDn_o = (tr_state == TR_ST_TRANSMIT) ? tx_sh_reg[0] : 1'b1;
	assign TxDn_o = (tr_state == TR_ST_TRANSMIT) ? tx_sh_reg[0] : UCSRnB[3];
	
	always@(*)
	begin : tx_mux_register
		if ((UCSRnC[7:6]==2'b00)||(DDR_XCKn && (UCSRnC[7:6] == 2'b01))) begin
			case(UCSZn)
				3'b000 :
					// tx_reg_mux[4:0] <= dbus_in[4:0];
					if ( UCSRnC[5] ) begin // Parity Mode
						tx_reg_mux[4:0] <= dbus_in[4:0];
						// xor(tx_reg_mux[5],tx_reg_mux[4],tx_reg_mux[3],tx_reg_mux[2],tx_reg_mux[1],tx_reg_mux[0],UCSRnC[4]);
						tx_reg_mux[5] <= tx_reg_mux[4]^tx_reg_mux[3]^tx_reg_mux[2]^tx_reg_mux[1]^tx_reg_mux[0]^UCSRnC[4] ;
						tx_reg_mux[9:6] <= {4{1'b1}};
					end else begin
						tx_reg_mux[4:0] <= dbus_in[4:0];
						tx_reg_mux[9:5] <= {5{1'b1}};	
					end
				3'b001 :
					// tx_reg_mux[5:0] = dbus_in[5:0];
					if (UCSRnC[5]) begin // Parity Mode
						tx_reg_mux[5:0] <= dbus_in[5:0];
						// xor(tx_reg_mux[6],tx_reg_mux[5],tx_reg_mux[4],tx_reg_mux[3],tx_reg_mux[2],tx_reg_mux[1],tx_reg_mux[0],UCSRnC[4]);
						tx_reg_mux[6] <= tx_reg_mux[5]^tx_reg_mux[4]^tx_reg_mux[3]^tx_reg_mux[2]^tx_reg_mux[1]^tx_reg_mux[0]^UCSRnC[4] ;
						tx_reg_mux[9:7] <= {3{1'b1}};	
					end else begin
						tx_reg_mux[5:0] <= dbus_in[5:0];
						tx_reg_mux[9:6] <= {4{1'b1}};
					end
				3'b010 :
					// tx_reg_mux[6:0] = dbus_in[6:0];
					if (UCSRnC[5]) begin // Parity Mode
						tx_reg_mux[6:0] <= dbus_in[6:0];
						// xor(tx_reg_mux[7],tx_reg_mux[6],tx_reg_mux[5],tx_reg_mux[4],tx_reg_mux[3],tx_reg_mux[2],tx_reg_mux[1],tx_reg_mux[0],UCSRnC[4]);
						tx_reg_mux[7] <= tx_reg_mux[6]^tx_reg_mux[5]^tx_reg_mux[4]^tx_reg_mux[3]^tx_reg_mux[2]^tx_reg_mux[1]^tx_reg_mux[0]^UCSRnC[4] ;
						tx_reg_mux[9:8] <= {2{1'b1}};	
					end else begin
						tx_reg_mux[6:0] <= dbus_in[6:0];
						tx_reg_mux[9:7] <= {3{1'b1}};
					end
				3'b011 :
					// tx_reg_mux[7:0] = dbus_in[7:0];
					if (UCSRnC[5]) begin // Parity Mode
						tx_reg_mux[7:0] <= dbus_in[7:0];
						// xor(tx_reg_mux[8],tx_reg_mux[7],tx_reg_mux[6],tx_reg_mux[5],tx_reg_mux[4],tx_reg_mux[3],tx_reg_mux[2],tx_reg_mux[1],tx_reg_mux[0],UCSRnC[4]);
						tx_reg_mux[8] <= tx_reg_mux[7]^tx_reg_mux[6]^tx_reg_mux[5]^tx_reg_mux[4]^tx_reg_mux[3]^tx_reg_mux[2]^tx_reg_mux[1]^tx_reg_mux[0]^UCSRnC[4] ;
						tx_reg_mux[9] <= 1'b1;	
					end else begin
						tx_reg_mux[7:0] <= dbus_in[7:0];
						tx_reg_mux[9:8] <= {2{1'b1}};
					end
				3'b111 :
					// tx_reg_mux[8:0] = {UCSRnB[0],dbus_in[7:0]};
					if (UCSRnC[5]) begin // Parity Mode
						tx_reg_mux[8:0] <= {UCSRnB[0],dbus_in[7:0]};
						// xor(tx_reg_mux[9],tx_reg_mux[8],tx_reg_mux[7],tx_reg_mux[6],tx_reg_mux[5],tx_reg_mux[4],tx_reg_mux[3],tx_reg_mux[2],tx_reg_mux[1],tx_reg_mux[0],UCSRnC[4]);
						tx_reg_mux[9] <= tx_reg_mux[8]^tx_reg_mux[7]^tx_reg_mux[6]^tx_reg_mux[5]^tx_reg_mux[4]^tx_reg_mux[3]^tx_reg_mux[2]^tx_reg_mux[1]^tx_reg_mux[0]^UCSRnC[4] ;
					end else begin
						tx_reg_mux[8:0] <= {UCSRnB[0],dbus_in[7:0]};
						tx_reg_mux[9] <= 1'b1;
					end
				default :
					tx_reg_mux[9:0] <= 10'b1111111111;
			endcase
		end else begin
			if(UCSRnC[2])begin
				tx_reg_mux[7:0] <= dbus_in[7:0];
				tx_reg_mux[9:8] <= {2{1'b1}};
			end else begin
				tx_reg_mux[7:0] <= {dbus_in[0],dbus_in[1],dbus_in[2],dbus_in[3],dbus_in[4],dbus_in[5],dbus_in[6],dbus_in[7]};
				tx_reg_mux[9:8] <= {2{1'b1}};
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin : tx_baud_rate_gen
		if (!ireset) begin		// Reset
			tx_baud_cnt <= 4'b0000 ;
		end else begin
			if (tr_state == TR_ST_IDLE) begin
				tx_baud_cnt <= 4'b0000 ;
			end else begin
				if (tx_clk_en) begin
					tx_baud_cnt <= tx_baud_cnt + 4'b0001 ;
				end
			end
		end
	end
	
	assign tx_samp = (UCSRnA[1] && (UCSRnC[7:6] == 2'b00)) ? ((tx_baud_cnt[2:0] == 3'b111) && tx_clk_en):
					(!UCSRnA[1] && (UCSRnC[7:6] == 2'b00)) ? ((tx_baud_cnt == 4'b1111) && tx_clk_en):
					(DDR_XCKn && UCSRnC[1] && (UCSRnC[7:6] == 2'b11)) ? (tx_baud_cnt[0] == UCSRnC[0]):
					(DDR_XCKn && !UCSRnC[1] && (UCSRnC[7:6] == 2'b11)) ? (tx_baud_cnt[0] == !UCSRnC[0]):
					(DDR_XCKn && (UCSRnC[7:6] == 2'b01)) ? (tx_baud_cnt[0] == 1'b1):
					(!DDR_XCKn && (UCSRnC[6] == 1'b1)) ? XCK_int :
					1'b0 ;
	
	assign XCKn_o = (tr_state == TR_ST_IDLE) ? UCSRnC[0] : tx_samp ;
	
	always @(posedge cp2)
	begin : tx_sample_delay
		tx_samp_delay <= tx_samp ;
	end
	
	always @(posedge cp2)
	begin : XCKn_sync
		XCK_int <= XCKn_i ;
	end
	
	assign tx_fal_e = tx_samp_delay & ~tx_samp ;
	assign tx_ris_e = ~tx_samp_delay & tx_samp ;
	
	// always @(posedge cp2 or negedge ireset)
	always @(posedge cp2)
	begin : Transmit_BitCnt
		if (tr_state == TR_ST_TRANSMIT) begin
			if (UCSRnC[7]==1'b0) begin
				if(UCSRnC[6]==1'b0)begin
					if(tx_samp)begin
						tx_bitcnt <= tx_bitcnt - 4'b0001 ;
					end 
				end else begin
					if(UCSRnC[0])begin
						if(tx_fal_e)begin
							tx_bitcnt <= tx_bitcnt - 4'b0001 ;
						end
					end else begin
						if(tx_ris_e)begin
							tx_bitcnt <= tx_bitcnt - 4'b0001 ;
						end
					end
				end
			end else begin
				case(UCSRnC[1:0])
					2'b00 :
						if(tx_fal_e)begin
							tx_bitcnt <= tx_bitcnt - 4'b0001 ;
						end 
					2'b01 :
						if(tx_ris_e)begin
							tx_bitcnt <= tx_bitcnt - 4'b0001 ;
						end 
					2'b10 :
						if(tx_ris_e)begin
							tx_bitcnt <= tx_bitcnt - 4'b0001 ;
						end 
					2'b11 :
						if(tx_fal_e)begin
							tx_bitcnt <= tx_bitcnt - 4'b0001 ;
						end 
					// default :
					// 	;
				endcase
			end
		end else begin
			if (UCSRnC[7]==1'b0) begin
				case(UCSZn)
					3'b000 :
						tx_bitcnt <= 4'b0101 + 4'b0001 + 4'b0001 + {3'b000,UCSRnC[5]} + {3'b000,UCSRnC[3]}; // Start + 5b + (Parity) + Stop1 + (Stop2) 
					3'b001 :
						tx_bitcnt <= 4'b0110 + 4'b0001 + 4'b0001 + {3'b000,UCSRnC[5]} + {3'b000,UCSRnC[3]}; // Start + 6b + (Parity) + Stop + (Stop2)
					3'b010 :
						tx_bitcnt <= 4'b0111 + 4'b0001 + 4'b0001 + {3'b000,UCSRnC[5]} + {3'b000,UCSRnC[3]}; // Start + 7b + (Parity) + Stop + (Stop2)
					3'b011 :
						tx_bitcnt <= 4'b1000 + 4'b0001 + 4'b0001 + {3'b000,UCSRnC[5]} + {3'b000,UCSRnC[3]}; // Start + 8b + (Parity) + Stop + (Stop2)
					3'b111 :
						tx_bitcnt <= 4'b1001 + 4'b0001 + 4'b0001 + {3'b000,UCSRnC[5]} + {3'b000,UCSRnC[3]}; // Start + 9b + (Parity) + Stop + (Stop2)
					default :
						tx_bitcnt <= 4'b0000;
				endcase
			end else begin
				tx_bitcnt <= 4'b1000 ;
			end 
		end
	end
	
	assign rxb_txb_we = ((ram_Addr == UDRn_Address) && ramwe) ;
	assign tx_fifo_wr = rxb_txb_we & UCSRnB[3]; // write enable for TX FIFO
	assign tx_fifo_re = ((tr_state == TR_ST_IDLE) && UCSRnB[3] );
	
	FIFO #(
		.DEPTH    ( 1 ),
		.WIDTH    ( LP_TX_SHIFTER_WIDTH),
		.SYNC_OUT ( 1 )
		) 
	FIFO_tx_inst(
		.ireset	       	(ireset),
		.cp2	       	(cp2),
		.din	       	(tx_reg_mux), 
		.we	       		(tx_fifo_wr), // ????
		.re	       		(tx_fifo_re), 
		.flush         	(1'b0), // Flush FIFO
		.dout	       	(tx_fifo_out),
		.full        	(tx_fifo_full),
		// .almost_full 	(tx_fifo_almost_full),
		.empty       	(tx_fifo_empty)
		);
	
	always @(*)
	begin: OutMuxComb
		case (ram_Addr)
			UCSRnA_Address :
				begin
					dbus_out <= UCSRnA;
					out_en <= ramre;
				end
			UCSRnB_Address :
				begin
					dbus_out <= {UCSRnB[7:2],rx_fifo_out[8],UCSRnB[0]};
					out_en <= ramre;
				end
			UCSRnC_Address :
				begin
					dbus_out <= UCSRnC;
					out_en <= ramre;
				end
			UBRRnH_Address :
				begin
					dbus_out <= {4'b0000,UBRRn[11:8]};
					out_en <= ramre;
				end
			UBRRnL_Address :
				begin
					dbus_out <= UBRRn[7:0];
					out_en <= ramre;
				end	
			UDRn_Address :
				begin
					dbus_out <= UDRn ;
					out_en <= ramre;
				end
			default :
				begin
					dbus_out <= {8{1'b0}};
					out_en <= 1'b0;
				end
		endcase
    end
	
	assign RxcIRQ	= UCSRnB[7] && UCSRnA[7] ;
	assign TxcIRQ   = UCSRnB[6] && UCSRnA[6] ;
	assign UdreIRQ	= UCSRnB[5] && UCSRnA[5] ;
	assign UStBIRQ  = 1'b0 ;
	
endmodule
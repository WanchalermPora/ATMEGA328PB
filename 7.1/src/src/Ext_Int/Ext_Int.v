`timescale 1 ns / 1 ns
module EXTINT
	#(
	parameter [11:0] EICRA_Address = 12'h069 ,
	parameter [11:0] PCICR_Address = 12'h068 ,
	parameter [11:0] PCMSK3_Address = 12'h073 ,
	parameter [11:0] PCMSK2_Address = 12'h06D ,
	parameter [11:0] PCMSK1_Address = 12'h06C ,
	parameter [11:0] PCMSK0_Address = 12'h06B ,
	
	parameter [5:0]  EIFR_Address  = 6'h1C ,
	parameter [5:0]  PCIFR_Address = 6'h1B ,
	parameter [5:0]  EIMSK_Address = 6'h1D ,
	
	parameter [5:0] ExtInt0IRQ_Address = 6'h01 ,
	parameter [5:0] ExtInt1IRQ_Address = 6'h02 ,
	parameter [5:0] PCInt0IRQ_Address = 6'h03 ,
	parameter [5:0] PCInt1IRQ_Address = 6'h04 ,
	parameter [5:0] PCInt2IRQ_Address = 6'h05 ,
	parameter [5:0] PCInt3IRQ_Address = 6'h1B 
	)
	(
	input 					ireset,
	input					cp2,
	input [5:0]      		IO_Addr ,
	input            		iore ,
	input            		iowe ,	
	input [11:0]      		ram_Addr ,
	input            		ramre ,
	input            		ramwe ,	
	output reg          	out_en ,
	input [7:0]      		dbus_in ,
	output reg [7:0] 		dbus_out ,
	
	// IRQ
	output wire             ExtInt0IRQ,
	output wire             ExtInt1IRQ,
	output wire             PCInt0IRQ,
	output wire             PCInt1IRQ,
	output wire             PCInt2IRQ,
	output wire             PCInt3IRQ,
	
	input [5:0]		 		irqack_addr,
	input			 		irqack,		
	
	input					EXTINT0,
	input					EXTINT1,
	
	input [27:0]			INT,					
	
	output wire				PCIE0,
	output wire				PCIE1,
	output wire				PCIE2,
	output wire				PCIE3,
	
	output wire				INT0_EN,
	output wire				INT1_EN,
	
	output wire [27:0]		PCINT
	);
	
	wire				ExtInt0IRQ_Ack;
	wire				ExtInt1IRQ_Ack;
	wire				PCInt0IRQ_Ack;
	wire				PCInt1IRQ_Ack;
	wire				PCInt2IRQ_Ack;
	wire				PCInt3IRQ_Ack;

	wire 				ExtInt0_Fl	;
	wire 				ExtInt1_Fl	;

	reg [7:0]			EICRA;
	reg [7:0]			EIMSK;
	reg [7:0]			EIFR;
	reg [7:0]			PCICR;
	reg [7:0]			PCIFR;
	reg [7:0]			PCMSK3;
	reg [7:0]			PCMSK2;
	reg [7:0]			PCMSK1;
	reg [7:0]			PCMSK0;
	
	reg 				pcint3_sync ;
	reg 				pcint3_setflag ;
	
	reg 				pcint2_sync ;
	reg 				pcint2_setflag ;
	
	reg 				pcint1_sync ;
	reg 				pcint1_setflag ;
	
	reg 				pcint0_sync ;
	reg 				pcint0_setflag ;
	
	reg 				EXTINT0_delay;
	reg 				EXTINT1_delay;
	
	wire [27:0]			PCINT_int ;
	wire [27:0]			INT_sync ;
	wire [27:0]			pcint_in ;
	
	assign INT1_EN = EIMSK[1] ;
	assign INT0_EN = EIMSK[0] ;
	assign PCIE3 = PCICR[3] ;
	assign PCIE2 = PCICR[2] ;
	assign PCIE1 = PCICR[1] ;
	assign PCIE0 = PCICR[0] ;
	
	assign PCINT_int = {PCMSK3[3:0],PCMSK2[7:0],1'b0,PCMSK1[6:0],PCMSK0[7:0]} ;
	assign PCINT = PCINT_int ;
	
	assign ExtInt1IRQ_Ack = (irqack_addr == ExtInt1IRQ_Address) && irqack ;
	assign ExtInt0IRQ_Ack = (irqack_addr == ExtInt0IRQ_Address) && irqack ;
	assign PCInt3IRQ_Ack = (irqack_addr == PCInt3IRQ_Address) && irqack ;
	assign PCInt2IRQ_Ack = (irqack_addr == PCInt2IRQ_Address) && irqack ;
	assign PCInt1IRQ_Ack = (irqack_addr == PCInt1IRQ_Address) && irqack ;
	assign PCInt0IRQ_Ack = (irqack_addr == PCInt0IRQ_Address) && irqack ;
	
	synchronizer #(
		.p_width     (28)
	)
	synchronizer_tn0_inst(
		.clk   (cp2),
		.d_in  (INT),
		.d_sync(INT_sync)
	);
	
	assign pcint_in = (INT ^ INT_sync) & PCINT_int ;
	
	always @(negedge ireset or posedge cp2)
	begin : EICRA_REG
		if (!ireset) begin		// Reset
			EICRA <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == EICRA_Address && ramwe) begin
				EICRA[3:0] <= dbus_in[3:0];
			end
		end
	end

	always @(negedge ireset or posedge cp2)
	begin : EIMSK_REG
		if (!ireset) begin		// Reset
			EIMSK <= {8{1'b0}};
		end else begin		// Clock
			if (IO_Addr == EIMSK_Address && iowe) begin
				EIMSK[1:0] <= dbus_in[1:0];
			end
		end
	end

	always @(negedge ireset or posedge cp2)
	begin : EIFR_REG
		if (!ireset) begin		// Reset
			EIFR <= {8{1'b0}};
		end else begin		// Clock
			case (EIFR[1])
				1'b0 :
					if(ExtInt1_Fl)begin
						EIFR[1] <= 1'b1 ;
					end 	
				1'b1 :
					if (ExtInt1IRQ_Ack == 1'b1 | (IO_Addr == EIFR_Address && iowe & (dbus_in[1] == 1'b1))) begin
						EIFR[1] <= 1'b0;
					end
				// default : 
				// ;
			endcase
			case (EIFR[0])
				1'b0 :
					if(ExtInt0_Fl)begin
						EIFR[0] <= 1'b1 ;
					end 
				1'b1 :
					if (ExtInt0IRQ_Ack == 1'b1 | (IO_Addr == EIFR_Address && iowe & (dbus_in[0] == 1'b1))) begin
						EIFR[0] <= 1'b0;
					end
				// default : 
				// ;
			endcase
		end
	end

	always @(negedge ireset or posedge cp2)
	begin : PCICR_REG
		if (!ireset) begin		// Reset
			PCICR <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == PCICR_Address && ramwe) begin
				PCICR[3:0] <= dbus_in[3:0];
			end
		end
	end

	always @(posedge cp2)
	begin
		pcint3_sync <= pcint_in[27]||pcint_in[26]||pcint_in[25]||pcint_in[24];
		pcint3_setflag <= pcint3_sync;
		
		pcint2_sync <= pcint_in[23]||pcint_in[22]||pcint_in[21]||pcint_in[20]||pcint_in[19]||pcint_in[18]||pcint_in[17]||pcint_in[16];
		pcint2_setflag <= pcint2_sync;
		
		pcint1_sync <= pcint_in[14]||pcint_in[13]||pcint_in[12]||pcint_in[11]||pcint_in[10]||pcint_in[9]||pcint_in[8];
		pcint1_setflag <= pcint1_sync;
		
		pcint0_sync <= pcint_in[7]||pcint_in[6]||pcint_in[5]||pcint_in[4]||pcint_in[3]||pcint_in[2]||pcint_in[1]||pcint_in[0];
		pcint0_setflag <= pcint0_sync;
	end

	always @(negedge ireset or posedge cp2)
	begin : PCIFR_REG
		if (!ireset) begin		// Reset
			PCIFR <= {8{1'b0}};
		end else begin		// Clock
			case (PCIFR[3])
				1'b0 :
					PCIFR[3] <= pcint3_setflag ;
				1'b1 :
					if (PCInt3IRQ_Ack == 1'b1 | (IO_Addr == PCIFR_Address && iowe & (dbus_in[3] == 1'b1))) begin
						PCIFR[3] <= 1'b0;
					end
				// default : 
				// ;
			endcase
			case (PCIFR[2])
				1'b0 :
					PCIFR[2] <= pcint2_setflag ;
				1'b1 :
					if (PCInt2IRQ_Ack == 1'b1 | (IO_Addr == PCIFR_Address && iowe & (dbus_in[2] == 1'b1))) begin
						PCIFR[2] <= 1'b0;
					end
				// default : 
				// ;
			endcase
			case (PCIFR[1])
				1'b0 :
					PCIFR[1] <= pcint1_setflag ;
				1'b1 :
					if (PCInt1IRQ_Ack == 1'b1 | (IO_Addr == PCIFR_Address && iowe & (dbus_in[1] == 1'b1))) begin
						PCIFR[1] <= 1'b0;
					end
				// default : 
				// ;
			endcase
			case (PCIFR[0])
				1'b0 :
					PCIFR[0] <= pcint0_setflag ;
				1'b1 :
					if (PCInt0IRQ_Ack == 1'b1 | (IO_Addr == PCIFR_Address && iowe & (dbus_in[0] == 1'b1))) begin
						PCIFR[0] <= 1'b0;
					end
				// default : 
				// ;
			endcase
		end
	end

	always @(negedge ireset or posedge cp2)
	begin : PCMSK3_REG
		if (!ireset) begin		// Reset
			PCMSK3 <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == PCMSK3_Address && ramwe) begin
				PCMSK3[3:0] <= dbus_in[3:0];
			end
		end
	end
	
	always @(negedge ireset or posedge cp2)
	begin : PCMSK2_REG
		if (!ireset) begin		// Reset
			PCMSK2 <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == PCMSK2_Address && ramwe) begin
				PCMSK2[7:0] <= dbus_in[7:0];
			end
		end
	end

	always @(negedge ireset or posedge cp2)
	begin : PCMSK1_REG
		if (!ireset) begin		// Reset
			PCMSK1 <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == PCMSK1_Address && ramwe) begin
				PCMSK1[6:0] <= dbus_in[6:0];
			end
		end
	end
	
	always @(negedge ireset or posedge cp2)
	begin : PCMSK0_REG
		if (!ireset) begin		// Reset
			PCMSK0 <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == PCMSK0_Address && ramwe) begin
				PCMSK0[7:0] <= dbus_in[7:0];
			end
		end
	end

	always @(posedge cp2)
	begin
		EXTINT0_delay <= EXTINT0;
		EXTINT1_delay <= EXTINT1;
	end
	
	assign ExtInt1_Fl = (EICRA[3:2]== 2'b00) ? (!EXTINT1_delay && !EXTINT1):
						(EICRA[3:2]== 2'b01) ? ((!EXTINT1_delay && EXTINT1)||(EXTINT1_delay && !EXTINT1)):
						(EICRA[3:2]== 2'b10) ? ( EXTINT1_delay && !EXTINT1):
						(!EXTINT1_delay && EXTINT1) ;
						
	assign ExtInt0_Fl = (EICRA[1:0]== 2'b00) ? (!EXTINT0_delay && !EXTINT0):
						(EICRA[1:0]== 2'b01) ? ((!EXTINT0_delay && EXTINT0)||(EXTINT0_delay && !EXTINT0)):
						(EICRA[1:0]== 2'b10) ? ( EXTINT0_delay && !EXTINT0):
						(!EXTINT0_delay && EXTINT0) ;
	
	assign ExtInt1IRQ = EIFR[1] & EIMSK[1] ;
	assign ExtInt0IRQ = EIFR[0] & EIMSK[0] ;
	assign PCInt3IRQ = PCIFR[3] & PCICR[3] ;
	assign PCInt2IRQ = PCIFR[2] & PCICR[2] ;
	assign PCInt1IRQ = PCIFR[1] & PCICR[1] ;
	assign PCInt0IRQ = PCIFR[0] & PCICR[0] ;
		
	always @(*)
	begin: OutMuxComb
		if (iore) begin
			case (IO_Addr)
				EIFR_Address :
					begin
						dbus_out <= EIFR;
						out_en <= iore;
					end
				PCIFR_Address :
					begin
						dbus_out <= PCIFR;
						out_en <= iore;
					end
				EIMSK_Address :
					begin
						dbus_out <= EIMSK;
						out_en <= iore;
					end
				default :
					begin
						dbus_out <= {8{1'b0}};
						out_en <= 1'b0;
					end
			endcase
		end else if (ramre) begin
			case (ram_Addr)
				EICRA_Address :
					begin
						dbus_out <= EICRA ;
						out_en <= ramre;
					end 
				PCICR_Address :
					begin
						dbus_out <= PCICR ;
						out_en <= ramre;
					end 
				PCMSK3_Address :
					begin
						dbus_out <= PCMSK3 ;
						out_en <= ramre;
					end 
				PCMSK2_Address :
					begin
						dbus_out <= PCMSK2 ;
						out_en <= ramre;
					end 
				PCMSK1_Address :
					begin
						dbus_out <= PCMSK1 ;
						out_en <= ramre;
					end 
				PCMSK0_Address :
					begin
						dbus_out <= PCMSK0 ;
						out_en <= ramre;
					end 
				default :
					begin
						dbus_out <= {8{1'b0}};
						out_en <= 1'b0;
					end
			endcase
		end else begin
			dbus_out <= {8{1'b0}};
			out_en <= 1'b0;
		end 
    end	
	
endmodule


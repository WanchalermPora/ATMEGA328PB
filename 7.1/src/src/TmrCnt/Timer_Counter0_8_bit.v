`timescale 1 ns / 1 ns
module Timer_Counter0_8_bit(ireset,
							cp2,
							cp2en,
							tmr_cp2en,
							csn,
							clk_en,
							IO_Addr,
							dbus_in,
							dbus_out,
							iore,
							iowe,
							OCnA,
							OCnB,
							OCnA_EN,
							OCnB_EN,
							out_en,
							ram_Addr,
							ramre,
							ramwe,
							irqack_addr,
							irqack,
							// stopped_mode,
							// tmr_running,
							// TCnOvfIRQ_Ack,
							TCnOvfIRQ,
							// TCnCmpAIRQ_Ack,
							TCnCmpAIRQ,
							// TCnCmpBIRQ_Ack,
							TCnCmpBIRQ);
	
	parameter		ram_depth  = 12 ;
	parameter [5:0] TCCRnA_Address= 6'h24 ;
	parameter [5:0] TCCRnB_Address= 6'h25 ;
	parameter [5:0] TCNTn_Address = 6'h26 ;
	parameter [5:0] OCRnA_Address = 6'h27 ;
	parameter [5:0] OCRnB_Address = 6'h28 ;
	parameter [5:0] TIFRn_Address = 6'h15 ;
	parameter [5:0] TCnCmpAIRQ_Address	  =	6'h0E ;
	parameter [5:0] TCnCmpBIRQ_Address 	  =	6'h0F ;
	parameter [5:0] TCnOvfIRQ_Address 	  =	6'h10 ;
	
	parameter [ram_depth-1:0] TIMSKn_Address = 12'h06E ;
	
	input            ireset ;
	input            cp2 ;
	input            cp2en ;
	input            tmr_cp2en ;
	input            clk_en ;
	// input            stopped_mode;		// ??
	// input            tmr_running;		// ??
	
	input [5:0]		 irqack_addr;
	input			 irqack;
	// input            TCnOvfIRQ_Ack;
	output           TCnOvfIRQ;
	// input            TCnCmpAIRQ_Ack;
	output           TCnCmpAIRQ;
	// input            TCnCmpBIRQ_Ack;
	output           TCnCmpBIRQ;
	input [7:0]      dbus_in ;
	output reg [7:0] dbus_out ;
	input [ram_depth-1:0] ram_Addr ;
    input            ramre ;
    input            ramwe ;
	input [5:0]      IO_Addr ;
	input            iore ;
	input            iowe ;
	
	output [2:0]	 csn ;
	output           OCnA ;
	output           OCnB ;
	output           OCnA_EN ;
	output           OCnB_EN ;
	output reg       out_en ;
	
	reg [7:0]    TCNTn ;  // TCn Counter Value Register
	reg [7:0]    TCCRnA ;  // TCn Control Register A
	reg [7:0]    TCCRnB ;  // TCn Control Register B
	reg [7:0]    OCRnA_buf ;  // TCn Output Compare Register A buffer
	reg [7:0]    OCRnB_buf ;  // TCn Output Compare Register B buffer
	reg [7:0]    OCRnA ;  // TCn Output Compare Register A 
	reg [7:0]    OCRnB ;  // TCn Output Compare Register B 
	
	reg [7:0]    TIFRn ; // reg [7:0]    TIFRn = 8'b00000000 ;  // TCn Interrupt Flag Register 
	reg [7:0]    TIMSKn ;  // TCn Interrupt Mask Register
	
	reg          OCnA_Int ;
	reg          OCnB_Int ;
	wire [2:0]   WGMn ;
	wire         TCnCmpAIRQ_Ack ;
	wire		 TCnCmpBIRQ_Ack ;
	wire		 TCnOvfIRQ_Ack ;
	reg          CntnDir ;
	reg          TCNTnWrFl ;
	wire         TCNTnCmpBl ;
	reg [7:0]    TOP ;
	
	assign WGMn = {TCCRnB[3],TCCRnA[1:0]};
	assign csn = TCCRnB[2:0] ;
	assign OCnA_EN = TCCRnA[7] || (TCCRnA[6]&&(TCCRnB[3]||(!TCCRnA[0])));
	assign OCnB_EN = TCCRnA[5] || (TCCRnA[4]&&((!TCCRnB[3])&&(!TCCRnA[0])));
	assign TCnCmpAIRQ_Ack = (irqack_addr == TCnCmpAIRQ_Address) && irqack ;
	assign TCnCmpBIRQ_Ack = (irqack_addr == TCnCmpBIRQ_Address) && irqack ;
	assign TCnOvfIRQ_Ack  = (irqack_addr == TCnOvfIRQ_Address) && irqack ;
	// assign TOP = ((WGMn == 3'b010) or (WGMn == 3'b101) or (WGMn == 3'b111)) ? OCRnA : 8'hFF ;
	
	always @(*)
	begin: TOP_reg
		if((WGMn == 3'b010) || (WGMn == 3'b101) || (WGMn == 3'b111)) begin
			TOP <= OCRnA ;
		end else begin
			TOP <= 8'hFF ;
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: TimerCounter_Cnt
		if (!ireset) begin		// Reset
			TCNTn <= {8{1'b0}};
		end else begin		// Clock
			if (IO_Addr == TCNTn_Address && iowe & cp2en) begin		// Write to TCNTn
				TCNTn <= dbus_in;
			end else if (tmr_cp2en) begin
				if (clk_en == 1'b1) begin
					case (WGMn)
						3'b000 : // Normal
							TCNTn <= TCNTn + 1;
						3'b001 : // PWM, Phase Correct
							case (CntnDir)
								1'b0 :		// Counts up
									if (TCNTn == TOP)
										TCNTn <= TOP - 1;
									else
										TCNTn <= TCNTn + 1;		// Increment TCNTn (0 to FF)
								1'b1 :		// Counts down
									if (TCNTn == 8'h00)
										TCNTn <= 8'h01;
									else
										TCNTn <= TCNTn - 1;		// Decrement TCNTn (FF to 0)	  
								default : ;   
							endcase
						3'b010 : // CTC
							if (TCNTn == TOP)		// Clear T/C on compare match
								TCNTn <= {8{1'b0}};
							else
								TCNTn <= TCNTn + 1;		// Increment TCNTn
						3'b011 : // Fast PWM
							TCNTn <= TCNTn + 1;
						3'b101 : // PWM, Phase Correct
							case (CntnDir)
								1'b0 :		// Counts up
									if (TCNTn == TOP)
										TCNTn <= TOP - 1;
									else
										TCNTn <= TCNTn + 1;		// Increment TCNTn (0 to FF)
								1'b1 :		// Counts down
									if (TCNTn == 8'h00)
										TCNTn <= 8'h01;
									else
										TCNTn <= TCNTn - 1;		// Decrement TCNTn (FF to 0)	  
								default : ;   
							endcase
						3'b111 : // Fast PWM
							if (TCNTn == TOP)		// Clear T/C on compare match
								TCNTn <= {8{1'b0}};
							else
								TCNTn <= TCNTn + 1;		// Increment TCNTn
						default : 
							TCNTn <= TCNTn ;
					endcase	
				end
			end 
		end
	end
	
//	always @(posedge cp2 or negedge ireset or TCNTn)
	always @(TCNTn)
	begin: CntnDirectionControl
		if (!ireset) begin	// Reset
			CntnDir <= 1'b0; // Counts up
		end else begin	// Clock
			if (tmr_cp2en) begin		// Clock enable
				if (clk_en == 1'b1) begin
					case (WGMn)
						3'b000 : // Normal
							CntnDir <= 1'b0;
						3'b001 : // PWM, Phase Correct
							case (CntnDir)
								1'b0 :
									if (TCNTn == TOP)
										CntnDir <= 1'b1;
								1'b1 :
									if (TCNTn == 8'h00)
										CntnDir <= 1'b0;
								default : ;	
							endcase
						3'b010 : // CTC
							CntnDir <= 1'b0;
						3'b011 : // Fast PWM
							CntnDir <= 1'b0;
						3'b101 : // PWM, Phase Correct
							case (CntnDir)
								1'b0 :
									if (TCNTn == TOP)
										CntnDir <= 1'b1;
								1'b1 :
									if (TCNTn == 8'h00)
										CntnDir <= 1'b0;
								default : ;	
							endcase
						3'b111 : // Fast PWM
							CntnDir <= 1'b0;			
						default : ;	
					endcase	
				end
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: TCNTnWriteControl
		if (!ireset) begin		// Reset
			TCNTnWrFl <= 1'b0;
		end else begin		// Clock
			if (cp2en) begin
				case (TCNTnWrFl)
					1'b0 :
						if (IO_Addr == TCNTn_Address && iowe & clk_en == 1'b0)		// Load data from the data bus 
							TCNTnWrFl <= 1'b1;
					1'b1 :
						if (clk_en == 1'b0)
							TCNTnWrFl <= 1'b0;
					default :
						;
				endcase
			end
		end
	end
	
	assign TCNTnCmpBl = ((TCNTnWrFl == 1'b1 | (IO_Addr == TCNTn_Address && iowe))) ? 1'b1 : 1'b0;
	
	always @(posedge cp2 or negedge ireset)
	begin: OutputCompare_nA
		if (!ireset) begin	// Reset
			OCnA_Int <= 1'b0;
		end else if (TCNTnCmpBl == 1'b0) begin	// Clock
			if (tmr_cp2en) begin		// Clock enable
				if (clk_en == 1'b1) begin
					if ((WGMn == 3'b000) || (WGMn == 3'b010)) begin // Non-PWM Mode
						case (TCCRnA[7:6])
							2'b00:
								OCnA_Int <= 1'b0;
							2'b01: 
								if((TCNTn == OCRnA) || (TCCRnB[7]==1'b1))begin
									OCnA_Int <= ~OCnA_Int;
								end
							2'b10: 
								if((TCNTn == OCRnA) || (TCCRnB[7]==1'b1))begin
									OCnA_Int <= 1'b0;
								end
							2'b11: 
								if((TCNTn == OCRnA) || (TCCRnB[7]==1'b1))begin
									OCnA_Int <= 1'b1;
								end
							default : ;	
						endcase
					end else if ((WGMn == 3'b011) || (WGMn == 3'b111)) begin // Fast PWM Mode
						case (TCCRnA[7:6])
							2'b00: 
								OCnA_Int <= 1'b0;
							2'b01: 
								if((TCNTn == OCRnA) && (WGMn[2]==1'b1))begin
									OCnA_Int <= ~OCnA_Int;
								end else begin
									OCnA_Int <= 1'b0;
								end
							2'b10: 
								if(TCNTn == OCRnA)begin
									OCnA_Int <= 1'b0;
								end else if (TCNTn == 8'h00) begin
									OCnA_Int <= 1'b1;
								end
							2'b11: 
								if(TCNTn == OCRnA)begin
									OCnA_Int <= 1'b1;
								end else if (TCNTn == 8'h00) begin
									OCnA_Int <= 1'b0;
								end
							default : ;	
						endcase
					end else if ((WGMn == 3'b001) || (WGMn == 3'b101)) begin // Phase Correct PWM Mode
						case (TCCRnA[7:6])
							2'b00: 
								OCnA_Int <= 1'b0;
							2'b01: 
								if((TCNTn == OCRnA) && (WGMn[2]==1'b1))begin
									OCnA_Int <= ~OCnA_Int;
								end else begin
									OCnA_Int <= 1'b0;
								end
							2'b10:
								if(TCNTn == OCRnA)begin
									if (CntnDir == 1'b0) begin
										OCnA_Int <= 1'b0;
									end else begin
										OCnA_Int <= 1'b1;
									end
								end
							2'b11:
								if(TCNTn == OCRnA)begin
									if (CntnDir == 1'b0) begin
										OCnA_Int <= 1'b1;
									end else begin
										OCnA_Int <= 1'b0;
									end
								end
							default : ;	
						endcase
					end
				end
			end
		end
	end	
				
	assign OCnA = OCnA_Int ;
	
	always @(posedge cp2 or negedge ireset)
	begin: OutputCompare_nB
		if (!ireset) begin	// Reset
			OCnB_Int <= 1'b0;
		end else if (TCNTnCmpBl == 1'b0)begin	// Clock
			if (tmr_cp2en) begin		// Clock enable
				if (clk_en == 1'b1) begin
					if ((WGMn == 3'b000) || (WGMn == 3'b010)) begin // Non-PWM Mode
						case (TCCRnA[5:4])
							2'b00:
								OCnB_Int <= 1'b0;
							2'b01: 
								if((TCNTn == OCRnB) || (TCCRnB[6]==1'b1))begin
									OCnB_Int <= ~OCnB_Int;
								end
							2'b10: 
								if((TCNTn == OCRnB) || (TCCRnB[6]==1'b1))begin
									OCnB_Int <= 1'b0;
								end
							2'b11: 
								if((TCNTn == OCRnB) || (TCCRnB[6]==1'b1))begin
									OCnB_Int <= 1'b1;
								end
							default : ;	
						endcase
					end else if ((WGMn == 3'b011) || (WGMn == 3'b111)) begin // Fast PWM Mode
						case (TCCRnA[5:4])
							2'b00: 
								OCnB_Int <= 1'b0;
							2'b01: 
								OCnB_Int <= 1'b0;
							2'b10: 
								if(TCNTn == OCRnB)begin
									OCnB_Int <= 1'b0;
								end else if (TCNTn == 8'h00) begin
									OCnB_Int <= 1'b1;
								end
							2'b11: 
								if(TCNTn == OCRnB)begin
									OCnB_Int <= 1'b1;
								end else if (TCNTn == 8'h00) begin
									OCnB_Int <= 1'b0;
								end
							default : ;	
						endcase
					end else if ((WGMn == 3'b001) || (WGMn == 3'b101)) begin // Phase Correct PWM Mode
						case (TCCRnA[5:4])
							2'b00: 
								OCnB_Int <= 1'b0;
							2'b01: 
								OCnB_Int <= 1'b0;
							2'b10:
								if(TCNTn == OCRnB)begin
									if (CntnDir == 1'b0) begin
										OCnB_Int <= 1'b0;
									end else begin
										OCnB_Int <= 1'b1;
									end
								end
							2'b11:
								if(TCNTn == OCRnB)begin
									if (CntnDir == 1'b0) begin
										OCnB_Int <= 1'b1;
									end else begin
										OCnB_Int <= 1'b0;
									end
								end
							default : ;	
						endcase
					end
				end
			end
		end
	end	
	
	assign OCnB = OCnB_Int ;
	
	always @(posedge cp2 or negedge ireset)
	begin: TCCRnA_Reg
		if (!ireset) begin		// Reset
			TCCRnA <= {8{1'b0}};
		end else begin		// Clock
			if (IO_Addr == TCCRnA_Address && iowe & cp2en) begin	// Clock Enable	
				TCCRnA[7:4] <= dbus_in[7:4];
				TCCRnA[1:0] <= dbus_in[1:0];
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: TCCRnB_Reg
		if (!ireset) begin		// Reset
			TCCRnB <= {8{1'b0}};
		end else begin		// Clock
			if (IO_Addr == TCCRnB_Address && iowe & cp2en) begin	// Clock Enable	
				TCCRnB[7:6] <= dbus_in[7:6];
				TCCRnB[3:0] <= dbus_in[3:0];
			end else begin
				TCCRnB[7:6] <= 2'b00;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: OCRnA_buf_Reg
		if (!ireset) begin		// Reset
			OCRnA_buf <= {8{1'b0}};
		end else begin		// Clock
			if (IO_Addr == OCRnA_Address && iowe & cp2en) begin	// Clock Enable	
				OCRnA_buf <= dbus_in;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: OCRnA_Reg
		if (!ireset) begin		// Reset
			OCRnA <= {8{1'b0}};
		end else begin		// Clock
			case(WGMn[1:0])
				2'b00 :
					if (IO_Addr == OCRnA_Address && iowe & cp2en) begin	// Clock Enable	
						OCRnA <= dbus_in;
					end
				2'b01 :
					if (TCNTn == TOP & tmr_cp2en & clk_en == 1'b1) begin
						OCRnA <= OCRnA_buf ;
					end
				2'b10 :
					if (IO_Addr == OCRnA_Address && iowe & cp2en) begin	// Clock Enable	
						OCRnA <= dbus_in;
					end
				2'b11 :
					if (TCNTn == 8'h00 & tmr_cp2en & clk_en == 1'b1) begin
						OCRnA <= OCRnA_buf ;
					end
				default :
				   OCRnA <= OCRnA;
			endcase
		end 
	end

	always @(posedge cp2 or negedge ireset)
	begin: OCRnB_buf_Reg
		if (!ireset) begin		// Reset
			OCRnB_buf <= {8{1'b0}};
		end else begin		// Clock
			if (IO_Addr == OCRnB_Address && iowe & cp2en) begin	// Clock Enable	
				OCRnB_buf <= dbus_in;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: OCRnB_Reg
		if (!ireset) begin		// Reset
			OCRnB <= {8{1'b0}};
		end else begin		// Clock
			case(WGMn[1:0])
				2'b00 :
					if (IO_Addr == OCRnB_Address && iowe & cp2en) begin	// Clock Enable	
						OCRnB <= dbus_in;
					end
				2'b01 :
					if (TCNTn == TOP & tmr_cp2en & clk_en == 1'b1) begin
						OCRnB <= OCRnB_buf ;
					end
				2'b10 :
					if (IO_Addr == OCRnB_Address && iowe & cp2en) begin	// Clock Enable	
						OCRnB <= dbus_in;
					end
				2'b11 :
					if (TCNTn == 8'h00 & tmr_cp2en & clk_en == 1'b1) begin
						OCRnB <= OCRnB_buf ;
					end
				default :
				   OCRnB <= OCRnB;
			endcase
		end 
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: TOVn_Reg
		if (!ireset) begin		// Reset
			TIFRn[0] <= 1'b0;
		end else begin        // Clock
			// if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)	begin	// !!!Special mode!!!
				// if (IO_Addr == TIFRn_Address && iowe ) begin		// Write to TOVn
					// TIFRn[0] <= dbus_in[0];
				// end
			// end else begin
				case (TIFRn[0])
					1'b0 :
						if (tmr_cp2en & clk_en == 1'b1) begin
							if (WGMn[1:0]==2'b01)begin
								if ((TCNTn == 8'h00) && (CntnDir == 1'b1)) begin
								// if (TCNTn == 8'h00) begin
									TIFRn[0] <= 1'b1;
								end 
							end else if (WGMn[2]==1'b0)begin
								if (TCNTn == 8'hFF) begin
									TIFRn[0] <= 1'b1;
								end 
							end else if (WGMn[0]==1'b1) begin
								if (TCNTn == TOP) begin
									TIFRn[0] <= 1'b1;
								end 
							end
						end
					1'b1 :
						if ((TCnOvfIRQ_Ack == 1'b1 | (IO_Addr == TIFRn_Address && iowe & (dbus_in[0] == 1'b1))) & cp2en) begin
							TIFRn[0] <= 1'b0;
						end
					default : 
					;
				endcase
			// end
		end	
	end	
	
	always @(posedge cp2 or negedge ireset)
	begin: OCFnA_Reg
		if (!ireset) begin		// Reset
			TIFRn[1] <= 1'b0;
		end else begin        // Clock
			// if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)		// !!!Special mode!!!
				// if (IO_Addr == TIFRn_Address && iowe) begin		// Write to OCFnA
					// TIFRn[1] <= dbus_in[1];
				// end
			// end else begin
				case (TIFRn[1])
					1'b0 :
						if (tmr_cp2en & clk_en == 1'b1) begin
							// if (TCNTn == OCRnA && TCCRnA[7:6]==) begin
							if (TCNTn == OCRnA) begin
								TIFRn[1] <= 1'b1;
							end 
						end
					1'b1 :
						if ((TCnCmpAIRQ_Ack == 1'b1 | (IO_Addr == TIFRn_Address && iowe & (dbus_in[1] == 1'b1))) & cp2en) begin
							TIFRn[1] <= 1'b0;
						end
					default : 
					;
				endcase
			// end
		end	
	end	
	
	always @(posedge cp2 or negedge ireset)
	begin: OCFnB_Reg
		if (!ireset) begin		// Reset
			TIFRn[2] <= 1'b0;
		end else begin        // Clock
			// if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)		// !!!Special mode!!!
				// if (IO_Addr == TIFRn_Address && iowe ) begin		// Write to OCFnB
					// TIFRn[2] <= dbus_in[2];
				// end
			// end else begin
				case (TIFRn[2])
					1'b0 :
						if (tmr_cp2en & clk_en == 1'b1) begin
							if (TCNTn == OCRnB) begin
								TIFRn[2] <= 1'b1;
							end 
						end
					1'b1 :
						if ((TCnCmpBIRQ_Ack == 1'b1 | (IO_Addr == TIFRn_Address && iowe & (dbus_in[2] == 1'b1))) & cp2en) begin
							TIFRn[2] <= 1'b0;
						end
					default : 
					;
				endcase
			// end
		end	
	end
	
	// add reset condition
	always@(posedge cp2 or negedge ireset)
	begin
		if (!ireset) begin
			TIFRn[7:3] <= 0;
		end
		else begin
			TIFRn[7:3] <= 0;
		end
	end

	always @(posedge cp2 or negedge ireset)
	begin: TIMSKn_reg
		if (!ireset) begin
			TIMSKn <= {8{1'b0}};
		end else begin
			if (cp2en)begin	// Clock Enable	
				if (ram_Addr == TIMSKn_Address && ramwe)begin
					TIMSKn[2:0] <= dbus_in[2:0];
				end
			end
		end
	end
	
	assign TCnOvfIRQ = TIFRn[0] & TIMSKn[0];		// Interrupt on overflow of TCNTn
	assign TCnCmpAIRQ = TIFRn[1] & TIMSKn[1];		// Interrupt on compare match A	of TCNTn
	assign TCnCmpBIRQ = TIFRn[2] & TIMSKn[2];		// Interrupt on compare match B	of TCNTn
	
	always @(*)
	begin: OutMuxComb
		if (iore) begin
			case (IO_Addr)
				TCCRnA_Address :
					begin
						dbus_out <= TCCRnA;
						out_en <= iore;
					end
				TCCRnB_Address :
					begin
						dbus_out <= {2'b00,TCCRnB[5:0]};
						out_en <= iore;
					end
				TCNTn_Address :
					begin
						dbus_out <= TCNTn;
						out_en <= iore;
					end
				OCRnA_Address :
					begin
						dbus_out <= OCRnA_buf;
						out_en <= iore;
					end
				OCRnB_Address :
					begin
						dbus_out <= OCRnB_buf;
						out_en <= iore;
					end
				TIFRn_Address :
					begin
						dbus_out <= TIFRn;
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
				TIMSKn_Address :
					begin
						dbus_out <= TIMSKn ;
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
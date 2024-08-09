`timescale 1 ns / 1 ns
module Timer_Counter_16_bit(ireset,
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
							// stopped_mode,
							// tmr_running,
							irqack_addr,
							irqack,
							ICPn_in,
							// TCnOvfIRQ_Ack,
							TCnOvfIRQ,
							// TCnCmpAIRQ_Ack,
							TCnCmpAIRQ,
							// TCnCmpBIRQ_Ack,
							TCnCmpBIRQ,
							// TCnICpIRQ_Ack,
							TCnICpIRQ);
								
	parameter		ram_depth  = 12 ;
	parameter [ram_depth-1:0] TCCRnA_Address = 12'h080 ;
	parameter [ram_depth-1:0] TCCRnB_Address = 12'h081 ;
	parameter [ram_depth-1:0] TCCRnC_Address = 12'h082 ;
	
	parameter [ram_depth-1:0] TCNTnL_Address = 12'h084 ;
	parameter [ram_depth-1:0] TCNTnH_Address = 12'h085 ;
	parameter [ram_depth-1:0] ICRnL_Address  = 12'h086 ;
	parameter [ram_depth-1:0] ICRnH_Address  = 12'h087 ;
	parameter [ram_depth-1:0] OCRnAL_Address = 12'h088 ;
	parameter [ram_depth-1:0] OCRnAH_Address = 12'h089 ;
	parameter [ram_depth-1:0] OCRnBL_Address = 12'h08A ;
	parameter [ram_depth-1:0] OCRnBH_Address = 12'h08B ;
	
	parameter [5:0] TIFRn_Address = 6'h16 ;
	
	parameter [ram_depth-1:0] TIMSKn_Address = 12'h06F ;
	
	parameter [5:0] TCnICpIRQ_Address	  =	6'h0A ;
	parameter [5:0] TCnCmpAIRQ_Address	  =	6'h0B ;
	parameter [5:0] TCnCmpBIRQ_Address 	  =	6'h0C ;
	parameter [5:0] TCnOvfIRQ_Address 	  =	6'h0D ;
	
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
	// input            TCnICpIRQ_Ack;
	output           TCnICpIRQ;
	
	input [7:0]      dbus_in ;
	output reg [7:0] dbus_out ;
	input [ram_depth-1:0] ram_Addr ;
    input            ramre ;
    input            ramwe ;
	input [5:0]      IO_Addr ;
	input            iore ;
	input            iowe ;
	input            ICPn_in ;
	
	output [2:0]     csn ;
	output           OCnA ;
	output           OCnB ;
	output           OCnA_EN ;
	output           OCnB_EN ;
	output reg       out_en ;
	
	
	reg [7:0]    TCCRnA ;  // TCn Control Register A
	reg [7:0]    TCCRnB ;  // TCn Control Register B
	reg [7:0]    TCCRnC ;  // TCn Control Register C
	reg [15:0]   TCNTn  ;  // TCn Counter Value Register L and H
	reg [7:0]    Temp   ;  // Temp for high byte
	reg [15:0]   ICRn   ;  // TCn Input Capture Register n L and H
	reg [15:0]   OCRnA  ;  // TCn Output Compare Register n A L and H
	reg [15:0]   OCRnB  ;  // TCn Output Compare Register n B L and H
	reg [15:0]   OCRnA_buf ;  // TCn Output Compare Register A buffer
	reg [15:0]   OCRnB_buf ;  // TCn Output Compare Register B buffer
	reg [7:0]    TIFRn ;  // reg [7:0]    TIFRn = 8'b00000000 ;  // TCn Interrupt Flag Register 
	reg [7:0]    TIMSKn ;  // TCn Interrupt Mask Register
	reg          ICPn_sig ;  // input capture signal
	reg [2:0]    ICPn_cnt;  // input capture counts
	wire         ICPn_en ;  // input capture enable
	wire         ICPn_buffer ;  // input capture buffer
	reg          ICPn_delay ;  // input capture delay
	
	reg          OCnA_Int ;
	reg          OCnB_Int ;
	wire [3:0]   WGMn ; // mode operation
	wire         TCnICpIRQ_Ack ;
	wire         TCnCmpAIRQ_Ack ;
	wire		 TCnCmpBIRQ_Ack ;
	wire		 TCnOvfIRQ_Ack ;
	reg          CntnDir ;
	reg          TCNTnWrFl ;
	wire         TCNTnCmpBl ;
	reg [15:0]   TOP ;
	
	assign WGMn = {TCCRnB[4:3],TCCRnA[1:0]};
	assign csn = TCCRnB[2:0] ;
	assign OCnA_EN = TCCRnA[7] || (TCCRnA[6]&&((WGMn==4'h0)||(WGMn==4'h4)||(WGMn==4'h9)||(WGMn==4'hB)||(WGMn==4'hC)||(WGMn==4'hE)||(WGMn==4'hF)));
	assign OCnB_EN = TCCRnA[5] || (TCCRnA[4]&&((WGMn==4'h0)||(WGMn==4'h4)||(WGMn==4'hC)));
	
	assign TCnICpIRQ_Ack = (irqack_addr == TCnICpIRQ_Address) && irqack ;
	assign TCnCmpAIRQ_Ack = (irqack_addr == TCnCmpAIRQ_Address) && irqack ;
	assign TCnCmpBIRQ_Ack = (irqack_addr == TCnCmpBIRQ_Address) && irqack ;
	assign TCnOvfIRQ_Ack  = (irqack_addr == TCnOvfIRQ_Address) && irqack ;
	
	always @(*)
	begin: TOP_reg
		case (WGMn)
			4'b0000 :
				TOP <= 16'hFFFF ;
			4'b0001 :
				TOP <= 16'h00FF ;
			4'b0010 :
				TOP <= 16'h01FF ;
			4'b0011 :
				TOP <= 16'h03FF ;
			4'b0100 :
				TOP <= OCRnA ;
			4'b0101 :
				TOP <= 16'h00FF ;
			4'b0110 :
				TOP <= 16'h01FF ;
			4'b0111 :
				TOP <= 16'h03FF ;
			4'b1000 :
				TOP <= ICRn ;
			4'b1001 :
				TOP <= OCRnA ;
			4'b1010 :
				TOP <= ICRn ;
			4'b1011 :
				TOP <= OCRnA ;
			4'b1100 :
				TOP <= ICRn ;
			4'b1101 :
				TOP <= 16'h0000 ;
			4'b1110 :
				TOP <= ICRn ;
			4'b1111 :
				TOP <= OCRnA ;
			default :
				TOP <= 16'h0000 ;
		endcase 
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: TimerCounter_Cnt
		if (!ireset) begin		// Reset
			TCNTn <= {16{1'b0}};
		end else begin
			if(ram_Addr == TCNTnL_Address && ramwe & cp2en) begin
				TCNTn[7:0] <= dbus_in;
				TCNTn[15:8] <= Temp;
			// end else if (ram_Addr == TCNTnH_Address && ramwe & cp2en) begin
				// TCNTn[15:8] <= dbus_in;
			end else if (tmr_cp2en) begin
				if (clk_en == 1'b1) begin
					if (WGMn == 4'b1101) begin // reserved
						TCNTn <= TCNTn ;
					end else if ((WGMn[2] == 1'b1) || (WGMn == 4'b0000)) begin // normal, ctc & fast pwm
						if (TCNTn == TOP)		// Clear T/C on compare match
							TCNTn <= {16{1'b0}};
						else
							TCNTn <= TCNTn + 1;		// Increment TCNTn
					end else begin // pwm phase correct & pwm phase and feq correct
						case (CntnDir)
							1'b0 :		// Counts up
								if (TCNTn == TOP)
									TCNTn <= TOP - 1;
								else
									TCNTn <= TCNTn + 1;		// Increment TCNTn (0 to FF)
							1'b1 :		// Counts down
								if (TCNTn == 16'h0000)
									TCNTn <= 16'h0001;
								else
									TCNTn <= TCNTn - 1;		// Decrement TCNTn (FF to 0)	  
							default : ;   
						endcase
					end 
				end
			end
		end
	end 
	
	always @(posedge cp2 or negedge ireset)
	begin: Temp_reg
		if (!ireset) begin		// Reset ?????
			Temp <= {8{1'b0}};
		end else begin
			if(ram_Addr == TCNTnL_Address && ramre) begin
				Temp <= TCNTn[15:8];
			end else if(ram_Addr == ICRnL_Address && ramre) begin
				Temp <= ICRn[15:8];
			// end else if (ram_Addr == ICRnH_Address && ramwe & cp2en) begin
				// Temp <= dbus_in;
			end else if (ram_Addr == TCNTnH_Address && ramwe & cp2en) begin
				Temp <= dbus_in;
			end else if (ram_Addr == OCRnAH_Address && ramwe & cp2en) begin
				Temp <= dbus_in;
			end else if (ram_Addr == OCRnBH_Address && ramwe & cp2en) begin
				Temp <= dbus_in;
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
					if ((WGMn[2] == 1'b1) || (WGMn == 4'b0000)) begin // normal, ctc & fast pwm
						CntnDir <= 1'b0;
					end else begin // pwm phase correct & pwm phase and feq correct
						case (CntnDir)
							1'b0 :
								if (TCNTn == TOP)
									CntnDir <= 1'b1;
							1'b1 :
								if (TCNTn == 16'h0000)
									CntnDir <= 1'b0;
							default : ;	
						endcase
					end
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
						if (((ram_Addr == TCNTnH_Address) || (ram_Addr == TCNTnL_Address)) && ramwe & clk_en == 1'b0)		// Load data from the data bus 
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
	
	assign TCNTnCmpBl = ((TCNTnWrFl == 1'b1 | (((ram_Addr == TCNTnL_Address) || (ram_Addr == TCNTnH_Address)) && ramwe))) ? 1'b1 : 1'b0;
	
	always @(posedge cp2 or negedge ireset)
	begin: OutputCompare_nA
		if (!ireset) begin	// Reset
			OCnA_Int <= 1'b0;
		end else if (TCNTnCmpBl == 1'b0) begin
			if (tmr_cp2en) begin		// Clock enable
				if (clk_en == 1'b1) begin
					if ((WGMn == 4'b0000) || (WGMn[2:0] == 3'b100)) begin // Non-PWM Mode
						case (TCCRnA[7:6])
							2'b00:
								OCnA_Int <= 1'b0;
							2'b01: 
								if((TCNTn == OCRnA) || (TCCRnC[7]==1'b1))begin
									OCnA_Int <= ~OCnA_Int;
								end
							2'b10: 
								if((TCNTn == OCRnA) || (TCCRnC[7]==1'b1))begin
									OCnA_Int <= 1'b0;
								end
							2'b11: 
								if((TCNTn == OCRnA) || (TCCRnC[7]==1'b1))begin
									OCnA_Int <= 1'b1;
								end
							default : ;	
						endcase
					end else if ((WGMn[3:2] == 2'b01) || (WGMn[3:1] == 3'b111)) begin // Fast PWM Mode
						case (TCCRnA[7:6])
							2'b00: 
								OCnA_Int <= 1'b0;
							2'b01: 
								if((TCNTn == OCRnA) && (WGMn[3]==1'b1))begin
									OCnA_Int <= ~OCnA_Int;
								end else begin
									OCnA_Int <= 1'b0;
								end
							2'b10: 
								if(TCNTn == OCRnA)begin
									OCnA_Int <= 1'b0;
								end else if (TCNTn == 16'h0000) begin
									OCnA_Int <= 1'b1;
								end
							2'b11: 
								if(TCNTn == OCRnA)begin
									OCnA_Int <= 1'b1;
								end else if (TCNTn == 16'h0000) begin
									OCnA_Int <= 1'b0;
								end
							default : ;	
						endcase
					end else if ((WGMn[3:2] == 2'b00) || (WGMn[3:2] == 2'b10))begin // pwm phase correct & pwm phase and feq correct
						case (TCCRnA[7:6])
							2'b00: 
								OCnA_Int <= 1'b0;
							2'b01: 
								if((TCNTn == OCRnA) && (WGMn[3]==1'b1) && (WGMn[0]==1'b1))begin
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
		end else if (TCNTnCmpBl == 1'b0) begin
			if (tmr_cp2en) begin		// Clock enable
				if (clk_en == 1'b1) begin
					if ((WGMn == 4'b0000) || (WGMn[2:0] == 3'b100)) begin // Non-PWM Mode
						case (TCCRnA[5:4])
							2'b00:
								OCnB_Int <= 1'b0;
							2'b01: 
								if((TCNTn == OCRnB) || (TCCRnC[6]==1'b1))begin
									OCnB_Int <= ~OCnB_Int;
								end
							2'b10: 
								if((TCNTn == OCRnB) || (TCCRnC[6]==1'b1))begin
									OCnB_Int <= 1'b0;
								end
							2'b11: 
								if((TCNTn == OCRnB) || (TCCRnC[6]==1'b1))begin
									OCnB_Int <= 1'b1;
								end
							default : ;	
						endcase
					end else if ((WGMn[3:2] == 2'b01) || (WGMn[3:1] == 3'b111)) begin // Fast PWM Mode
						case (TCCRnA[5:4])
							2'b00: 
								OCnB_Int <= 1'b0;
							2'b01: 
								OCnB_Int <= 1'b0;
							2'b10: 
								if(TCNTn == OCRnB)begin
									OCnB_Int <= 1'b0;
								end else if (TCNTn == 16'h0000) begin
									OCnB_Int <= 1'b1;
								end
							2'b11: 
								if(TCNTn == OCRnB)begin
									OCnB_Int <= 1'b1;
								end else if (TCNTn == 16'h0000) begin
									OCnB_Int <= 1'b0;
								end
							default : ;	
						endcase
					end else if ((WGMn[3:2] == 2'b00) || (WGMn[3:2] == 2'b10))begin // pwm phase correct & pwm phase and feq correct
						case (TCCRnB[5:4])
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
	begin: input_capture_Cnt
		if (!ireset) begin	// Reset
			ICPn_cnt <= {3{1'b0}};
		end else begin
			if (TCCRnB[7] == 1'b1) begin
				ICPn_cnt[2:1] <=  ICPn_cnt[1:0] ;
				ICPn_cnt[0]   <=  ICPn_in ;
			end else begin
				ICPn_cnt <= {3{1'b0}};
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset) 
	begin: input_capture_NoiseCanceler
		if (!ireset) begin	// Reset
			ICPn_sig <= 1'b0;
		end else begin
			if (TCCRnB[7] == 1'b1) begin
				if ((ICPn_cnt == 3'b000) && (ICPn_in == 1'b0))begin
					ICPn_sig <= 1'b0;
				end else if ((ICPn_cnt == 3'b111) && (ICPn_in == 1'b1))begin
					ICPn_sig <= 1'b1;
				end
			end else begin
				ICPn_sig <= ICPn_in;
			end
		end
	end

	assign ICPn_buffer = (TCCRnB[6] == 1'b0) ? ICPn_sig : ~ICPn_sig; //  non-inverting or inverting

    // delay ICPn for one clock
    always @(posedge(cp2))
        ICPn_delay <= ICPn_buffer;

    assign ICPn_en = ICPn_delay & ~ICPn_buffer;
	
	always @(posedge cp2 or negedge ireset)
	begin: TCCRnA_Reg
		if (!ireset) begin		// Reset
			TCCRnA <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == TCCRnA_Address && ramwe & cp2en) begin	// Clock Enable	
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
			if (ram_Addr == TCCRnB_Address && ramwe & cp2en) begin	// Clock Enable	
				TCCRnB[7:6] <= dbus_in[7:6];
				TCCRnB[4:0] <= dbus_in[4:0];
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: TCCRnC_Reg
		if (!ireset) begin		// Reset
			TCCRnC <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == TCCRnC_Address && ramwe & cp2en) begin	// Clock Enable	
				TCCRnC[7:6] <= dbus_in[7:6];
			end else begin
				TCCRnC[7:6] <= 2'b00;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset) 
	begin: ICRn_Reg
		if (!ireset) begin		// Reset
			ICRn <= {16{1'b0}};
		end else begin		// Clock
			if (ICPn_en == 1'b1) begin
				ICRn <= TCNTn ;
			// end else if (ram_Addr == ICRnL_Address && ramwe & cp2en) begin		
				// ICRn[7:0] <= dbus_in ;
				// ICRn[15:8] <= Temp ;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: OCRnA_buf_Reg
		if (!ireset) begin		// Reset
			OCRnA_buf <= {16{1'b0}};
		end else begin		// Clock
			if (ram_Addr == OCRnAL_Address && ramwe & cp2en) begin	// Clock Enable	
				OCRnA_buf[7:0] <= dbus_in;
				OCRnA_buf[15:8] <= Temp;
			// end else if (ram_Addr == OCRnAH_Address && ramwe & cp2en) begin
				// OCRnA_buf[15:8] <= dbus_in;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: OCRnA_Reg
		if (!ireset) begin		// Reset
			OCRnA <= {16{1'b0}};
		end else begin		// Clock
			if ((WGMn == 4'b0000) || (WGMn[2:0] == 3'b100)) begin // Update of OCR1x at Immediate
				if (ram_Addr == OCRnAL_Address && ramwe & cp2en) begin	// Clock Enable	
					OCRnA[7:0] <= dbus_in;
					OCRnA[15:8] <= Temp;
				// end else if (ram_Addr == OCRnAH_Address && ramwe & cp2en) begin
					// OCRnA[15:8] <= dbus_in;
				end
			end else if ((WGMn[3:2] == 2'b01) || (WGMn[3:1] == 3'b100) || (WGMn[3:1] == 3'b111)) begin // Update of OCR1x at BOTTOM
				if (TCNTn == 16'h0000 & tmr_cp2en & clk_en == 1'b1) begin
					OCRnA <= OCRnA_buf ;
				end
			end else if (WGMn[2] == 1'b0) begin // Update of OCR1x at TOP
				if (TCNTn == TOP & tmr_cp2en & clk_en == 1'b1) begin
					OCRnA <= OCRnA_buf ;
				end
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: OCRnB_buf_Reg
		if (!ireset) begin		// Reset
			OCRnB_buf <= {16{1'b0}};
		end else begin		// Clock
			if (ram_Addr == OCRnBL_Address && ramwe & cp2en) begin	// Clock Enable	
				OCRnB_buf[7:0] <= dbus_in;
				OCRnB_buf[15:8] <= Temp;
			// end else if (ram_Addr == OCRnBH_Address && ramwe & cp2en) begin
				// OCRnB_buf[15:8] <= dbus_in;
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: OCRnB_Reg
		if (!ireset) begin		// Reset
			OCRnB <= {16{1'b0}};
		end else begin		// Clock
			if ((WGMn == 4'b0000) || (WGMn[2:0] == 3'b100)) begin // Update of OCR1x at Immediate
				if (ram_Addr == OCRnBL_Address && ramwe & cp2en) begin	// Clock Enable	
					OCRnB[7:0] <= dbus_in;
					OCRnB[15:8] <= Temp;
				// end else if (ram_Addr == OCRnBH_Address && ramwe & cp2en) begin
					// OCRnB[15:8] <= dbus_in;
				end
			end else if ((WGMn[3:2] == 2'b01) || (WGMn[3:1] == 3'b100) || (WGMn[3:1] == 3'b111)) begin // Update of OCR1x at BOTTOM
				if (TCNTn == 16'h0000 & tmr_cp2en & clk_en == 1'b1) begin
					OCRnB <= OCRnB_buf ;
				end
			end else if (WGMn[2] == 1'b0) begin // Update of OCR1x at TOP
				if (TCNTn == TOP & tmr_cp2en & clk_en == 1'b1) begin
					OCRnB <= OCRnB_buf ;
				end
			end
		end
	end
	
	always @(posedge cp2 or negedge ireset) 
	begin: TOVn_Reg
		if (!ireset) begin		// Reset
			TIFRn[0] <= 1'b0;
		end else begin        // Clock
			// if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)	begin	// !!!Special mode!!!
				// if (IO_Addr == TIFRn_Address && iowe) begin		// Write to TOVn
					// TIFRn[0] <= dbus_in[0];
				// end
			// end else begin
				case (TIFRn[0])
					1'b0 :
						if (tmr_cp2en & clk_en == 1'b1) begin
							if ((WGMn == 4'b0000) || (WGMn[2:0] == 3'b100)) begin // Non-PWM Mode
								if (TCNTn == 16'hFFFF) begin
									TIFRn[0] <= 1'b1;
								end 
							end else if ((WGMn[3:2] == 2'b01) || (WGMn[3:1] == 3'b111)) begin // Fast PWM Mode
								if (TCNTn == TOP) begin
									TIFRn[0] <= 1'b1;
								end 
							end else if (((WGMn[3:2] == 2'b00) || (WGMn[3:2] == 2'b10)) && (CntnDir == 1'b1))begin // pwm phase correct & pwm phase and feq correct
								if (TCNTn == 16'h0000) begin
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
			// if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)	begin	// !!!Special mode!!!
				// if (IO_Addr == TIFRn_Address && iowe) begin		// Write to OCFnA
					// TIFRn[1] <= dbus_in[1];
				// end
			// end else begin
				case (TIFRn[1])
					1'b0 :
						if (tmr_cp2en & clk_en == 1'b1) begin
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
			// if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)	begin	// !!!Special mode!!!
				// if (IO_Addr == TIFRn_Address && iowe) begin		// Write to OCFnB
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
	
	always @(posedge cp2 or negedge ireset) 
	begin: ICFn_Reg
		if (!ireset) begin		// Reset
			TIFRn[5] <= 1'b0;
		end else begin        // Clock
			// if (stopped_mode == 1'b1 & tmr_running == 1'b0 & cp2en)	begin	// !!!Special mode!!!
				// if (IO_Addr == TIFRn_Address && iowe) begin		// Write to ICFn
					// TIFRn[5] <= dbus_in[5];
				// end
			// end else begin
				case (TIFRn[5])
					1'b0 :
						if (tmr_cp2en & clk_en == 1'b1) begin
							if ((WGMn[3] == 1'b1 && WGMn[0] == 1'b0 && TCNTn == TOP) || ICPn_en ) begin
								TIFRn[5] <= 1'b1;
							end 
						end
					1'b1 :
						if ((TCnICpIRQ_Ack == 1'b1 | (IO_Addr == TIFRn_Address && iowe & (dbus_in[5] == 1'b1))) & cp2en) begin
							TIFRn[5] <= 1'b0;
						end
					default : 
					;
				endcase
			// end
		end	
	end

		// add initial condition
	always@(posedge cp2 or negedge ireset)
	begin
		if (!ireset) begin
			TIFRn[7:6] <= 0;
			TIFRn[4:3] <= 0;
		end
		else begin
			TIFRn[7:6] <= 0;
			TIFRn[4:3] <= 0;
		end
	end
	
	always @(posedge cp2 or negedge ireset)
	begin: TIMSKn_reg
		if (!ireset) begin
			TIMSKn <= {8{1'b0}};
		end else begin
			if (cp2en)begin	// Clock Enable	
				if (ram_Addr == TIMSKn_Address && ramwe)begin
					TIMSKn[5] <= dbus_in[5];
					TIMSKn[2:0] <= dbus_in[2:0];
				end
			end
		end
	end
	
	assign TCnOvfIRQ = TIFRn[0] & TIMSKn[0];		// Interrupt on overflow of TCNTn
	assign TCnCmpAIRQ = TIFRn[1] & TIMSKn[1];		// Interrupt on compare match A	of TCNTn
	assign TCnCmpBIRQ = TIFRn[2] & TIMSKn[2];		// Interrupt on compare match B	of TCNTn
	assign TCnICpIRQ = TIFRn[5] & TIMSKn[5];		// Interrupt on input capture of TCNTn
	
	always @(*)
	begin: OutMuxComb
		if (iore) begin
			case (IO_Addr)
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
				TCCRnA_Address :
					begin
						dbus_out <= TCCRnA;
						out_en <= ramre;
					end
				TCCRnB_Address :
					begin
						dbus_out <= TCCRnB;
						out_en <= ramre;
					end
				TCCRnC_Address :
					begin
						dbus_out <= {2'b00,TCCRnC[5:0]};
						out_en <= ramre;
					end
				TCNTnL_Address :
					begin
						dbus_out <= TCNTn[7:0];
						out_en <= ramre;
					end
				TCNTnH_Address :
					begin
						dbus_out <= Temp;
						out_en <= ramre;
					end
				OCRnAL_Address :
					begin
						dbus_out <= OCRnA_buf[7:0];
						out_en <= ramre;
					end
				OCRnAH_Address :
					begin
						dbus_out <= OCRnA_buf[15:8];
						out_en <= ramre;
					end
				OCRnBL_Address :
					begin
						dbus_out <= OCRnB_buf[7:0];
						out_en <= ramre;
					end
				OCRnBH_Address :
					begin
						dbus_out <= OCRnB_buf[15:8];
						out_en <= ramre;
					end
				TIMSKn_Address :
					begin
						dbus_out <= TIMSKn ;
						out_en <= ramre;
					end 
				ICRnL_Address :
					begin
						dbus_out <= ICRn[7:0] ;
						out_en <= ramre;
					end
				ICRnH_Address :
					begin
						dbus_out <= Temp ;
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
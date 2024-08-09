`timescale 1 ns / 1 ns
module SPI_1	
	#(
	parameter [11:0] SPCRn_Address = 12'h0AC , // SPCR1
	parameter [11:0] SPSRn_Address = 12'h0AD , // SPSR1
	parameter [11:0] SPDRn_Address = 12'h0AE , // SPDR1
	parameter [5:0] SpiIRQ_Address = 6'h27
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
	
	input wire              miso_i,     // Master mode
	input wire              mosi_i,		// Slave mode
	input wire              sck_i,		// Slave mode
	input wire              ss_i,		// Slave/Master mode
	output wire             ss_o,		// Master mode
	output reg          	miso_o,		// Slave mode
	output reg          	mosi_o,		// Master mode
	output reg          	sck_o,		// Master mode
	// IRQ
	output wire             SpiIRQ,
	input [5:0]		 		irqack_addr,
	input			 		irqack,
	// input wire              SpiIRQ_Ack,
	
	// input wire              por;
	// input wire              spiextload;
	
	output                  SPE1 ,
	output 					MSTR1			
	);
	
	reg [7:0]	SPCRn ;
	reg [7:0]	SPSRn ;
	// reg [7:0]	SPDRn ;
	// reg [7:0]	SPDRn_buf ;	

	reg SPIF_Next;
	reg WCOL_Next; 

	reg [7:0]           SPDR_Rc;
	reg [7:0]           SPDR_Rc_Next;
	reg [7:0]           SPDR_Sh_Current;
	reg [7:0]           SPDR_Sh_Next;
   
	reg [5:0]           Div_Next;
	reg [5:0]           Div_Current;
	reg                 Div_Toggle;
   
	reg                 DivCntMsb_Current;
	reg                 DivCntMsb_Next;
   
	localparam [3:0]     MstSMSt_Type_MstSt_Idle = 0,
						MstSMSt_Type_MstSt_B0 = 1,
						MstSMSt_Type_MstSt_B1 = 2,
						MstSMSt_Type_MstSt_B2 = 3,
						MstSMSt_Type_MstSt_B3 = 4,
						MstSMSt_Type_MstSt_B4 = 5,
						MstSMSt_Type_MstSt_B5 = 6,
						MstSMSt_Type_MstSt_B6 = 7,
						MstSMSt_Type_MstSt_B7 = 8;
	reg [3:0]           MstSMSt_Current;
	reg [3:0]           MstSMSt_Next;
   
	wire                TrStart;
   
	reg                 scko_Next;
	reg                 scko_Current;		//!!!
   
	reg                 UpdRcDataRg_Current;
	reg                 UpdRcDataRg_Next;
   
	reg                 TmpIn_Current;
	reg                 TmpIn_Next;
   
	// Slave
	reg                 sck_EdgeDetDFF;
	wire                SlvSampleSt;
   
	wire                SlvSMChangeSt;
   
	localparam [3:0]     SlvSMSt_Type_SlvSt_Idle = 0,
						SlvSMSt_Type_SlvSt_B0I = 1,
						SlvSMSt_Type_SlvSt_B0 = 2,
						SlvSMSt_Type_SlvSt_B1 = 3,
						SlvSMSt_Type_SlvSt_B2 = 4,
						SlvSMSt_Type_SlvSt_B3 = 5,
						SlvSMSt_Type_SlvSt_B4 = 6,
						SlvSMSt_Type_SlvSt_B5 = 7,
						SlvSMSt_Type_SlvSt_B6 = 8,
						SlvSMSt_Type_SlvSt_B6W = 9;
	reg [3:0]           SlvSMSt_Current;
	reg [3:0]           SlvSMSt_Next;
   
	// SIF clear SM
	reg                 SPIFClrSt_Current;
	reg                 SPIFClrSt_Next;
   
	// WCOL clear SM
	reg                 WCOLClrSt_Current;
	reg                 WCOLClrSt_Next;
   
	reg                 MstDSamp_Next;
	reg                 MstDSamp_Current;
	
	wire				SpiIRQ_Ack;

	function[7:0] Fn_RevBitVector;
		input [7:0]        InVector;
		input  integer    Dummy_Agr;
		begin
			Fn_RevBitVector = {InVector[0],InVector[1],InVector[2],InVector[3],InVector[4],InVector[5],InVector[6],InVector[7]};
		end
	endfunction

	assign SPE1 = SPCRn[6];
	assign MSTR1 = SPCRn[4];
	assign SpiIRQ_Ack = (irqack_addr == SpiIRQ_Address) && irqack ;
	
	always @(negedge ireset or posedge cp2)
	begin : SPCRn_REG
		if (!ireset) begin		// Reset
			SPCRn <= {8{1'b0}};
		end else begin		// Clock
			if (ram_Addr == SPCRn_Address && ramwe) begin
				SPCRn[7:5] <= dbus_in[7:5];
				SPCRn[3:0] <= dbus_in[3:0];
			end
			case (SPCRn[4])
				1'b0 :
					if (ram_Addr == SPCRn_Address & ramwe == 1'b1 & dbus_in[4] == 1'b1) begin		
						SPCRn[4] <= 1'b1;
					end
				1'b1 :
					if ((ram_Addr == SPCRn_Address & ramwe == 1'b1 & dbus_in[4] == 1'b0) | (ss_i == 1'b0)) begin 
						SPCRn[4] <= 1'b0;
					end
				// default :
				// 	SPCRn[4] <= SPCRn[4];
			endcase
		end
	end
	
	always @(negedge ireset or posedge cp2)
	begin : SPI2X_bit
		if (!ireset) begin		// Reset
			SPSRn[0] <= 1'b0 ;
		end else begin		// Clock
			if (ram_Addr == SPSRn_Address && ramwe) begin
				SPSRn[0] <= dbus_in[0];
			end
		end
	end
	
	always @(negedge ireset or posedge cp2)
	begin : SeqPrc
		if (!ireset) begin		// Reset
			SPSRn[7:1] <= {7{1'b0}};
			
			Div_Current <= {6{1'b0}};
			DivCntMsb_Current <= 1'b0;

			MstSMSt_Current <= MstSMSt_Type_MstSt_Idle;
			SlvSMSt_Current <= SlvSMSt_Type_SlvSt_Idle;

			SPDR_Sh_Current <= {8{1'b1}};
			SPDR_Rc <= {8{1'b0}};

			sck_EdgeDetDFF <= 1'b0;
			SPIFClrSt_Current <= 1'b0;
			WCOLClrSt_Current <= 1'b0;

			sck_o <= 1'b0;
			scko_Current <= 1'b0;
			miso_o <= 1'b0;
			mosi_o <= 1'b0;

			TmpIn_Current <= 1'b0;
			UpdRcDataRg_Current <= 1'b0;
			MstDSamp_Current <= 1'b0;
		end else begin // Clock
			SPSRn[7] <= SPIF_Next;
			SPSRn[6] <= WCOL_Next;

			Div_Current <= Div_Next;
			DivCntMsb_Current <= DivCntMsb_Next;
			MstSMSt_Current <= MstSMSt_Next;
			SlvSMSt_Current <= SlvSMSt_Next;
			SPDR_Sh_Current <= SPDR_Sh_Next;
			SPDR_Rc <= SPDR_Rc_Next;
			sck_EdgeDetDFF <= sck_i;
			SPIFClrSt_Current <= SPIFClrSt_Next;
			WCOLClrSt_Current <= WCOLClrSt_Next;

			scko_Current <= scko_Next;
			sck_o <= scko_Next;
			miso_o <= SPDR_Sh_Next[7];
			mosi_o <= SPDR_Sh_Next[7];

			TmpIn_Current <= TmpIn_Next;
			UpdRcDataRg_Current <= UpdRcDataRg_Next;
			MstDSamp_Current <= MstDSamp_Next;
		end
	end // SeqPrc 
	
	always @(MstSMSt_Current or Div_Current or SPCRn or SPSRn)
	begin : DividerToggleComb
		Div_Toggle = 1'b0;
		if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle) begin
			if (SPSRn[0] == 1'b1) begin		// Extended mode
				case (SPCRn[1:0])
					2'b00 :		// fosc /2
						if (Div_Current == 6'b000000) begin
							Div_Toggle = 1'b1;
						end
					2'b01 :		// fosc /8
						if (Div_Current == 6'b000011) begin
							Div_Toggle = 1'b1;
						end
					2'b10 :		// fosc /32
						if (Div_Current == 6'b001111) begin
							Div_Toggle = 1'b1;
						end
					2'b11 :		// fosc /64
						if (Div_Current == 6'b011111) begin
							Div_Toggle = 1'b1;
						end
					// default :
					// 	Div_Toggle = 1'b0;
				endcase
			end else begin // Normal mode
				case (SPCRn[1:0])
					2'b00 :		// fosc /4	  
						if (Div_Current == 6'b000001) begin
							Div_Toggle = 1'b1;
						end
					2'b01 :		// fosc /16
						if (Div_Current == 6'b000111) begin
							Div_Toggle = 1'b1;
						end
					2'b10 :		// fosc /64
						if (Div_Current == 6'b011111) begin
							Div_Toggle = 1'b1;
						end
					2'b11 :		// fosc /128
						if (Div_Current == 6'b111111) begin
							Div_Toggle = 1'b1;
						end
					// default :
					// 	Div_Toggle = 1'b0;
				endcase
			end
		end
	end
   
   
	always @(MstSMSt_Current or Div_Current or DivCntMsb_Current or Div_Toggle)
	begin : DividerNextComb
		Div_Next = Div_Current;
		DivCntMsb_Next = DivCntMsb_Current;
		if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle) begin
			if (Div_Toggle == 1'b1)begin
				Div_Next = {6{1'b0}};
				DivCntMsb_Next = (~DivCntMsb_Current);
			end else begin
				Div_Next = Div_Current + 1;
			end
		end
    end
   
	assign TrStart = ((ram_Addr == SPDRn_Address & ramwe == 1'b1 & SPCRn[6] == 1'b1)) ? 1'b1 : 1'b0;
   
   // Transmitter Master Mode Shift Control SM
   
	always @(MstSMSt_Current or DivCntMsb_Current or Div_Toggle or TrStart or SPCRn)
	begin : MstSmNextComb
		MstSMSt_Next = MstSMSt_Current;
		case (MstSMSt_Current)
			MstSMSt_Type_MstSt_Idle :
				if (TrStart == 1'b1 & SPCRn[4] == 1'b1) begin
					MstSMSt_Next = MstSMSt_Type_MstSt_B0;
				end
			MstSMSt_Type_MstSt_B0 :
				if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) begin
					MstSMSt_Next = MstSMSt_Type_MstSt_B1;
				end
			MstSMSt_Type_MstSt_B1 :
				if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) begin
					MstSMSt_Next = MstSMSt_Type_MstSt_B2;
				end
			MstSMSt_Type_MstSt_B2 :
				if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) begin
					MstSMSt_Next = MstSMSt_Type_MstSt_B3;
				end
			MstSMSt_Type_MstSt_B3 :
				if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) begin
					MstSMSt_Next = MstSMSt_Type_MstSt_B4;
				end
			MstSMSt_Type_MstSt_B4 :
				if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) begin
					MstSMSt_Next = MstSMSt_Type_MstSt_B5;
				end
			MstSMSt_Type_MstSt_B5 :
				if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) begin
					MstSMSt_Next = MstSMSt_Type_MstSt_B6;
				end
			MstSMSt_Type_MstSt_B6 :
				if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) begin
					MstSMSt_Next = MstSMSt_Type_MstSt_B7;
				end
			MstSMSt_Type_MstSt_B7 :
				if (DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) begin
					MstSMSt_Next = MstSMSt_Type_MstSt_Idle;
				end
			default :
				MstSMSt_Next = MstSMSt_Type_MstSt_Idle;
		endcase
	end
   
   
	always @(SPIFClrSt_Current or SPCRn or SPSRn or ram_Addr or ramre or ramwe)
	begin : SPIFClrCombProc
		SPIFClrSt_Next = SPIFClrSt_Current;
		case (SPIFClrSt_Current)
			1'b0 :
				if (ram_Addr == SPSRn_Address & ramre == 1'b1 & SPSRn[7] == 1'b1 & SPCRn[6] == 1'b1) begin
					SPIFClrSt_Next = 1'b1;
				end
			1'b1 :
				if (ram_Addr == SPDRn_Address & (ramre == 1'b1 | ramwe == 1'b1)) begin
					SPIFClrSt_Next = 1'b0;
				end
			// default :
			// 	SPIFClrSt_Next = SPIFClrSt_Current;
		endcase
	end  //SPIFClrCombProc
      
      
    always @(WCOLClrSt_Current or SPSRn or ram_Addr or ramre or ramwe)
    begin : WCOLClrCombProc
        WCOLClrSt_Next = WCOLClrSt_Current;
        case (WCOLClrSt_Current)
			1'b0 :
				if (ram_Addr == SPSRn_Address & ramre == 1'b1 & SPSRn[6] == 1'b1) begin 
					WCOLClrSt_Next = 1'b1;
				end
            1'b1 :
				if (ram_Addr == SPDRn_Address & (ramre == 1'b1 | ramwe == 1'b1)) begin
					WCOLClrSt_Next = 1'b0;
				end
            // default :
			// 	WCOLClrSt_Next = WCOLClrSt_Current;
        endcase
    end //WCOLClrCombProc
         
         
    always @(SPCRn or scko_Current or scko_Next or MstDSamp_Current or MstSMSt_Current)
    begin : MstDataSamplingComb
        MstDSamp_Next = 1'b0;
        case (MstDSamp_Current)
            1'b0 :
				if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle) begin
                    if (SPCRn[2] == SPCRn[3]) begin
                        if (scko_Next == 1'b1 & scko_Current == 1'b0) begin		// Rising edge 	  
                           MstDSamp_Next = 1'b1;
						end
                    end else begin // CPHA/=CPOL
                        if (scko_Next == 1'b0 & scko_Current == 1'b1) begin		// Falling edge 	  
                           MstDSamp_Next = 1'b1;
						end
					end
                end
            1'b1 :
                MstDSamp_Next = 1'b0;
            // default :
            //     MstDSamp_Next = 1'b0;
        endcase
    end // MstDataSamplingComb
            
            //
            
    always @(UpdRcDataRg_Current or MstSMSt_Current or MstSMSt_Next or SlvSMSt_Current or SlvSMSt_Next or SPCRn)
    begin : DRLatchComb
        UpdRcDataRg_Next = 1'b0;
        case (UpdRcDataRg_Current)
            1'b0 :
                if ((SPCRn[4] == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle & MstSMSt_Next == MstSMSt_Type_MstSt_Idle) | (SPCRn[4] == 1'b0 & SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle & SlvSMSt_Next == SlvSMSt_Type_SlvSt_Idle)) begin
                    UpdRcDataRg_Next = 1'b1;
				end
            1'b1 :
                UpdRcDataRg_Next = 1'b0;
			// default :
			// 	UpdRcDataRg_Next = 1'b0;
        endcase
    end
            
            
    always @(TmpIn_Current or mosi_i or miso_i or MstDSamp_Current or SlvSampleSt or SPCRn or ss_i)
    begin : TmpInComb
        TmpIn_Next = TmpIn_Current;
        if (SPCRn[4] == 1'b1 & MstDSamp_Current == 1'b1) begin		// Master mode
            TmpIn_Next = miso_i;
        end else if (SPCRn[4] == 1'b0 & SlvSampleSt == 1'b1 & ss_i == 1'b0) begin		// Slave mode ???
            TmpIn_Next = mosi_i;
		end
    end

    always @(MstSMSt_Current or SlvSMSt_Current or SPDR_Sh_Current or SPCRn or DivCntMsb_Current or Div_Toggle or TrStart or dbus_in or ss_i or TmpIn_Current or SlvSMChangeSt or SlvSampleSt or UpdRcDataRg_Current)
    begin : ShiftRgComb
        SPDR_Sh_Next = SPDR_Sh_Current;
        if (TrStart == 1'b1 & (MstSMSt_Current == MstSMSt_Type_MstSt_Idle & SlvSMSt_Current == SlvSMSt_Type_SlvSt_Idle & (~(SPCRn[4] == 1'b0 & SlvSampleSt == 1'b1 & ss_i == 1'b0)))) begin		// Load
            if (SPCRn[5] == 1'b1) begin		// the LSB of the data word is transmitted first
				SPDR_Sh_Next = Fn_RevBitVector(dbus_in, 8);
            end else begin// the MSB of the data word is transmitted first
                SPDR_Sh_Next = dbus_in;
			end
        end else if (SPCRn[4] == 1'b1 & UpdRcDataRg_Current == 1'b1) begin	 	// ???
                  SPDR_Sh_Next[7] = 1'b1;
        end else if ((SPCRn[4] == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle & DivCntMsb_Current == 1'b1 & Div_Toggle == 1'b1) | (SPCRn[4] == 1'b0 & SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle & SlvSMChangeSt == 1'b1 & ss_i == 1'b0)) begin
                  // Shift
            SPDR_Sh_Next = {SPDR_Sh_Current[7 - 1:0], TmpIn_Current};
		end
	end //ShiftRgComb
               
               
	always @(scko_Current or SPCRn or ram_Addr or ramwe or dbus_in or DivCntMsb_Next or DivCntMsb_Current or TrStart or MstSMSt_Current or MstSMSt_Next)
	begin : sckoGenComb
		scko_Next = scko_Current;
		if (ram_Addr == SPCRn_Address & ramwe == 1'b1) begin		// Write to SPCR
			scko_Next = dbus_in[3];		// CPOL
		end else if (TrStart == 1'b1 & SPCRn[2] == 1'b1 & MstSMSt_Current == MstSMSt_Type_MstSt_Idle) begin
			scko_Next = (~SPCRn[3]);
		end else if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle & MstSMSt_Next == MstSMSt_Type_MstSt_Idle) begin		// "Parking"
			scko_Next = SPCRn[3];
		end else if (MstSMSt_Current != MstSMSt_Type_MstSt_Idle & DivCntMsb_Current != DivCntMsb_Next) begin
			scko_Next = (~scko_Current);
		end
	end
               
    // Receiver data register
               
	always @(SPDR_Rc or SPCRn or SPDR_Sh_Current or UpdRcDataRg_Current or TmpIn_Current)
	begin : SPDRRcComb
		SPDR_Rc_Next = SPDR_Rc;
		if (UpdRcDataRg_Current == 1'b1) begin
			if (SPCRn[4] == 1'b0 & SPCRn[2] == 1'b1) begin
				if (SPCRn[5] == 1'b1) begin		// the LSB of the data word is transmitted first
					SPDR_Rc_Next = Fn_RevBitVector({SPDR_Sh_Current[7 - 1:0], TmpIn_Current}, 2);
				end else begin // the MSB of the data word is transmitted first
					SPDR_Rc_Next = {SPDR_Sh_Current[7 - 1:0], TmpIn_Current};
				end
			end else begin
				if (SPCRn[5] == 1'b1) begin		// the LSB of the data word is transmitted first
					SPDR_Rc_Next = Fn_RevBitVector(SPDR_Sh_Current, 8);
				end else begin // the MSB of the data word is transmitted first
					SPDR_Rc_Next = SPDR_Sh_Current;
				end
			end
		end
	end
               
	//****************************************************************************************			
	// Slave
	//****************************************************************************************

	// Rising edge 
	assign SlvSampleSt = (((sck_EdgeDetDFF == 1'b0 & sck_i == 1'b1 & SPCRn[3] == SPCRn[2]) | (sck_EdgeDetDFF == 1'b1 & sck_i == 1'b0 & SPCRn[3] != SPCRn[2]))) ? 1'b1 : 		// Falling edge
						1'b0;

	// Falling edge 
	assign SlvSMChangeSt = (((sck_EdgeDetDFF == 1'b1 & sck_i == 1'b0 & SPCRn[3] == SPCRn[2]) | (sck_EdgeDetDFF == 1'b0 & sck_i == 1'b1 & SPCRn[3] != SPCRn[2]))) ? 1'b1 : 		// Rising edge
						  1'b0;

	// Slave Master Mode Shift Control SM
               
	always @(SlvSMSt_Current or SPCRn or SlvSampleSt or SlvSMChangeSt or ss_i)
	begin : SlvSMNextComb
		SlvSMSt_Next = SlvSMSt_Current;
		if (ss_i == 1'b0) begin
			case (SlvSMSt_Current)
				SlvSMSt_Type_SlvSt_Idle :
					if (SPCRn[4] == 1'b0) begin
						if (SPCRn[2] == 1'b1) begin
							if (SlvSMChangeSt == 1'b1) begin
								SlvSMSt_Next = SlvSMSt_Type_SlvSt_B0;
							end
						end else begin //	CPHA='0'
							if (SlvSampleSt == 1'b1) begin
								SlvSMSt_Next = SlvSMSt_Type_SlvSt_B0I;
							end
						end
					end
				SlvSMSt_Type_SlvSt_B0I :
					if (SlvSMChangeSt == 1'b1) begin
						SlvSMSt_Next = SlvSMSt_Type_SlvSt_B0;
					end
				SlvSMSt_Type_SlvSt_B0 :
					if (SlvSMChangeSt == 1'b1) begin
						SlvSMSt_Next = SlvSMSt_Type_SlvSt_B1;
					end
				SlvSMSt_Type_SlvSt_B1 :
					if (SlvSMChangeSt == 1'b1) begin
						SlvSMSt_Next = SlvSMSt_Type_SlvSt_B2;
					end
				SlvSMSt_Type_SlvSt_B2 :
					if (SlvSMChangeSt == 1'b1) begin
						SlvSMSt_Next = SlvSMSt_Type_SlvSt_B3;
					end
				SlvSMSt_Type_SlvSt_B3 :
					if (SlvSMChangeSt == 1'b1) begin
						SlvSMSt_Next = SlvSMSt_Type_SlvSt_B4;
					end
				SlvSMSt_Type_SlvSt_B4 :
					if (SlvSMChangeSt == 1'b1) begin
						SlvSMSt_Next = SlvSMSt_Type_SlvSt_B5;
					end
				SlvSMSt_Type_SlvSt_B5 :
					if (SlvSMChangeSt == 1'b1) begin
						SlvSMSt_Next = SlvSMSt_Type_SlvSt_B6;
					end
				SlvSMSt_Type_SlvSt_B6 :
					if (SlvSMChangeSt == 1'b1) begin
						if (SPCRn[2] == 1'b0) begin
							SlvSMSt_Next = SlvSMSt_Type_SlvSt_Idle;
						end else begin// CPHA='1'
							SlvSMSt_Next = SlvSMSt_Type_SlvSt_B6W;
						end
					end
				SlvSMSt_Type_SlvSt_B6W :
					if (SlvSampleSt == 1'b1) begin
						SlvSMSt_Next = SlvSMSt_Type_SlvSt_Idle;
					end
				default :
					SlvSMSt_Next = SlvSMSt_Type_SlvSt_Idle;
			endcase
		end
	end
               
               
	// always @(adr or iowe or dbus_in or ss_b_resync or SPCR)
	// begin: MSTRGenComb
		// MSTR_Next = `MSTR;
		// case (`MSTR)
			// 1'b0 :
				// if (adr == SPCR_Address & iowe == 1'b1 & dbus_in[4] == 1'b1)		// TBD (ss_b_resync='0')
					// MSTR_Next = 1'b1;
			// 1'b1 :
				// if ((adr == SPCR_Address & iowe == 1'b1 & dbus_in[4] == 1'b0) | (ss_b_resync == 1'b0))
					// MSTR_Next = 1'b0;
			// default :
				// MSTR_Next = `MSTR;
		// endcase
	// end


	always @(WCOLClrSt_Current or SlvSMSt_Current or MstSMSt_Current or ram_Addr or ramwe or ramre or SPCRn or SPSRn or SlvSampleSt or ss_i)
	begin : WCOLGenComb
		WCOL_Next = SPSRn[6];
		case (SPSRn[6])
			1'b0 :
				if (ram_Addr == SPDRn_Address & ramwe == 1'b1 & ((SPCRn[4] == 1'b0 & (SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle | (SlvSampleSt == 1'b1 & ss_i == 1'b0))) | (SPCRn[4] == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle)))
					WCOL_Next = 1'b1;
			1'b1 :
				if (((ram_Addr == SPDRn_Address & (ramwe == 1'b1 | ramre == 1'b1)) & WCOLClrSt_Current == 1'b1) & (~(ram_Addr == SPDRn_Address & ramwe == 1'b1 & ((SPCRn[4] == 1'b0 & (SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle | (SlvSampleSt == 1'b1 & ss_i == 1'b0))) | (SPCRn[4] == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle)))))
					WCOL_Next = 1'b0;
			// default :
			// 	WCOL_Next = SPSRn[6];
		endcase
	end


	always @(SPIFClrSt_Current or ram_Addr or ramwe or ramre or SPCRn or SPSRn or SlvSMSt_Current or SlvSMSt_Next or MstSMSt_Current or MstSMSt_Next or SpiIRQ_Ack)
	begin : SPIFGenComb
		SPIF_Next = SPSRn[7];
		case (SPSRn[7])
			1'b0 :
				if ((SPCRn[4] == 1'b0 & SlvSMSt_Current != SlvSMSt_Type_SlvSt_Idle & SlvSMSt_Next == SlvSMSt_Type_SlvSt_Idle) | (SPCRn[4] == 1'b1 & MstSMSt_Current != MstSMSt_Type_MstSt_Idle & MstSMSt_Next == MstSMSt_Type_MstSt_Idle))
					SPIF_Next = 1'b1;
			1'b1 :
				if ((ram_Addr == SPDRn_Address & (ramwe == 1'b1 | ramre == 1'b1) & SPIFClrSt_Current == 1'b1) | SpiIRQ_Ack == 1'b1)
					SPIF_Next = 1'b0;
			// default :
			// 	SPIF_Next = SPSRn[7];
		endcase
	end

	//*************************************************************************************

	// IRQ
	assign SpiIRQ = SPCRn[7] & SPSRn[7];
	
	always @(*)
	begin: OutMuxComb
		// if (iore) begin
			case (ram_Addr)
				SPCRn_Address :
					begin
						dbus_out <= SPCRn;
						out_en <= ramre;
					end
				SPSRn_Address :
					begin
						dbus_out <= SPSRn;
						out_en <= ramre;
					end
				SPDRn_Address :
					begin
						dbus_out <= SPDR_Rc;
						out_en <= ramre;
					end
				default :
					begin
						dbus_out <= {8{1'b0}};
						out_en <= 1'b0;
					end
			endcase
		// end else if (ramre) begin
			// case (ram_Addr)
				// TIMSKn_Address :
					// begin
						// dbus_out <= TIMSKn ;
						// out_en <= ramre;
					// end 
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
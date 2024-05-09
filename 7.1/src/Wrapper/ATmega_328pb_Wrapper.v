`timescale 1 ps / 1 ps
module ATmega_328pb_Wrapper
	#(
	parameter			impl_mul    = 1,
	parameter			use_rst     = 1,
   	parameter			pc22b       = 0, 
   	parameter			eind_width  = 0,
	parameter			ram_depth  = 12,
   	parameter			rampz_width = 0,
   	parameter			irqs_width  = 45
	)
	(
	input wire 			nrst,
	input wire 			clk,
	input wire 			pwr_on_nrst,
	
	output wire [13:0]	pc ,
	input wire [15:0]	inst_i ,
	
	output wire [11:0]  ram_Addr,
	output wire        	ramre ,
	output wire			ramwe ,	
	output wire [7:0] 	dbus_out ,
	input [7:0] 		dbus_in ,
	
	// PORTB related 
	output wire[7:0]  	pu_B,
	output wire[7:0]  	dd_B,
	output wire[7:0]  	pv_B,
	output wire[7:0]  	die_B,
	input wire[7:0]   	PINB_i,
	
	// PORTC related 
	output wire[6:0]  	pu_C,
	output wire[6:0]  	dd_C,
	output wire[6:0]  	pv_C,
	output wire[6:0]  	die_C,
	input wire[6:0]  	PINC_i,
	
	// PORTD related 
	output wire[7:0]  	pu_D,
	output wire[7:0]  	dd_D,
	output wire[7:0]  	pv_D,
	output wire[7:0]  	die_D,
	input wire[7:0]  	PIND_i,
	
	// PORTE related 
	output wire[3:0]  	pu_D,
	output wire[3:0]  	dd_D,
	output wire[3:0]  	pv_D,
	output wire[3:0]  	die_D,
	input wire[3:0]   	PINE_i,
	
	// // Timer related
	// input wire   		tmr_ext_1,
	// input wire     		tmr_ext_2,
	
	
	
	// // USART0 related
	// input wire      	rxd_0,
	// output wire        	txd_0, 
	// output wire       	RXEN0,        
	// output wire      	TXEN0,
	// input wire			XCK0_i ,
	// output wire 		XCK0_o ,
	
	// // USART1 related
	// input wire      	rxd_1,
	// output wire      	txd_1, 
	// output wire       	RXEN1,        
	// output wire      	TXEN1,
	// input wire			XCK1_i ,
	// output wire 		XCK1_o ,
	
	// // SPI0 related
	// input wire	  		miso_i_0,   
	// input wire	     	mosi_i_0,   
	// input wire	      	sck_i_0,    
	// input wire	      	ss_b_0,  
	// output wire       	miso_o_0,	
	// output wire       	mosi_o_0,	
	// output wire      	sck_o_0,	
	// output wire       	SPE0,        
	// output wire      	MSTR0,
	
	// // SPI1 related
	// input wire	  		miso_i_1,   
	// input wire	     	mosi_i_1,   
	// input wire	      	sck_i_1,    
	// input wire	      	ss_b_1,  
	// output wire       	miso_o_1,	
	// output wire       	mosi_o_1,	
	// output wire      	sck_o_1,	
	// output wire       	SPE1,        
	// output wire      	MSTR1,
	
	
	
	);
	
	localparam	Pres_Rst = 0,
				TC_0 = 1,
				TC_1 = 2,
				TC_2 = 3,
				TC_3 = 4,
				TC_4 = 5,
				Spi_0= 6,
				Spi_1= 7,
				Usart_0=8,
				Usart_1=9,
				Mcucr =10,
				P_B =11,
				P_C =12,
				P_D =13,
				P_E =14;
				
	wire					cp2;
	wire 					jtag_cp2en; 
	wire					core_ireset;
	wire 					core_valid_instr;
	wire 					core_insert_nop;
	wire 					core_block_irq;
	wire 					core_change_flow;
	wire [13:0] 			core_pc;
	wire [15:0]				core_inst; 
	wire [5:0] 				core_adr; 
	wire 					core_iore; 
	wire 					core_iowe; 
	wire [ram_depth-1:0] 	core_ramadr; 
	wire 					core_ramre; 
	wire 					core_ramwe; 
	wire 					core_cpuwait; 
	wire [7:0] 				core_dbusout; 
	wire [7:0] 				core_dbusin; 
	wire [irqs_width-1:0] 	core_irqlines;
	wire      				core_irqack;
	wire [5:0] 				core_irqackad;
	wire 					core_sleepi; 
	wire 					core_irqok; 
	wire 					core_globint; 
	wire 					core_wdri;
	wire [15:0] 			core_spm_out; 
	wire 					core_spm_inst; 
	wire 					core_spm_wait;
	wire [7:0]				ext_dbus;
	wire 					jtag_tmr_cp2en;
	wire 					pres0_rst ;
	wire					pres0_clk8en ;
	wire					pres0_clk16en ;
	wire					pres0_clk256en ;
	wire					pres0_clk1024en ;
	wire 					pres1_rst ;
	wire					cs0 ;
	wire					cs1 ;
	wire					cs2 ;
	wire					cs3 ;
	wire					cs4 ;
	wire					clk_en_0 ;
	wire					clk_en_1 ;
	wire					clk_en_2 ;
	wire					clk_en_3 ;
	wire					clk_en_4 ;
	wire					clk_t2 ;
	wire					AS2 ;
	wire					EXCLK;
	wire					SPE0;
	wire					MSTR0;
	wire					SPE1;
	wire					MSTR1;
	wire					RXEN0;
	wire					TXEN0;
	wire					RXEN1;
	wire					TXEN1;
	wire					BODS;
	wire					BODSE;
	wire					PUD;
	wire					IVSEL;
	wire					IVCE;
	wire					UMSEL0;
	wire					UMSEL1;
	wire					OC2A_EN;
	wire					OC1B_EN;
	wire					OC1A_EN;
	wire					SCK0_OUT;
	wire					XCK1_OUT;
	wire					SPI0_SL_OUT;
	wire					OC2A;
	wire					OC1B;
	wire					OC1A;
	wire					SPI0_MT_OUT;
	wire					TXD1;
	wire [27:0]				pcint;
	wire					PCIE0;
	wire					PCIE1;
	wire					PCIE2;
	wire					PCIE3;
	wire					SLEEP;
	wire					INTRC;
	wire					RSTDISBL;
	wire					TWEN0;
	wire					SCK1_OUT;
	wire					SPI1_SL_OUT;
	wire					SCL0_OUT;
	wire					SDA0_OUT;
	wire [7:0]				ADCxD;
	wire					OC0A_EN;
	wire					OC0B_EN;
	wire					OC2B_EN;
	wire					OC3B_EN;
	wire					OC4B_EN;
	wire					OC4A_EN;
	wire					OC3A_EN;
	wire					XCK0_OUT;
	wire					OC0A;
	wire					OC0B;
	wire					OC2B;
	wire					OC3B;
	wire					OC4B;
	wire					OC4A;
	wire					OC3A;
	wire					TXD0;
	wire					INT1_EN;
	wire					INT0_EN;
	wire					TWEN1;
	wire					SCK1_OUT;
	wire					SPI1_MT_OUT;
	wire					SCL1_OUT;
	wire					SDA1_OUT;
	wire					DDR_XCK0;
	wire					DDR_XCK1;
	wire					aco_oe;
	wire					acompout;
	wire [7:0] 				data_bus[0:20] ;
	wire 					d_en_bus[0:20] ;	
	wire [7:0]				io_data;
	// wire [7:0]				sram_data;
	// wire [7:0] 				core_data;
	
	wire [7:0]				pu_B_int;
	wire [7:0]  			dd_B_int;
	wire [7:0]  			pv_B_int;
	wire [7:0]  			die_B_int;
	wire [7:0]				pinB_int;
	wire [7:0]				DIB_int;
	
	wire [6:0]				pu_C_int;
	wire [6:0]  			dd_C_int;
	wire [6:0]  			pv_C_int;
	wire [6:0]  			die_C_int;
	wire [6:0]				pinC_int;	
	wire [6:0]				DIC_int;
	
	wire [7:0]				pu_D_int;
	wire [7:0]  			dd_D_int;
	wire [7:0]  			pv_D_int;
	wire [7:0]  			die_D_int;
	wire [7:0]				pinD_int;	
	wire [7:0]				DID_int;
	
	wire [3:0]				pu_E_int;
	wire [3:0]  			dd_E_int;
	wire [3:0]  			pv_E_int;
	wire [3:0]  			die_E_int;
	wire [3:0]				pinE_int;	
	wire [3:0]				DIE_int;
	
	assign cp2 = clk;
	assign jtag_cp2en = 1'b1;
	assign core_insert_nop  = 1'b0;
	assign core_block_irq   = 1'b0;
	assign pc = core_pc;
	assign core_inst = inst_i;
	assign core_cpuwait = 1'b0;
	assign dbus_out = core_dbusout ;
	assign ram_Addr = core_ramadr ;
	assign ramre = core_ramre ;
	assign ramwe = core_ramwe ;
	assign ext_dbus = dbus_in ;
	assign jtag_tmr_cp2en = 1'b1;
	
	assign pinB_int = PINB_i ;
	assign pu_B = pu_B_int ;
	assign dd_B = dd_B_int ;
	assign pv_B = pv_B_int ;
	assign die_B = die_B_int ; 
	
	assign pinC_int = PINC_i ;
	assign pu_C = pu_C_int ;
	assign dd_C = dd_C_int ;
	assign pv_C = pv_C_int ;
	assign die_C = die_C_int ; 
	
	assign pinD_int = PIND_i ;
	assign pu_D = pu_D_int ;
	assign dd_D = dd_D_int ;
	assign pv_D = pv_D_int ;
	assign die_D = die_D_int ; 
	
	assign pinE_int = PINE_i ;
	assign pu_E = pu_E_int ;
	assign dd_E = dd_E_int ;
	assign pv_E = pv_E_int ;
	assign die_E = die_E_int ; 
	
	integer i;
	for (i = 0; i < 21; i = i + 1) begin
		if (d_en_bus[i]) begin
			assign io_data = data_bus[i];
		end
	end
	
	assign core_dbusin = ((256<=core_adr) && (core_adr<2304)) ? ext_dbus : io_data ;
	
	avr_core #(
		.impl_mul      	(impl_mul),
		.use_rst		(use_rst),
		.pc22b			(pc22b),
		.eind_width		(eind_width),
		.ram_depth		(ram_depth),
		.rampz_width	(rampz_width),
		.irqs_width		(irqs_width)
	)avr_core_inst(
		.cp2 			(cp2),
		.cp2en			(jtag_cp2en),
		.ireset			(core_ireset),
		.valid_instr	(core_valid_instr),
		.insert_nop		(core_insert_nop),
		.block_irq		(core_block_irq),
		.change_flow	(core_change_flow),
		.pc				(core_pc),
		.instruction	(core_inst),
		.adr			(core_adr),
		.iore			(core_iore),
		.iowe			(core_iowe),
		.ramadr			(core_ramadr),
		.ramre			(core_ramre),
		.ramwe			(core_ramwe),
		.cpuwait		(core_cpuwait),
		.dbusin			(core_dbusin),
		.dbusout		(core_dbusout),	
		.irqlines		(core_irqlines),
		.irqack			(core_irqack),
		.irqackad		(core_irqackad),
		.sleepi			(core_sleepi),
		.irqok			(core_irqok),
		.globint		(core_globint),
		.wdri			(core_wdri),
		.spm_out		(core_spm_out),
		.spm_inst		(core_spm_inst),
		.spm_wait		(core_spm_wait)
	);
	
	mcu_cs #(
		.MCUCR_Address (6'h35)
	)mcu_cs_inst(
		.ireset		(core_ireset),
		.cp2		(cp2),
		.IO_Addr	(core_adr),
		.iore		(core_iore),
		.iowe		(core_iowe),
		.dbus_in	(core_dbusout),
		.out_en		(d_en_bus[Mcucr]),
		.dbus_out	(data_bus[Mcucr]),
		.BODS_o		(BODS),
		.BODSE_o	(BODSE),
		.PUD_o		(PUD),
		.IVSEL_o	(IVSEL),	
		.IVCE_o		(IVCE)
	);
	
	prescaler_reset #()
	prescaler_reset_inst(
		.ireset				(core_ireset),
		.cp2				(cp2),
		.cp2en				(jtag_cp2en),
		.adr				(core_adr),
		.iore				(core_iore),
		.iowe				(core_iowe),
		.dbus_in			(core_dbusout),
		.out_en				(d_en_bus[Pres_Rst]),
		.dbus_out			(data_bus[Pres_Rst]),
		.prescaler0_reset	(pres0_rst),
		.prescaler1_reset	(pres1_rst)
	);
	
	prescaler0 #()
	prescaler0_inst(
		.reset		(pres0_rst),
		.clk		(cp2),
		.clk8en		(pres0_clk8en),
		.clk64en	(pres0_clk16en),
		.clk256en	(pres0_clk256en),
		.clk1024en	(pres0_clk1024en)
	);
	
	mux_after_prescaler0 #()
	mux_after_prescaler0_inst(
		.clk		(cp2),
		.clk8en		(pres0_clk8en),
		.clk64en	(pres0_clk16en),
		.clk256en	(pres0_clk256en),
		.clk1024en	(pres0_clk1024en),
		.t0			(DID_int[4]),
		.t1			(DID_int[5]),
		.t3			(DIE_int[3]),
		.t4			(DIE_int[1]),
		.cs0		(cs0),
		.cs1		(cs1),
		.cs3		(cs3),
		.cs4		(cs4),    
		.clk_en_0	(clk_en_0),
		.clk_en_1	(clk_en_1),
		.clk_en_3	(clk_en_3),
		.clk_en_4	(clk_en_4)
	);
	
	prescaler1 #()
	prescaler1_inst(
		.reset		(pres1_rst),
		.clk_sync	(cp2),
		.clk_async	(),
		.async_sel	(AS2),
		.cs2		(cs2),
		.clk_o		(clk_t2),
		.clk_en		(clk_en_2)
	);
	
	Timer_Counter0_8_bit #(
		.ram_depth			(ram_depth),
		.TCCRnA_Address		(6'h24),
		.TCCRnB_Address		(6'h25),
		.TCNTn_Address 		(6'h26),
		.OCRnA_Address 		(6'h27),
		.OCRnB_Address 		(6'h28),
		.TIFRn_Address 		(6'h15),
		.TCnCmpAIRQ_Address	(6'h0E),
		.TCnCmpBIRQ_Address	(6'h0F),
		.TCnOvfIRQ_Address	(6'h10),
		.TIMSKn_Address 	(12'h06E)
	)Timer_Counter0_8_bit_inst(
		.ireset			(core_ireset),
		.cp2			(cp2),
		.cp2en			(jtag_cp2en),
		.tmr_cp2en		(jtag_tmr_cp2en),
		.clk_en			(clk_en_0),
		.irqack_addr	(core_irqackad),
		.irqack			(core_irqack),
		.TCnCmpAIRQ		(core_irqlines[14]),
		.TCnCmpBIRQ		(core_irqlines[15]),
		.TCnOvfIRQ		(core_irqlines[16]),
		.dbus_in		(core_dbusout),
		.dbus_out		(data_bus[TC_0]),
		.ram_Addr		(core_ramadr),
		.ramre			(core_ramre),
		.ramwe			(core_ramwe),
		.IO_Addr		(core_adr),
		.iore			(core_iore),
		.iowe			(core_iowe),
		.csn			(cs0),
		.OCnA			(OC0A),
		.OCnB			(OC0B),
		.OCnA_EN		(OC0A_EN),
		.OCnB_EN		(OC0B_EN),
		.out_en			(d_en_bus[TC_0])
	);
	
	Timer_Counter_16_bit #(
		.ram_depth			(ram_depth),
		.TCCRnA_Address		(12'h080),
		.TCCRnB_Address		(12'h081),
		.TCCRnC_Address		(12'h082),
		.TCNTnL_Address 	(12'h084),
		.TCNTnH_Address 	(12'h085),
		.ICRnL_Address 		(12'h086),
		.ICRnH_Address 		(12'h087),
		.OCRnAL_Address 	(12'h088),
		.OCRnAH_Address 	(12'h089),
		.OCRnBL_Address 	(12'h08A),
		.OCRnBH_Address 	(12'h08B),
		.TIFRn_Address 		(6'h16),
		.TIMSKn_Address 	(12'h06F),
		.TCnICpIRQ_Address	(6'h0A),
		.TCnCmpAIRQ_Address	(6'h0B),
		.TCnCmpBIRQ_Address	(6'h0C),
		.TCnOvfIRQ_Address	(6'h0D)
	)Timer_Counter_16_bit_1_inst(
		.ireset			(core_ireset),
		.cp2			(cp2),
		.cp2en			(jtag_cp2en),
		.tmr_cp2en		(jtag_tmr_cp2en),
		.clk_en			(clk_en_1),
		.irqack_addr	(core_irqackad),
		.irqack			(core_irqack),
		.TCnICpIRQ		(core_irqlines[10]),
		.TCnCmpAIRQ		(core_irqlines[11]),
		.TCnCmpBIRQ		(core_irqlines[12]),
		.TCnOvfIRQ		(core_irqlines[13]),
		.dbus_in		(core_dbusout),
		.dbus_out		(data_bus[TC_1]),
		.ram_Addr		(core_ramadr),
		.ramre			(core_ramre),
		.ramwe			(core_ramwe),
		.IO_Addr		(core_adr),
		.iore			(core_iore),
		.iowe			(core_iowe),
		.ICPn_in		(DIB_int[0]),
		.csn			(cs1),
		.OCnA			(OC1A),
		.OCnB			(OC1B),
		.OCnA_EN		(OC1A_EN),
		.OCnB_EN		(OC1B_EN),
		.out_en			(d_en_bus[TC_1])
	);
	
	Timer_Counter_16_bit #(
		.ram_depth			(ram_depth),
		.TCCRnA_Address		(12'h090),
		.TCCRnB_Address		(12'h091),
		.TCCRnC_Address		(12'h092),
		.TCNTnL_Address 	(12'h094),
		.TCNTnH_Address 	(12'h095),
		.ICRnL_Address 		(12'h096),
		.ICRnH_Address 		(12'h097),
		.OCRnAL_Address 	(12'h098),
		.OCRnAH_Address 	(12'h099),
		.OCRnBL_Address 	(12'h09A),
		.OCRnBH_Address 	(12'h09B),
		.TIFRn_Address 		(6'h18),
		.TIMSKn_Address 	(12'h071),
		.TCnICpIRQ_Address	(6'h20),
		.TCnCmpAIRQ_Address	(6'h21),
		.TCnCmpBIRQ_Address	(6'h22),
		.TCnOvfIRQ_Address	(6'h23)
	)Timer_Counter_16_bit_3_inst(
		.ireset			(core_ireset),
		.cp2			(cp2),
		.cp2en			(jtag_cp2en),
		.tmr_cp2en		(jtag_tmr_cp2en),
		.clk_en			(clk_en_3),
		.irqack_addr	(core_irqackad),
		.irqack			(core_irqack),
		.TCnICpIRQ		(core_irqlines[32]),
		.TCnCmpAIRQ		(core_irqlines[33]),
		.TCnCmpBIRQ		(core_irqlines[34]),
		.TCnOvfIRQ		(core_irqlines[35]),
		.dbus_in		(core_dbusout),
		.dbus_out		(data_bus[TC_3]),
		.ram_Addr		(core_ramadr),
		.ramre			(core_ramre),
		.ramwe			(core_ramwe),
		.IO_Addr		(core_adr),
		.iore			(core_iore),
		.iowe			(core_iowe),
		.ICPn_in		(DIE_int[2]),
		.csn			(cs3),
		.OCnA			(OC3A),
		.OCnB			(OC3B),
		.OCnA_EN		(OC3A_EN),
		.OCnB_EN		(OC3B_EN),
		.out_en			(d_en_bus[TC_3])
	);
	
	Timer_Counter_16_bit #(
		.ram_depth			(ram_depth),
		.TCCRnA_Address		(12'h0A0),
		.TCCRnB_Address		(12'h0A1),
		.TCCRnC_Address		(12'h0A2),
		.TCNTnL_Address 	(12'h0A4),
		.TCNTnH_Address 	(12'h0A5),
		.ICRnL_Address 		(12'h0A6),
		.ICRnH_Address 		(12'h0A7),
		.OCRnAL_Address 	(12'h0A8),
		.OCRnAH_Address 	(12'h0A9),
		.OCRnBL_Address 	(12'h0AA),
		.OCRnBH_Address 	(12'h0AB),
		.TIFRn_Address 		(6'h19),
		.TIMSKn_Address 	(12'h072),
		.TCnICpIRQ_Address	(6'h29),
		.TCnCmpAIRQ_Address	(6'h2A),
		.TCnCmpBIRQ_Address	(6'h2B),
		.TCnOvfIRQ_Address	(6'h2C)
	)Timer_Counter_16_bit_4_inst(
		.ireset			(core_ireset),
		.cp2			(cp2),
		.cp2en			(jtag_cp2en),
		.tmr_cp2en		(jtag_tmr_cp2en),
		.clk_en			(clk_en_4),
		.irqack_addr	(core_irqackad),
		.irqack			(core_irqack),
		.TCnICpIRQ		(core_irqlines[41]),
		.TCnCmpAIRQ		(core_irqlines[42]),
		.TCnCmpBIRQ		(core_irqlines[43]),
		.TCnOvfIRQ		(core_irqlines[44]),
		.dbus_in		(core_dbusout),
		.dbus_out		(data_bus[TC_4]),
		.ram_Addr		(core_ramadr),
		.ramre			(core_ramre),
		.ramwe			(core_ramwe),
		.IO_Addr		(core_adr),
		.iore			(core_iore),
		.iowe			(core_iowe),
		.ICPn_in		(DIE_int[0]),
		.csn			(cs4),
		.OCnA			(OC4A),
		.OCnB			(OC4B),
		.OCnA_EN		(OC4A_EN),
		.OCnB_EN		(OC4B_EN),
		.out_en			(d_en_bus[TC_4])
	);
	
	Timer_Counter2_8_bit #(
		.ram_depth			(ram_depth),
		.TCCRnA_Address		(12'h0b0),
		.TCCRnB_Address		(12'h0b1),
		.TCNTn_Address 		(12'h0b2),
		.OCRnA_Address 		(12'h0b3),
		.OCRnB_Address 		(12'h0b4),
		.ASSR_Address 		(12'h0b6),
		.TIFRn_Address 		(6'h17),
		.TCnCmpAIRQ_Address	(6'h07),
		.TCnCmpBIRQ_Address	(6'h08),
		.TCnOvfIRQ_Address	(6'h09),
		.TIMSKn_Address 	(12'h070)
	)Timer_Counter2_8_bit_inst(
		.ireset			(core_ireset),
		.cp2			(clk_t2),
		.cp2en			(jtag_cp2en),
		.tmr_cp2en		(jtag_tmr_cp2en),
		.clk_en			(clk_en_0),
		.irqack_addr	(core_irqackad),
		.irqack			(core_irqack),
		.TCnCmpAIRQ		(core_irqlines[7]),
		.TCnCmpBIRQ		(core_irqlines[8]),
		.TCnOvfIRQ		(core_irqlines[9]),
		.dbus_in		(core_dbusout),
		.dbus_out		(data_bus[TC_2]),
		.ram_Addr		(core_ramadr),
		.ramre			(core_ramre),
		.ramwe			(core_ramwe),
		.IO_Addr		(core_adr),
		.iore			(core_iore),
		.iowe			(core_iowe),
		.AS2			(AS2),
		.EXCLK			(EXCLK), 
		.csn			(cs2),
		.OCnA			(OC2A),
		.OCnB			(OC2B),
		.OCnA_EN		(OC2A_EN),
		.OCnB_EN		(OC2B_EN),
		.out_en			(d_en_bus[TC_2])
	);
	
	SPI_0 #(
		.SPCRn_Address 	(6'h2C) , // SPCR0
		.SPSRn_Address 	(6'h2D) , // SPSR0
		.SPDRn_Address 	(6'h2E) ,  // SPDR0
		.SpiIRQ_Address (6'h11)
	)SPI_0_inst(
		.ireset		(core_ireset),
		.cp2		(cp2),
		.IO_Addr 	(core_adr),
		.iore 		(core_iore),
		.iowe 		(core_iowe),	
		.out_en 	(d_en_bus[Spi_0]),
		.dbus_in 	(core_dbusout),
		.dbus_out 	(data_bus[Spi_0]),
		
		.miso_i		(DIB_int[4]),     // Master mode
		.mosi_i		(DIB_int[3]),		// Slave mode
		.sck_i		(DIB_int[5]),		// Slave mode
		.ss_i		(DIB_int[2]),		// Slave/Master mode
		.ss_o		(),		// Master mode
		.miso_o		(SPI0_SL_OUT),		// Slave mode
		.mosi_o		(SPI0_MT_OUT),		// Master mode
		.sck_o		(SCK0_OUT),		// Master mode
		// IRQ
		.SpiIRQ		(core_irqlines[17]),
		.irqack_addr(core_irqackad),
		.irqack		(core_irqack),
		.SPE0 		(SPE0),
		.MSTR0		(MSTR0)		
	);
	
	SPI_1 #(
		.SPCRn_Address 	(12'h0AC) , // SPCR1
		.SPSRn_Address 	(12'h0AD) , // SPSR1
		.SPDRn_Address 	(12'h0AE) ,  // SPDR1
		.SpiIRQ_Address (6'h27)
	)SPI_1_inst(
		.ireset		(core_ireset),
		.cp2		(cp2),
		.ram_Addr 	(core_ramadr),
		.ramre 		(core_ramre),
		.ramwe 		(core_ramwe),	
		.out_en 	(d_en_bus[Spi_1]),
		.dbus_in 	(core_dbusout),
		.dbus_out 	(data_bus[Spi_1]),
		
		.miso_i		(DIC_int[0]),     // Master mode
		.mosi_i		(DIE_int[3]),		// Slave mode
		.sck_i		(DIC_int[1]),		// Slave mode
		.ss_i		(DIE_int[2]),		// Slave/Master mode
		.ss_o		(),		// Master mode
		.miso_o		(SPI1_SL_OUT),		// Slave mode
		.mosi_o		(SPI1_MT_OUT),		// Master mode
		.sck_o		(SCK1_OUT),		// Master mode
		// IRQ
		.SpiIRQ		(core_irqlines[39]),
		.irqack_addr(core_irqackad),
		.irqack		(core_irqack),
		.SPE1 		(SPE1),
		.MSTR1		(MSTR1)		
	);
	
	USARTn #(
		.UDRn_Address 		(12'h0C6) ,
	    .UCSRnA_Address 	(12'h0C0) ,
	    .UCSRnB_Address 	(12'h0C1) ,
	    .UCSRnC_Address 	(12'h0C2) ,
	    .UBRRnH_Address 	(12'h0C5) ,
	    .UBRRnL_Address 	(12'h0C4) ,
	    .RxcIRQ_Address 	(6'h12) ,
	    .UdreIRQ_Address 	(6'h13) ,
	    .TxcIRQ_Address 	(6'h14) ,
	    .UStBIRQ_Address 	(6'h1A)
	)USARTn_0_inst(
		.ireset		(core_ireset),
		.cp2		(cp2),
		.ram_Addr 	(core_ramadr),
		.ramre 		(core_ramre),
		.ramwe 		(core_ramwe),
		.out_en 	(d_en_bus[Usart_0]),
		.dbus_in 	(core_dbusout),
		.dbus_out 	(data_bus[Usart_0]),
		.DDR_XCKn 	(DDR_XCK0),
		.UMSEL		(UMSEL0),
		.XCKn_i 	(DID_int[4]),
		.XCKn_o 	(XCK0_OUT),
		.RxDn_i 	(DID_int[0]),
		.TxDn_o 	(TXD0),
		.RXENn 		(RXEN0),
		.TXENn 		(TXEN0),
		.RxcIRQ 	(core_irqlines[18]),
		.UdreIRQ	(core_irqlines[19]), 
		.TxcIRQ 	(core_irqlines[20]),
		.UStBIRQ	(core_irqlines[26]),
		.irqack_addr(core_irqackad),
		.irqack		(core_irqack)
	);
	
	USARTn #(
		.UDRn_Address 		(12'h0C7) ,
	    .UCSRnA_Address 	(12'h0C8) ,
	    .UCSRnB_Address 	(12'h0C9) ,
	    .UCSRnC_Address 	(12'h0CA) ,
	    .UBRRnH_Address 	(12'h0CD) ,
	    .UBRRnL_Address 	(12'h0CC) ,
	    .RxcIRQ_Address 	(6'h1C) ,
	    .UdreIRQ_Address 	(6'h1D) ,
	    .TxcIRQ_Address 	(6'h1E) ,
	    .UStBIRQ_Address 	(6'h1F)
	)USARTn_1_inst(
		.ireset		(core_ireset),
		.cp2		(cp2),
		.ram_Addr 	(core_ramadr),
		.ramre 		(core_ramre),
		.ramwe 		(core_ramwe),
		.out_en 	(d_en_bus[Usart_1]),
		.dbus_in 	(core_dbusout),
		.dbus_out 	(data_bus[Usart_1]),
		.DDR_XCKn 	(DDR_XCK1),
		.UMSEL		(UMSEL1),
		.XCKn_i 	(DIB_int[5]),
		.XCKn_o 	(XCK1_OUT),
		.RxDn_i 	(DIB_int[4]),
		.TxDn_o 	(TXD1),
		.RXENn 		(RXEN1),
		.TXENn 		(TXEN1),
		.RxcIRQ 	(core_irqlines[28]),
		.UdreIRQ	(core_irqlines[29]), 
		.TxcIRQ 	(core_irqlines[30]),
		.UStBIRQ	(core_irqlines[31]),
		.irqack_addr(core_irqackad),
		.irqack		(core_irqack)
	);
	
	Port_B #()
	Port_B_inst(
		.ireset		(core_ireset),
		.cp2		(cp2),
		.IO_Addr 	(core_adr),
		.iore 		(core_iore),
		.iowe 		(core_iowe),	
		.out_en 	(d_en_bus[P_B]),
		.dbus_in 	(core_dbusout),
		.dbus_out 	(data_bus[P_B]),
		
		.pinB_i 	(pinB_int),
		.DIB_o		(DIB_int),
		.pu_B		(pu_B_int),
		.dd_B		(dd_B_int),
		.pv_B		(pv_B_int),
		.die_B		(die_B_int),
		.DDR_XCK1   (DDR_XCK1),
		
		.PUD 		(PUD),
		.SLEEP      (SLEEP),
		.INTRC		(INTRC),
		.EXTCK		(EXCLK), // ******
		.AS2		(AS2),
		.SPE0		(SPE0),
		.MSTR		(MSTR0),
		.RXEN1		(RXEN1),
		.TXEN1		(TXEN1),
		.OC2A_EN	(OC2A_EN),
		.OC1B_EN	(OC1B_EN),
		.OC1A_EN	(OC1A_EN),
		.SCK0_OUT	(SCK0_OUT),
		.XCK1_OUT	(XCK1_OUT),
		.SPI0_SL_OUT(SPI0_SL_OUT),
		.OC2A		(OC2A),
		.OC1B		(OC1B),
		.OC1A		(OC1A),
		.SPI0_MT_OUT(SPI0_MT_OUT),
		.UMSEL		(UMSEL1),
		.TXD1		(TXD1),
		.PCINT		(pcint[7:0]),//pcint[7:0]
		.PCIE0		(PCIE0)
	);
	
	Port_C #()
	Port_C_inst(
		.ireset		(core_ireset),
		.cp2		(cp2),
		.IO_Addr 	(core_adr),
		.iore 		(core_iore),
		.iowe 		(core_iowe),	
		.out_en 	(d_en_bus[P_C]),
		.dbus_in 	(core_dbusout),
		.dbus_out 	(data_bus[P_C]),
		
		.pinC_i 	(pinC_int),
		.DIC_o		(DIC_int),
		.pu_C		(pu_C_int),
		.dd_C		(dd_C_int),
		.pv_C		(pv_C_int),
		.die_C		(die_C_int),
		
		.PUD 		(PUD),
		.SLEEP      (SLEEP),
		.RSTDISBL	(RSTDISBL),
		.TWEN0		(TWEN0),
		.SPE1		(SPE1),
		.MSTR		(MSTR1),
		.SCK1_OUT	(SCK1_OUT),
		.SPI1_SL_OUT(SPI1_SL_OUT),
		.SCL0_OUT	(SCL0_OUT),
		.SDA0_OUT	(SDA0_OUT),
		.ADCxD		(ADCxD[5:0]),//ADCxD[5:0]
		.PCINT		(pcint[14:8]),//pcint[14:8]
		.PCIE1		(PCIE1)	
	);
	
	Port_D #()
	Port_D_inst(
		.ireset		(core_ireset),
		.cp2		(cp2),
		.IO_Addr 	(core_adr),
		.iore 		(core_iore),
		.iowe 		(core_iowe),	
		.out_en 	(d_en_bus[P_D]),
		.dbus_in 	(core_dbusout),
		.dbus_out 	(data_bus[P_D]),
		
		.pinD_i 	(pinD_int),
		.DID_o		(DID_int),
		.pu_D		(pu_D_int),
		.dd_D		(dd_D_int),
		.pv_D		(pv_D_int),
		.die_D		(die_D_int),
		.DDR_XCK0   (DDR_XCK0),
		
		.PUD 		(PUD),
		.SLEEP      (SLEEP),
		.RXEN0		(RXEN0),
		.TXEN0		(TXEN0),
		.OC0A_EN	(OC0A_EN),
		.OC0B_EN	(OC0B_EN),
		.OC2B_EN	(OC2B_EN),
		.OC3B_EN	(OC3B_EN),
		.OC4B_EN	(OC4B_EN),
		.OC4A_EN	(OC4A_EN),
		.OC3A_EN	(OC3A_EN),
		.XCK0_OUT	(XCK0_OUT),
		.OC0A		(OC0A),
		.OC0B		(OC0B),
		.OC2B		(OC2B),
		.OC3B		(OC3B),
		.OC4B		(OC4B),
		.OC4A		(OC4A),
		.OC3A		(OC3A),
		.UMSEL		(UMSEL0),
		.TXD0		(TXD0),
		.PCINT		(pcint[23:16]), //pcint[23:16]
		.INT1_EN	(INT1_EN),
		.INT0_EN	(INT0_EN),
		.PCIE2		(PCIE2)
	);
	
	Port_E #()
	Port_E_inst(
		.ireset		(core_ireset),
		.cp2		(cp2),
		.IO_Addr 	(core_adr),
		.iore 		(core_iore),
		.iowe 		(core_iowe),	
		.out_en 	(d_en_bus[P_E]),
		.dbus_in 	(core_dbusout),
		.dbus_out 	(data_bus[P_E]),
		
		.pinE_i 	(pinE_int),
		.DIE_o		(DIE_int),
		.pu_E		(pu_E_int),
		.dd_E		(dd_E_int),
		.pv_E		(pv_E_int),
		.die_E		(die_D_int),
		
		.PUD 		(PUD),
		.SLEEP      (SLEEP),
		.RSTDISBL	(RSTDISBL),
		.TWEN1		(TWEN1),
		.SPE1		(SPE1),
		.MSTR		(MSTR1),
		.SCK1_OUT	(SCK1_OUT),
		.SPI1_MT_OUT(SPI1_MT_OUT),
		.SCL1_OUT	(SCL1_OUT),
		.SDA1_OUT	(SDA1_OUT),
		.ADCxD		(ADCxD[7:6]), //ADCxD[7:6]
		.PCINT		(pcint[27:24]), //pcint[27:24]
		.PCIE3		(PCIE3),
		.aco_oe		(aco_oe),
		.acompout	(acompout)
	);
	
endmodule
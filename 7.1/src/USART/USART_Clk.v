`timescale 1 ns / 1 ns
module USART_Clk 
	#(
	parameter SYNC_RST = 0
	) 
    (
    input  wire       nrst,
	input  wire       clk,
	input wire[11:0]  bsel,
	// input wire[3:0]   bscale,
	input wire        change_cfg, 
	input wire        rxen,
	input wire        txen,
	input  wire       clr_tx_cnt,
	output wire       rx_clk_en_o,
	output wire       tx_clk_en_o
    );
		
	reg [11:0]  rx_prsc_cnt	;
	// reg       	rx_clk_en;
	wire      	rx_cnt_exp;		

	reg [11:0]  tx_prsc_cnt;				
	// reg        	tx_clk_en;
	wire       	tx_cnt_exp;
 
	assign rx_cnt_exp = ~(|rx_prsc_cnt);

	assign tx_cnt_exp = ~(|tx_prsc_cnt);

	always @(posedge clk or negedge nrst)
	begin: sh_seq
		if (!nrst)begin		// Reset   
			rx_prsc_cnt  <= {12{1'b0}};
			// rx_clk_en    <= 1'b0;
       
			tx_prsc_cnt  <= {12{1'b0}};
			// tx_clk_en    <= 1'b0;
        end else begin		// Clock 
			// RX
			if(change_cfg | rx_cnt_exp) begin
				rx_prsc_cnt <= bsel;
			end else if(rxen) begin
				rx_prsc_cnt <= rx_prsc_cnt - 12'b1; // Decrement
			end else begin
				rx_prsc_cnt <= bsel;
			end 
 
			// TX
			if(change_cfg | tx_cnt_exp | clr_tx_cnt)begin
				tx_prsc_cnt <= bsel;
			end else if(txen) begin
				tx_prsc_cnt <= tx_prsc_cnt - 12'b1; // Decrement
			end else begin
				tx_prsc_cnt <= bsel;
			end
		end
	end // sh_seq

	assign rx_clk_en_o = rx_cnt_exp && rxen;
	assign tx_clk_en_o = tx_cnt_exp && txen;
		
endmodule // clk_gen_logic			
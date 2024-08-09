`timescale 1 ns / 1 ns
module prescaler1 // with selected clock_en by cs2 
  (
    reset,
    clk_sync,
    clk_async,
    async_sel,
    cs2,
	clk_o,
    clk_en);
    input reset, clk_sync, clk_async, async_sel;
    input [2:0] cs2;
    output clk_en;
	output clk_o;

    reg [9:0] counter;// reg [9:0] counter = 10'b0000000000;
	wire clk; 
	reg clk_en_i;
	assign clk = (async_sel) ? clk_async : clk_sync;
	assign clk_o = clk ;
    
//    always @(posedge(clk) iff (reset == 0) or posedge(reset))
    always @(posedge(clk) or posedge(reset)) 
    begin : count_up
      if (reset) 
        counter <= 0;
      else
        counter <= counter + 1;
    end

    always @(*) begin: select_divider
      (* parallel_case *) case (cs2)  // synthesis parallel_case
        3'b000 : clk_en_i = 0;
        3'b001 : clk_en_i = 1;
        3'b010 : clk_en_i = (counter[2:0] == {3{1'b1}})? 1'b1 : 1'b0;
        3'b011 : clk_en_i = (counter[4:0] == {5{1'b1}})? 1'b1 : 1'b0;
        3'b100 : clk_en_i = (counter[5:0] == {6{1'b1}})? 1'b1 : 1'b0;
        3'b101 : clk_en_i = (counter[6:0] == {7{1'b1}})? 1'b1 : 1'b0;
        3'b110 : clk_en_i = (counter[7:0] == {8{1'b1}})? 1'b1 : 1'b0;
        3'b111 : clk_en_i = (counter[9:0] == {10{1'b1}})? 1'b1 : 1'b0;
        default: clk_en_i = 0;
      endcase
    end
    
    

    assign clk_en = clk_en_i;

endmodule
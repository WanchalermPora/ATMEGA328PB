`timescale 1 ns / 1 ns
module prescaler0 // no mux for clock enable selection. output all clk*en
  (
    reset,
    clk,
    clk8en,
    clk64en,
    clk256en,
    clk1024en);
    input reset, clk;
    output clk8en, clk64en, clk256en, clk1024en;

    reg [9:0] counter;// reg [9:0] counter = 10'b0000000000;
    assign clk8en = (counter[2:0] == {3{1'b1}})? 1'b1 : 1'b0;
    assign clk64en = (counter[5:0] == {6{1'b1}})? 1'b1 : 1'b0;
    assign clk256en = (counter[7:0] == {8{1'b1}})? 1'b1 : 1'b0;
    assign clk1024en = (counter[9:0] == {10{1'b1}})? 1'b1 : 1'b0;
 
    always @(posedge(clk) or posedge(reset)) 
    begin : count_up
		if (reset) begin
			counter <= 10'b0000000000;
		end else begin
			counter <= counter + 10'b0000000001;
		end
    end
endmodule
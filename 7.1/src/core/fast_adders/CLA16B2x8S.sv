`timescale 1 ns / 1 ns

//**********************************************************************************************
// 16-bit carry look-ahead adder for AVR (built using 8-bit CLA sections)
// Version 0.1
// Modified 13.09.2006
// Designed by Ruslan Lepetenok
//**********************************************************************************************

module CLA16B2x8S(A, B, CI, S, CO);
   input [15:0]  A;
   input [15:0]  B;
   input         CI;
   output [15:0] S;
   output        CO;
   
   logic          InternalCarry;
   
   
   CLA8B AdderB0to7_Inst(.a_in(A[7:0]), .b_in(B[7:0]), .c_in(CI), .s_out(S[7:0]), .c_out(InternalCarry));
   
   
   CLA8B AdderB8to15_Inst(.a_in(A[15:8]), .b_in(B[15:8]), .c_in(InternalCarry), .s_out(S[15:8]), .c_out(CO));
   
endmodule

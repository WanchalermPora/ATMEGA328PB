// Initializing Block RAM (Single-Port Block RAM)
// File: rams_sp_rom
module rams_sp_rom (clk, addr, di, dout);
	// input clk;
	// input we;
	input [13:0] addr;
	output [15:0] dout;

	reg [15:0] ram [0:16383];

	initial
	begin
		ram[0] = 16'b000111XXXXXXXXXX; // adc
		ram[1] = 16'b000011XXXXXXXXXX; // add
		ram[2] = 16'b10010110XXXXXXXX; // adiw
		ram[3] = 16'b001000XXXXXXXXXX; // and
		ram[4] = 16'b0111XXXXXXXXXXXX; // andi
		ram[5] = 16'b1001010XXXXX0101; // asr
		ram[6] = 16'b100101001XXX1000; // bclr
		ram[7] = 16'b1111100XXXXX0XXX; // bld
		ram[8] = 16'b111101XXXXXXXXXX; // brbc
		ram[9] = 16'b111100XXXXXXXXXX; // brbs
		ram[10] = 16'b100101000XXX1000; // bset
		ram[11] = 16'b1111101XXXXXXXXX; // bst
		ram[12] = 16'b1001010XXXXX111X; // call
		ram[13] = 16'b10011000XXXXXXXX; // cbi
		ram[14] = 16'b1001010XXXXX0000; // com
		ram[15] = 16'b000101XXXXXXXXXX; // cp
		ram[16] = 16'b000001XXXXXXXXXX; // cpc
		ram[17] = 16'b0011XXXXXXXXXXXX; // cpi
		ram[18] = 16'b000100XXXXXXXXXX; // cpse
		ram[19] = 16'b1001010XXXXX1010; // dec
		ram[20] = 16'b001001XXXXXXXXXX; // eor
		ram[21] = 16'b10010101XXXX1001; // icall
		ram[22] = 16'b10010100XXXX1001; // ijmp
		ram[23] = 16'b10110XXXXXXXXXXX; // in
		ram[24] = 16'b1001010XXXXX0011; // inc
		ram[25] = 16'b1001010XXXXX110X; // jmp
		ram[26] = 16'b1001000XXXXX1100; // ld_x
		ram[27] = 16'b1001000XXXXX1101; // ld_x+
		ram[28] = 16'b1001000XXXXX1110; // ld_-x
		ram[29] = 16'b1001000XXXXX1001; // ld_y+
		ram[30] = 16'b1001000XXXXX1010; // ld_-y
		ram[31] = 16'b10q0qq0ddddd1qqq; // ldd_y+q
		ram[32] = 16'b1001000XXXXX0001; // ld_z+
		ram[33] = 16'b1001000XXXXX0010; // ld_-z
		ram[34] = 16'b10q0qq0ddddd0qqq; // ldd_z+q
		ram[35] = 16'b1110XXXXXXXXXXXX; // ldi
		ram[36] = 16'b1001000XXXXX0000; // lds
		ram[37] = 16'b1001010111001000; // lpm
		ram[38] = 16'b1001010XXXXX0110; // lsr
		ram[39] = 16'b001011XXXXXXXXXX; // mov
		ram[40] = 16'b1001010XXXXX0001; // neg
		ram[41] = 16'b0000000000000000; // nop
		ram[42] = 16'b001010XXXXXXXXXX; // or
		ram[43] = 16'b0110XXXXXXXXXXXX; // ori
		ram[44] = 16'b10111XXXXXXXXXXX; // out
		ram[45] = 16'b1001000XXXXX1111; // pop
		ram[46] = 16'b1001001XXXXX1111; // push
		ram[47] = 16'b1101XXXXXXXXXXXX; // rcall
		ram[48] = 16'b100101010XX01000; // ret
		ram[49] = 16'b100101010XX11000; // reti
		ram[50] = 16'b1100XXXXXXXXXXXX; // rjmp
		ram[51] = 16'b1001010XXXXX0111; // ror
		ram[52] = 16'b000010XXXXXXXXXX; // sbc
		ram[53] = 16'b0100XXXXXXXXXXXX; // sbci
		ram[54] = 16'b10011010XXXXXXXX; // sbi
		ram[55] = 16'b10011001XXXXXXXX; // sbic
		ram[56] = 16'b10011011XXXXXXXX; // sbis
		ram[57] = 16'b10010111XXXXXXXX; // sbiw
		ram[58] = 16'b1111110XXXXXXXXX; // sbrc
		ram[59] = 16'b1111111XXXXXXXXX; // sbrs
		ram[60] = 16'b10010101100X1000; // sleep
		ram[61] = 16'b1001001rrrrr1100; // st_x
		ram[62] = 16'b1001001rrrrr1101; // st_x+
		ram[63] = 16'b1001001rrrrr1110; // st_-x
		ram[64] = 16'b1001001rrrrr1001; // st_y+
		ram[65] = 16'b1001001rrrrr1010; // st_-y
		ram[66] = 16'b10q0qq1rrrrr1qqq; // std_y+q
		ram[67] = 16'b1001001rrrrr0001; // st_z+
		ram[68] = 16'b1001001rrrrr0010; // st_-z
		ram[69] = 16'b10q0qq1rrrrr0qqq; // std_z+q
		ram[70] = 16'b1001001XXXXX0000; // sts
		ram[71] = 16'b000110XXXXXXXXXX; // sub
		ram[72] = 16'b0101XXXXXXXXXXXX; // subi
		ram[73] = 16'b1001010XXXXX0010; // swap
		ram[74] = 16'b10010101101X1000; // wdr
		ram[75] = 16'b00000001ddddrrrr; // movw
		ram[76] = 16'b1001010111101000; // spm
		ram[77] = 16'b100111rdddddrrrr; // mul
		ram[78] = 16'b00000010ddddrrrr; // muls
		ram[79] = 16'b000000110ddd0rrr; // mulsu
		ram[80] = 16'b000000110ddd1rrr; // fmul
		ram[81] = 16'b000000111ddd0rrr; // fmuls
		ram[82] = 16'b000000111ddd1rrr; // fmulsu
		ram[83] = 16'b0000000000000000; // nop
		ram[84] = 16'b0000000000000000; // nop
		ram[85] = 16'b0000000000000000; // nop
		ram[86] = 16'b0000000000000000; // nop
		ram[87] = 16'b0000000000000000; // nop
		ram[88] = 16'b0000000000000000; // nop
		ram[89] = 16'b0000000000000000; // nop
		ram[90] = 16'b0000000000000000; // nop
		ram[91] = 16'b0000000000000000; // nop
		ram[92] = 16'b0000000000000000; // nop
		ram[93] = 16'b0000000000000000; // nop
		ram[94] = 16'b0000000000000000; // nop
		ram[95] = 16'b0000000000000000; // nop
		ram[96] = 16'b0000000000000000; // nop
		ram[97] = 16'b0000000000000000; // nop
		ram[98] = 16'b0000000000000000; // nop
		ram[99] = 16'b0000000000000000; // nop
		ram[100] = 16'b0000000000000000; // nop
		ram[101] = 16'b0000000000000000; // nop
		ram[102] = 16'b0000000000000000; // nop
		ram[103] = 16'b0000000000000000; // nop
		ram[104] = 16'b0000000000000000; // nop
		ram[105] = 16'b0000000000000000; // nop
		ram[106] = 16'b0000000000000000; // nop
		ram[107] = 16'b0000000000000000; // nop
		ram[108] = 16'b0000000000000000; // nop
		ram[109] = 16'b0000000000000000; // nop
		ram[110] = 16'b0000000000000000; // nop
		ram[111] = 16'b0000000000000000; // nop
		ram[112] = 16'b0000000000000000; // nop
		ram[113] = 16'b0000000000000000; // nop
		ram[114] = 16'b0000000000000000; // nop
		ram[115] = 16'b0000000000000000; // nop
		ram[116] = 16'b0000000000000000; // nop
		ram[117] = 16'b0000000000000000; // nop
		ram[118] = 16'b0000000000000000; // nop
		ram[119] = 16'b0000000000000000; // nop
		ram[120] = 16'b0000000000000000; // nop
		ram[121] = 16'b0000000000000000; // nop
		ram[122] = 16'b0000000000000000; // nop
		ram[123] = 16'b0000000000000000; // nop
		ram[124] = 16'b0000000000000000; // nop
		ram[125] = 16'b0000000000000000; // nop
		ram[126] = 16'b0000000000000000; // nop
		ram[127] = 16'b0000000000000000; // nop
	end
	assign dout = ram[addr];
endmodule
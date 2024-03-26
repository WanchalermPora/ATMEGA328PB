// Initializing Block RAM from external data file
// Binary data
// File: Program_Mem.v
// `include "../../02_design/02_rtl/src/fft.ino.bin"

module Program_Mem

    (clk, we, addr, din, dout);

    parameter use_bin = 0;
    parameter use_crc = 0;

    input clk;
	input we;
	input [13:0] addr;
	input [15:0] din;
	output [15:0] dout;

	reg [7:0] ram [0:32767];
	reg [15:0] d_out;
    reg [31:0] RRRR;
    integer file ,code , count;
    // integer file;
    integer error;
    integer i;
    integer j;


	initial begin
		// i <= 0;

        if (use_bin) begin
            $display("---------------------------------------------");
            $display("Begin Using binary files");
            $display("---------------------------------------------");            
            
            if (use_crc) begin
                // $display("");
                // $display("---------------------------------------------");
                $display("Using CRC                 ");
                $display("---------------------------------------------");   
                // file = $fopen("../../02_design/02_rtl/src/binaries/ADC_SUBI_SBIW_MULS_ROL.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/binaries/ADD_SBC_COM_EOR_MUL.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/binaries/ADIW_OR_NEG_FMULS_LSL.bin" , "rb");     
                // file = $fopen("../../02_design/02_rtl/src/binaries/BSET_BCLR.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/binaries/FMUL_MULSU_CLR_INC_LSR_ASR.bin" , "rb");
                file = $fopen("../../02_design/02_rtl/src/binaries/CALL.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/binaries/crc_2.bin" , "rb");
            end            
            
            else begin
                // $display("");
                // $display("---------------------------------------------");
                $display("Using Others                 ");
                $display("---------------------------------------------");  
                // file = $fopen("../../02_design/02_rtl/src/binaries/fft.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/binaries/randomassembly.bin" , "rb");
                file = $fopen("../../02_design/02_rtl/src/binaries/random2.bin" , "rb");
            end

            if (file == 0) begin
                $display("Could not open file");
            end
        
            code = $fread(ram,file);  
        // $displayh(ram);        
            $fclose(file);
        end

        else begin
        
            $display("---------------------------------------------");
            $display("Begin Using custom prog mem");
            $display("---------------------------------------------");

        ram[0] = 8'h21;  ram[1] = 8'he2;            //LDI R18,0x21	
        ram[2] = 8'h04;  ram[3] = 8'he3;            //LDI R16,0x34
        ram[4] = 8'h36;  ram[5] = 8'he5;            //LDI R19,0x56
        ram[6] = 8'h48;  ram[7] = 8'he7;            //LDI R20,0x78
        
        ram[8] = 8'h20;  ram[9] = 8'h93;            //STS 0x0800 ,R18
        ram[10] = 8'h00;  ram[11] = 8'h08;
        
        ram[12] = 8'h40;  ram[13] = 8'h93;              //STS 0x0001 ,R20
        ram[14] = 8'h01;  ram[15] = 8'h00;
        
        ram[16] = 8'h30;  ram[17] = 8'h93;              //STS 0x0021 ,R19 
        ram[18] = 8'h5F;  ram[19] = 8'h00;

        // ram[16] = 8'h30;  ram[17] = 8'h93;              //STS 0x0021 ,R19 
        // ram[18] = 8'h01;  ram[19] = 8'h08;
        
        ram[20] = 8'h00;  ram[21] = 8'h93;              //STS 0x007F ,R16
        ram[22] = 8'h7F;  ram[23] = 8'h00;

        ram[24] = 8'h30;  ram[25] = 8'h90;            //LDS R3 0x0800
        ram[26] = 8'h00;  ram[27] = 8'h08;    

        ram[28] = 8'h40;  ram[29] = 8'h90;            //LDS R4 0x0001
        ram[30] = 8'h01;  ram[31] = 8'h00; 

        ram[32] = 8'h50;  ram[33] = 8'h90;            //LDS R4 0x0001
        ram[34] = 8'h5F;  ram[35] = 8'h00; 


        ram[36] = 8'he1;  ram[37] = 8'he0;  // LDI R30, 2
        ram[38] = 8'hf3;  ram[39] = 8'he0; // LDI R31, 3 
        
        // ram[40] = 8'h09;  ram[41] = 8'h95;  // ICALL 
        ram[40] = 8'h05;  ram[41] = 8'h90;  // LPM 
        ram[42] = 8'h50;  ram[43] = 8'h90; 
        // ram[40] = 8'h0e;  ram[41] = 8'h94;  // CALL 
        // ram[42] = 8'h90;  ram[43] = 8'h00;  //  
        
        ram[144*2 ] = 8'h2F;  ram[144*2  + 1] = 8'h93; // PUSH R18 @144
        ram[145*2 ] = 8'h2F;  ram[145*2 + 1] = 8'h91; // POP R18 @145
        ram[146*2 ] = 8'h08;  ram[146*2 + 1] = 8'h95; // RET @130
        ram[147*2 ] = 8'h08;  ram[147*2 + 1] = 8'h95; // RET @131

        
        ram[42] = 8'he8;  ram[43] = 8'he0;  // LDI R30, 8
        ram[44] = 8'hf0;  ram[45] = 8'he0; // LDI R31, 0         
        ram[46] = 8'h09;  ram[47] = 8'h94;  // 




        end
        
	end

    
	always @(posedge clk)
	// always @(*)
	begin
		// if (we) begin
			// ram[addr] <= din;
		// end 
		d_out[7:0] <= ram[addr*2];
        d_out[15:8] <= ram[(addr*2) + 1];
	end
	assign dout = d_out;
endmodule

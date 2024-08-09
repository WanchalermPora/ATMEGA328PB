// Initializing Block RAM from external data file
// Binary data
// File: Program_Mem.v
// `include "../../02_design/02_rtl/src/fft.ino.bin"

module Program_Mem

    (clk, we, addr, din, dout);

    parameter use_bin = 1;
    parameter use_crc = 0;
	parameter use_peri = 0;

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

	logic [13:0] iAdress ;
	logic  iRD ;

	always @(*) begin
		#(5) iAdress <= addr;
		#(1) iRD <= !(clk);

        // iAdress <= addr;
		// iRD <= !(clk);
        // iRD <= !(clk);
	end
	// assign 

	initial begin
		// i <= 0;
        // Progmem default = FF
        foreach (ram[i]) begin
            ram[i] = 8'hff;
        end

        if (use_bin) begin
            // $display("---------------------------------------------");
            // $display("Begin Using binary files");
            // $display("---------------------------------------------");            
            
            if (use_crc) begin
                // $display("");
                // $display("---------------------------------------------");
                $display("Using CRC                 ");
                // $display("---------------------------------------------");   
                // file = $fopen("../../02_design/02_rtl/src/core/binaries/ADC_SUBI_SBIW_MULS_ROL.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/core/binaries/ADD_SBC_COM_EOR_MUL.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/core/binaries/ADIW_OR_NEG_FMULS_LSL.bin" , "rb");     
                // file = $fopen("../../02_design/02_rtl/src/core/binaries/BSET_BCLR.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/core/binaries/FMUL_MULSU_CLR_INC_LSR_ASR.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/core/binaries/CALL.bin" , "rb");
                file = $fopen("../../02_design/02_rtl/src/core/binaries/crc_2.bin" , "rb");
				// file = $fopen("../../02_design/02_rtl/src/core/binaries/peri_test.bin" , "rb");
				
            end            
            else if (use_peri) begin
				$display("Using Peripherals                 ");
				// file = $fopen("../../02_design/02_rtl/src/core/binaries/peri_test.bin" , "rb");
				// $display("../../02_design/02_rtl/src/core/binaries/peri_test.bin");
				// file = $fopen("../../02_design/02_rtl/src/core/binaries/TImer_test.bin" , "rb");
				// $display("../../02_design/02_rtl/src/core/binaries/TImer_test.bin");				
				// file = $fopen("../../02_design/02_rtl/src/core/binaries/USART_test.bin" , "rb");
				// $display("../../02_design/02_rtl/src/core/binaries/USART_test.bin");
				// file = $fopen("../../02_design/02_rtl/src/core/binaries/TWI_test.bin" , "rb");
				// $display("../../02_design/02_rtl/src/core/binaries/TWI_test.bin");
				// file = $fopen("../../02_design/02_rtl/src/core/binaries/GPIO_IN_OUT.bin" , "rb");
				// $display("../../02_design/02_rtl/src/core/binaries/GPIO_IN_OUT.bin");
				file = $fopen("../../02_design/02_rtl/src/core/binaries/ext_int_test.bin" , "rb");
				// $display("../../02_design/02_rtl/src/core/binaries/ext_int_test.bin");	
                // $display("---------------------------------------------");  
			end
            else begin
                // $display("");
                // $display("---------------------------------------------");
                $display("Using Others                 ");
                // file = $fopen("../../02_design/02_rtl/src/core/binaries/fft.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/core/binaries/randomassembly.bin" , "rb");

				file = $fopen("../../02_design/02_rtl/src/core/binaries/random2.bin" , "rb");
                // file = $fopen("../../02_design/02_rtl/src/memory/random2.bin" , "rb");

                // $display("../../02_design/02_rtl/src/core/binaries/random2.bin");
                // $display("---------------------------------------------");  
            end

            if (file == 0) begin
                $display("Could not open file");
            end
        
            code = $fread(ram,file);  
        // $displayh(ram);        
            $fclose(file);
        end

        else begin
        
    //         $display("---------------------------------------------");
    //         $display("Begin Using custom prog mem");
    //         $display("---------------------------------------------");


        ram[0] = 8'hea;    ram[1] = 8'he0;            //LDI 
        ram[1*2] = 8'hF0;  ram[1*2+1] = 8'hE0;            //LDI 
        ram[2*2] = 8'h0F;  ram[2*2 + 1] = 8'h01;            //movw 
        ram[3*2] = 8'h00;  ram[3*2 + 1] = 8'h00;            //
        ram[4*2] = 8'h00;  ram[4*2 + 1] = 8'h00;            //nop 
        ram[5*2] = 8'he8;  ram[5*2 + 1] = 8'h95;            
        
    //     ram[8] = 8'h20;  ram[9] = 8'h93;            //STS 0x0800 ,R18
    //     ram[10] = 8'h00;  ram[11] = 8'h08;
        
    //     ram[12] = 8'h40;  ram[13] = 8'h93;              //STS 0x0001 ,R20
    //     ram[14] = 8'h01;  ram[15] = 8'h00;
        
    //     ram[16] = 8'h30;  ram[17] = 8'h93;              //STS 0x0021 ,R19 
    //     ram[18] = 8'h5F;  ram[19] = 8'h00;

    //     // ram[16] = 8'h30;  ram[17] = 8'h93;              //STS 0x0021 ,R19 
    //     // ram[18] = 8'h01;  ram[19] = 8'h08;
        
    //     ram[20] = 8'h00;  ram[21] = 8'h93;              //STS 0x007F ,R16
    //     ram[22] = 8'h7F;  ram[23] = 8'h00;

    //     ram[24] = 8'h30;  ram[25] = 8'h90;            //LDS R3 0x0800
    //     ram[26] = 8'h00;  ram[27] = 8'h08;    

    //     ram[28] = 8'h40;  ram[29] = 8'h90;            //LDS R4 0x0001
    //     ram[30] = 8'h01;  ram[31] = 8'h00; 

    //     ram[32] = 8'h50;  ram[33] = 8'h90;            //LDS R4 0x0001
    //     ram[34] = 8'h5F;  ram[35] = 8'h00; 


    //     ram[36] = 8'he1;  ram[37] = 8'he0;  // LDI R30, 2
    //     ram[38] = 8'hf3;  ram[39] = 8'he0; // LDI R31, 3 
        
    //     // ram[40] = 8'h09;  ram[41] = 8'h95;  // ICALL 
    //     ram[40] = 8'h05;  ram[41] = 8'h90;  // LPM 
    //     ram[42] = 8'h50;  ram[43] = 8'h90; 
    //     // ram[40] = 8'h0e;  ram[41] = 8'h94;  // CALL 
    //     // ram[42] = 8'h90;  ram[43] = 8'h00;  //  
        
    //     ram[144*2 ] = 8'h2F;  ram[144*2  + 1] = 8'h93; // PUSH R18 @144
    //     ram[145*2 ] = 8'h2F;  ram[145*2 + 1] = 8'h91; // POP R18 @145
    //     ram[146*2 ] = 8'h08;  ram[146*2 + 1] = 8'h95; // RET @130
    //     ram[147*2 ] = 8'h08;  ram[147*2 + 1] = 8'h95; // RET @131

        
    //     ram[42] = 8'he8;  ram[43] = 8'he0;  // LDI R30, 8
    //     ram[44] = 8'hf0;  ram[45] = 8'he0; // LDI R31, 0         
    //     ram[46] = 8'h09;  ram[47] = 8'h94;  // 




        end
        
	end


    
	always @(*)
	// always @(negedge clk)
	begin
		if (we) begin
			ram[addr] <= din;
		end 
		// if (iRD) begin
        else begin
			d_out[7:0] <= ram[iAdress*2];
        	d_out[15:8] <= ram[(iAdress*2) + 1];
		end
	end
	assign dout = d_out;
endmodule

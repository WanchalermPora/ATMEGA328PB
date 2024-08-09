int a = 0 , b = 0;
task  run_test_random();
    fork
        begin
            if (( PC == 16'h1 && b == 0) 
            ) begin
                // print_SREG();
                $display("found PC = %04h ", PC , "AT : %06d" , cycles_cnt);
                // repeat(2)@(negedge clk)
                // print_GPREG();
                // print_SREG();
                // print_SP();
                // $display("inst = %04h " , INST);
                // $display("inst = %04h " , INST1);
                b = 1;
            end
        end
        begin
            if (ICALL) begin
                // $write("At cycle : %06d" , cycles_cnt ," ICALL  =  " , ICALL , " with pc : %0h" , PC - 1);
                // repeat(2) @(posedge clk) ; @(negedge clk) ;
                // $write(" to : %0h" , PC ,"\n");
            end
        end
        begin
            
            // if (( PC == 16'h2EC5) 
            if (( PC == 16'h30CD && a == 0) // PC FOR latest dump
            ) begin
                // if (a == 2) begin
                // $display(a);
                a = 1;
                // wait(PC == 16'h3560) begin // PC FOR Ret in dump subroutine
                    // repeat(5)@(posedge clk);
                    $display("found PC = %04h ", PC , "AT : %06d" , cycles_cnt);
                    dump_sram_in_hex_end( 16'h463 , 1180  , "dumpall_DUT");
                // end
                // a = a + 1;
                
                // export_from_sram_in_C( 256 , 256 + 32 , h_filename );
                // export_from_sram_in_hex( 256 , 256 + 32 , h_filename );
            end
            
        end
    join_none
endtask 

task  print_GPREG();
    // $display("- - - - - - - - - - - - - - - - - - - - - - - -");
    $display("GENERAL PROPOSE REGISTER       ");
    $display("- - - - - - - - - - - - - - - - - - - - - - - - - - - -" );
    for (int i = 0; i < 32 ; i++ ) begin
        $display(" R[%02d] = %08h" , i , GPREG[i]);
    end
    $display("- - - - - - - - - - - - - - - - - - - - - - - - - - - -" );
endtask //

task  print_SREG();
    // $display("- - - - - - - - - - - - - - - - - - - - - - - -");
    $display("SREG                        ");
    $display("- - - - - - - - - - - - - - - - - - - - - - - - - - - -" );
    $write("I = %01b ", SREG[7] );
    $write(" T = %01b ", SREG[6] );
    $write(" H = %01b ", SREG[5] );
    $write(" S = %01b ", SREG[4] );
    $write(" V = %01b ", SREG[3] );
    $write(" N = %01b ", SREG[2] );
    $write(" Z = %01b ", SREG[1] );
    $write(" C = %01b ", SREG[0] , "\n");
    $display("- - - - - - - - - - - - - - - - - - - - - - - - - - - -" );
endtask //

task  print_SP();
    // $display("- - - - - - - - - - - - - - - - - - - - - - - -");
    $display("STACK POINTER                        ");
    $display("- - - - - - - - - - - - - - - - - - - - - - - - - - - -" );
    $write(" SP  = %04h ", SP , "\n");
    $write(" SPH = %02h ", SPH , "\n");
    $write(" SPL = %02h ", SPL , "\n");
    $display("- - - - - - - - - - - - - - - - - - - - - - - - - - - -" );
endtask //

task  export_from_sram_in_C(int start , int finish , string filename);
    int hfile;
    int iteration = 0 ;
    if (start >= 256 && finish >= 257 ) begin
        if (iteration == 0) hfile = $fopen({"../../03_verif/testbench_core/log/", filename ,".h"} , "w");
        else hfile = $fopen({"../../03_verif/testbench_core/log/", filename ,".h"} , "a");
        
        if (hfile) $display("exporting SRAM AT %04d into %s.h" , cycles_cnt , filename);
        $fwrite(hfile , "int A = ");
        for (int i = start - 256  ; i < finish - 256 ; i++) begin
            $fwriteh(hfile , "%02h " , SRAM[i]);
        end
        $fwrite(hfile , "\n");
        $fclose(hfile);
        iteration++;
    end
    
endtask //

task  export_from_sram_in_hex(int start , int finish , string filename);
    int hfile;
    int iteration = 0 ;
    logic [7:0]  bytecnt = 8'h10;
    logic [8*4 - 1 :0]  address = 0;
    logic [7:0]  readmode = 8'h00;
    if (start >= 256 && finish >= 257 ) begin
        if (iteration == 0) hfile = $fopen({"../../03_verif/testbench_core/log/", filename ,".hex"} , "w");
        else hfile = $fopen({"../../03_verif/testbench_core/log/", filename ,".hex"} , "a");
        
        if (hfile) $display("exporting SRAM AT %04d into %s.hex" , cycles_cnt , filename);
        $fwrite(hfile , ":");
        $fwriteh(hfile , "%02h" , bytecnt);
        $fwriteh(hfile , "%04h" , address);
        $fwriteh(hfile , "%02h" , readmode);

        for (int i = start - 256  ; i < finish - 256 ; i++) begin
            $fwriteh(hfile , "%02h" , SRAM[i]);
        end
        $fwrite(hfile , "\n");
        address = address + (finish - start);
        $fclose(hfile);
        iteration++;
    end
    
endtask //

task  dump_sram_in_hex_end(logic[15:0] start , int size , string filename);
    int hfile;
    // int iteration = 0 ;
    logic [7:0]  bytecnt = 8'h10;
    logic [8*4 - 1 :0]  address = start;
    logic [7:0]  readmode = 8'h00;
    logic [15:0] first_bytecnt = 8'h10 - start[0];
    logic [7:0]  last_bytecnt; 
    // if (start >= 256 && finish >= 257 ) begin
        // if (iteration == 0) 
        hfile = $fopen({"../../03_verif/testbench_v2/log/", filename ,".hex"} , "w");
        // else hfile = $fopen({"../../03_verif/testbench_core/log/", filename ,".hex"} , "a");
        
        if (hfile) $display("dumping SRAM AT %04d into %s.hex" , cycles_cnt , filename);
        // first line 
        first_bytecnt = 8'h10 - start[3:0]; 
        address = start ;
        $fwrite(hfile , ":");
        $fwriteh(hfile , "%02h" , first_bytecnt);
        $fwriteh(hfile , "%04h" , address);
        $fwriteh(hfile , "%02h" , readmode);
        for (int i = start - 256  ; i < start + first_bytecnt - 256 ; i++) begin
            // $displayh("%04h",i + 256);
            $fwriteh(hfile , "%02h" , SRAM[i]);
        end
        // $fwriteh(hfile , "%02h" , 8'hFF);
        $fwrite(hfile , "\n");
        address = address + first_bytecnt;

        // else 
        // for (int j = 0  ; j <  (size - first_bytecnt)/16  ; j++) begin
        while (address <= start + size - 16) begin
            $fwrite(hfile , ":");
            $fwriteh(hfile , "%02h" , bytecnt);
            $fwriteh(hfile , "%04h" , address);
            $fwriteh(hfile , "%02h" , readmode);
            for (int i = address - 256  ; i < address + 16 - 256 ; i++) begin
                // $displayh("%04h",i + 256);
                $fwriteh(hfile , "%02h" , SRAM[i]);
            end
            address = address + 16;
            // $fwriteh(hfile , "%02h" , 8'hFF);
            $fwrite(hfile , "\n");
        end
        // $fwrite(hfile , "\n");
        // address = address + (finish - start);
        last_bytecnt = start + size - address;
        $fwrite(hfile , ":");
        $fwriteh(hfile , "%02h" , last_bytecnt);
        $fwriteh(hfile , "%04h" , address);
        $fwriteh(hfile , "%02h" , readmode);
        for (int i = address - 256   ; i < start + size - 256 ; i++) begin
            // $displayh("%04h",i + 256);
            $fwriteh(hfile , "%02h" , SRAM[i]);
        end
        $fwrite(hfile , "\n");
        $fdisplay(hfile , ":00000001FF");

        $fclose(hfile);
        // iteration++;
    // end
    
endtask //

function bit check_by_cycle_rand( int cycle );
    bit a = 0;
    
    if ((cycle == 10) || 
    (cycle == 100) ||
    (cycle == 1000) ||
    (cycle == 2000) ||
    (cycle == 3000) ||
    (cycle == 4000) ||
    (cycle == 5000))begin
        a = 1;
        $display("");
        $display("+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +");
        $display("Display Components at Cycles : %04d  " , cycle , "At PC =  %016h" , PC ,"  Pinpoint: %0d , %0d" , PC*2 , PC*2 + 1 );
        $display("+ + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +");
        // $display(a);
    end 

    else begin
        a = 0;
    end
    // $display(cycle);
    return a;

endfunction

function bit check_by_pc(logic[15:0] cur_pc , logic[15:0] des_pc);
    bit a = 0;
    
    if (cur_pc == des_pc) begin
        a = 1;
    end
    else begin
        a = 0;
    end
    return a;
endfunction

task  check_crc(int position , bit to_files, string filename);
    int hfile;
    $display("+ + + + + + + + + + +");
    $display("Display CRC");
    $display("+ + + + + + + + + + +");
    $write("CRC = %02h","%02h","\n" , SRAM[position + 1] , SRAM[position]);
    if (to_files) begin
        hfile = $fopen({"../../03_verif/testbench_core/log/", filename ,".hex"} , "a");
        // $fwriteh(hfile , "%02h" , header);
        // $fwriteh(hfile , "%04h" , address);
        // $fwriteh(hfile , "%02h" , readmode);
        $fwriteh(hfile , "%02h" , SRAM[position]);
        $fwriteh(hfile , "%02h" , SRAM[position+1]);
        $fwrite(hfile , "\n");
        $fclose(hfile);
    end
endtask //
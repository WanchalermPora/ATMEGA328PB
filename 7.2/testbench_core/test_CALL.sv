int i = 1 ;
task  run_test_CALL();
    fork
        begin
            if (PC == 16'hCD) begin 
                $display("end iteration %0d" , i);
                i++;
                $write("-------------------------------------------------");
                $write("\n");
            end
        end
        begin
            if (JMP) begin
                $write("At cycle : %06d" , cycles_cnt ," JMP  =  " , JMP , " with pc : %0h" , PC - 1);
                repeat(2) @(posedge cp2_0) ; @(negedge cp2_0) ;
                $write(" to : %0h" , PC ,"\n");
            end
        end
        /*
        begin
            if (IJMP) begin
                $write("At cycle : %06d" , cycles_cnt ," IJMP  =  " , IJMP , " with pc : %0h" , PC - 1);
                @(posedge cp2_0) ; @(negedge cp2_0) ;
                $write(" to : %0h" , PC ,"\n");
            end
        end
        
        begin
            if (RJMP) begin
                $write("At cycle : %06d" , cycles_cnt ," RJMP  =  " , RJMP , " with pc : %0h" , PC - 1 );
                @(posedge cp2_0) ; @(negedge cp2_0) ;
                $write(" to : %0h" , PC ,"\n");
            end
        end
        
        begin
            if (CALL) begin
                $write("At cycle : %06d" , cycles_cnt ," CALL  =  " , CALL , " with pc : %0h" , PC - 1);
                repeat(3) @(posedge cp2_0) ; @(negedge cp2_0) ;
                $write(" to : %0h" , PC ,"\n");
            end
        end
        
        begin
            if (ICALL) begin
                $write("At cycle : %06d" , cycles_cnt ," ICALL  =  " , ICALL , " with pc : %0h" , PC - 1);
                repeat(2) @(posedge cp2_0) ; @(negedge cp2_0) ;
                $write(" to : %0h" , PC ,"\n");
            end
        end

        begin
            if (RCALL) begin
                $write("At cycle : %06d" , cycles_cnt ," RCALL  =  " , RCALL , " with pc : %0h" , PC - 1);
                repeat(2) @(posedge cp2_0) ; @(negedge cp2_0) ;
                $write(" to : %0h" , PC ,"\n");
            end
        end
        */
    join_none
endtask 

task  checkloop(  int cycle );

    if ((cycle == 236968) || 
    (cycle == 237428) ||
    (cycle == 237841) ||
    (cycle == 238278) ||
    (cycle == 238278) ||
    (cycle == 239323) ||
    (cycle == 240063))begin
        $display("++++++++++++++++++++");
        $display("begin test function");
        $display("++++++++++++++++++++");

    end 

    if (cycle == 240740) begin
        $display("********************");
        $display("end test function");
        $display("********************");
    end


endtask //

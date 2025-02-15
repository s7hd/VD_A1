
module fifo_test #(parameter DEPTH=8, DATA_WIDTH=8)(
    input logic clk, 
    fifo_intf  mif
    // fifo_intf #(DATA_WIDTH) mif;
                    );

// SYSTEMVERILOG: timeunit and timeprecision specification
    timeunit 1ns;
    timeprecision 1ns;

// SYSTEMVERILOG: new data types - bit ,logic
    bit         debug = 1;
    logic [DATA_WIDTH-1:0] rdata;  // Data read from FIFO
    logic [DATA_WIDTH-1:0] randi [0:DEPTH];
    logic [DATA_WIDTH-1:0] status = 0;
    
    // Monitor Results
  initial begin
      $timeformat ( -9, 0, " ns", 9 );
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
    end


    // Expectation Test Function
    task expect_test(input [DATA_WIDTH-1:0] expects, output [DATA_WIDTH-1:0] status);
        if (rdata !== expects) begin // Qamar: should it be rdata or mif.data_out?
            $display("ERROR: Expected %h, Got %h", expects, rdata);
            status = status + 1;
            $finish;
        end
    endtask

    // Main FIFO Test
initial
  begin: fifo_test
  int error_status;

  mif.fifo_reset();
    $display("==================================================");
    $display("                Clear Memory Test");
    $display("==================================================");

        // Write random data into FIFO
    for (int i = 0; i< DEPTH; i++)
     begin
       randi[i] = $random % 8'hFF;
       mif.fifo_write (randi[i], debug);
      end

        // Read back and verify data
    for (int i = 0; i<DEPTH; i++)
      begin 
       mif.fifo_read (rdata, debug);
       expect_test(rdata,status);
//        expect_test(randi[i],status);      
      end

    printstatus(error_status);
    $display("==================================================");
    $display("             Data = Address Test");
    $display("==================================================");


        // Write sequential values into FIFO
            for (int i = 0; i< DEPTH; i++) begin
       mif.fifo_write(i, debug); // QAMAR: should this be wdata or i?
  end
          // Read and check if data matches expected values
    for (int i = 0; i<DEPTH; i++)
      begin
       mif.fifo_read(rdata, debug);
       // check each memory location for data = address
       error_status = checkit (rdata, i);
      end
// SYSTEMVERILOG: void function
    printstatus(error_status);

    $finish;
  end


    // Function to check correctness
    function int checkit(input [DATA_WIDTH-1:0] actual, expected);
        static int error_status;
        if (actual !== expected) begin
            $display("ERROR: Data:%h Expected:%h", actual, expected);
            error_status++;
        end
        return error_status;
    endfunction: checkit

    // Array Verification Task
    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            logic [DATA_WIDTH-1:0] rand_data = $random;
            mif.fifo_write(rand_data, debug);
        end

        for (int i = 0; i < DEPTH; i++) begin
            mif.fifo_read(rdata, debug);
        end

        $display("Memory Test Completed");
        $finish;
    end


// SYSTEMVERILOG: void function
function void printstatus(input int status);
if (status == 0)
begin
    $display("\n");
    $display("                                  \\|/");
    $display("                                  (o o)");
    $display(" ___________oOO-{}-OOo____________");
    $display("|                                                                       |");
    $display("|                              TEST PASSED                              |");
    $display("|_________________________|");
    $display("\n");
end
else
begin
    $display("Test Failed with %d Errors", status);
    $display("\n");
    $display("                              _ ._  _ , _ ._");
    $display("                            (_ ' ( `  )_  .__)");
    $display("                          ( (  (    )   `)  ) _)");
    $display("                         (_ (   (_ . ) _) ,_)");
    $display("                             ~~\ ' . /~~");
    $display("                             ,::: ;   ; :::,");
    $display("                            ':::::::::::::::'");
    $display(" ___________/ _ \___________");
    $display("|                                                                       |");
    $display("|                              TEST FAILED                              |");
    $display("|_________________________|");
    $display("\n");
end
endfunction : printstatus

endmodule

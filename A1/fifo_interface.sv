
interface fifo_intf #(parameter DATA_WIDTH = 8) (input logic clk); 
logic rst_n;
logic wr_en;
logic rd_en;
logic [DATA_WIDTH-1:0] data_in;
logic [DATA_WIDTH-1:0] data_out;
logic full;
logic empty;

modport DUT (input rst_n,wr_en, rd_en, data_in, output data_out,full,empty);
modport TB (output rst_n,wr_en, rd_en, data_in, input data_out,full,empty);

task fifo_reset();
        if(!rst_n) begin
        empty<=1; end
        else if(rst_n) begin
        empty<=0; end
endtask


task fifo_write (input [DATA_WIDTH-1:0] wdata, input debug=0);
  @(negedge clk);
  wr_en <= 1;
  rd_en  <= 0;
  data_in  <= wdata;
  @(negedge clk);
  wr_en <= 0;
  if (debug == 1)
  $display("Write Data:%h", data_in);
endtask

task fifo_read (output [DATA_WIDTH-1:0] rdata, input debug = 0);
   @(negedge clk); 
   wr_en <= 0;
   rd_en  <= 1;
   @(negedge clk);
   rd_en <= 0;
   rdata = data_out;                        
   if (debug == 1) 
  $display("Read  Data:%h", rdata);
endtask

endinterface

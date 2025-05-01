`timescale 1ns / 1ps

module test_dataDistributor();
    
    parameter resolution = 8;
    parameter inputSize = 4;
    parameter kernelSize = 3;
    parameter NUM_MODULES = 4;
    
    reg [kernelSize*kernelSize*resolution - 1: 0] i = 72'habcdeffedcbaabcdef;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg [kernelSize*kernelSize*resolution - 1: 0] in_data;
    reg ack_sr = 1'b0;
    reg data_read = 0;
    reg write_enable = 0;
    wire [NUM_MODULES-1:0] valid;
    wire [resolution*NUM_MODULES - 1 : 0] module_out;
    wire full;
    
    data_distributor dut(.clk(clk), .rst(rst), .write_enable(write_enable), .write_data(in_data), .module_out(module_out), .valid(valid), .full(full));

    always #5 clk = ~clk;
    always  begin
        #55;
        data_read = 1'b0;
        #20;
        data_read = 1'b0;
        #50;
        data_read = 1'b0;
    end
    
    always  begin
        #20;
        write_enable = 1'b1;
        #30;
        write_enable  = 1'b1;
        #80;
        write_enable  = 1'b1;
    end
    
    initial #10 rst = 1'b0;
//    initial #11 rst = 1'b0;
    
    always@(posedge clk) begin
        in_data <= i;
        i <= i + 1000;
    end
        initial #120 $finish;
    
endmodule    

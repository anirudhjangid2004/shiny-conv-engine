`timescale 1ns / 1ps


module test_weightPipe();
    parameter resolution = 8;
    parameter inputSize = 4;
    parameter kernelSize = 3;
    parameter stride = 1;
    parameter NUM_MODULES = 4;
    parameter FIFO_DEPTH = 16;
    parameter MEM_DEPTH = 16;
    
    reg [kernelSize*resolution - 1: 0] i = 24'hADBEEF;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg in_valid = 1'b0;
    reg shift = 1'b0;
    
    wire valid;
    wire [resolution - 1 : 0] data_out;
        
    weightPipe #(
        .kernelSize(kernelSize),
        .resolution(resolution)
        )
        unit_weight_pipe(.clk(clk), .rst(rst), .row_in(i), .row_valid(in_valid), 
                        .shift(shift), .data_out(data_out), .valid(valid));
                        
    always #10 clk =~clk;
     
    always@(posedge clk) begin
         i <= i + 1000;
    end
     
    initial begin
        #40;
        rst = 1'b0;
    end
        
    initial begin
        #60 in_valid = 1'b1;
        #600 in_valid = 1'b0;
    end           
                  
    initial #300 $finish;   
endmodule

`timescale 1ns / 1ps


module test_topModule();

    parameter resolution = 8;
    parameter inputSize = 16;
    parameter kernelSize = 4;
    parameter stride = 1;
    parameter NUM_MODULES = (inputSize-kernelSize-stride + 2)*(inputSize-kernelSize-stride + 2);
    parameter FIFO_DEPTH = 256;
    parameter MEM_DEPTH = 256;
    
    reg [inputSize*resolution - 1: 0] inputValue = 128'h01020102010201020102010201020102;
    reg [kernelSize*resolution - 1: 0] weightValue = 32'h01020102;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg in_valid = 1'b0;
    reg weight_valid = 1'b0;

    wire result_valid;
    wire [resolution*NUM_MODULES - 1 : 0] result;
    
    topModule #(
        .inputSize(inputSize),
        .kernelSize(kernelSize),
        .resolution(resolution),
        .stride(stride),
        .FIFO_DEPTH(FIFO_DEPTH),
        .MEM_DEPTH(MEM_DEPTH)
        )
        unit_topModule(clk, rst, inputValue, in_valid, 
                       weightValue, weight_valid, 
                       result, result_valid);
                        
                        
    always #50 clk =~clk;
     
    always@(posedge clk) begin
         inputValue <= inputValue + 0;
         weightValue <= weightValue + 0;
    end
     
    initial begin
        #200;
        rst = 1'b0;
    end
        
    initial begin
        #600 
        in_valid = 1'b1;
        weight_valid = 1'b1;
        
        #600
        weight_valid = 1'b0;
        
        #6000 in_valid = 1'b0;
    end           
                  
    initial #30000 $finish; 

endmodule
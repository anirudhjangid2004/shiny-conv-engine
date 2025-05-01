`timescale 1ns / 1ps

module test_inputPipe();

    parameter resolution = 8;
    parameter inputSize = 4;
    parameter kernelSize = 3;
    parameter stride = 1;
    parameter NUM_MODULES = 4;
    parameter FIFO_DEPTH = 16;
    parameter MEM_DEPTH = 16;
    
    reg [inputSize*resolution - 1: 0] i = 32'hDEADBEEF;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg in_valid = 1'b0;

    
    wire [NUM_MODULES-1:0] array_valid;
    wire [resolution*NUM_MODULES - 1 : 0] array_out;
    
    inputPipe #(
        .inputSize(inputSize),
        .kernelSize(kernelSize),
        .resolution(resolution),
        .stride(stride),
        .FIFO_DEPTH(FIFO_DEPTH),
        .MEM_DEPTH(MEM_DEPTH)
        )
        unit_input_pipe(.clk(clk), .rst(rst), .row_in(i), .in_valid(in_valid), .array_out(array_out), 
                        .array_valid(array_valid));
                        
    always #10 clk =~clk;
     
    always@(posedge clk) begin
         i <= i + 000;
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

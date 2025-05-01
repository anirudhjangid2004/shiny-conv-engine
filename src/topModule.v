`timescale 1ns / 1ps


module topModule #(
    parameter inputSize = 16,
    parameter kernelSize = 4,
    parameter resolution = 8,
    parameter stride = 1,
    parameter NUM_MODULES = (inputSize-kernelSize-stride + 2)*(inputSize-kernelSize-stride + 2),   // Number of modules to distribute data to
    parameter FIFO_DEPTH = 256,    // Maximum FIFO depth
    parameter MEM_DEPTH = 256
)(
    input clk,
    input rst,
    input [inputSize*resolution - 1 : 0] input_row_in,
    input in_valid,
    input [kernelSize*resolution - 1 : 0] weight_row_in,
    input row_valid,
    
    output [NUM_MODULES*resolution - 1 : 0] result,
    output result_valid
    );
    
    wire [NUM_MODULES*resolution - 1:0] inputPipe_out;
    wire [NUM_MODULES - 1 : 0] inputPipe_valid;
    
    wire [resolution - 1 : 0] weightPipe_out;
    wire weightPipe_valid;
    
    wire shift_valid;
    
    wire [NUM_MODULES*resolution - 1:0] pe_out;
    wire [NUM_MODULES - 1 : 0] pe_valid;
    
    inputPipe #(.inputSize(inputSize), .kernelSize(kernelSize), .resolution(resolution), .stride(stride),
                .FIFO_DEPTH(FIFO_DEPTH), .MEM_DEPTH(MEM_DEPTH))
    u_ip (.clk(clk), .rst(rst), .row_in(input_row_in), .in_valid(in_valid), 
          .array_out(inputPipe_out), .array_valid(inputPipe_valid), .shift_valid(shift_valid));
    
    weightPipe #(.kernelSize(kernelSize), .resolution(resolution))
    u_wp (.clk(clk), .rst(rst), .row_in(weight_row_in), .row_valid(row_valid), .shift(shift_valid),
          .data_out(weightPipe_out), .valid(weightPipe_valid));
    
    peArray #(.inputSize(inputSize), .kernelSize(kernelSize), .resolution(resolution), .stride(stride),
              .FIFO_DEPTH(FIFO_DEPTH), .MEM_DEPTH(MEM_DEPTH))
    u_pa (.clk(clk), .rst(rst), .inputPipe_values(inputPipe_out), .inputPipe_valid(inputPipe_valid),
          .weightPipe_data(weightPipe_out), .weightPipe_valid(weightPipe_valid), 
          .result(pe_out), .result_valid(pe_valid));
          
    pe_output #(.inputSize(inputSize), .kernelSize(kernelSize), .resolution(resolution), .stride(stride))
    u_pe_output(.clk(clk), .rst(rst), .value(pe_out), .valid(pe_valid), .output_pe(result), .output_pe_valid(result_valid));
    
endmodule

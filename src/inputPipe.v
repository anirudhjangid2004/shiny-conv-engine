`timescale 1ns / 1ps

/*
    This module is working fine
*/

module inputPipe #(
    parameter inputSize = 6,
    parameter kernelSize = 3,
    parameter resolution = 8,
    parameter stride = 1,
    parameter NUM_MODULES = (inputSize-kernelSize-stride + 2)*(inputSize-kernelSize-stride + 2),   // Number of modules to distribute data to
    parameter FIFO_DEPTH = 16,    // Maximum FIFO depth
    parameter MEM_DEPTH = 16
)(
    input clk,
    input rst, 
    input [inputSize*resolution - 1 : 0] row_in,
    input in_valid,
    
    output [NUM_MODULES*resolution - 1:0] array_out,
    output [NUM_MODULES - 1 : 0] array_valid,
    output shift_valid
    
    );
    
    wire out_valid;
    wire [kernelSize*kernelSize*resolution - 1: 0] darr_out;
    wire bufferFull;
    
    wire [resolution*NUM_MODULES - 1 : 0] dist_out;
    wire [0 : NUM_MODULES-1] dist_valid;
    wire dist_full;
    
//    wire [NUM_MODULES*resolution - 1:0] array_out;
//    wire [NUM_MODULES - 1 : 0] array_valid;
    
    dataArrange #(
        .inputSize(inputSize),
        .kernelSize(kernelSize),
        .resolution(resolution),
        .stride(stride)
        )
        unit_data_arrangement(.clk(clk), .rst(rst), .row_in(row_in), .in_valid(in_valid),
                              .out_valid(out_valid), .data_out(darr_out), .bufferFull(bufferFull));
                              
     data_distributor #(
         .inputSize(inputSize),
         .kernelSize(kernelSize),
         .resolution(resolution),
         .stride(stride),
         .NUM_MODULES(NUM_MODULES),
         .FIFO_DEPTH(FIFO_DEPTH),
         .MEM_DEPTH(MEM_DEPTH)
     )
     unit_data_distributor(.clk(clk), .rst(rst), .write_enable(out_valid), .write_data(darr_out), 
                           .module_out(dist_out), .valid(dist_valid), .full(dist_full));
                      
     assign shift_valid = dist_valid[NUM_MODULES - 1];               
                           
     syncArray #(
         .inputSize(inputSize),
         .kernelSize(kernelSize),
         .resolution(resolution),
         .stride(stride),
         .NUM_MODULES(NUM_MODULES),
         .FIFO_DEPTH(FIFO_DEPTH),
         .MEM_DEPTH(MEM_DEPTH)
     )
     unit_sync_array(.clk(clk), .rst(rst), .data_in(dist_out), .valid(dist_valid), 
                     .data_out(array_out), .vout(array_valid));
    
endmodule

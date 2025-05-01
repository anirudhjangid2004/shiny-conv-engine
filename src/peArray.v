`timescale 1ns / 1ps

module peArray#(
    parameter inputSize = 4,
    parameter kernelSize = 3,
    parameter resolution = 8,
    parameter stride = 1,
    parameter NUM_MODULES = (inputSize-kernelSize-stride + 2)*(inputSize-kernelSize-stride + 2),   // Number of modules to distribute data to
    parameter FIFO_DEPTH = 16,    // Maximum FIFO depth
    parameter MEM_DEPTH = 16
)(
    input clk,
    input rst,
    input [NUM_MODULES*resolution - 1:0] inputPipe_values,
    input [NUM_MODULES - 1 : 0] inputPipe_valid,
    input [resolution - 1 : 0] weightPipe_data,
    input weightPipe_valid,
    
    output [NUM_MODULES*resolution - 1 : 0] result,
    output [NUM_MODULES - 1 : 0] result_valid
);
    
    wire [resolution-1:0] w_interconnect [NUM_MODULES:0];
    assign w_interconnect[0] = weightPipe_data;
    
    genvar i;
    generate
    for(i = 0; i < NUM_MODULES; i = i + 1) begin
        MAC_PE #(.kernelSize(kernelSize), .resolution(resolution))
            u_pe (.clk(clk), .rst(rst), .enable(inputPipe_valid[NUM_MODULES - 1 - i]), 
                  .x_in(inputPipe_values[(NUM_MODULES - i)*resolution-1 -: resolution]), 
                  .w_in(w_interconnect[i]), .w_out(w_interconnect[i + 1]), 
                  .mac_out(result[(((NUM_MODULES - i)*resolution) - 1) -: (resolution)]), .outValid(result_valid[NUM_MODULES - 1 - i]));    
    end
    endgenerate
    
    
endmodule

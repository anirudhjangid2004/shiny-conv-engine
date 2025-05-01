`timescale 1ns / 1ps

/*
    WOrking Jangid tested at 18 48 on 06/04/2025
*/

module weightPipe #( 
    parameter kernelSize = 3,
    parameter resolution = 8
)(
    input clk,
    input rst,
    input [kernelSize*resolution - 1 : 0] row_in,
    input row_valid,
    input shift,
    output [resolution - 1 : 0] data_out,
    output valid
    );
    
    wire [kernelSize*kernelSize*resolution - 1 : 0] out_wc;
    wire out_wc_valid;
    
    weightConcatenate #(
        .N(kernelSize),
        .WIDTH(resolution)
    ) u_wc ( .clk(clk), .rst(rst), 
             .row_in(row_in),
             .row_valid(row_valid),
             .concatenated_out(out_wc),
             .valid(out_wc_valid)
            );
            
    shiftWeights #(
        .N(kernelSize),
        .WIDTH(resolution)
    ) u_sw (.clk(clk), .rst(rst),
            .shift(shift), .data_in(out_wc),
            .input_valid(out_wc_valid),
            .data_out(data_out),
            .valid(valid)
            ); 
    
endmodule

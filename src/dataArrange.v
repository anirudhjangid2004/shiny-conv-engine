`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Comments: This module will input the rows of input matrix one by one and 
//           will output same no. of elements as in a row but in an arranged
//           manner as required for MAC.
//
//////////////////////////////////////////////////////////////////////////////////

module dataArrange #(
    parameter inputSize = 4,
    parameter kernelSize = 3,
    parameter resolution = 8,
    parameter stride = 1
)(
    input clk,
    input rst,
    input [inputSize*resolution - 1 : 0] row_in,
    input in_valid,
    output reg out_valid,
    output [kernelSize*kernelSize*resolution - 1: 0] data_out,
    output reg bufferFull
);   
    
    integer i, j;

    reg [7:0] counter = 0;
    reg [7:0] x_count = 0;
    reg [7:0] y_count = 0;
    reg counter_down = 1'b0;

    reg [inputSize*resolution - 1 : 0] inputBuff [0 : inputSize-1];
    reg [kernelSize*kernelSize*resolution - 1 : 0] outputBuff;


    // Sequential logic to handle input buffering
    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
//            counter_down <= 1'b0;
            bufferFull <= 1'b0;
        end 
        else begin
            if(in_valid) begin
                if (!counter_down) begin
                    inputBuff[counter] <= row_in;
                    counter <= counter + 1;
                end 
                else begin
                    counter <= 0;
                    bufferFull <= 1'b1;
                end
            end
            else begin
                inputBuff[counter] <= inputBuff[counter];
                counter <= counter;
            end
        end
    end

    // Changing the ckt into combinational, basically making the assignments blocking
    // Sequential logic for sliding window operation
    always @(posedge clk) begin
        if (rst) begin
            x_count <= 0;
            y_count <= 0;
            out_valid <= 1'b0;
            counter_down <= 1'b0;
            i <= 0;
            j <= 0;
        end 
        else if (counter >= kernelSize) begin
            if ((x_count < inputSize - kernelSize - stride + 2) && 
                (y_count < inputSize - kernelSize - stride + 2) &&
                 !counter_down) begin
                // Fill the output buffer
                for (i = 0; i < kernelSize; i = i + 1) begin
                    for (j = 0; j < kernelSize*resolution; j = j + 1) begin
                        outputBuff[i * kernelSize*resolution + j] <= 
                            inputBuff[y_count + i][(inputSize - kernelSize - x_count)*resolution + j];
                    end
                end

                // Update x_count
                x_count <= x_count + stride;
                out_valid <= 1'b1;
            end 
            else if ((x_count >= inputSize - kernelSize - stride + 2) && 
                     (y_count < inputSize - kernelSize - stride + 2)  &&
                     !counter_down) begin
                // Move to the next row
                x_count <= 0;
                y_count <= y_count + stride;
                out_valid <= 1'b0;
            end 
            else begin
                // Reset counts and indicate completion
                x_count <= 0;
                y_count <= 0;
                counter_down <= 1'b1;
                out_valid <= 1'b0;
            end
        end
    end

    // Assign the output
    assign data_out = (out_valid == 1'b1) ? outputBuff : {kernelSize*kernelSize*resolution{1'b0}};

endmodule


`timescale 1ns / 1ps

module shiftWeights #(
    parameter N = 3,
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst,
    input wire shift,
    input wire [N*N*WIDTH-1:0] data_in, // Large row input
    input wire input_valid,
    output reg [WIDTH-1:0] data_out, // One element at a time
    output reg valid
);

    reg [N*N*WIDTH-1:0] shift_reg;
    integer i;
    reg [7 : 0] shift_count;
    reg shift_empty;

    always @(posedge clk or posedge rst) begin
        
        if (rst) begin
            shift_reg <= 0;
            data_out <= 0;
            shift_count <= 0;
            shift_empty <= 1;
            valid <= 1'b0;
            i <= 0;
        end 
        
        else if(input_valid && shift_empty) begin
            shift_reg <= data_in;
            shift_empty <= 0;
            valid <= 1'b0;
        end
        
        else if (shift) begin
            data_out <= shift_reg[N*N*WIDTH-1 -: WIDTH]; // Extract the MSB element
            shift_reg <= {shift_reg[N*N*WIDTH-WIDTH-1:0], {WIDTH{1'b0}}}; // Shift left
            shift_count <= shift_count + 1;
            valid <= 1'b1;
            if(shift_count == N * N - 1) begin
                shift_count <= 0;
                shift_empty <= 1;
            end 
        end
    end
    
endmodule

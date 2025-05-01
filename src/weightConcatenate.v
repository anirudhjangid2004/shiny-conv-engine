`timescale 1 ns/1 ps

module weightConcatenate #(
    parameter N = 3,  // Matrix size (N x N)
    parameter WIDTH = 8 // Bit width of each element in a row
)(
    input wire clk,
    input wire rst,
    input wire [N*WIDTH-1:0] row_in,  // Input row (concatenated N elements)
    input wire row_valid, // Indicates valid input row
    output reg [N*N*WIDTH-1:0] concatenated_out, // Final concatenated row
    output reg valid // Output valid signal
);

    reg [N*N*WIDTH-1:0] buffer;
    reg [$clog2(N):0] row_count;

    always @(posedge clk) begin
        if (rst) begin
            buffer <= 0;
            row_count <= 0;
            valid <= 0;
        end 
        else if (row_valid) begin
            buffer <= {buffer[N*WIDTH*(N-1)-1:0], row_in}; // Shift and store the row
            row_count <= row_count + 1;
            if (row_count == N-1) begin
                concatenated_out <= {buffer[N*WIDTH*(N-1)-1:0], row_in};
                valid <= 1;
                row_count <= 0;
            end 
            else begin
                valid <= 0;
            end
        end
    end
endmodule

`timescale 1ns / 1ps

module macSyncReg #(
   parameter N = 3,                  // Number of stages
   parameter resolution = 4          // Width of input data
) (
   input wire clk,
   input wire rst,
   input wire [resolution - 1:0] din,
   input wire valid,  
   output wire [resolution - 1:0] dout,
   output wire vout
);

    reg [resolution - 1:0] shift_reg [0:N-1]; // N-stage shift register
    reg [N - 1 : 0] shift_reg_valid;
    integer i = 0;

    // Shift logic
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < N; i = i + 1) begin
                shift_reg[i] <= 0;
            end
        end 
        else begin
            for (i = N-1; i > 0; i = i - 1) begin
                shift_reg[i] <= shift_reg[i-1];
            end
            shift_reg[0] <= din;
        end
    end

    assign dout = shift_reg[N-1];
    
    
    always @(posedge clk) begin
        if (rst) begin
            shift_reg_valid <= 0;
        end else begin
            shift_reg_valid <= {shift_reg_valid[N-2:0], valid};
        end
    end

    assign vout = shift_reg_valid[N-1];

endmodule
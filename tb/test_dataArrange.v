`timescale 1ns / 1ps

module test_dataArrange();
    
    parameter resolution = 8;
    parameter inputSize = 4;
    parameter kernelSize = 3;
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg [inputSize*resolution - 1 : 0] in_data;
    reg in_valid = 1'b1;
    wire out_valid;    
    wire [kernelSize*kernelSize*resolution - 1 : 0] output_data;
    
    dataArrange dut(.clk(clk), .rst(rst), .row_in(in_data), .in_valid(in_valid),.out_valid(out_valid), .data_out(output_data));

    always #5 clk = ~clk;
    initial #10 rst = 1'b0;
    initial #12 in_valid = 1'b1;
//    initial #11 rst = 1'b0;
    
    always@(posedge clk) begin
        in_data <= 32'h01020304;
    end
    
    initial #120 $finish;
    
endmodule

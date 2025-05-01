`timescale 1ns / 1ps

module test_shiftReg_weights();

    parameter resolution = 8;
    parameter inputSize = 4;
    parameter kernelSize = 4;
    
    reg [resolution-1 : 0] i = 0;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg in_valid = 1'b0;
    reg [kernelSize*kernelSize*resolution - 1 : 0] in_data;
    wire out_valid;
    wire [resolution - 1 : 0] word_out;
    wire buff_ready;
    
    shiftReg_Input dut(.clk(clk), .rst(rst), .in_valid(in_valid), .in_data(in_data), .word_out(word_out), .out_valid(out_valid), .buff_ready(buff_ready));
    
    always #5 clk = ~clk;
        
    initial #10 rst = 1'b0;
    initial #15 in_valid = 1'b1;
    
    always@(posedge clk) begin
        in_data <= {kernelSize*kernelSize{i}};
        i <= i + 1;
    end
    
    initial #120 $finish;

endmodule

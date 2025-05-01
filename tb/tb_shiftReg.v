`timescale 1ns / 1ps
module tb_shiftReg();

    reg clk = 0;
    reg rst = 1;
    reg inValid = 0; 
    reg [71 : 0] inData;
    reg permit = 0;
    wire [7 : 0] word_out;
    wire out_valid;
    wire reg_loaded;
    
    shiftReg_Input #(.inputSize(4), .kernelSize(3), .resolution(8))
    sri (.clk(clk), .rst(rst), .in_valid(inValid), .in_data(inData), .permit(permit),
         .word_out(word_out), .out_valid(out_valid), .reg_loaded(reg_loaded));
    
    always #50 clk = ~clk;
    
    initial #200 rst = 0;
    initial #300 inValid = 1;
    initial begin
        inData = 0;
        #250;
        inData = 72'haabbccddaabbccddee;
    end
endmodule
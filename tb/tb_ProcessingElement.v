`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.01.2025 22:52:14
// Design Name: 
// Module Name: tb_ProcessingElement
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_ProcessingElement();
    reg clk = 0;
    reg rst = 1;
    reg enable = 0;
    reg [7:0] x_in;
    reg [7:0] w_in;
    wire [7:0] w_out;
    wire [7:0] mac_out;
    wire outValid;
    
    MAC_PE #(.resolution(8), .kernelSize(2))
        dut (.clk(clk),
             .rst(rst),
             .enable(enable),
             .x_in(x_in),
             .w_in(w_in),
             .w_out(w_out),
             .mac_out(mac_out),
             .outValid(outValid));
             
    always begin
        #10
        clk = ~clk;      
    end
    
    initial begin
        #15 rst <= 1'b0;
        #30 enable = 1'b1;
    end
    
    initial begin
        #45
        x_in = 1;
        w_in = 1;
        #20
        x_in = 2;
        w_in = 2;
        #20
        x_in = 3;
        w_in = 3;
        #20
        x_in = 1;
        w_in = 2;
    end
    
    initial begin
        #170
        $finish;
    end
    
endmodule

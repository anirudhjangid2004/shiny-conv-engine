`timescale 1ns / 1ps

// Final processing element, responsible for MAC operations. Have memory(only calculates values with high enable until required number of operations are performed)

module MAC_PE #(
    parameter resolution = 8,
    parameter kernelSize = 2
)(
    input clk,
    input rst,
    input enable,                           // Indicates validity of input data
    input [7:0] x_in,
    input [7:0] w_in,
    output [resolution - 1:0] w_out,
    output reg [resolution - 1:0] mac_out,
    output reg outValid
);
    
    reg [resolution - 1 : 0] maxCount = kernelSize * kernelSize;
    reg [resolution - 1 : 0] counter = {resolution{1'b0}};
    
    // Buffering the inputs
    reg [resolution - 1 : 0] win_buff;
    reg [resolution - 1 : 0] xin_buff;
    reg data_logged = 0;
    
    // Accumulator
    reg  [resolution - 1 : 0] accumulator = {resolution{1'b0}};
    wire [resolution - 1 : 0] multiplier; 
    
    always@(posedge clk) begin
        if (rst) begin
        end
        else begin
            if(enable) begin
                if(counter < maxCount) begin
                    win_buff <= w_in;
                    xin_buff <= x_in;
                    counter <= counter + 1;
                end
                else if (counter == maxCount) begin
                    counter <= {{(resolution-1){1'b0}}, {1'b1}};
                    win_buff <= w_in;
                    xin_buff <= x_in;
                end
            end
            else begin
                win_buff <= win_buff;
                xin_buff <= xin_buff;
                counter <= counter;
            end
        end
    end
    
    assign w_out = win_buff;
    
    assign multiplier = xin_buff * win_buff;
    
    always@(counter) begin
        if(rst) begin
            accumulator <= 0;
        end    
        if (counter == 1) begin
            accumulator <= multiplier;        
        end
        else if (counter <= maxCount) begin
            accumulator <= accumulator + multiplier;        
        end
    end
    
    always@(posedge clk) begin
        if(rst) begin
        end
        else begin
            if(counter < maxCount) begin
                outValid <= 1'b0;
                mac_out <= {resolution{1'b0}};
                data_logged <= 1'b0;
            end
            else if (counter == maxCount && ~(data_logged)) begin
                outValid <= 1'b1;
                mac_out <= accumulator;
                data_logged <= 1'b1;
            end
            else begin
                outValid <= 1'b0;
                mac_out <= {resolution{1'b0}};
                data_logged <= 1'b1;            
            end
        end
    end
    
endmodule
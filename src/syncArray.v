`timescale 1ns / 1ps
`include "params.vh"

/*
    This will contain the delaying registers to generate
    the required delay.
    Input from dataDistributor
    Output to peArray
    
    The pattern will be like
    
        0   1   2   3   ......  NUM_MODULE - 1
        
    For this we can make a shift reg which itself is parametric
    which means it will have number of levels equal to parameter.
*/

module syncArray #(
    parameter resolution = 8,     
    parameter inputSize = 4,
    parameter kernelSize = 3,
    parameter stride = 1,
    parameter NUM_MODULES = (inputSize-kernelSize-stride + 2)*(inputSize-kernelSize-stride + 2),   // Number of modules to distribute data to
    parameter FIFO_DEPTH = 16,    // Maximum FIFO depth
    parameter MEM_DEPTH = 16
)(
    input wire clk,
    input wire rst,
    input wire [NUM_MODULES*resolution - 1:0] data_in, // Input array containing Q slices
    input wire [NUM_MODULES - 1 : 0] valid,
    output wire [NUM_MODULES*resolution - 1:0] data_out, // Output array containing Q slices   
    output wire [NUM_MODULES - 1 : 0] vout
);

    reg [resolution - 1 : 0] interim;
    reg interim_valid;
    
    reg [NUM_MODULES*resolution - 1:0] data_in_final;
    reg [NUM_MODULES - 1:0] valid_final;
    
    
    always@(posedge clk) begin
        if(rst) begin
            data_in_final <= 0;
            valid_final   <= 0;
        end
        else begin
            data_in_final <= data_in;
            valid_final <= valid;
        end 
    end
    
    always@(posedge clk) begin
        if(rst) begin
            interim <= 0;
            interim_valid <= 0;            
        end
        else begin
            interim <= data_in_final[(NUM_MODULES)*resolution - 1 -: resolution];
            interim_valid <= valid_final[NUM_MODULES - 1];
        end
    end

    // Generate loop to instantiate shift registers
    genvar i;
    generate
        for (i = 0; i < NUM_MODULES; i = i + 1) begin : shift_registers
            if (i == 0) begin
                // No delay for the first instance
                assign data_out[NUM_MODULES*resolution - 1 -: resolution] = 
                       data_in_final[NUM_MODULES*resolution - 1 -: resolution];
                
                assign vout[NUM_MODULES-1] = valid_final[NUM_MODULES-1];           
                
            end
            
            else if(i == 1) begin
                assign data_out[(NUM_MODULES - 1)*resolution - 1 -: resolution] = 
                       interim;
                assign vout[NUM_MODULES-2] = interim_valid;
            end
             
            else begin
                // Shift register instances with increasing delay
//                $display("value of i is %d", );
                macSyncReg #(
                    .N(i),                  // Increasing delay
                    .resolution(resolution) // Data width
                ) u_shift_register (
                    .clk(clk),
                    .rst(rst),
                    .valid(valid_final[(NUM_MODULES - 1 - i)]),
                    .din(data_in_final[(NUM_MODULES - i)*resolution - 1 : (NUM_MODULES - 1 - i)*resolution]),
                    .vout(vout[(NUM_MODULES - 1 - i)]),
                    .dout(data_out[(NUM_MODULES - i)*resolution - 1 : (NUM_MODULES - 1 - i)*resolution])
                );
            end
        end
    endgenerate

endmodule


`timescale 1ns / 1ps

module pe_output #(
    parameter inputSize = 6,
    parameter kernelSize = 3,
    parameter resolution = 8,
    parameter stride = 1,
    parameter NUM_MODULES = (inputSize - kernelSize - stride + 2) * (inputSize - kernelSize - stride + 2)
)(
    input clk, rst,
    input [NUM_MODULES*resolution - 1:0] value,
    input [NUM_MODULES - 1:0] valid,
    output reg [NUM_MODULES*resolution - 1:0] output_pe,
    output reg output_pe_valid
);

reg [NUM_MODULES -1:0] valid_inputs;
reg [NUM_MODULES*resolution - 1:0] input_values;
integer counter;

always@(posedge clk or posedge rst) begin
    if(rst) begin
        counter <= 0;
        valid_inputs <= 0;
        input_values <= 0;
        output_pe_valid <= 0;
        output_pe <= 0;
    end else begin
        if(counter < NUM_MODULES) begin
            if(valid[NUM_MODULES - counter - 1]) begin
                input_values[(NUM_MODULES - counter - 1)*resolution +: resolution] <= 
                    value[(NUM_MODULES - counter - 1)*resolution +: resolution];
                valid_inputs[NUM_MODULES - counter - 1] <= 1'b1;
                counter <= counter + 1;
            end
        end
        
        if(counter == NUM_MODULES && &valid_inputs) begin
            output_pe <= input_values;
            output_pe_valid <= 1'b1;
            // Reset everything to start next frame
            counter <= 0;
            valid_inputs <= 0;
            input_values <= 0;
        end else begin
            output_pe_valid <= 1'b0;
        end
    end
end

endmodule
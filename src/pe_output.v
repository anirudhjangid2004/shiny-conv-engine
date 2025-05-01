//`timescale 1ns / 1ps

//module pe_output #(
//    parameter inputSize = 6,
//    parameter kernelSize = 3,
//    parameter resolution = 8,
//    parameter stride = 1,
//    parameter NUM_MODULES = (inputSize-kernelSize-stride + 2)*(inputSize-kernelSize-stride + 2)
//)(
//    input clk, rst,
//    input [NUM_MODULES*resolution - 1:0] value,
//    input [NUM_MODULES - 1:0] valid,
//    output [NUM_MODULES*resolution - 1:0] output_pe,
//    output output_pe_valid
//);

//reg [NUM_MODULES -1:0] valid_inputs;
//reg [NUM_MODULES*resolution - 1:0] input_values;

//integer counter;

//always@(posedge clk) begin
//    if(rst) begin
//        counter <= 0;
//        valid_inputs <= 0;
//        input_values <= 0;
//    end
//    else begin
//        if(valid[NUM_MODULES - counter - 1]) begin
//            counter <= counter + 1;
//            if(counter >= NUM_MODULES - 1) counter <= 0;
            
//            input_values[(NUM_MODULES - counter - 1)*resolution -1 -: resolution] <= 
//            value[(NUM_MODULES - counter - 1)*resolution -1 -: resolution];                
            
//            valid_inputs[NUM_MODULES - counter - 1] <= valid[NUM_MODULES - counter - 1];
//        end
//    end
//end

//assign output_pe_valid = &valid_inputs;
//assign output_pe = (&valid_inputs == 1'b1) ? input_values : 0;

//endmodule


//`timescale 1ns / 1ps

//module pe_output #(
//    parameter inputSize = 6,
//    parameter kernelSize = 3,
//    parameter resolution = 8,
//    parameter stride = 1,
//    parameter NUM_MODULES = (inputSize - kernelSize - stride + 2) * (inputSize - kernelSize - stride + 2)
//)(
//    input clk, rst,
//    input [NUM_MODULES*resolution - 1:0] value,
//    input [NUM_MODULES - 1:0] valid,
//    output reg [NUM_MODULES*resolution - 1:0] output_pe,
//    output reg output_pe_valid
//);

//reg [NUM_MODULES -1:0] valid_inputs;
//reg [NUM_MODULES*resolution - 1:0] input_values;

//integer counter;

//always@(posedge clk) begin
//    if(rst) begin
//        counter <= 0;
//        valid_inputs <= 0;
//        input_values <= 0;
//        output_pe_valid <= 0;
//        output_pe <= 0;
//    end 
//    else begin
//        if(counter < NUM_MODULES) begin
//            if(valid[NUM_MODULES - counter - 1]) begin
//                input_values[(NUM_MODULES - counter - 1)*resolution +: resolution] <= 
//                    value[(NUM_MODULES - counter - 1)*resolution +: resolution];
                    
//                valid_inputs[NUM_MODULES - counter - 1] <= 1'b1;
                
//                counter <= counter + 1;
//            end
//        end
        
//        if(&valid_inputs) begin
//            output_pe <= input_values;
//            output_pe_valid <= 1'b1;
//            counter <= 0; // Ready for next set
//            valid_inputs <= 0;
//            input_values <= 0;
//        end 
//        else begin
//            output_pe_valid <= 1'b0;
//        end
//    end
//end

//endmodule


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


//`timescale 1ns / 1ps

//module pe_output #(
//    parameter inputSize = 6,
//    parameter kernelSize = 3,
//    parameter resolution = 8,
//    parameter stride = 1,
//    parameter NUM_MODULES = (inputSize - kernelSize - stride + 2)*(inputSize - kernelSize - stride + 2)
//)(
//    input clk, rst,
//    input [NUM_MODULES*resolution-1:0] value,
//    input [NUM_MODULES-1:0] valid,
//    output reg [NUM_MODULES*resolution-1:0] output_pe,
//    output reg output_pe_valid
//);

//// Internal registers
//reg [NUM_MODULES*resolution-1:0] input_values;
//reg [NUM_MODULES-1:0] valid_inputs;

//integer i;

//// Always block
//always @(posedge clk or posedge rst) begin
//    if (rst) begin
//        input_values <= 0;
//        valid_inputs <= 0;
//        output_pe <= 0;
//        output_pe_valid <= 0;
//    end 
//    else begin
//        // Save incoming values based on valid signals
//        for (i = 0; i < NUM_MODULES; i = i + 1) begin
//            if (valid[i]) begin
//                input_values[i*resolution +: resolution] <= value[i*resolution +: resolution];
//                valid_inputs[i] <= 1'b1;
//            end
//        end
        
//        // Once all inputs are valid
//        if (&valid_inputs) begin
//            output_pe <= input_values;
//            output_pe_valid <= 1'b1;
//            valid_inputs <= 0;
//        end else begin
//            output_pe_valid <= 0;
//        end
//    end
//end

//endmodule
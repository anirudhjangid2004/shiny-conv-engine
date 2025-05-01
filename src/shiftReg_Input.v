`timescale 1ns / 1ps

module shiftReg_Input #(
    parameter inputSize = 4,           // Input size
    parameter resolution = 8,           // Bit resolution of each weight
    parameter kernelSize = 3
)(
    input clk,
    input rst,
    input in_valid,
    input permit,
    input [kernelSize*kernelSize*resolution - 1 : 0] in_data,
    output reg [resolution - 1 : 0] word_out,
    output reg out_valid,
    output reg_loaded
);

//    reg [7:0] counter = 0;  // Counter for tracking the total words shifted
//    reg [kernelSize*kernelSize*resolution - 1 : 0] weight_buff; 
//    reg [1:0] buff_addr = 0; // Address for the weight buffer
//    reg [inputSize*inputSize*resolution - 1 : 0] shift_reg; // Internal shift register
//    reg shiftReg_loaded = 1'b0;
//    reg [7:0] shiftedWord = 8'b0;

////    // Buffer the incoming weights
////    always @(negedge clk or posedge rst) begin
////        if (rst) begin
////            buff_addr <= 0;
////        end else if (in_valid && (buff_addr < 2'b01) && buff_ready) begin
////            weight_buff <= in_data;
////            buff_addr <= buff_addr + 1;
////        end
////    end

////    always @(posedge clk or posedge rst) begin
////        if (rst) begin
////            buff_ready <= 1'b0;
////        end else if (in_valid && (buff_addr < 2'b01)) begin
////            buff_ready <= 1'b1;
////        end else if (buff_addr >= 2'b01) begin
////            buff_ready <= 1'b0;
////        end
////    end

//    // Initialize the shift register and shift out data serially
//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            counter <= 0;
//            out_valid <= 1'b0;
//            buff_full <= 1'b0;
//            word_out <= 0;
//            shift_reg <= 0;
//        end 
//        else if (buff_ready) begin
//            if (counter == 0 || counter == 1) begin
//                // Load the current buffer into the shift register
//                shift_reg <= weight_buff;
//                out_valid <= 1'b0;
//                shiftReg_loaded <= 1'b1;
//            end 
//            else if (counter == 0) begin
//                out_valid <= 1'b0;
//            end
//            // Keep incrementing the counter with every clock
//            counter <= counter + 1;
//        end   
//        else if (shiftedWord >= kernelSize * kernelSize) begin
//            // Prepare for the next buffer
//            counter <= 1;
////            buff_addr <= buff_addr - 1;
//            shiftReg_loaded  <= 1'b0;
//            // Shift the buffer stack
////            if (buff_addr > 0) begin
////                weight_buff[0] <= weight_buff[1];
////            end
//            out_valid <= 1'b0;
//        end
//    end
    
//    always@(posedge clk) begin
//        if(shiftReg_loaded == 1'b1 && (shiftedWord < kernelSize*kernelSize)) begin
//            // Shift out data word by word
//            $display("This thing is executing");
//            out_valid <= 1'b1;
//            word_out <= shift_reg[resolution - 1 : 0];
//            shift_reg <= shift_reg >> resolution; // Right-shift by one word
//            shiftedWord <= shiftedWord + 1;
//        end
//        else if (shiftedWord <= inputSize*inputSize) begin
//            shiftedWord <= 8'b0;
//        end
//    end

    reg [kernelSize*kernelSize*resolution - 1 : 0] data_load;
    reg [7:0] counter;
    reg data_valid;
    
    always@(posedge clk) begin
    
        if(rst) begin
            counter <= 0;
            data_load <= 0;
            word_out  <= 0; 
            data_valid <= 0;
            out_valid <= 0;
        end
        
        else begin
            if(in_valid && !data_valid) begin
                data_load <= in_data;
                counter <= 0;
                data_valid <= 1'b1;   
            end   
            else if(data_valid) begin
//                
                if(permit) begin
                    word_out <= data_load[kernelSize*kernelSize*resolution - 1 -: resolution];
                    data_load <= data_load << resolution;
                    counter <= counter + 1;
                    out_valid <= 1'b1;                
                end
                
                if(counter >= kernelSize*kernelSize) begin
                    data_valid <= 1'b0;
                    out_valid <= 1'b0;
                    counter <= 8'h00;
                end            
            end            
        end
    end
    
    assign reg_loaded = data_valid;
    
endmodule

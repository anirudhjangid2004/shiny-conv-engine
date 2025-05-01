`timescale 1ns / 1ps

/*
    Seems to be working man, 26/02/25, jb tk read write pointer alag the
    
    NEEDS MAJOR CHANGE, WILL REMOVE THE FIFO and place a normal memory with valid bits
    This will help save energy by reducing the switching process, unlike fifo
    
    ALL the changes suggested above are done and now this thing is working

    TO IMPLEMENT:
    Take care where r_mem_count is going? when r_mem_count is full.

*/

module data_distributor #(
    parameter resolution = 8,     
    parameter inputSize = 4,
    parameter kernelSize = 3,
    parameter stride = 1,
    parameter NUM_MODULES = (inputSize-kernelSize-stride + 2)*(inputSize-kernelSize-stride + 2),   // Number of modules to distribute data to
    parameter FIFO_DEPTH = 32,    // Maximum FIFO depth
    parameter MEM_DEPTH = 32
)(  
    input wire clk,              
    input wire rst,              
    input wire write_enable,     
//    input wire data_pop,
    input wire [kernelSize*kernelSize*resolution-1: 0] write_data,
    output reg [NUM_MODULES*resolution - 1 : 0] module_out, 
    output reg [0 : NUM_MODULES-1] valid,     
    output full             // FIFO full flag
//    output empty             // FIFO empty flag
);

//    reg [kernelSize*kernelSize*resolution - 1: 0] fifo_mem [0:FIFO_DEPTH-1]; // FIFO memory array
//    reg [$clog2(FIFO_DEPTH+1)-1:0] w_fifo_count;      // Number of elements in FIFO
//    reg [$clog2(FIFO_DEPTH+1)-1:0] r_fifo_count;      // Number of elements in FIFO
    
    
    reg [kernelSize*kernelSize*resolution - 1: 0] memory [0 : MEM_DEPTH-1];
    reg [$clog2(FIFO_DEPTH+1)-1:0] w_mem_count;      // Number of elements in FIFO
    reg [$clog2(FIFO_DEPTH+1)-1:0] r_mem_count;      
    
    reg [$clog2(NUM_MODULES)-1:0] module_sel;       // Module selector (round-robin)
    reg [7 : 0] validated;
    reg [15 : 0] i;
    reg start;

    // SHIFT REGISTER SIGNALS
    reg [0 : NUM_MODULES - 1] InValid;
    reg [kernelSize*kernelSize*resolution - 1 : 0] InData [0 : NUM_MODULES - 1];
//    reg [0 : NUM_MODULES - 1] mem_valid;
    wire [resolution - 1 : 0] WordOut [0 : NUM_MODULES - 1];
    wire [0 : NUM_MODULES - 1] OutValid;
    wire [0 : NUM_MODULES - 1] RegValid;
    reg [0 : NUM_MODULES - 1] Permit;

    // FIFO control signals
    assign full = (w_mem_count == MEM_DEPTH);
//    assign empty = (r_fifo_count == 0);

    // Write to FIFO
//    always @(posedge clk or posedge rst) begin   // This was negedge initially
//        if (rst) begin

//        end 
//        else if (write_enable && !full) begin
//            fifo_mem[fifo_count] <= write_data;
//            fifo_count <= fifo_count + 1;
//        end
//    end

    // Distribute data from FIFO
//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
            
//            r_fifo_count <= 0;          // Reset FIFO count
//            module_sel <= 0;          // Reset module selector
////            valid <= 0;               // Clear valid signals
////            module_out <= 0;          // Clear output data
//            Permit <= 0;
//            validated <= 0;
//        end 
//        else if (!empty && data_pop) begin
//            if((r_fifo_count >= NUM_MODULES) && (r_fifo_count <= w_fifo_count)) begin

//                // Assign data to the selected module
//                InValid[module_sel] <= 1'b1;
//                InData[module_sel] <= fifo_mem[0];
////                valid[module_sel]  <= 1'b1;
//                validated <= validated + 1;
    
//                // Decrease FIFO count
//                r_fifo_count <= r_fifo_count + 1;
    
//                // Increment round-robin module selector
//                if(module_sel < NUM_MODULES) module_sel <= (module_sel + 1);
//                else module_sel <= 0;
                
//                // Make permission to make the outputs valid 
//                if(validated >= NUM_MODULES) Permit <= 4'hf;
//                else Permit <= 4'h0;
//            end
//        end
//    end
    
//    always@(posedge clk) begin  
//        if(rst) begin
//            for(i = 0; i < FIFO_DEPTH; i = i + 1) fifo_mem[i] = 0;
//            w_fifo_count <= 0;
//            start <= 1'b1;
//        end
//        else begin  
//            if (write_enable && !full) begin
//                fifo_mem[w_fifo_count] <= write_data;
//                w_fifo_count <= w_fifo_count + 1;
                
//                if(~start) begin
//                    start <= 1'b0;
//                    for (i = 0; i < w_fifo_count - 1; i = i + 1) begin
//                        fifo_mem[i] <= fifo_mem[i + 1];
//                    end
//                end
//            end
//            // Pop the topmost element and shift remaining elements up
//            else begin
//                for (i = 0; i < w_fifo_count; i = i + 1) begin
//                    fifo_mem[i] <= fifo_mem[i + 1];
//                end
//            end
//        end
//    end
    
    //---------------------------WRITE LOGIC FOR MEMORY------------------------------------//
    always@(posedge clk) begin
        if(rst) begin
//            mem_valid <= 0;
            w_mem_count <= 0;
        end
        else begin
            if (write_enable) begin
                memory[w_mem_count] <= write_data;
                if (w_mem_count < MEM_DEPTH - 1)w_mem_count <= w_mem_count + 1;
                else w_mem_count <= 0;
            end
        end
    end
    
    //-------------------------------READ LOGIC FOR MEMORY--------------------------------//
    always@(posedge clk) begin
        if(rst) begin
            r_mem_count <= 0;
            module_sel <= 0;
            Permit <= 0;
            validated <= 0;
        end
        else begin
            if( (r_mem_count <= w_mem_count) && (w_mem_count >= NUM_MODULES)) begin
                
                InValid[module_sel] <= 1'b1;
                InData[module_sel] <= memory[r_mem_count];
                validated <= validated + 1;
                
                if(r_mem_count < w_mem_count) r_mem_count <= r_mem_count + 1;
                else r_mem_count <= r_mem_count;
                
                // Increment round-robin module selector
                if(module_sel < NUM_MODULES) module_sel <= (module_sel + 1);
                else module_sel <= 0;
            
                // Make permission to make the outputs valid 
                if(validated >= NUM_MODULES) Permit <= {NUM_MODULES{1'b1}};
                else Permit <= {NUM_MODULES{1'b0}};
            end
        end
    end
    
    
    //----------------------INTRODUCING SHIFT REGISTERS FOR INPUT--------------------------//
    genvar j;
    for(j = 0; j < NUM_MODULES; j = j + 1) begin
        shiftReg_Input #(.inputSize(inputSize), .resolution(resolution), .kernelSize(kernelSize))
            shftInp (.clk(clk), .rst(rst), .in_valid(InValid[j]), .in_data(InData[j]), .word_out(WordOut[j]),
                     .out_valid(OutValid[j]), .reg_loaded(RegValid[j]), .permit(Permit[j]));
    end
    
    //--------------------------Module out value allocation--------------------------------//
    always@(posedge clk) begin
        if(rst) begin
            module_out <= 0;
            valid <= 0;
        end
        else begin   
            for(i = 0; i < NUM_MODULES; i = i + 1) begin
                module_out = (module_out << resolution) | WordOut[i];
            end
            valid <= OutValid;
        end
    end
    
endmodule


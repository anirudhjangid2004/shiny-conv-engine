`timescale 1ns / 1ps

module macSyncReg #(
   parameter N = 3,                  // Number of stages
   parameter resolution = 4          // Width of input data
) (
   input wire clk,
   input wire rst,
   input wire [resolution - 1:0] din,
   input wire valid,  
   output wire [resolution - 1:0] dout,
   output wire vout
);

    reg [resolution - 1:0] shift_reg [0:N-1]; // N-stage shift register
    reg [N - 1 : 0] shift_reg_valid;
    integer i = 0;

    // Shift logic
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < N; i = i + 1) begin
                shift_reg[i] <= 0;
            end
        end 
        else begin
            for (i = N-1; i > 0; i = i - 1) begin
                shift_reg[i] <= shift_reg[i-1];
            end
            shift_reg[0] <= din;
        end
    end

    assign dout = shift_reg[N-1];
    
    
    always @(posedge clk) begin
        if (rst) begin
            shift_reg_valid <= 0;
        end else begin
            shift_reg_valid <= {shift_reg_valid[N-2:0], valid};
        end
    end

    assign vout = shift_reg_valid[N-1];

endmodule

//`timescale 1ns / 1ps

//module macSyncReg #(
//   parameter N = 4,                  // Number of stages
//   parameter resolution = 4          // Width of input data
//) (
//   input wire clk,
//   input wire rst,
//   input wire [resolution - 1:0] din,
//   input wire valid,  
//   output wire [resolution - 1:0] dout,
//   output wire vout
//);

//    // Individual registers instead of arrays
//    wire [resolution - 1:0] stage_data [0:N];
//    wire stage_valid [0:N];

//    assign stage_data[0] = din;
//    assign stage_valid[0] = valid;

//    // Generate shift register stages
//    genvar i;
//    generate
//        for (i = 0; i < N; i = i + 1) begin : shift_stages
//            reg [resolution - 1:0] data_reg;
//            reg valid_reg;

//            always @(posedge clk) begin
//                if (rst) begin
//                    data_reg <= 0;
//                    valid_reg <= 0;
//                end else begin
//                    data_reg <= stage_data[i];
//                    valid_reg <= stage_valid[i];
//                end
//            end

//            assign stage_data[i+1] = data_reg;
//            assign stage_valid[i+1] = valid_reg;
//        end
//    endgenerate

//    assign dout = stage_data[N];
//    assign vout = stage_valid[N];

//endmodule


//`timescale 1ns / 1ps

//module macSyncReg #(
//   parameter N = 4,
//   parameter resolution = 4
//) (
//   input wire clk,
//   input wire rst,
//   input wire [resolution - 1:0] din,
//   input wire valid,
//   output wire [resolution - 1:0] dout,
//   output wire vout
//);

//    // Stage registers
//    reg [resolution-1:0] stage_d [0:N-1];
//    reg stage_v [0:N-1];

//    integer i;

//    always @(posedge clk) begin
//        if (rst) begin
//            for (i = 0; i < N; i = i + 1) begin
//                stage_d[i] <= 0;
//                stage_v[i] <= 0;
//            end
//        end else begin
//            stage_d[0] <= din;
//            stage_v[0] <= valid;

//            for (i = 1; i < N; i = i + 1) begin
//                stage_d[i] <= stage_d[i-1];
//                stage_v[i] <= stage_v[i-1];
//            end
//        end
//    end

//    assign dout = stage_d[N-1];
//    assign vout = stage_v[N-1];

//endmodule

//=============================================================
// alu.v
// 8-bit ALU supporting 8 operations (minimum requirement met)
//
// ALUOP encoding:
//  000 = ADD   result = a + b
//  001 = SUB   result = a - b
//  010 = AND   result = a & b
//  011 = OR    result = a | b
//  100 = XOR   result = a ^ b
//  101 = NOT   result = ~a          (b ignored)
//  110 = SHL   result = a << 1      (logical shift left)
//  111 = SHR   result = a >> 1      (logical shift right)
//=============================================================
`timescale 1ns/1ps

module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] op,
    output reg  [7:0] result,
    output wire        zero
);

    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR  = 3'b011;
    localparam ALU_XOR = 3'b100;
    localparam ALU_NOT = 3'b101;
    localparam ALU_SHL = 3'b110;
    localparam ALU_SHR = 3'b111;

    always @(*) begin
        case (op)
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_XOR: result = a ^ b;
            ALU_NOT: result = ~a;
            ALU_SHL: result = a << 1;
            ALU_SHR: result = a >> 1;
            default: result = 8'd0;
        endcase
    end

    assign zero = (result == 8'd0);

endmodule

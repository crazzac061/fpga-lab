//=============================================================
// control_unit.v
// Contains: Decode logic + Program Counter (PC)
//
// Instruction format (24 bits, one word per instruction):
//
//  [23:16] IMMEDIATE   [7:0]
//  [15:13] ALUOP       [2:0]   (8 ALU operations, see alu.v)
//  [12]    IMM_SEL             1 = OPERAND1 = IMMEDIATE
//                               0 = OPERAND1 = register path
//  [11]    NEG_SEL             1 = register path uses 2's complement(REGOUT2)
//                               0 = register path uses REGOUT2 directly
//  [10]    WRITEENABLE
//  [9:7]   WRITEREG    [2:0]
//  [6:4]   READREG1    [2:0]
//  [3:1]   READREG2    [2:0]
//  [0]     unused (reserved)
//
// PC increments every clock cycle (simple sequential fetch).
// Extend the "always" block below to support branching if needed.
//=============================================================
`timescale 1ns/1ps

module control_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire [23:0] instr,

    output reg  [7:0]  pc,

    output wire [2:0]  readreg1,
    output wire [2:0]  readreg2,
    output wire [2:0]  writereg,
    output wire        writeenable,
    output wire [2:0]  aluop,
    output wire        imm_sel,
    output wire        neg_sel,
    output wire [7:0]  immediate
);

    // ---------------- Decode (combinational) ----------------
    assign immediate   = instr[23:16];
    assign aluop       = instr[15:13];
    assign imm_sel     = instr[12];
    assign neg_sel     = instr[11];
    assign writeenable = instr[10];
    assign writereg    = instr[9:7];
    assign readreg1    = instr[6:4];
    assign readreg2    = instr[3:1];

    // ---------------- Program Counter ----------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 8'd0;
        else
            pc <= pc + 8'd1;   // simple sequential fetch; add branch logic here if needed
    end

endmodule

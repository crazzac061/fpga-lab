//=============================================================
// instr_mem.v
// Simple instruction ROM, addressed by PC.
// Preloaded here with a small demo program exercising several
// ALU operations. Replace the "initial" block contents (or use
// $readmemh with an external .hex file) for your own programs.
//
// Instruction format reminder (24 bits):
//  [23:16] IMMEDIATE
//  [15:13] ALUOP
//  [12]    IMM_SEL   (1 = OPERAND1 = IMMEDIATE)
//  [11]    NEG_SEL   (1 = OPERAND1 = -REGOUT2 when IMM_SEL=0)
//  [10]    WRITEENABLE
//  [9:7]   WRITEREG
//  [6:4]   READREG1
//  [3:1]   READREG2
//  [0]     unused
//=============================================================
`timescale 1ns/1ps

module instr_mem (
    input  wire [7:0]  pc,
    output wire [23:0] instr
);

    // 256-entry instruction ROM
    reg [23:0] rom [0:255];

    assign instr = rom[pc];

    initial begin
        // ---- Demo program ----
        // R0 = 5            : ADD, IMM_SEL=1, imm=5,  WE=1, WRITEREG=0
        rom[0] = { 8'd5, 3'b000, 1'b1, 1'b0, 1'b1, 3'd0, 3'd0, 3'd0, 1'b0 };

        // R1 = 10           : ADD, IMM_SEL=1, imm=10, WE=1, WRITEREG=1
        // READREG1=7 (R7=0 at this point) so OPERAND2 contributes 0, giving a clean immediate load
        rom[1] = { 8'd10, 3'b000, 1'b1, 1'b0, 1'b1, 3'd1, 3'd7, 3'd0, 1'b0 };

        // R2 = R0 + R1      : ADD, IMM_SEL=0, NEG_SEL=0, READREG1=0(OPERAND2), READREG2=1(OPERAND1 path)
        rom[2] = { 8'd0, 3'b000, 1'b0, 1'b0, 1'b1, 3'd2, 3'd0, 3'd1, 1'b0 };

        // R3 = R1 - R0
        // NOTE: by the fixed datapath, OPERAND1 = f(REGOUT2) [from READREG2],
        //       OPERAND2 = REGOUT1 [from READREG1], and SUB computes OPERAND1 - OPERAND2.
        // So for R1 - R0: READREG2=1 (-> OPERAND1 = R1), READREG1=0 (-> OPERAND2 = R0)
        rom[3] = { 8'd0, 3'b001, 1'b0, 1'b0, 1'b1, 3'd3, 3'd0, 3'd1, 1'b0 };

        // R4 = -R0 (2's complement path) : NEG_SEL=1, ALUOP=ADD, OPERAND2 tied to REGOUT1(R0) so add 0
        // READREG1=0 (OPERAND2=R0, but we want 0 added -> use READREG1 pointing to an empty reg, e.g. R7=0)
        rom[4] = { 8'd0, 3'b000, 1'b0, 1'b1, 1'b1, 3'd4, 3'd7, 3'd0, 1'b0 };

        // R5 = R0 AND R1
        rom[5] = { 8'd0, 3'b010, 1'b0, 1'b0, 1'b1, 3'd5, 3'd1, 3'd0, 1'b0 };

        // R6 = R0 OR R1
        rom[6] = { 8'd0, 3'b011, 1'b0, 1'b0, 1'b1, 3'd6, 3'd1, 3'd0, 1'b0 };

        // R7 = R0 SHL 1  (READREG2 selects R0 -> OPERAND1 path, ALUOP=SHL)
        rom[7] = { 8'd0, 3'b110, 1'b0, 1'b0, 1'b1, 3'd7, 3'd7, 3'd0, 1'b0 };

        // NOP / halt-like: fetch continues, remaining locations default to 0 (ADD 0+0 -> R0, WE=0)
    end

endmodule

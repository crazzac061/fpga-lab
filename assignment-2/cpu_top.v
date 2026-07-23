//=============================================================
// cpu_top.v
// Top level 8-bit CPU - wires together:
//   Instruction Memory -> Control Unit (Decode + PC)
//   Register File (8 x 8-bit)
//   2's Complement unit
//   2 x 2-to-1 Muxes (operand1 select chain)
//   ALU (8 operations)
// Matches the block diagram: IMMEDIATE, READREG1/2, WRITEREG,
// WRITEENABLE, REGOUT1/2, OPERAND1/2, ALUOP, ALURESULT
//=============================================================
`timescale 1ns/1ps

module cpu_top (
    input  wire        clk,
    input  wire        reset
);

    // ---------------- Wires ----------------
    wire [7:0]  pc;
    wire [23:0] instr;

    wire [2:0]  readreg1, readreg2, writereg;
    wire        writeenable;
    wire [2:0]  aluop;
    wire        imm_sel;   // selects IMMEDIATE vs register path -> OPERAND1
    wire        neg_sel;   // selects 2's complement of REGOUT2 vs REGOUT2 -> stage1
    wire [7:0]  immediate;

    wire [7:0]  regout1, regout2;
    wire [7:0]  twoscomp_out;
    wire [7:0]  mux1_out;     // REGOUT2 vs 2's complement(REGOUT2)
    wire [7:0]  operand1;     // mux1_out vs IMMEDIATE
    wire [7:0]  operand2;     // = REGOUT1 (direct wire, per diagram)
    wire [7:0]  aluresult;

    // ---------------- Instruction Memory ----------------
    instr_mem u_imem (
        .pc     (pc),
        .instr  (instr)
    );

    // ---------------- Control Unit (Decode + PC) ----------------
    control_unit u_ctrl (
        .clk          (clk),
        .reset        (reset),
        .instr        (instr),
        .pc           (pc),
        .readreg1     (readreg1),
        .readreg2     (readreg2),
        .writereg     (writereg),
        .writeenable  (writeenable),
        .aluop        (aluop),
        .imm_sel      (imm_sel),
        .neg_sel      (neg_sel),
        .immediate    (immediate)
    );

    // ---------------- Register File (8x8) ----------------
    reg_file u_regfile (
        .clk        (clk),
        .we         (writeenable & ~reset),   // block writes while reset is asserted
        .waddr      (writereg),
        .wdata      (aluresult),   // ALURESULT feeds back to write data
        .raddr1     (readreg1),
        .raddr2     (readreg2),
        .rdata1     (regout1),     // REGOUT1[7:0]
        .rdata2     (regout2)      // REGOUT2[7:0]
    );

    // OPERAND2 is wired directly from REGOUT1 (per diagram)
    assign operand2 = regout1;

    // ---------------- 2's Complement Unit ----------------
    twos_comp u_twoscomp (
        .in     (regout2),
        .out    (twoscomp_out)
    );

    // ---------------- Mux 1: REGOUT2 vs 2's complement(REGOUT2) ----------------
    mux2 #(.WIDTH(8)) u_mux1 (
        .a      (regout2),
        .b      (twoscomp_out),
        .sel    (neg_sel),
        .y      (mux1_out)
    );

    // ---------------- Mux 2: mux1_out vs IMMEDIATE -> OPERAND1 ----------------
    mux2 #(.WIDTH(8)) u_mux2 (
        .a      (mux1_out),
        .b      (immediate),
        .sel    (imm_sel),
        .y      (operand1)
    );

    // ---------------- ALU ----------------
    alu u_alu (
        .a          (operand1),
        .b          (operand2),
        .op         (aluop),
        .result     (aluresult),
        .zero       ()             // unused here, available if needed for branches
    );

endmodule

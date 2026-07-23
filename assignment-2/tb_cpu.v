//=============================================================
// tb_cpu.v
// Simple testbench: applies clock/reset and dumps register
// file contents each cycle so you can verify ALU results.
//=============================================================
`timescale 1ns/1ps

module tb_cpu;

    reg clk;
    reg reset;

    cpu_top dut (
        .clk   (clk),
        .reset (reset)
    );

    // 10ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        #20;              // hold reset across 2 full clock cycles
        reset = 0;

        // run long enough to execute the demo program
        #100;

        $display("---- Final Register File Contents ----");
        $display("R0 = %d", dut.u_regfile.regs[0]);
        $display("R1 = %d", dut.u_regfile.regs[1]);
        $display("R2 = %d", dut.u_regfile.regs[2]);
        $display("R3 = %d", dut.u_regfile.regs[3]);
        $display("R4 = %d", dut.u_regfile.regs[4]);
        $display("R5 = %d", dut.u_regfile.regs[5]);
        $display("R6 = %d", dut.u_regfile.regs[6]);
        $display("R7 = %d", dut.u_regfile.regs[7]);

        $finish;
    end

    // waveform dump (optional, for tools like gtkwave)
    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, tb_cpu);
    end

    // per-cycle trace
    always @(posedge clk) begin
        if (!reset)
            $display("t=%0t  PC=%0d  Instr=%h  ALUOP=%b  WE=%b  WRITEREG=%0d  R1raddr=%0d R2raddr=%0d  regout1=%0d regout2=%0d  op1=%0d op2=%0d  ALURESULT=%0d",
                $time, dut.pc, dut.instr, dut.aluop, dut.writeenable,
                dut.writereg, dut.readreg1, dut.readreg2, dut.regout1, dut.regout2,
                dut.operand1, dut.operand2, dut.aluresult);
    end

endmodule

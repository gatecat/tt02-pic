`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb;

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    reg clk = 0, reset = 0, prog_strobe = 0, prog_data = 0;
    reg [3:0] gpi = 0;

    reg [11:0] program[0:10];

    task cycle;
    begin
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;
    end
    endtask

    integer i, j;
    initial begin
        program[0] = 12'b00_00010_00000; // CLRW
        program[1] = 12'b00_00000_10000; // GPO <= W
        program[2] = 12'b00_10100_00000; // W <= W + 1
        program[3] = 12'b10_10000_00001; // GOTO 1
        program[4] = 12'b00_00000_00000;
        program[5] = 12'b00_00000_00000;
        program[6] = 12'b00_00000_00000;
        program[7] = 12'b00_00000_00000;
        program[8] = 12'b00_00000_00000;
        program[9] = 12'b00_00000_00000;
        program[10] = 12'b00_00000_00000;

        for (i = 0; i < 11; i = i + 1'b1) begin
            for (j = 0; j < 24; j = j + 1'b1) begin
                prog_data = (j < 12) ? program[i][j] : (j == (i + 12));
                cycle;
            end
            prog_strobe = 1'b1;
            #10;
            prog_strobe = 1'b0;
            #10;
        end
        reset = 1'b1;
        repeat (1000) cycle;
    end

    // wire up the inputs and outputs
    wire [7:0] inputs = {gpi, prog_data, prog_strobe, reset, clk};
    wire [7:0] outputs;
    wire [7:0] gpo = outputs[7:0];

    always @(gpo) begin
        #1
        $display("gpo=%b", gpo);
    end

    // instantiate the DUT
    tiny_kinda_pic pic_i (
        .io_in  (inputs),
        .io_out (outputs)
        );

endmodule

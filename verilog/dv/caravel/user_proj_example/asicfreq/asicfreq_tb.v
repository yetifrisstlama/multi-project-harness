`default_nettype none

`timescale 1 ns / 1 ps

`include "caravel.v"
`include "spiflash.v"

module asicfreq_tb;
    reg clock;
    reg RSTB;
    reg power1, power2;
    reg power3, power4;

    wire gpio;
    wire [37:0] mprj_io;

    // External clock is used by default.  Make this artificially fast for the
    // simulation.  Normally this would be a slow clock and the digital PLL
    // would be the fast clock.

    always #12.5 clock <= (clock === 1'b0);

    initial begin
        clock = 0;
    end

    initial begin
        $dumpfile("asicfreq.vcd");
        $dumpvars(0, asicfreq_tb);

        // Repeat cycles of 1000 clock edges as needed to complete testbench
        repeat (44) begin
            repeat (1000) @(posedge clock);
            // $display("+1000 cycles");
        end
        $display("%c[1;31m",27);
        $display ("Monitor: Timeout, Test Mega-Project IO Ports (RTL) Failed");
        $display("%c[0m",27);
        $display("FAIL");
        $stop;
    end

    // apply a clock to the signal under test (SUT) pad
    // ... that's as deep as I could dig in the hierarchy
    //
    // mprj_io[17: 0] --> area1_io_pad[17:0]
    // mprj_io[37:18] --> area2_io_pad[19:0]
    //
    // also interesting:
    // uut.padframe.mprj_pads.area2_io_pad[7].gpiov2_base.x_on_pad
    // uut.padframe.mprj_pads.area2_io_pad[7].gpiov2_base.pad_tristate
    assign uut.padframe.mprj_pads.area2_io_pad[7].gpiov2_base.PAD = clock;

    // assign mprj_io[25] = clock;

    // Check the last statement in the C program
    always @(posedge clock) begin
        if (
            uut.mprj.mprj.proj_4.strobe &&
            uut.mprj.mprj.proj_4.addr == 32'h1 &&
            uut.mprj.mprj.proj_4.value >= 32'h300
            // uut.mprj.mprj.proj_4.value == (uut.mprj.mprj.proj_4.oc - 32'h8)
        ) begin
            if (
                // area1_io_pad[6] = ser_tx output
                !uut.padframe.mprj_pads.area1_io_pad[6].gpiov2_base.x_on_pad &&
                !uut.padframe.mprj_pads.area1_io_pad[6].gpiov2_base.pad_tristate &&

                // area2_io_pad[7] = mprj_io[25] = SUT input
                uut.padframe.mprj_pads.area2_io_pad[7].gpiov2_base.pad_tristate &&
                !uut.padframe.mprj_pads.area2_io_pad[7].gpiov2_base.x_on_pad
            ) begin
                $display("PASS");
                $finish;
            end else begin
                $display("GPIO error");
                $display("FAIL");
                $stop;
            end
        end
    end

    initial begin
        RSTB <= 1'b0;
        #2000;
        RSTB <= 1'b1;       // Release reset
    end

    initial begin       // Power-up sequence
        power1 <= 1'b0;
        power2 <= 1'b0;
        power3 <= 1'b0;
        power4 <= 1'b0;
        #200;
        power1 <= 1'b1;
        #200;
        power2 <= 1'b1;
        #200;
        power3 <= 1'b1;
        #200;
        power4 <= 1'b1;
    end

    wire flash_csb;
    wire flash_clk;
    wire flash_io0;
    wire flash_io1;

    wire VDD1V8;
    wire VDD3V3;
    wire VSS;

    assign VDD3V3 = power1;
    assign VDD1V8 = power2;
    wire USER_VDD3V3 = power3;
    wire USER_VDD1V8 = power4;
    assign VSS = 1'b0;

    caravel uut (
        .vddio    (VDD3V3),
        .vssio    (VSS),
        .vdda     (VDD3V3),
        .vssa     (VSS),
        .vccd     (VDD1V8),
        .vssd     (VSS),
        .vdda1    (USER_VDD3V3),
        .vdda2    (USER_VDD3V3),
        .vssa1    (VSS),
        .vssa2    (VSS),
        .vccd1    (USER_VDD1V8),
        .vccd2    (USER_VDD1V8),
        .vssd1    (VSS),
        .vssd2    (VSS),
        .clock    (clock),
        .gpio     (gpio),
            .mprj_io  (mprj_io),
        .flash_csb(flash_csb),
        .flash_clk(flash_clk),
        .flash_io0(flash_io0),
        .flash_io1(flash_io1),
        .resetb   (RSTB)
    );

    spiflash #(
        .FILENAME("asicfreq.hex")
    ) spiflash (
        .csb(flash_csb),
        .clk(flash_clk),
        .io0(flash_io0),
        .io1(flash_io1),
        .io2(),         // not used
        .io3()          // not used
    );

endmodule

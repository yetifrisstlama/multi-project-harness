
`timescale 1 ns / 1 ps

`include "caravel.v"
`include "spiflash.v"

module la_test2_tb;
	reg clock;
    	reg RSTB;
	wire SDO;

    	wire gpio;
    	wire [31:0] mprj_io;
	wire [15:0] checkbits;

	assign checkbits = mprj_io[15:8];

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin
		$dumpfile("la_test2.vcd");
		$dumpvars(0, la_test2_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (30) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		$display ("Monitor: Timeout, Test Mega-Project IO (RTL) Failed");
		$display("%c[0m",27);
		$finish;
	end

	initial begin
		wait(checkbits == 16'h AB60);
		$display("Monitor: Test 2 MPRJ-Logic Analyzer Started");
		wait(checkbits == 16'h AB61);
		$display("Monitor: Test 2 MPRJ-Logic Analyzer Passed");
		$finish;
	end

	initial begin
		RSTB <= 1'b0;
		#1000;
		RSTB <= 1'b1;	    // Release reset
		#2000;
	end

	wire VDD1V8;
    	wire VDD3V3;
	wire VSS;
    
    	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	assign VSS = 1'b0;
	assign VDD1V8 = 1'b1;
	assign VDD3V3 = 1'b1;

	caravel uut (
		.vdd3v3	  (VDD3V3),
		.vdd1v8	  (VDD1V8),
		.vss	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        	.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("la_test2.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),
		.io3()
	);

endmodule
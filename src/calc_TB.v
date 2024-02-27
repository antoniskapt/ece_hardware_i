/*	src/calc_TB.v
 *
 *	Kapetanios Antonios [10419]
 *	kapetaat@ece.auth.gr
 *
 *	(54) Hardware I
 *	Dep. of ECE, AUTh
 *
 *	January 2024
 *
 *	The Verilog-2001 standard is followed.
 */
`include "calc.v"
`timescale 1ns/1ps

/*	Calculator testbench. */
module calc_TB();

	// DUT inputs
	reg clk_TB;
	reg btnc_TB;
	reg btnl_TB;
	reg btnu_TB;
	reg btnr_TB;
	reg btnd_TB;
	reg [15:0] sw_TB;
	reg [15:0] expected;

	// DUT outputs
	wire [15:0] led_TB;

	// instantiate the calc module
	calc DUT(.clk(clk_TB), .btnc(btnc_TB),
	.btnl(btnl_TB), .btnu(btnu_TB),
	.btnr(btnr_TB), .btnd(btnd_TB),
	.sw(sw_TB), .led(led_TB));

	// initialize the CLOCK and drive
	// the reset signal (btnu resets
	// the accumulator).
	initial begin
		$dumpfile("calc_tb.vcd");
		$dumpvars(0, calc_TB);
		btnd_TB=1'b1;
		clk_TB=1'b0;
		btnu_TB=1'b1;
		sw_TB=16'h1234;
		#20	btnu_TB=1'b0;
	end

	// set the clock halftime
	always begin
		#10	clk_TB=~clk_TB;
	end

	always begin
		btnd_TB = 1'b0; // Set btnd_TB low
		#9; // Wait for 6 time units
		btnd_TB = 1'b1; // Set btnd_TB high
		#2; // Wait for 4 time units
		btnd_TB = 1'b0; // Set btnd_TB low again
		#9; // Wait for 10 time units
	end

	// stimulus & check block
	initial begin

		#29	btnd_TB=1'b1;
			btnl_TB=1'b0; btnc_TB=1'b1; btnr_TB=1'b1; // OR

		#20	btnl_TB=1'b0; btnc_TB=1'b1; btnr_TB=1'b0; // AND
			sw_TB=16'h0ff0;

		#20	btnl_TB=1'b0; btnc_TB=1'b0; btnr_TB=1'b0; // ADD
			sw_TB=16'h324f;

		#20	btnl_TB=1'b0; btnc_TB=1'b0; btnr_TB=1'b0; // ADD
			sw_TB=16'h324f;

		#20	btnl_TB=1'b0; btnc_TB=1'b0; btnr_TB=1'b1; // SUB
			sw_TB=16'h2d31;

		#20	btnl_TB=1'b1; btnc_TB=1'b0; btnr_TB=1'b0; // XOR
			sw_TB=16'hffff;

		#20	btnl_TB=1'b1; btnc_TB=1'b0; btnr_TB=1'b1; // LT
			sw_TB=16'h7346;

		#20	btnl_TB=1'b1; btnc_TB=1'b1; btnr_TB=1'b0; // SLL
			sw_TB=16'h0004;

		#20	btnl_TB=1'b1; btnc_TB=1'b1; btnr_TB=1'b1; // SRA
			sw_TB=16'h0004;

		#20	btnl_TB=1'b1; btnc_TB=1'b0; btnr_TB=1'b1; // LT
			sw_TB=16'hffff;

		#20	$finish;
	end

endmodule

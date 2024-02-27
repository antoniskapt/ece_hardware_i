/*	src/calc.v
 *
 *	Kapetanios Antonios [10417]
 *	kapetaat@ece.auth.gr
 *
 *	(54) Hardware I
 *	Dep. of ECE, AUTh
 *
 *	January 2024
 *
 *	The Verilog-2001 standard is followed.
 */

`include "alu.v"
`include "accum.v"
`include "decoder.v"

/*	Calculator using the ALU of excerise 1.
 *
 *	INPUTS:
 *		clk: clock
 *		btnc: Central button
 *		btnl: Left button
 *		btnu: Up button
 *		btnr: Right button
 *		btnd: Down button
 *		sw: switches for data input
 *	OUTPUTS:
 *		led: LED for the accumulator's output
 */
module calc(	input clk,
 				input btnc,
				input btnl,
				input btnu,
				input btnr,
				input btnd,
				input [15:0] sw,
				output reg [15:0] led);

	wire [3:0] alu_op;
	wire [31:0] alu_result;
	wire alu_zero;
	reg [31:0] sw_ext;
	wire [15:0] acc_out;
	reg [31:0] acc_out_ext;

	// instantiate the accumulator
	accumulator ACC(.clk(clk), .reset(btnu), .update(btnd), .r_in(alu_result[15:0]), .r_out(acc_out));

	// right after a positive edge of the clock the `acc_out` has been updated and the sign extension can be performed
	always @(*) begin

		// the output of the accumulator is assigned to `led`
		led=acc_out;

		// sign extend the output of the accumulator.
		// This will be used as op1 for the ALU.
		acc_out_ext={{16{led[15]}},led};

		// sign extension of sw.
		// This will be used as op2 for the ALU
		sw_ext={{16{sw[15]}},sw};
	end

	// instantiate the accumulator
	decoder D(btnc,btnl,btnr,alu_op);

	// instantiate the ALU
	alu U(.op1(acc_out_ext), .op2(sw_ext), .alu_op(alu_op), .zero(zero), .result(alu_result));

endmodule
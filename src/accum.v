/*	src/accum.v
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

/*	A 16 bit register triggered by the positive clock edge with synchronous reset. */
module accumulator(	input wire clk,
					input wire reset,
					input wire update,
					input wire [15:0] r_in,
					output reg [15:0] r_out);

	always @(posedge clk)
		begin
			if(reset)
				r_out=16'b0;
			else if(update) // update when btnd is pressed
				r_out=r_in;
			else
				r_out<=r_out; // keep the previous value
		end
endmodule
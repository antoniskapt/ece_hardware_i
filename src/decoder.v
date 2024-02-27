/*	src/decoder.v
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

/*	Determines the ALU operation code based
 *	on the state of the buttons.
 */
module decoder(	input wire btnc,
				input wire btnl,
				input wire btnr,
				output reg[3:0] alu_op);

	always @*
	begin
		alu_op[0]=((btnl)&&(!btnr))||((btnr)&&((btnl)^(btnc)));
		alu_op[1]=((btnr)&&(btnl))||((!btnl)&&(!btnc));
		alu_op[2]=(((btnr)&&(btnl))||((btnr)^(btnl)))&&(!btnc);
		alu_op[3]=(((!btnr)&&(btnc))||(!((btnr)^(btnc))))&&(btnl);
	end
endmodule
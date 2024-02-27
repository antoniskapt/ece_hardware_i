/*	src/alu.v
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
 *
 *	References:
 *	https://inst.eecs.berkeley.edu/~cs150/fa06/Labs/verilog-ieee.pdf
 *	- Section "4.5 Signed expressions"
 */

/*	32bit ALU implementing
 *	1) logical conjuction		op1∧op2
 *	2) logical disjunction		op1∨op2
 *	3) signed addition			op1+op2
 *	4) signed substraction		op1-op2
 *	5) less than				op1<op2
 *	6) shift logical left		op1>>op2[4:0]
 *	7) shift logical right		op1<<op2[4:0]
 *	8) arithmetic shift right	op1>>>op2[4:0]
 *	9) exclusive disjunction	op1⊕op2 (logical non-equivalence)
 */
module alu( input [31:0] op1,	// 2's complement
			input [31:0] op2,	// 2's complement
			input [3:0] alu_op,
			output reg zero,
			output reg [31:0] result);

	parameter [3:0] ALUOP_AND=4'b0000;
	parameter [3:0] ALUOP_OR=4'b0001;
	parameter [3:0] ALUOP_ADD=4'b0010;
	parameter [3:0] ALUOP_SUB=4'b0110;
	parameter [3:0] ALUOP_LESS=4'b0111;
	parameter [3:0] ALUOP_LSR=4'b1000;
	parameter [3:0] ALUOP_LSL=4'b1001;
	parameter [3:0] ALUOP_ASR=4'b1010;
	parameter [3:0] ALUOP_XOR=4'b1101;

	// for ALUOP_LESS both operands must be converted to signed format.
	// for ALUOP_ASR op1 must be converted to signed form and the result must be converted to unsigned format.

	// ALU multiplexor.
	always @*
	begin: alu_mux
		case (alu_op)
			ALUOP_AND:	result=op1&op2;
			ALUOP_OR:	result=op1|op2;
			ALUOP_ADD:	result=op1+op2;
			ALUOP_SUB:	result=op1-op2;
			ALUOP_LESS:	result= $signed(op1)<$signed(op2)? 32'b1:32'b0;
			ALUOP_LSR:	result=op1>>op2[4:0];
			ALUOP_LSL:	result=op1<<op2[4:0];
			ALUOP_ASR:	result=$unsigned($signed(op1)>>>op2[4:0]);
			ALUOP_XOR:	result=op1^op2;
			default:	result=32'bX;
		endcase

		if(result == 32'b0)
			zero=1'b1;
		else zero=1'b0;
	end
endmodule
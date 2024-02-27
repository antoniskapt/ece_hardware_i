/*	src/regfile.v
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

/*	32x32bit register file
 *	INPUTS:
 *		clk: clock
 *		readReg1: address for reading port 1
 *		readReg2: address for reading port 2
 *		writeReg: address for writing port
 *		writeData: data to be written
 *		write: write enable signal
 *	OUTPUTS:
 *		readData1: data from reading port 1
 *		readData2: data from reading port 2
 *
 *	The current implementation does not ensure
 *	that x0 will be hardwired to 0 as is the case
 *	in RISC-V architecture. [The RISC-V Instruction
 *	Set Manual Volume I: Unprivileged ISA -
 *	Document Version 20191213].
 *
 *	This register file does not implement the
 *	program counter (pc) register.
 */
module regfile(	input clk,
				input [4:0] readReg1,
				input [4:0] readReg2,
				input [4:0] writeReg,
				input [31:0] writeData,
				input write,
				output reg [31:0] readData1,
				output reg [31:0] readData2);

	// array of 32 32bit registers
	reg [31:0] x_reg [31:0];

	// initialize all registers to 0
	integer i;
	initial begin
		for(i=0; i<32; i=i+1)
			x_reg[i]<=32'b0;
	end

	// update the outputs once the the
	// value of the registers has been
	// changed.
	always @* begin
		readData1=x_reg[readReg1];
		readData2=x_reg[readReg2];
	end

	// register implementation with
	// no reset signal. Instead all
	// of the registers have been
	// initialized to 0.
	always @(posedge clk)
	begin
		if(write)
			x_reg[writeReg]<=writeData;
	end
endmodule
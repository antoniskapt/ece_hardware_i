/*	src/top_proc_TB.v
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
`include "multicycle.v"
`include "ram.v"
`include "rom.v"
`timescale 1ns/1ps

module top_proc_TB();

	// DUT inputs
	parameter INITIAL_PC=32'h00400000;
	reg clk_TB; // clock
	reg reset; // synchronous reset
	wire [31:0] instruction; // instruction to be executed
	wire [31:0] dReadData; // data read from memory

	//DUT outputs
	wire [31:0] dWriteData; // data to be written to memory
	wire [31:0] PC; // program counter
	wire [31:0] dAddress; // address to be written to memory
	wire MemRead; // memory read signal
	wire MemWrite; // memory write signal
	wire [31:0] WriteBackData; // data to be written to register file

	INSTRUCTION_MEMORY ROM(	.clk(clk_TB),
							.addr(PC[8:0]),
							.dout(instruction));

	DATA_MEMORY RAM (	.clk(clk_TB),
						.we(MemWrite),
						.addr(dAddress[8:0]),
						.din(dWriteData),
						.dout(dReadData));

	multicycle #(.INITIAL_PC(INITIAL_PC)) DUT(
					.clk(clk_TB),
					.rst(reset),
					.instr(instruction),
					.dReadData(dReadData),
					.PC(PC),
					.dAddress(dAddress),
					.dWriteData(dWriteData),
					.MemRead(MemRead),
					.MemWrite(MemWrite),
					.WriteBackData(WriteBackData));

	// initialize the clock
	// and drive the reset signal
	initial begin
		// Dumpfiles for generating the waveforms
		$dumpfile("top_proc_tb.vcd");
		$dumpvars(0, top_proc_TB);
		clk_TB=1'b1;
		reset=1'b1;
		#30 reset=1'b0;
	end

	// clock halftime
	always begin
		#10 clk_TB=~clk_TB;
	end

	initial begin
		#100000 $finish;
	end
endmodule
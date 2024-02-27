/*	src/datapath.v
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
`include "regfile.v"
`include "alu.v"

/*	DATAPATH
 *
 *	INPUT:
 *		clk: clock
 *		rst: synchronous reset
 *		instr: instruction
 *		PCSrc: PC source
 *		ALUSrc: source of the 2nd operand of ALU
 *		RegWrite: write to register file
 *		MemToReg: input multiplexer of register file
 *		ALUCtrl: ALU control
 *		loadPC: load PC
 *	OUTPUT:
 *		PC: program counter
 *		Zero: ALU zero flag
 *		dAddress: data memory address
 *		dWriteData: data memory write data
 *		dReadData: data memory read data
 *		WriteBackData: write back data
 */
module datapath #(parameter INITIAL_PC=32'h00400000)
				(	input clk,
					input rst,
					input [31:0] instr,
					input PCSrc,
					input ALUSrc,
					input RegWrite,
					input MemToReg,
					input [3:0] ALUCtrl,
					input loadPC,
					input [31:0] dReadData,
					output reg [31:0] PC,
					output reg Zero,
					output reg [31:0] dAddress,
					output reg [31:0] dWriteData,
					output reg [31:0] WriteBackData);

	// OPCODES
	parameter BRANCH=7'b1100011; // beq
	parameter   LOAD=7'b0000011; // lw
	parameter  STORE=7'b0100011; // sw
	parameter OP_IMM=7'b0010011; // addi, slti, xori, ori, andi, slli, srli, srai
	parameter     OP=7'b0110011; // add, sub, sll, slt, xor, srl, sra, or, and

	// FUNCT3
	parameter BEQ=3'b000;
	parameter LW=3'b010;
	parameter SW=3'b010;
	parameter ADDI=3'b000;
	parameter SLTI=3'b010;
	parameter XORI=3'b100;
	parameter ORI=3'b110;
	parameter ANDI=3'b111;
	parameter SLLI=3'b001;
	parameter SRLI=3'b101;
	parameter SRAI=3'b101;
	parameter ADD=3'b000;
	parameter SUB=3'b000;
	parameter SLL=3'b001;
	parameter SLT=3'b010;
	parameter XOR=3'b100;
	parameter SRL=3'b101;
	parameter SRA=3'b101;
	parameter OR=3'b110;
	parameter AND=3'b111;

	// initialize the pc
	initial begin
		PC=INITIAL_PC;
	end

	always @(posedge clk) begin
		if(rst)	// synchronous reset
			PC<=INITIAL_PC;
		else if(loadPC) begin
			/* next PC MUX
			 * If PCSrc==1, meaning that
			 * the instruction is a branch and
			 * the branch is taken, the next PC
			 * is the current PC plus the branch
			 * offset. Otherwise, the next PC is
			 * the current PC plus 4.
			 */
			if(PCSrc)
				PC<=PC+branch_offset;
			else
				PC<=PC+4;
		end
	end

	reg [4:0] rd;
	reg [4:0] rs1;
	reg [4:0] rs2;
	wire [31:0] read_data_1;
	wire [31:0] read_data_2;
	reg [31:0] write_data_reg;

	reg [2:0] funct3;
	reg [6:0] opcode;
	reg [11:0] immediate_12;
	reg [31:0] immediate_32;
	reg [31:0] branch_offset;

	reg [31:0] operand_1;
	reg [31:0] operand_2;
	wire [31:0] alu_res;

	// instantiate register file
	regfile REGISTERS(	.clk(clk),
						.readReg1(rs1),
						.readReg2(rs2),
						.writeReg(rd),
						.writeData(write_data_reg),
						.write(RegWrite),
						.readData1(read_data_1),
						.readData2(read_data_2));

	/* ALU operand 2 MUX
	 * If ALUSrc==0, the 2nd operand of ALU is
	 * the value of register rs2. Otherwise,
	 * the 2nd operand of ALU is the immediate
	 * value.
	 */
	always @* begin
		operand_1=read_data_1;
		if(ALUSrc==0) operand_2=read_data_2;
		else operand_2=immediate_32;
	end

	wire Zero_ALU;
	// instantiate ALU
	alu ALU(	.op1(operand_1),
				.op2(operand_2),
				.alu_op(ALUCtrl),
				.zero(Zero_ALU),
				.result(alu_res));

	// Decode the instruction
	always @(instr) begin
		opcode=instr[6:0];
		funct3=instr[14:12];
		rd=instr[11:7];
		rs1=instr[19:15];
		rs2=instr[24:20];

		// Immediate generator
		case(opcode)
			OP_IMM: begin
						immediate_12=instr[31:20];
						if(funct3==SLLI || funct3==SRLI || funct3==SRAI)
							immediate_32=instr[24:20]; // shamt (zero extended)
						else immediate_32={{20{instr[31]}},immediate_12};
					end
			LOAD: begin
					immediate_12=instr[31:20]; // 12bit offset
					immediate_32={{20{immediate_12[11]}},immediate_12}; // sign extended offset
				end
			STORE: begin
					immediate_12={instr[31:25],instr[11:7]}; // 12bit offset
					immediate_32={{20{immediate_12[11]}},immediate_12}; // sign extended offset
				end
			BRANCH: begin
						immediate_12={instr[31],instr[7],instr[30:25],instr[11:8]};
						immediate_32={{19{immediate_12[11]}},immediate_12,1'b0}; // sign extended immediate
						branch_offset=immediate_32<<1;
					end
		endcase
	end

	always @* begin
		Zero=Zero_ALU;

		dAddress=alu_res; // memory address to write to (SW)
		// Writing back to register file MUX
		dWriteData=read_data_2; // data to be written to memory
		if(MemToReg) begin
				// the data to be written to register file
				// is fetched from memory (LW)
				WriteBackData=dReadData;
				write_data_reg=dReadData;
			end
		else begin
				// the data to be written to register file
				// is the result of the ALU
				WriteBackData=alu_res;
				write_data_reg=alu_res;
			end
	end
endmodule
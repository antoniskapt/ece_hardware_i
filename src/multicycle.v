/*	src/multicycle.v
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
`include "datapath.v"

/*	Control signal unit.
 *	INPUTS:
 *		clk: clock signal.
 *		rst: synchronous reset signal.
 *		instr: instruction to be executed.
 *		dReadData: data read from memory.
 *	OUTPUTS:
 *		PC: program counter.
 *		dAddress: address to be written to memory.
 *		dWriteData: data to be written to memory.
 *		MemRead: memory read signal.
 *		MemWrite: memory write signal.
 *		WriteBackData: data to be written to register file.
 */
module multicycle #(parameter INITIAL_PC=32'h00400000) (
					input clk,
					input rst,
					input [31:0] instr,
					input [31:0] dReadData,
					output wire [31:0] PC,
					output wire [31:0] dAddress,
					output wire [31:0] dWriteData,
					output reg MemRead,
					output reg MemWrite,
					output wire [31:0] WriteBackData);

	// OPCODES
	parameter BRANCH=7'b1100011; // beq
	parameter   LOAD=7'b0000011; // lw
	parameter  STORE=7'b0100011; // sw
	parameter OP_IMM=7'b0010011; // addi, slti, xori, ori, andi, slli, srli, srai
	parameter     OP=7'b0110011; // add, sub, sll, slt, xor, srl, sra, or, and

	// FUNCT3
	parameter BEQ =3'b000;
	parameter LW  =3'b010;
	parameter SW  =3'b010;
	parameter ADDI=3'b000;
	parameter SLTI=3'b010;
	parameter XORI=3'b100;
	parameter ORI =3'b110;
	parameter ANDI=3'b111;
	parameter SLLI=3'b001;
	parameter SRLI=3'b101;
	parameter SRAI=3'b101;
	parameter ADD =3'b000;
	parameter SUB =3'b000;
	parameter SLL =3'b001;
	parameter SLT =3'b010;
	parameter XOR =3'b100;
	parameter SRL =3'b101;
	parameter SRA =3'b101;
	parameter OR  =3'b110;
	parameter AND =3'b111;

	parameter [3:0] ALUOP_AND =4'b0000;
	parameter [3:0] ALUOP_OR  =4'b0001;
	parameter [3:0] ALUOP_ADD =4'b0010;
	parameter [3:0] ALUOP_SUB =4'b0110;
	parameter [3:0] ALUOP_LESS=4'b0111;
	parameter [3:0] ALUOP_LSR =4'b1000;
	parameter [3:0] ALUOP_LSL =4'b1001;
	parameter [3:0] ALUOP_ASR =4'b1010;
	parameter [3:0] ALUOP_XOR =4'b1101;

	reg PCSrc, ALUSrc, RegWrite, MemToReg;
	reg [3:0] ALUCtrl;
	reg loadPC;
	wire Zero;

	// instantiate the datapath
	datapath #(.INITIAL_PC(INITIAL_PC)) DP(
				.clk(clk),
				.rst(rst),
				.instr(instr),
				.dAddress(dAddress),
				.PCSrc(PCSrc),
				.ALUSrc(ALUSrc),
				.RegWrite(RegWrite),
				.MemToReg(MemToReg),
				.ALUCtrl(ALUCtrl),
				.loadPC(loadPC),
				.PC(PC),
				.Zero(Zero),
				.dWriteData(dWriteData),
				.dReadData(dReadData),
				.WriteBackData(WriteBackData));

	/*
	*	BEGIN FSM
	*/
	// States:
	parameter IF=5'b00001; // Instruction Fetch
	parameter ID=5'b00010; // Instruction Decode
	parameter EX=5'b00100; // Execute
	parameter MEM=5'b01000;// Memory Access
	parameter WB=5'b10000; // Write Back

	reg [4:0] current_state, next_state;

	always @(posedge clk) begin: STATE_MEMORY
		if (rst)
			current_state<=IF;
		else
			current_state<=next_state;
	end

	always @(current_state) begin: NEXT_STATE_LOGIC
		case (current_state)
			IF: next_state     =ID;
			ID: next_state     =EX;
			EX: next_state     =MEM;
			MEM: next_state    =WB;
			WB: next_state     =IF;
			default: next_state=IF;
		endcase
	end

	reg [6:0] opcode;
	reg [2:0] funct3;
	reg [6:0] funct7;

	always @(current_state) begin: OUTPUT_LOGIC
		opcode=instr[6:0];
		funct3=instr[14:12];
		funct7=instr[31:25];

		case(current_state)
			IF: begin
				RegWrite   =1'b0;
				MemToReg   =1'b0;
				loadPC     =1'b0;
				PCSrc      =1'b0;
			end
			ID: begin
				case(opcode)
					STORE:  ALUCtrl=ALUOP_ADD;
					LOAD:   ALUCtrl=ALUOP_ADD;
					BRANCH: ALUCtrl=ALUOP_SUB;
					OP_IMM:	begin
						case(funct3)
							ADDI: ALUCtrl=ALUOP_ADD;
							SLTI: ALUCtrl=ALUOP_LESS;
							XORI: ALUCtrl=ALUOP_XOR;
							ORI:  ALUCtrl=ALUOP_OR;
							ANDI: ALUCtrl=ALUOP_AND;
							SLLI: ALUCtrl=ALUOP_LSL;
							// SRLI is identical to SRAI
							// the right shift type is
							// encoded in bit 30.
							SRLI: begin
								case(instr[30])
									1'b0: ALUCtrl=ALUOP_LSR;
									1'b1: ALUCtrl=ALUOP_ASR;
								endcase
							end
						endcase
						end
					OP: case(funct7)
							7'b0000000: begin
								case(funct3)
									ADD: ALUCtrl=ALUOP_ADD;
									SLL: ALUCtrl=ALUOP_LSL;
									SLT: ALUCtrl=ALUOP_LESS; //SLT
									XOR: ALUCtrl=ALUOP_XOR; //XOR
									OR:  ALUCtrl=ALUOP_OR; //OR
									AND: ALUCtrl=ALUOP_AND; //AND
									SRL: ALUCtrl=ALUOP_LSR; //SRL
								endcase
								end
							7'b0100000 : begin
								case(funct3)
									SUB: ALUCtrl=ALUOP_SUB; //SUB
									SRA: ALUCtrl=ALUOP_ASR; //SRA
								endcase
								end
						endcase
					default: ALUCtrl=0;
				endcase

				// Determine ALUSrc
				case(opcode)
					LOAD:    ALUSrc=1'b1;
					STORE:   ALUSrc=1'b1;
					OP_IMM:  ALUSrc=1'b1;
					OP:      ALUSrc=1'b0;
					BRANCH:  ALUSrc=1'b0;
					default: ALUSrc=1'b0;
				endcase
			end
		EX: begin
			end
		MEM: begin
			// Memory and register-file
			// related control signals.
			case(instr[6:0])
				LOAD: begin
					MemRead =1'b1;
					MemWrite=1'b0;
					end
				STORE: begin
					MemRead =1'b0;
					MemWrite=1'b1;
					end
				BRANCH: begin // PC source control signal.
					MemRead        =1'b0;
					MemWrite       =1'b0;
					if (Zero) PCSrc=1'b1;
					else PCSrc     =1'b0;
					end
				default: begin
					MemRead =1'b0;
					MemWrite=1'b0;
					end
			endcase
			end
		WB: begin
			case(instr[6:0])
				LOAD: begin
					MemToReg=1'b1;
					RegWrite=1'b1;
				end
				STORE: begin
					MemToReg=1'b0;
					RegWrite=1'b0;
				end
				default: begin
					MemToReg=1'b0;
					RegWrite=1'b1;
				end
			endcase
			loadPC  =1'b1;
			MemRead =1'b0;
			MemWrite=1'b0;
			end
		endcase
	end
/*
 *	END FSM
 */
endmodule

# util/instructions.py
import ctypes

def sign_extend(value, bits):
	sign_bit = 1 << (bits - 1)
	return (value & (sign_bit - 1)) - (value & sign_bit)

# Decode RV32I binary instructions into assembly code
def decode_rv32i(instruction):
	opcode = instruction & 0b1111111  # Extract opcode
	rd = (instruction >> 7) & 0b11111  # Extract rd
	funct3 = (instruction >> 12) & 0b111  # Extract funct3
	rs1 = (instruction >> 15) & 0b11111  # Extract rs1
	rs2 = (instruction >> 20) & 0b11111  # Extract rs2
	funct7 = (instruction >> 25) & 0b1111111  # Extract funct7

	# Define opcode and funct3 mappings
	opcode_map = {
		0b0110011: {0b000: "add" if funct7 == 0b0000000 else "sub", 0b001: "sll", 0b010: "slt", 0b100: "xor", 0b101: "srl" if funct7 == 0b0000000 else "sra", 0b110: "or", 0b111: "and"},
		0b0010011: {0b000: "addi", 0b010: "slti", 0b100: "xori", 0b110: "ori", 0b111: "andi", 0b001: "slli", 0b101: "srli" if funct7 == 0b0000000 else "srai"},
		0b0000011: {0b010: "lw"},
		0b0100011: {0b010: "sw"},
		0b1100011: {0b000: "beq"},
	}

	# Decode instruction based on opcode and funct3
	if opcode in opcode_map and funct3 in opcode_map[opcode]:
		instr_name = opcode_map[opcode][funct3]
		if opcode == 0b0110011:  # R-type
			return f"{instr_name} x{rd}, x{rs1}, x{rs2}"
		elif opcode == 0b0010011:  # I-type
			imm = sign_extend(instruction >> 20, 12)
			return f"{instr_name} x{rd}, x{rs1}, {imm}"
	elif opcode == 0b0000011:  # I-type (load)
		imm = sign_extend(instruction >> 20, 12)
		return f"{instr_name} x{rd}, {imm}(x{rs1})"
	elif opcode == 0b0100011:  # S-type
		imm = sign_extend(((instruction >> 25) << 5) | ((instruction >> 7) & 0b11111), 12)
		return f"{instr_name} x{rs2}, {imm}(x{rs1})"
	elif opcode == 0b1100011:  # B-type
		imm = sign_extend(((instruction >> 31) << 12) | ((instruction >> 7) & 0b1) << 11 | ((instruction >> 25) << 5) | ((instruction >> 8) & 0b1111) << 1, 13)
		return f"{instr_name} x{rs1}, x{rs2}, {imm}"


instructions = [
	0b00000000010000000000000010010011,
	0b00000000000100000000000100010011,
	0b00000000001100000000000110010011,
	0b00000000011100000000001000010011,
	0b11111111111000000000001010010011,
	0b00000000001100011000001100110011,
	0b01000000010100110000001110110011,
	0b00000000001000011001010000110011,
	0b00000000010001000010010010110011,
	0b00000000011100001100010100110011,
	0b00000000100101010101010110110011,
	0b00000000011000011111011000110011,
	0b00000000110001010110011010110011,
	0b01000000001000101101011100110011,
	0b00000000101000010010000000100011,
	0b00000000000000010010011110000011,
	0b00000000011101101111100000010011,
	0b00000000010001101110100010010011,
	0b00000000001100100101100100010011,
	0b00000000100000110000001101100011,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000,
	0b00000000110001011100100110010011,
	0b00000000000110011001101000010011,
	0b01000000001000101101101010010011,
	0b00000001110010100010101100010011,
	0b00000000000000000000000000000000,
	0b00000000000000000000000000000000
]

for instruction in instructions:
	print(decode_rv32i(instruction))
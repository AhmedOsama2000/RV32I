module ALU_Control
#(
	parameter ALU_DECODER_IN = 3
)
(
	// Input
	input  wire [2:0] Funct3,
	input  wire       Funct7_5,
	input  wire       Funct7_0,
	input  wire       EN_PC,
	input  wire [6:0] opcode,
	input  wire       undef_instr,     
	// Output
	output reg  [ALU_DECODER_IN-1:0] ALU_Ctrl,
	output reg           			 Sub
);

// Supported ISA Based on the opcode
// Integer Instrustions
// R_TYPE Format
localparam R_TYPE  = 7'b0110011;

// I_Type Format
localparam IMM 	   = 7'b0010011;
localparam LOAD    = 7'b0000011;
localparam JALR    = 7'b1100111;

// S_Type
localparam STORE   = 7'b0100011;
// SB_Type
localparam BRANCH  = 7'b1100011; 

// UJ_Type
localparam JAL     = 7'b1101111;

// U_Type
localparam LUI 	   = 7'b0110111;
localparam AUIPC   = 7'b0010111;

always @(*) begin

	Sub       = 1'b0;
	ALU_Ctrl = 3'b111;
	if (undef_instr || !EN_PC) begin
		ALU_Ctrl = 3'b111;
	end
	else if (opcode == R_TYPE) begin
		Sub = Funct7_5;
		if (Funct3 == 3'b000) begin
			ALU_Ctrl = 3'b000;
		end
		else if (Funct3 == 3'b010 || Funct3 == 3'b011) begin
			ALU_Ctrl = 3'b001;
		end
		else if (Funct3 == 3'b111 || Funct3 == 3'b100 || Funct3 == 3'b110) begin
			ALU_Ctrl = 3'b010;
		end
		else if (Funct3 == 3'b001 || Funct3 == 3'b101) begin
			ALU_Ctrl = 3'b011;
		end
		else begin
			ALU_Ctrl = 3'b111;
		end
	end
	else if (opcode == IMM) begin
		if (Funct3 == 3'b000) begin
			ALU_Ctrl = 3'b000;
		end
		else if (Funct3 == 3'b111 || Funct3 == 3'b100 || Funct3 == 3'b110) begin
			ALU_Ctrl = 3'b010;
		end
		else if (Funct3 == 3'b001 || Funct3 == 3'b101) begin
			ALU_Ctrl = 3'b011;
		end
		else if (Funct3 == 3'b010 || Funct3 == 3'b011) begin
			ALU_Ctrl = 3'b001;
		end
		else begin
			ALU_Ctrl = 3'b111;
		end
	end
	else if (opcode == BRANCH) begin
		ALU_Ctrl = 3'b100;
	end
	else if (opcode == LOAD || opcode == STORE || opcode == JALR || opcode == JAL || opcode == LUI || opcode == AUIPC) begin
		ALU_Ctrl = 3'b000;
	end
	else begin
		ALU_Ctrl = 3'b111;
	end
end

endmodule
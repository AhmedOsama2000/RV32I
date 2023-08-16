module Main_Decoder
(
	// INPUT
	input wire [6:0] Opcode,
	input wire       EN_PC,
	input wire       NOP_Ins,
	input wire       if_id_flush,	
	input wire [4:0] Funct7_6_2, 
	// OUTPUT
	// Memory Control Signals
	output reg       MEM_Wr_En,
	// Register Write Source
	output reg [1:0] Src_to_Reg,
	// RegFile Control Signals
	output reg 	     Reg_Wr_En,
	// Integer ALU Source signals
	output wire 	 ALU_Src1_Sel,
	output wire 	 ALU_Src2_Sel,
	// PC signals
	output reg       Branch,
	output reg       Jump,
	// undefined instruction
	output reg       undef_instr
);

// Supported ISA Based on the opcode
// Integer Instrustions
// R_TYPE Format
localparam R_TYPE = 7'b0110011;
// I_Type Format
localparam IMM 	  = 7'b0010011;
localparam LOAD   = 7'b0000011;
localparam JALR   = 7'b1100111;
// S_Type
localparam STORE  = 7'b0100011;
// SB_Type
localparam BRANCH = 7'b1100011; 
// UJ_Type
localparam JAL    = 7'b1101111;
// U_Type
localparam LUI 	  = 7'b0110111;
localparam AUIPC  = 7'b0010111;

reg [1:0] alu_src_flags;

reg PC_Change;
reg pc_src_flags;

assign {ALU_Src1_Sel,ALU_Src2_Sel} = alu_src_flags;

always @(*) begin
	
	MEM_Wr_En     = 1'b0;
	Src_to_Reg    = 2'b00;
	Reg_Wr_En     = 1'b0;
	alu_src_flags = 2'b00;
	Branch        = 1'b0;
	Jump          = 1'b0;
	undef_instr   = 1'b0;

	// NOP insertion or Instruction is corrupted
	if (NOP_Ins || !EN_PC || if_id_flush) begin
		Src_to_Reg    = 2'b00;
		Reg_Wr_En     = 1'b0;
		alu_src_flags = 'b0;
		Branch        = 1'b0;
	    Jump          = 1'b0;
		undef_instr   = 1'b0;
		MEM_Wr_En     = 1'b0;
	end
	else begin
		case (Opcode)
			R_TYPE: begin
				Reg_Wr_En     = 1'b1;
			end
			IMM:begin
				Reg_Wr_En     = 1'b1;
				alu_src_flags = 2'b01; 
			end
			LOAD: begin
				Reg_Wr_En     = 1'b1;
				alu_src_flags = 2'b01;
				Src_to_Reg    = 2'b01;
			end
			STORE: begin
				alu_src_flags = 2'b01;
				MEM_Wr_En     = 1'b1;
			end
			BRANCH: begin
				alu_src_flags = 2'b11;
				PC_Change     = 1'b1;
				Branch        = 1'b1;
			end
			JAL: begin
				PC_Change     = 1'b1;
				Reg_Wr_En     = 1'b1;
				Src_to_Reg    = 2'b10;
				alu_src_flags = 2'b11;
				Jump          = 1'b1;
			end
			JALR: begin
				Jump          = 1'b1;
				Reg_Wr_En     = 1'b1;
				PC_Change     = 1'b1;
				Src_to_Reg    = 2'b10;
				alu_src_flags = 2'b01;
			end
			LUI: begin
				Reg_Wr_En     = 1'b1;
				alu_src_flags = 2'b01;
			end
			AUIPC: begin
				Reg_Wr_En     = 1'b1;
				alu_src_flags = 2'b11;
			end
			default: begin
				PC_Change     = 1'b0;
				MEM_Wr_En     = 1'b0;
				Reg_Wr_En     = 1'b0;
				alu_src_flags = 2'b0;
				pc_src_flags  = 2'b0;
				undef_instr   = 1'b1;
			end
		endcase
	end
	
end

endmodule
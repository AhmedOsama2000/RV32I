module ID_EX_REG #(
	parameter IMM_GEN = 32,
	parameter XLEN    = 32
)
(
	////////////////////////// INPUT //////////////////////
	input wire 				 CLK,
	input wire          	 rst_n,
	// PC src
	input wire [31:0] 		 PC_I,
	input wire [6:0]         Opcode_I,
	input wire               Branch_I,
	input wire               Jump_I,
	// IMM src
	input wire [IMM_GEN-1:0] IMM_I,
	// ALU Function Decision
	input wire [2:0]         Funct3_I,
	input wire [6:0]         Funct7_I,
	// RegFiles srcs
	input wire [XLEN-1:0]    Rs1_I,
	input wire [XLEN-1:0]    Rs2_I,
	input wire [XLEN-1:0]    mem_wb_data,
	input wire [1:0]		 Src_to_Reg_I,
	input wire  		     Reg_Wr_En_I,
	input wire [4:0]       	 if_id_rs1,
	input wire [4:0]      	 if_id_rs2,
	input wire [4:0]      	 if_id_rd,
	input wire [4:0]         mem_wb_rd,
	input wire               reg_mem_wb_wr,
	// ALU srcs
	input wire       		 Sub_I,
	input wire 		 		 ALU_Src1_Sel_I,
	input wire 		 		 ALU_Src2_Sel_I,
	input wire [2:0]         ALU_Ctrl_I,
	// Memory srcs
	input wire 		         MEM_Wr_En_I,
	////////////////////////// OUTPUT //////////////////////
	// PC src
	output reg [31:0] 		 PC_O,
	output reg [6:0]         Opcode_O,
	output reg        		 Branch_O,
	output reg               Jump_O,
	// IMM src
	output reg [IMM_GEN-1:0] IMM_O,
	// ALU Function Decision
	output reg [2:0]         Funct3_O,
	output reg [6:0]         Funct7_O,
	// RegFiles srcs
	output reg [XLEN-1:0]    Rs1_O,
	output reg [XLEN-1:0]    Rs2_O,
	output reg               Sub_O,
	output reg [1:0]		 Src_to_Reg_O,
	output reg  		     Reg_Wr_En_O,
	output reg [4:0]         id_ex_rs1,
	output reg [4:0]         id_ex_rs2,
	output reg [4:0]         id_ex_rd,
	// ALU srcs
	output reg 		 		 ALU_Src1_Sel_O,
	output reg 		 		 ALU_Src2_Sel_O,
	output reg [2:0]         ALU_Ctrl_O,
	// Memory srcs
	output reg 		 		 MEM_Wr_En_O
);

reg [XLEN-1:0] passed_rs1;
reg [XLEN-1:0] passed_rs2;

always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		PC_O 		    <= 'b0;
		Branch_O 	    <= 1'b0;
		Jump_O          <= 1'b0;
		IMM_O 		    <= 'b0;
		Opcode_O        <= 7'b0;
		Funct3_O        <= 'b0;
		Funct7_O        <= 7'b0;
		Src_to_Reg_O    <= 2'b0;
		Reg_Wr_En_O     <= 1'b0;
		id_ex_rs1       <= 'b0;
		id_ex_rs2 	    <= 'b0;
		id_ex_rd 	    <= 'b0;
		ALU_Src1_Sel_O  <= 1'b0;
		ALU_Src2_Sel_O  <= 1'b0;
		ALU_Ctrl_O      <= 3'b0;
		Sub_O        	<= 1'b0;
		MEM_Wr_En_O     <= 1'b0;
		Rs1_O           <= 32'b0;
		Rs2_O           <= 32'b0;
	end
	else begin
		PC_O 		    <= PC_I;
		Branch_O 	    <= Branch_I;
		Jump_O          <= Jump_I;
		Opcode_O        <= Opcode_I;
		IMM_O 		    <= IMM_I;
		Funct3_O        <= Funct3_I;
		Funct7_O 		<= Funct7_I;
		Src_to_Reg_O    <= Src_to_Reg_I;
		Reg_Wr_En_O     <= Reg_Wr_En_I;
		id_ex_rs1       <= if_id_rs1;
		id_ex_rs2 	    <= if_id_rs2;
		id_ex_rd 	    <= if_id_rd;
		ALU_Src1_Sel_O  <= ALU_Src1_Sel_I;
		ALU_Src2_Sel_O  <= ALU_Src2_Sel_I;
		ALU_Ctrl_O      <= ALU_Ctrl_I;
		Sub_O        	<= Sub_I;
		Rs1_O           <= passed_rs1;
		Rs2_O           <= passed_rs2;
		MEM_Wr_En_O     <= MEM_Wr_En_I;
		Src_to_Reg_O    <= Src_to_Reg_I;
	end

end

always @(*) begin
	if ((mem_wb_rd == if_id_rs1) && reg_mem_wb_wr) begin
		passed_rs1 = mem_wb_data;
	end
	else begin
		passed_rs1 = Rs1_I;
	end
end
always @(*) begin
	if ((mem_wb_rd == if_id_rs2) && reg_mem_wb_wr) begin
		passed_rs2 = mem_wb_data;
	end
	else begin
		passed_rs2 = Rs2_I;
	end
end

endmodule
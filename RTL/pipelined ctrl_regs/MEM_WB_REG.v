module MEM_WB_REG #(
	parameter XLEN = 32
)
(
	////////////////////////// INPUT //////////////////////
	input wire 				 CLK,
	input wire          	 rst_n,
	// PC src
	input wire [31:0] 		 PC_I,
	// RegFiles srcs
	input wire  		     Reg_Wr_En_I,
	input wire [4:0]      	 ex_mem_rd,
	// ALU srcs
	input wire [XLEN-1:0]    result_I,
	// Register srcs
	input wire [1:0]		 Src_to_Reg_I,
	input wire [XLEN-1:0]    DMEM_I,
	////////////////////////// OUTPUT //////////////////////
	// PC src
	output reg [31:0] 		 PC_O,
	// RegFiles srcs
	output reg  		     Reg_Wr_En_O,
	output reg [4:0]         mem_wb_rd,
	// ALU srcs
	output reg [XLEN-1:0]    result_O,
	// Memory srcs
	output reg [1:0]		 Src_to_Reg_O,
	output reg [XLEN-1:0]    DMEM_O
);

  
always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		PC_O 		 <= 'b0;
		Reg_Wr_En_O  <= 1'b0;
		mem_wb_rd 	 <= 'b0;
		result_O     <= 'b0;
		Src_to_Reg_O <= 2'b0;
		DMEM_O       <= 'b0;
	end
	else begin
		DMEM_O       <= DMEM_I;
		PC_O 		 <= PC_I;
		Reg_Wr_En_O  <= Reg_Wr_En_I;
		mem_wb_rd 	 <= ex_mem_rd;
		result_O     <= result_I;
		Src_to_Reg_O <= Src_to_Reg_I;
	end

end

endmodule
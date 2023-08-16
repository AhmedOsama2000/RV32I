module EX_MEM_REG #(
	parameter XLEN           = 32,
	parameter IMM_GEN 		 = 32
)
(
	////////////////////////// INPUT //////////////////////
	input wire 				 CLK,
	input wire          	 rst_n,
	// PC src
	input wire [31:0] 		 PC_I,
	// RegFiles srcs
	input wire [1:0]		 Src_to_Reg_I,
	input wire  		     Reg_Wr_En_I,
	input wire [4:0]      	 id_ex_rd,
	// Memory srcs
	input wire  [XLEN-1:0]   store_to_mem_I,
	input wire 		         MEM_Wr_En_I,
	////////////////////////// OUTPUT //////////////////////
	// PC src
	output reg [31:0] 		 PC_O,
	// RegFiles srcs
	output reg [1:0]		 Src_to_Reg_O,
	output reg  		     Reg_Wr_En_O,
	output reg [4:0]         ex_mem_rd,
	// Memory srcs
	output reg  [XLEN-1:0]   store_to_mem_O,
	output reg 		 		 MEM_Wr_En_O
);

// Reconstruction Signals / Register sources
reg [4:0] recon_rd;      

always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		PC_O 		    <= 'b0;
		Reg_Wr_En_O     <= 1'b0;
		ex_mem_rd 	    <= 'b0;
		Src_to_Reg_O    <= 2'b0;
		MEM_Wr_En_O     <= 1'b0;
		store_to_mem_O  <= 'b0;
	end
	else begin
		PC_O 		    <= PC_I;
		Reg_Wr_En_O     <= Reg_Wr_En_I;
		Src_to_Reg_O    <= Src_to_Reg_I;
		ex_mem_rd 	    <= id_ex_rd;
		MEM_Wr_En_O     <= MEM_Wr_En_I;
		store_to_mem_O  <= store_to_mem_I;
	end

end

endmodule
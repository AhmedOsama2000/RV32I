module IF_ID_REG 
(
	////////////////////////// INPUT //////////////////////
	input  wire 		CLK,
	input  wire         rst_n,
	// PC src
	input  wire         stall,
	input  wire         EN_PC_I,
	input  wire [31:0] 	PC_I,
	input  wire [31:0]  instr_I,
	input  wire         flush,
	////////////////////////// OUTPUT //////////////////////
	output reg          if_id_flush,
	output reg          EN_PC_O,
	output reg [31:0] 	PC_O,
	output reg [31:0]   instr_O
);
    

always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		PC_O 	    <= 32'b0;
		instr_O     <= 32'b0;
		EN_PC_O     <= 1'b0;
		if_id_flush <= 1'b0;
	end
	else if (flush) begin
		instr_O     <= 32'b0;
		if_id_flush <= 1'b1;
	end
	else if (!stall) begin
		if_id_flush <= 1'b0;
		EN_PC_O     <= EN_PC_I;
		PC_O 	    <= PC_I * 4;
		instr_O     <= instr_I;
	end

end

endmodule
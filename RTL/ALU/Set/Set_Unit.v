module SET_UNIT #(
	parameter XLEN = 32
) 
(
	input  wire [XLEN-1:0] Rs1,
	input  wire [XLEN-1:0] Rs2,
	input  wire  		   Funct3_0,
	input  wire 		   En,
	output reg  [XLEN-1:0] Result 
);

localparam SLT  = 1'b0;
localparam SLTU = 1'b1;

wire [XLEN-1:0] Sub_Res;

CLA_SUB subtractor (
	.Rs1(Rs1),
	.Rs2(Rs2),
	.En(En),
	.Result(Sub_Res)
);

always @(*) begin
	
	Result = 'b0;
	if (En && Funct3_0 == SLTU) begin

		if (Rs1 < Rs2) begin
			Result[0] = 1'b1;
		end
		else begin
			Result[0] = 1'b0;
		end

	end
	else if (En && Funct3_0 == SLT) begin
		if (Rs1[XLEN-1] == Rs2[XLEN-1]) begin
			// Reuse the ALU_Result 
			Result[0] = Sub_Res[XLEN-1];
		end
		else begin
			Result[0] = Rs1[XLEN-1];
		end
	end
	else begin
		Result = 'b0;
	end

end

endmodule
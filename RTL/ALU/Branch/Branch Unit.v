module Branch_Unit #(
	parameter XLEN   = 32,
	parameter FUNCT3 = 3
)
(
	// INPUT
	input  wire  [FUNCT3-1:0] funct3,
	input  wire  [XLEN-1:0]   Rs1,
	input  wire  [XLEN-1:0]   Rs2,
	input  wire   			  En, 
	// OUTPUT
	output reg 				  Branch_taken
);

localparam BEQ  = 3'b000;
localparam BNE  = 3'b001;
localparam BLT  = 3'b100;
localparam BGE  = 3'b101;
localparam BLTU = 3'b110;
localparam BGEU = 3'b111;

wire [XLEN-1:0] Sub_Res;

CLA_SUB subtractor (
	.Rs1(Rs1),
	.Rs2(Rs2),
	.En(En),
	.Result(Sub_Res)
);

always @(*) begin

	if (!En) begin
		Branch_taken = 1'b0;
	end
	else begin
		case (funct3) 
			BEQ: begin
				Branch_taken = (!Sub_Res)? 1'b1:1'b0;
			end
			BNE: begin
				Branch_taken = (Sub_Res)? 1'b1:1'b0;
			end
			BLT: begin
				if (Rs1[XLEN-1] == Rs2[XLEN-1]) begin
					Branch_taken = Sub_Res[XLEN-1];
				end
				else begin
					Branch_taken = Rs1[XLEN-1];
				end
			end
			BLTU: begin
				Branch_taken = (Rs1 < Rs2)? 1'b1:1'b0;
			end
			BGE: begin
				if (Rs1[XLEN-1] == Rs2[XLEN-1]) begin
					Branch_taken = !Sub_Res[XLEN-1];
				end
				else begin
					Branch_taken = !Rs1[XLEN-1];
				end
			end
			BGEU: begin
				Branch_taken = ( !(Rs1 < Rs2) || !Sub_Res)? 1'b1:1'b0;
			end
			default: Branch_taken = 1'b0;
		endcase
	end
end

endmodule
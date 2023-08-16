module Logical_Unit #(
	parameter FUNCT3 = 2,
	parameter XLEN   = 32
)
(
	// INPUT
	input  wire [XLEN-1:0]   Rs1,
	input  wire [XLEN-1:0]   Rs2,
	input  wire [FUNCT3-1:0] Funct3_1_0,
	input  wire 			 En, 
	// OUTPUT
	output reg  [XLEN-1:0] Result
);

localparam AND = 2'b11;
localparam OR  = 2'b10;
localparam XOR = 2'b00;

always @(*) begin
	if (En) begin
		case (Funct3_1_0)
			AND    : Result = Rs1 & Rs2;
			
			OR     : Result = Rs1 | Rs2;

			XOR    : Result = Rs1 ^ Rs2;

			default: Result = 'b0;
		endcase
	end
	else begin
		Result = 'b0;
	end

end

endmodule
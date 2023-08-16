module mux2x1 #(
	parameter XLEN = 32
) 
(
	input  wire [XLEN-1:0] i0,
	input  wire [XLEN-1:0] i1,
	input  wire            sel,
	output reg  [XLEN-1:0] out
);

always @(*) begin
	if (!sel) begin
		out = i0;
	end
	else begin
		out = i1;
	end
end

endmodule
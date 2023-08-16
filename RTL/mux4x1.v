module mux4x1 #(
	parameter XLEN = 32
) 
(
	input  wire [XLEN-1:0] i0,
	input  wire [XLEN-1:0] i1,
	input  wire [XLEN-1:0] i2,
	input  wire            sel0,
	input  wire            sel1,
	output reg  [XLEN-1:0] out
);

wire [1:0] sel_mux;

assign sel_mux = {sel1,sel0};

always @(*) begin
	if (sel_mux == 2'b00) begin
		out = i0;
	end
	else if (sel_mux == 2'b01) begin
		out = i1;
	end
	else if (sel_mux == 2'b10) begin
		out = i2;
	end
	else begin
		out = i0;
	end
end

endmodule
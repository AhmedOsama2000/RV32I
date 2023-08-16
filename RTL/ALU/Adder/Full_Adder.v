module FA (
	input  wire A0,
	input  wire B0,
	input  wire C0,
	input  wire En,
	output wire S0
);
	
	assign S0 = (En)? (A0 ^ B0 ^ C0):1'b0;

endmodule
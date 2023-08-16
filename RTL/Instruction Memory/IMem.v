module IMem (
	input  wire [31:0] PC,
	output wire [31:0] instr
);

integer i;
reg [31:0] IMEM [0:63];

assign instr = IMEM[PC];


endmodule
module RegFile #(
	parameter XLEN = 32
)
(
	// Control Signals
	input  wire 	       rst_n,
	input  wire 	       CLK,
	input  wire            Reg_Wr,
	// Input
	input  wire [4:0] 	   Rs1_rd,
	input  wire [4:0] 	   Rs2_rd,
	input  wire [4:0]      Rd_Wr,
	input  wire [XLEN-1:0] Rd_In,
	// Output
	output reg [XLEN-1:0]  Rs1_Out,
	output reg [XLEN-1:0]  Rs2_Out
);

integer i = 0;

// Registers
reg [XLEN-1:0] X [0:31];

// Write Registers
always @(posedge CLK,negedge rst_n) begin
	
	if (!rst_n) begin
		for (i = 0;i < XLEN;i = i + 1) begin
			X[i] <= 'b0;
		end
	end
	else if (Reg_Wr && Rd_Wr != 5'b00000) begin
		X[Rd_Wr] <= Rd_In;
	end

end

always @(*) begin
	Rs1_Out = X[Rs1_rd];
	Rs2_Out = X[Rs2_rd];
end

endmodule
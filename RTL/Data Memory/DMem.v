module DMem #(
	parameter XLEN = 32
)
(
	input  wire             CLK,
	input  wire             rst_n,
	input  wire        	    Mem_Wr_En,
	input  wire [XLEN-1:0]  Data_In,
	input  wire [XLEN-1:0]  Addr,
	output wire [XLEN-1:0]  Data_Out
);

reg [31:0] DMEM [0:63];
integer i;

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0;i < 64;i = i + 1) begin
			DMEM[i] <= 32'b0;
		end
	end
	else if (Mem_Wr_En) begin
		DMEM[Addr]  <= Data_In;
	end
end

assign Data_Out = DMEM[Addr];


endmodule
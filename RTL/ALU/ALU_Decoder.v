module ALU_Decoder #(
	parameter DECODER_IN  = 3,
	parameter DECODER_OUT = 2**(DECODER_IN) 
)
(
	input  wire [DECODER_IN-1:0]  ALU_Ctrl,
	output reg  [DECODER_OUT-1:0] D_out
);

always @(*) begin
	D_out = 8'b0000_0000;
	case (ALU_Ctrl)
		3'b000 : D_out = 8'b0000_0001; // ADD_SUB unit
		3'b001 : D_out = 8'b0000_0010; // Set Unit
		3'b010 : D_out = 8'b0000_0100; // Logic Unit
		3'b011 : D_out = 8'b0000_1000; // Shift Unit
		3'b100 : D_out = 8'b0001_0001; // Branch Unit + ADD Unit to get the address
		default: D_out = 8'b0000_0000; // IDLE
	endcase

end

endmodule
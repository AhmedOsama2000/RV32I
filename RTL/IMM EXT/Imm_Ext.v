module IMM_EXT 
(
	input  wire [31:0] IMM_IN,
	input  wire [6:0]  opcode,     
	output reg  [31:0] IMM_OUT
);

localparam ARITM_IMM = 7'b0010011;

localparam LOAD      = 7'b0000011;

localparam JAL       = 7'b1101111;
localparam BRANCH 	 = 7'b1100011;

localparam STORE 	 = 7'b0100011;

localparam LUI     	 = 7'b0110111; 
localparam AUIPC   	 = 7'b0010111;

localparam JALR    	 = 7'b1100111;

always @(*) begin
	case (opcode)
		JAL: begin
			IMM_OUT = {{11{IMM_IN[31]}},IMM_IN[31],IMM_IN[19:12],IMM_IN[20],IMM_IN[30:21],1'b0};
		end
		LUI , AUIPC: begin
			IMM_OUT = {IMM_IN[31:12], {12{1'b0}}};
		end
		ARITM_IMM , JALR, LOAD: begin
			IMM_OUT = {{20{IMM_IN[31]}},IMM_IN[31:20]};
		end
		BRANCH: begin
			IMM_OUT = {{19{IMM_IN[31]}},IMM_IN[31],IMM_IN[7],IMM_IN[30:25],IMM_IN[11:8],1'b0};
		end
		STORE: begin
			IMM_OUT = {{20{IMM_IN[31]}},IMM_IN[31:25],IMM_IN[11:7]};
		end
		default: IMM_OUT = 32'b0;
	endcase
end

endmodule
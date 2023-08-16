module ALU #(
	parameter XLEN 		  = 32,
	parameter DECODER_IN  = 3,
	parameter DECODER_OUT = 2**DECODER_IN
)
(
	input  wire                  rst_n,
	input  wire                  CLK,
	input  wire [XLEN-1:0] 		 Rs1,
	input  wire [XLEN-1:0] 		 Rs2,
	input  wire [DECODER_IN-1:0] ALU_ctrl,
	input  wire [2:0]            Funct3,
	input  wire  			     Funct7_5,
	input  wire                  Sub,
	output reg [XLEN-1:0]        Result,
	output reg                   overflow           
);

wire [DECODER_OUT-1:0] D_out;
wire [XLEN-1:0] 	   add_sub_res;
wire [XLEN-1:0] 	   set_res;
wire [XLEN-1:0] 	   logic_res;
wire [XLEN-1:0] 	   shift_res;
wire                   add_sub_overflow;

// ALU Decoder
ALU_Decoder alu_decode (
	.ALU_Ctrl(ALU_ctrl),
	.D_out(D_out)
);

// Adder/subtractor
CLA_ADD_SUB CLA (
	.En(D_out[0]),
	.Rs1(Rs1),
	.Rs2(Rs2),
	.Sub(Sub),
	.Result(add_sub_res),
	.overflow(add_sub_overflow)
);

// Set Unit
SET_UNIT set (
	.En(D_out[1]),
	.Rs1(Rs1),
	.Rs2(Rs2),
	.Funct3_0(Funct3[0]),
	.Result(set_res)
);

// Logic Unit
Logical_Unit Logic (
	.En(D_out[2]),
	.Rs1(Rs1),
	.Rs2(Rs2),
	.Funct3_1_0(Funct3[1:0]),
	.Result(logic_res)
);

// Shift Unit
Shift_Unit shift (
	.En(D_out[3]),
	.Rs1(Rs1),
	.Rs2(Rs2[4:0]),
	.funct3_2(Funct3[2]),
	.funct7_5(Funct7_5),
	.Result(shift_res)
);

// EX Stage
// Register The Result
always @(posedge CLK,negedge rst_n) begin
	
	overflow <= add_sub_overflow;
	if (!rst_n) begin
		Result   <= 'b0;
		overflow <= 1'b0;
	end
	else if (ALU_ctrl == 3'b000 || ALU_ctrl == 3'b100) begin
		Result   <= add_sub_res;
	end
	else if (ALU_ctrl == 3'b001) begin
		Result   <= set_res;
	end
	else if (ALU_ctrl == 3'b010) begin
		Result   <= logic_res;
	end
	else if (ALU_ctrl == 3'b011) begin
		Result   <= shift_res;
	end

end

endmodule
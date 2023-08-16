module CLA_ADD_SUB
#(
  	parameter XLEN = 32
)
(
	input  wire [XLEN-1:0] Rs1,
	input  wire [XLEN-1:0] Rs2,
	input  wire            En,
	input  wire            Sub,
	output wire [XLEN-1:0] Result,
	output wire            overflow
);
     
wire [XLEN:0]   Carry;
wire [XLEN-1:0] G;
wire [XLEN-1:0] Pg;
wire [XLEN-1:0] Sum;
wire [XLEN-1:0] passed_rs2; 

assign passed_rs2 = (Sub && En)? ~Rs2:Rs2;

// Create the Full Adders
genvar full_adder_gen;
generate
	for (full_adder_gen = 0; full_adder_gen < XLEN;full_adder_gen = full_adder_gen + 1) begin

		// Output Carry is not needed but generated via the CLA_Generator
		FA full_adder_insts ( 
			.A0(Rs1[full_adder_gen]),
			.B0(passed_rs2[full_adder_gen]),
			.C0(Carry[full_adder_gen]),
			.En(En),
			.S0(Sum[full_adder_gen])
		);
	end
endgenerate
 	
// CLA_Generator	
// Generate carries
genvar             gen_c;
generate
	for (gen_c = 0; gen_c < XLEN; gen_c = gen_c + 1) begin

	    assign G[gen_c]  			= Rs1[gen_c] & passed_rs2[gen_c] & En;
	    assign Pg[gen_c]  		= (Rs1[gen_c] | passed_rs2[gen_c]) & En;
	    assign Carry[gen_c+1] = (G[gen_c] | (Pg[gen_c] & Carry[gen_c])) & En;

	 end
endgenerate
   
  // Carry Depend on ADD/SUB Operation
  assign Carry[0] = Sub;
 
  assign {overflow,Result} = {Carry[XLEN] ^ Carry[XLEN-1],Sum};
 
endmodule
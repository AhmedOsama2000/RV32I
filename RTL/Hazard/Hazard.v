module Hazard_Unit (
	// INPUT
	input  wire [6:0] Opcode,
	// PC Change Detection        
	input  wire       pc_change,
	// Register Sources
	input  wire [4:0] IF_ID_rs1,
	input  wire [4:0] IF_ID_rs2,
	input  wire [4:0] IF_ID_rd,
	// Registered Destination Sources
	input  wire [4:0] ID_EX_Reg_rd,
	// OUTPUT
	output wire		  PC_Stall,
	output wire		  NOP_Ins, // no-operation insertion
	output reg        flush
);

// Expected Hazards
reg   expc_haz;


// Detect if the source is x0
wire   rs1_zero;
wire   rs2_zero;

// Stall The Core signal
reg [1:0] stall_core;

reg NS;
reg CS;

assign {PC_Stall,NOP_Ins} = stall_core; 

assign rs1_zero = (IF_ID_rs1 == 5'b0)? 1'b1:1'b0;
assign rs2_zero = (IF_ID_rs2 == 5'b0)? 1'b1:1'b0;

always @(*) begin
	if ((IF_ID_rs1 == ID_EX_Reg_rd) || (IF_ID_rs2 == ID_EX_Reg_rd)) begin
		if (!rs1_zero && !rs2_zero) begin
			expc_haz = 1'b1 ;
		end
		else begin
			expc_haz = 1'b0 ;
		end
	end
	else begin
		expc_haz = 1'b0 ;
	end
end

// Handle Exceptions
always @(*) begin
	flush 	   = 1'b0;
	stall_core = 2'b00;
	if (pc_change) begin
		flush      = 1'b1;
		stall_core = 2'b01;
	end
	else if ( (Opcode == 7'b0000011 || Opcode == 7'b0000111) && expc_haz) begin
		stall_core = 2'b11;
	end
	else begin
		stall_core = 2'b00;
		flush      = 1'b0;
	end
end

endmodule
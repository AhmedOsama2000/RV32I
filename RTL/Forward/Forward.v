module Forward_Unit #(
	parameter WIDTH_SOURCE = 5
)
(
	input  wire 				   EX_MEM_Reg_Wr,
	input  wire 				   MEM_WB_Reg_Wr,
	input  wire [WIDTH_SOURCE-1:0] ID_EX_rs1,
	input  wire [WIDTH_SOURCE-1:0] ID_EX_rs2,
	input  wire [WIDTH_SOURCE-1:0] EX_MEM_rd,
	input  wire [WIDTH_SOURCE-1:0] MEM_WB_rd,

	// OUTPUT
	output reg [1:0] 			   Forward_A,
	output reg [1:0] 			   Forward_B
);

wire EX_dest_x0;
wire MEM_dest_x0;

assign EX_dest_x0 	  = !EX_MEM_rd? 1'b1:1'b0;
assign MEM_dest_x0 	  = !MEM_WB_rd? 1'b1:1'b0;

// Src1 ==> A
always @(*) begin

	Forward_A = 2'b00;
	
	// EX Forward
	if (EX_MEM_Reg_Wr && !EX_dest_x0 && (EX_MEM_rd == ID_EX_rs1)) begin
		Forward_A = 2'b10;		
	end
	// MEM Forward
	else if (MEM_WB_Reg_Wr && !MEM_dest_x0 && (MEM_WB_rd == ID_EX_rs1)) begin
		Forward_A = 2'b01;		
	end
	else begin
		Forward_A = 2'b00;
	end
	
end

// Src1 ==> B
always @(*) begin

	Forward_B = 2'b00;
	
	// EX Forward
	if (EX_MEM_Reg_Wr && !EX_dest_x0 && (EX_MEM_rd == ID_EX_rs2)) begin
		Forward_B = 2'b10;		
	end
	// MEM Forward
	else if (MEM_WB_Reg_Wr && !MEM_dest_x0 && (MEM_WB_rd == ID_EX_rs2)) begin
		Forward_B = 2'b01;		
	end
	else begin
		Forward_B = 2'b00;
	end
	
end

endmodule
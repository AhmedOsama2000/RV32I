module Shift_Unit #(
	parameter XLEN   = 32
)
(
	// INPUT
	input  wire signed [XLEN-1:0] Rs1,
	input  wire  	   [4:0] 	  Rs2,
	input  wire  			 	  funct3_2, 
	input  wire              	  funct7_5,
	input  wire              	  En,
	// OUTPUT
	output reg         [XLEN-1:0] Result
);

reg [XLEN-1:0] t0;
reg [XLEN-1:0] t1;
reg [XLEN-1:0] t2;
reg [XLEN-1:0] t3;
reg [XLEN-1:0] t4;
reg [XLEN-1:0] t5;
wire           sign_bit;
integer 	   i;

assign sign_bit = (funct7_5)? Rs1[XLEN-1]:1'b0;

always @(*) begin
	t0 = 'b0;
	t1 = 'b0;
	t2 = 'b0;
	t3 = 'b0;
	t4 = 'b0;
	t5 = 'b0;
	if (En && {funct7_5,funct3_2} != 2'b10) begin	
		if (!funct3_2) begin	
			for (i = 0;i < XLEN;i = i + 1) begin	
				t0[XLEN-i-1] = Rs1[i];
			end
		end
		else begin
			t0 = Rs1;
		end
		t1 = (Rs2[0])? {{sign_bit},t0[XLEN-1:1]}     :t0;
		t2 = (Rs2[1])? {{2{sign_bit}},t1[XLEN-1:2]}  :t1;
		t3 = (Rs2[2])? {{4{sign_bit}},t2[XLEN-1:4]}  :t2;
		t4 = (Rs2[3])? {{8{sign_bit}},t3[XLEN-1:8]}  :t3;
		t5 = (Rs2[4])? {{16{sign_bit}},t4[XLEN-1:16]}:t4;
		if (!funct3_2) begin
			for (i = 0;i < XLEN;i = i + 1) begin
				Result[XLEN-i-1] = t5[i];
			end
		end
		else begin
			Result = t5;
		end
	end
	else begin
		t0 = 'b0;
		t1 = 'b0;
		t2 = 'b0;
		t3 = 'b0;
		t4 = 'b0;
		t5 = 'b0;
		Result = 'b0;
	end
end

endmodule
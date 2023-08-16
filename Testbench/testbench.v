module testbench;

reg rst_n;
reg CLK;
reg EN_PC;


RV32I DUT (
	.CLK(CLK),
	.rst_n(rst_n),
	.EN_PC(EN_PC)
);

always begin
	#5
	CLK = ~CLK;
end

initial begin
	EN_PC = 1'b0;
	rst_n = 1'b0;
	CLK   = 1'b0;
	repeat (5) @(negedge CLK);

	rst_n = 1'b1;
	EN_PC = 1'b1;
	$readmemh("prog.txt",DUT.instr_mem.IMEM);
	$readmemh("data_mem.txt",DUT.Data_Memory.DMEM);
	repeat (500) @(negedge CLK);
	EN_PC = 1'b0;

	$stop;

end

endmodule
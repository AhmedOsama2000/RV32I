module RV32I #(
	parameter XLEN   = 32,
	parameter IMM    = 32 
)
(
	input 	wire 						rst_n,
	input 	wire 						CLK,
	input	wire 						EN_PC
);

// -------------------------------------- Internal Signals -------------------------------------- //
// -------------------------------------- PC Signals -------------------------------------- //
wire [XLEN-1:0]   pc_prog_out;   
wire [XLEN-1:0]   pc_mem_wb;
// -------------------------------------- IMemory Signals -------------------------------------- //
wire [31:0] 	  get_instr;
// -------------------------------------- IF/ID Register Signals -------------------------------------- //
wire 			  flush_ctrl;
wire              EN_PC_if_id;
wire [31:0]       pc_if_id;
wire [31:0]       instr_if_id;
// -------------------------------------- DMemory Signals -------------------------------------- //
wire [XLEN-1:0]   data_mem_out;
// -------------------------------------- Controller Signals -------------------------------------- //
wire [6:0]        opcode = instr_if_id[6:0];
wire 	   		  nop_ins;
wire [6:0]   	  funct7 = instr_if_id[31:25];
wire [2:0]   	  funct3 = instr_if_id[14:12];
wire 	          mem_wr_en;
wire [1:0]   	  src_to_reg;
wire              reg_wr_En;
wire              alu_src1_sel;
wire              alu_src2_sel;
wire              branch;
wire              jump;
wire              Sub;
wire              undef_instr;
wire    [2:0]     alu_ctrl;
// -------------------------------------- Scoreboard Signals -------------------------------------- //
wire              stall_core;
wire              pc_change;
// -------------------------------------- IMM_EXT Signals -------------------------------------- //
wire [XLEN-1:0]   imm_o;
// -------------------------------------- RegFile Signals -------------------------------------- //
wire [XLEN-1:0]   rs1_out;
wire [XLEN-1:0]   rs2_out;
wire [XLEN-1:0]   rs1_out_id_ex;
wire [XLEN-1:0]   rs2_out_id_ex;
// -------------------------------------- ID/EX Register Signals -------------------------------------- //
wire  [31:0]      pc_id_ex;
wire 			  branch_id_ex;
wire 			  jump_id_ex;
wire  [IMM-1:0]   imm_id_ex;
wire  [6:0]		  opcode_id_ex;
wire  [2:0]       funct3_id_ex;
wire  [6:0]       funct7_id_ex;
wire 			  reg_wr_en_id_ex;
wire  [4:0]	      id_ex_rs1;
wire  [4:0]	      id_ex_rs2;
wire  [4:0]	      id_ex_rd;
wire 			  Sub_id_ex;
wire 			  alu_src1_sel_id_ex;
wire 			  alu_src2_sel_id_ex;
wire  [2:0]		  alu_ctrl_id_ex;
wire 			  mem_wr_En_id_ex;
wire  [1:0]		  src_to_reg_id_ex;
// -------------------------------------- EX/MEM Register Signals -------------------------------------- //
wire  [31:0]      pc_ex_mem;
wire   			  reg_wr_en_ex_mem;
wire  [4:0]	      ex_mem_rd;
wire 			  mem_wr_En_ex_mem;
wire  [1:0]		  src_to_reg_ex_mem;
wire  [31:0]      store_to_mem;
// -------------------------------------- MEM/WB Register Signals -------------------------------------- //
wire 			  reg_wr_en_mem_wb;
wire [4:0]	      mem_wb_rd;
wire [31:0]       pc4_to_reg;
wire [XLEN-1:0]   result_mem_wb;
wire [1:0]	      src_to_reg_mem_wb;
wire [XLEN-1:0]   reg_rd;
wire [XLEN-1:0]   data_mem_out_mem_wb;
// -------------------------------------- FORWARD SIGNALS -------------------------------------- //
wire   [1:0]      forw_src1;
wire   [1:0]      forw_src2;
wire   [XLEN-1:0] forw1_out;
wire   [XLEN-1:0] forw2_out;  
// -------------------------------------- ALU SIGNALS -------------------------------------- //
wire              branch_taken;
wire              overflow;
wire [XLEN-1:0]   rs1_src;
wire [XLEN-1:0]   rs2_src;
wire [XLEN-1:0]   result;
/*******************************************************************
FETCH STAGE
*******************************************************************/
/*******************************************************************
PROGRAM COUNTER
*******************************************************************/
PC prog_count (
	// input
	.CLK(CLK),
	.rst_n(rst_n),
	.stall_pc(stall_core),
	.PC_Addr(ALU.CLA.Result),
	.En_PC(EN_PC),
	.PC_Change(pc_change),
	// output
	.PC_Out(pc_prog_out)     
); 

/*******************************************************************
INSTRUCTION Memory
*******************************************************************/
IMem instr_mem (
	.PC(pc_prog_out),
	.instr(get_instr)
);

IF_ID_REG  IF_ID_Register (
	////////////////////////// INPUT //////////////////////
	.CLK(CLK),
	.rst_n(rst_n),
	// PC src
	.EN_PC_I(EN_PC),
	.stall(stall_core),
	.flush(flush_if_id),
	.PC_I(pc_prog_out),
	.instr_I(get_instr),
	////////////////////////// OUTPUT //////////////////////
	.if_id_flush(flush_ctrl),
	.EN_PC_O(EN_PC_if_id),
	.PC_O(pc_if_id),
	.instr_O(instr_if_id)
);

/*******************************************************************
DECODE STAGE
*******************************************************************/
/*******************************************************************
CONTROLLER
*******************************************************************/
Control_Unit Controller (
	.Opcode(opcode),
	.NOP_Ins(nop_ins),
	.CTRL_FLUSH(flush_ctrl),
	.Funct7(funct7),
	.Funct3(funct3),
	// Memory Control Signals
	.MEM_Wr_En(mem_wr_en),
	// Register Write Srcs
	.Src_to_Reg(src_to_reg),
	// RegFile Control Signals
	.Reg_Wr_En(reg_wr_En),
	// Integer ALU Source signals
	.ALU_Src1_Sel(alu_src1_sel),
	.ALU_Src2_Sel(alu_src2_sel),
	// PC signals
	.EN_PC(EN_PC_if_id),
	.Branch(branch),
	.Jump(jump),
	// ALU ADD/SUB Operation
	.Sub(Sub),
	// undefined instruction
	.undef_instr(undef_instr),
	// To ALU Decoders
	.ALU_Ctrl(alu_ctrl)
);
/*******************************************************************
HAZARD
*******************************************************************/
Hazard_Unit Hazard (
	// INPUT
	.Opcode(opcode_id_ex),
	// PC Change Detection        
	.pc_change(pc_change),
	// Register Sources
	.IF_ID_rs1(instr_if_id[19:15]),
	.IF_ID_rs2(instr_if_id[24:20]),
	.IF_ID_rd(instr_if_id[11:7]),
	// Registered Destination Sources
	.ID_EX_Reg_rd(id_ex_rd),
	// OUTPUT
	.PC_Stall(stall_core),
	.NOP_Ins(nop_ins), // no-operation insertion
	.flush(flush_if_id)
);
/*******************************************************************
REGISTER FILES
*******************************************************************/
RegFile #(
	.XLEN(XLEN)
)
	Register_File 
(
	.rst_n(rst_n),
	.CLK(CLK),
	.Reg_Wr(reg_wr_en_mem_wb),
	.Rs1_rd(instr_if_id[19:15]),
	.Rs2_rd(instr_if_id[24:20]),
	.Rd_Wr(mem_wb_rd),
	.Rd_In(reg_rd),
	.Rs1_Out(rs1_out),
	.Rs2_Out(rs2_out)
);

/*******************************************************************
IMM EXT
*******************************************************************/
IMM_EXT Imm_Ext (
	.IMM_IN(instr_if_id),
	.opcode(opcode),     
	.IMM_OUT(imm_o)
);
/*******************************************************************
EXCUTE STAGE
*******************************************************************/

/*******************************************************************
ID/EX REGISTER
*******************************************************************/
ID_EX_REG ID_EX_Register (
	.CLK(CLK),
	.rst_n(rst_n),
	// PC src
	.PC_I(pc_if_id),
	.Branch_I(branch),
	.Jump_I(jump),
	// IMM src
	.IMM_I(imm_o),
	.Opcode_I(opcode),
	// ALU Function Decision
	.Funct3_I(funct3),
	.Funct7_I(funct7),
	// RegFiles srcs
	.mem_wb_rd(mem_wb_rd),
	.mem_wb_data(reg_rd),
	.Rs1_I(rs1_out),
	.Rs2_I(rs2_out),
	.Reg_Wr_En_I(reg_wr_En),
	.Src_to_Reg_I(src_to_reg),
	.if_id_rs1(instr_if_id[19:15]),
	.if_id_rs2(instr_if_id[24:20]),
	.if_id_rd(instr_if_id[11:7]),
	.reg_mem_wb_wr(reg_wr_en_mem_wb),
	// ALU srcs
	.Sub_I(Sub),
	.ALU_Src1_Sel_I(alu_src1_sel),
	.ALU_Src2_Sel_I(alu_src2_sel),
	.ALU_Ctrl_I(alu_ctrl),
	// Memory srcs
	.MEM_Wr_En_I(mem_wr_en),
	// PC src
	.PC_O(pc_id_ex),
	.Branch_O(branch_id_ex),
	.Jump_O(jump_id_ex),
	// IMM src
	.IMM_O(imm_id_ex),
	.Opcode_O(opcode_id_ex),
	// ALU Function Decision
	.Funct3_O(funct3_id_ex),
	.Funct7_O(funct7_id_ex),
	// RegFiles srcs
	.Rs1_O(rs1_out_id_ex),
	.Rs2_O(rs2_out_id_ex),
	.Reg_Wr_En_O(reg_wr_en_id_ex),
	.Src_to_Reg_O(src_to_reg_id_ex),
	.id_ex_rs1(id_ex_rs1),
	.id_ex_rs2(id_ex_rs2),
	.id_ex_rd(id_ex_rd),
	// ALU srcs
	.Sub_O(Sub_id_ex),
	.ALU_Src1_Sel_O(alu_src1_sel_id_ex),
	.ALU_Src2_Sel_O(alu_src2_sel_id_ex),
	.ALU_Ctrl_O(alu_ctrl_id_ex),
	// Memory srcs
	.MEM_Wr_En_O(mem_wr_En_id_ex)
);
/*******************************************************************
FORWARD
*******************************************************************/
Forward_Unit alu_forward (
	.EX_MEM_Reg_Wr(reg_wr_en_ex_mem),
	.MEM_WB_Reg_Wr(reg_wr_en_mem_wb),
	.ID_EX_rs1(id_ex_rs1),
	.ID_EX_rs2(id_ex_rs2),
	.EX_MEM_rd(ex_mem_rd),
	.MEM_WB_rd(mem_wb_rd),
	.Forward_A(forw_src1),
	.Forward_B(forw_src2)
);
/*******************************************************************
 ALU Sources MUX Selection
*******************************************************************/
mux2x1 sel_src1 (
	.i0(forw1_out),
	.i1(pc_id_ex),
	.sel(alu_src1_sel_id_ex),
	.out(rs1_src)
);

mux2x1 sel_src2 (
	.i0(forw2_out),
	.i1(imm_id_ex),
	.sel(alu_src2_sel_id_ex),
	.out(rs2_src)
);

mux4x1 forw1_sel (
	.i0(rs1_out_id_ex), 		   // Don't Forward
	.i1(reg_rd),          // Forward From 5th Stage
	.i2(result),		   // Forward From 4th Stage
	.sel0(forw_src1[0]),
	.sel1(forw_src1[1]),
	.out(forw1_out)
);

mux4x1 forw2_sel (
	.i0(rs2_out_id_ex), 		   // Don't Forward
	.i1(reg_rd),          // Forward From 5th Stage
	.i2(result),		   // Forward From 4th Stage
	.sel0(forw_src2[0]),
	.sel1(forw_src2[1]),
	.out(forw2_out)
);

/*******************************************************************
ALU
*******************************************************************/
ALU #(
	.XLEN(XLEN)
) 
	ALU 
(
	.rst_n(rst_n),
	.CLK(CLK),
	.Rs1(rs1_src),
	.Rs2(rs2_src),
	.Sub(Sub_id_ex),
	.ALU_ctrl(alu_ctrl_id_ex),
	.Funct3(funct3_id_ex),
	.Funct7_5(funct7_id_ex[5]),
	.Result(result),
	.overflow(overflow)  
);

Branch_Unit #(
	.XLEN(XLEN)
) 
	Branch_Detect
(
	// INPUT
	.funct3(funct3_id_ex),
	.Rs1(forw1_out),
	.Rs2(forw2_out),
	.En(ALU.alu_decode.D_out[4]), 
	// OUTPUT
	.Branch_taken(branch_taken)
);

assign pc_change = (branch_taken & branch_id_ex) | (jump_id_ex);

/*******************************************************************
 MEMORY STAGE
*******************************************************************/
/*******************************************************************
 EX/MEM Register
*******************************************************************/
EX_MEM_REG #(
	.XLEN(XLEN)
)
	EX_MEM_Register 
(
////////////////////////// INPUT //////////////////////
	.CLK(CLK),
	.rst_n(rst_n),
	// PC src
	.PC_I(pc_id_ex),
	// RegFiles srcs
	.Reg_Wr_En_I(reg_wr_en_id_ex),
	.id_ex_rd(id_ex_rd),
	// ALU srcs
	// Memory srcs
	.store_to_mem_I(forw2_out),
	.MEM_Wr_En_I(mem_wr_En_id_ex),
	.Src_to_Reg_I(src_to_reg_id_ex),
	////////////////////////// OUTPUT //////////////////////
	// PC src
	.PC_O(pc_ex_mem),
	// RegFiles srcs
	.Reg_Wr_En_O(reg_wr_en_ex_mem),
	.ex_mem_rd(ex_mem_rd),
	.Src_to_Reg_O(src_to_reg_ex_mem),
	.store_to_mem_O(store_to_mem),
	// Memory srcs
	.MEM_Wr_En_O(mem_wr_En_ex_mem)
);
/*******************************************************************
 Data Memory
*******************************************************************/
DMem #(
	.XLEN(XLEN)
)
	Data_Memory
(
	.CLK(CLK),
	.rst_n(rst_n),
	.Mem_Wr_En(mem_wr_En_ex_mem),
	.Data_In(store_to_mem),
	.Addr(result),
	.Data_Out(data_mem_out)
);

/*******************************************************************
WRITE_BACK STAGE 
*******************************************************************/
MEM_WB_REG #(
	.XLEN(XLEN)
) 
	MEM_WB_Register	
(
////////////////////////// INPUT //////////////////////
	.CLK(CLK),
	.rst_n(rst_n),
	// PC src
	.PC_I(pc_ex_mem),
	// RegFiles srcs
	.Reg_Wr_En_I(reg_wr_en_ex_mem),
	.ex_mem_rd(ex_mem_rd),
	.result_I(result),
	// Register Write srcs
	.Src_to_Reg_I(src_to_reg_ex_mem),
	// Data Memory 
	.DMEM_I(data_mem_out),
	////////////////////////// OUTPUT //////////////////////
	// PC src
	.PC_O(pc_mem_wb),
	// RegFiles srcs
	.Reg_Wr_En_O(reg_wr_en_mem_wb),
	.mem_wb_rd(mem_wb_rd),
	// ALU srcs
	.result_O(result_mem_wb),
	// Register Write srcs
	.Src_to_Reg_O(src_to_reg_mem_wb),
	// Data Memory 
	.DMEM_O(data_mem_out_mem_wb)
);

assign pc4_to_reg = pc_mem_wb + 3'b100;

mux4x1 reg_src (
	.i0(result_mem_wb),   // From Integer ALU
	.i1(data_mem_out_mem_wb), // From Data Memory in case of load		   
	.i2(pc4_to_reg),       // In Case of jump instructions
	.sel0(src_to_reg_mem_wb[0]),
	.sel1(src_to_reg_mem_wb[1]),
	.out(reg_rd)
);


endmodule


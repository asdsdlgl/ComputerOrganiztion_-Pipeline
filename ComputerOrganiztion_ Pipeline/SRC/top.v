// top
`include "PC.v"
`include "IF_ID.v"
`include "HDU.v"
`include "Controller.v"
`include "Regfile.v"
`include "Mux2to1.v"
`include "ID_EX.v"
`include "Mux4to1.v"
`include "Jump_Ctrl.v"
`include "FU.v"
`include "ALU.v"
`include "EX_M.v"
`include "M_WB.v"
module top ( clk,
             rst,
			 // Instruction Memory
			 IM_Address,
             		 Instruction,
			 // Data Memory
			 DM_Address,
			 DM_enable,
			 DM_Write_Data,
			 DM_Read_Data);

	parameter data_size = 32;
	parameter mem_size = 16;	

	input  clk, rst;
	
	// Instruction Memory
	output [mem_size-1:0] IM_Address;	
	input  [data_size-1:0] Instruction;

	// Data Memory
	output [mem_size-1:0] DM_Address;
	output DM_enable;
	output [data_size-1:0] DM_Write_Data;	
    	input  [data_size-1:0] DM_Read_Data;
	
	// write your code here
	wire [31:0] src2;
	wire [15:0] imm;
	wire [31:0] ID_ir;
	wire [17:0] PCin;
	wire [17:0] PCout;
	wire PCWrite;
	wire [17:0] PC_add4;

	wire IF_IDWrite;
	wire IF_Flush;
	wire ID_Flush;
	wire [17:0] ID_PC;

	wire [5:0] opcode;
	wire [5:0] funct;
	wire RegDst;
	wire Jump;
	wire Branch;
	wire Jal;
	wire Jr;
	wire MemToReg;
	wire [3:0] ALUOp;
	wire RegWrite;
	wire MemWrite;
	wire Signextend;
	wire SignextendLoad;

	wire [31:0] Rs_data;
	wire [31:0] Rt_data;
	wire WB_RegWrite;
	wire [4:0] WB_WR_out;
	wire [31:0] WB_Final_WD_out;

	wire [31:0] se_imm;

	wire [4:0] Rd_Rt_out;
	wire [4:0] WR_out;

	wire [4:0] EX_WR_out;
	wire EX_MemtoReg;
	wire [1:0] EX_JumpOP;
	wire   EX_RegWrite;
	wire   EX_MemWrite;
	wire   EX_Jal;
	wire   EX_RegDst;
	wire   EX_Jump;
	wire   EX_Branch;
	wire   EX_Jr;
	wire   [17:0] EX_PC;
	wire   [3:0] EX_ALUOp;
	wire   [4:0] EX_shamt;
	wire   [31:0] EX_Rs_data;
	wire   [31:0] EX_Rt_data;
	wire   [31:0] EX_se_imm;
	wire   [4:0] EX_Rs;
	wire   [4:0] EX_Rt;
	wire EX_Signextend;
	wire EX_SignextendLoad;

	wire [17:0] BranchAddr;

	wire [31:0] sF1_data;
	wire [31:0] sF2_data;
	wire [31:0] enF1_data;
	wire [31:0] enF2_data;

	wire	enF1;
	wire	enF2;
	wire	sF1;
	wire	sF2;

	wire EX_Zero;
	wire [31:0] EX_ALU_result;
	wire [17:0] EX_PCplus8;

	wire  [4:0] M_WR_out;
	wire  M_MemWrite;
	wire [31:0] M_WD_out;
	wire  M_MemtoReg;
	wire  M_RegWrite;
	wire  M_Jal;
	wire  [31:0] M_ALU_result;
	wire  [31:0] M_Rt_data;
	wire  [17:0] M_PCplus8;

	wire M_Signextend;
	wire M_SignextendLoad;

	wire [31:0] sign_ex1;
	wire [31:0] sign_ex2;

	wire WB_MemtoReg;
	wire  [31:0] WB_DM_Read_Data;
	wire  [31:0] WB_WD_out;

	wire [31:0] DoubleEnd;

	wire [4:0] Rd;
	wire [4:0] Rs;
	wire [4:0] Rt;
	wire [4:0] shamt;
	wire [17:0] JumpAddr;



	assign IM_Address = PCout[17:2];		
		// Controller
	assign opcode		 = ID_ir[31:26];
	assign funct		 = ID_ir[5:0];
	
		// Registers
	assign Rd			 = ID_ir[15:11];
	assign Rs			 = ID_ir[25:21];
	assign Rt			 = ID_ir[20:16];
	
		// sign_extend
	assign imm			 = ID_ir[15:0];
	
		// shamt to ID_EX pipe
	assign shamt		 = ID_ir[10:6];
	
		//Jump Part
	assign JumpAddr		 = {EX_se_imm[15:0],2'b0};
	
		// Data Memory

	assign DM_Address	 = M_ALU_result[17:2];
	assign DM_enable	 = M_MemWrite;	


	//IF
	PC PC1 ( 
	.clk(clk), 
	.rst(rst),
	.PCWrite(PCWrite),
	.PCin(PCin), 
	.PCout(PCout)
	);

	assign PC_add4 = PCout + 18'd4;

	IF_ID IF_ID1 ( 
	.clk(clk),
	.rst(rst),
	.IF_IDWrite(IF_IDWrite),
	.IF_Flush(IF_Flush),
	.IF_PC(PC_add4),
	.IF_ir(Instruction),
	.ID_PC(ID_PC),
	.ID_ir(ID_ir)
	);

	//ID

	HDU HDU1 ( 
	.ID_Rs(Rs),
    	.ID_Rt(Rt),
	.EX_WR_out(EX_WR_out),
	.EX_MemtoReg(EX_MemtoReg),
	.EX_JumpOP(EX_JumpOP),
	.PCWrite(PCWrite),			 
	.IF_IDWrite(IF_IDWrite),
	.IF_Flush(IF_Flush),
	.ID_Flush(ID_Flush)
	);

	Controller Controller1 ( 
	.opcode(opcode),
	.funct(funct),
	.RegDst(RegDst),
	.Jump(Jump),
	.Branch(Branch),
	.Jal(Jal),
	.Jr(Jr),
	.MemToReg(MemToReg),
	.ALUOp(ALUOp),
	.RegWrite(RegWrite),
	.MemWrite(MemWrite),
	.Signextend(Signextend),
	.SignextendLoad(SignextendLoad)
	);

	Regfile Registers1 ( 
	.clk(clk), 
	.rst(rst),
	.Read_addr_1(Rs),
	.Read_addr_2(Rt),
	.Read_data_1(Rs_data),
	.Read_data_2(Rt_data),
	.RegWrite(WB_RegWrite),
	.Write_addr(WB_WR_out),
	.Write_data(WB_Final_WD_out)
	);

	assign se_imm = {
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15],
	imm[15:0]
	};

	Mux2to1#(5) Rd_Rt ( 
	.I0(Rd),
	.I1(Rt),
	.S(RegDst),
	.out(Rd_Rt_out)
	);

	Mux2to1#(5) WR ( 
	.I0(Rd_Rt_out),
	.I1(5'd31),
	.S(Jal),
	.out(WR_out)
	);

	//ID_EX
	
	ID_EX ID_EX1 ( 
	.clk(clk), 
	.rst(rst),
	.ID_Flush(ID_Flush),
	.ID_MemtoReg(MemToReg),
	.ID_RegWrite(RegWrite),
	.ID_MemWrite(MemWrite),
	.ID_Jal(Jal),
	.ID_Reg_imm(RegDst),
	.ID_Jump(Jump),
	.ID_Branch(Branch),
	.ID_Jr(Jr),			   
	.ID_PC(ID_PC),
	.ID_ALUOp(ALUOp),
	.ID_shamt(shamt),
	.ID_Rs_data(Rs_data),
	.ID_Rt_data(Rt_data),
	.ID_se_imm(se_imm),
	.ID_WR_out(WR_out),
	.ID_Rs(Rs),
	.ID_Rt(Rt),
  	.ID_Signextend(Signextend),
	.ID_SignextendLoad(SignextendLoad),
	.EX_MemtoReg(EX_MemtoReg),
	.EX_RegWrite(EX_RegWrite),
	.EX_MemWrite(EX_MemWrite),
	.EX_Jal(EX_Jal),
	.EX_Signextend(EX_Signextend),
	.EX_SignextendLoad(EX_SignextendLoad),
	.EX_Reg_imm(EX_RegDst),
	.EX_Jump(EX_Jump),
	.EX_Branch(EX_Branch),
	.EX_Jr(EX_Jr),
	.EX_PC(EX_PC),
	.EX_ALUOp(EX_ALUOp),
	.EX_shamt(EX_shamt),
	.EX_Rs_data(EX_Rs_data),
	.EX_Rt_data(EX_Rt_data),
	.EX_se_imm(EX_se_imm),
	.EX_WR_out(EX_WR_out),
	.EX_Rs(EX_Rs),
	.EX_Rt(EX_Rt)		   			   
	);

	//EX

	assign BranchAddr = EX_PC + {EX_se_imm[15:0],2'b0};

	Mux4to1 PC_Mux (
	.I0(PC_add4),
	.I1(BranchAddr),
	.I2(enF1_data[17:0]),
	.I3(JumpAddr),
	.S(EX_JumpOP),
	.out(PCin)
	);

	Jump_Ctrl Jump_Ctrl1 (
	.Branch(EX_Branch),
    	.Zero(EX_Zero),
    	.Jr(EX_Jr),
    	.Jump(EX_Jump),
    	.JumpOP(EX_JumpOP)
	);

	FU FU1 ( 
	.EX_Rs(EX_Rs),
    	.EX_Rt(EX_Rt),
	.M_RegWrite(M_RegWrite),
	.M_WR_out(M_WR_out),
	.WB_RegWrite(WB_RegWrite),
	.WB_WR_out(WB_WR_out),
	.enF1(enF1),
	.enF2(enF2),
	.sF1(sF1),
	.sF2(sF2)	
	);

	Mux2to1#(data_size) sF1_Mux (
	.I0(WB_Final_WD_out),       		
	.I1(M_WD_out),      			
	.S(sF1),    				
	.out(sF1_data)
	);

	Mux2to1#(data_size) sF2_Mux (
	.I0(WB_Final_WD_out),       		
	.I1(M_WD_out),      			
	.S(sF2),        			
	.out(sF2_data)
	);

	Mux2to1#(data_size) enF1_Mux (
	.I0(EX_Rs_data),        		
	.I1(sF1_data),
	.S(enF1),       			
	.out(enF1_data)     			
	);

	Mux2to1#(data_size) enF2_Mux (
	.I0(EX_Rt_data),
	.I1(sF2_data),
	.S(enF2),       		
	.out(enF2_data)     			
	);
//


	Mux2to1#(data_size) Rt_imm (
	.I0(enF2_data),
	.I1(EX_se_imm),
	.S(EX_RegDst),
	.out(src2)
	);

	ALU ALU1 ( 
	.ALUOp(EX_ALUOp),
	.src1(enF1_data),
	.src2(src2),
	.shamt(EX_shamt),
	.ALU_result(EX_ALU_result),
	.Zero(EX_Zero)
	);

	assign EX_PCplus8 = EX_PC + 18'd4;

	//EX_M
	
	EX_M EX_M1 ( 
	.clk(clk),
	.rst(rst),
	.EX_MemtoReg(EX_MemtoReg),
	.EX_RegWrite(EX_RegWrite),
	.EX_MemWrite(EX_MemWrite),
	.EX_Jal(EX_Jal),
	.EX_ALU_result(EX_ALU_result),
	.EX_Rt_data(enF2_data),
	.EX_PCplus8(EX_PCplus8),
	.EX_WR_out(EX_WR_out),
	.M_MemtoReg(M_MemtoReg),
	.M_RegWrite(M_RegWrite),
	.M_MemWrite(M_MemWrite),
	.M_Jal(M_Jal),
	.M_ALU_result(M_ALU_result),
	.M_Rt_data(M_Rt_data),
	.M_PCplus8(M_PCplus8),
	.M_WR_out(M_WR_out),
	.M_SignextendLoad(M_SignextendLoad),
	.M_Signextend(M_Signextend),
	.EX_SignextendLoad(EX_SignextendLoad),
	.EX_Signextend(EX_Signextend)	 		  
	);

	//Mem

	Mux2to1 Jal_RD_Select (
	.I0(M_ALU_result),
	.I1({14'b0,M_PCplus8}),
	.S(M_Jal),
	.out(M_WD_out)
	);	

	assign sign_ex1 = {{16{M_Rt_data[15]}},M_Rt_data[15:0]};
//assign sign_ex1 = {{16{M_WD_out[15]}},M_WD_out[15:0]};

	Mux2to1 dm(
	.I0(M_Rt_data),
	.I1(sign_ex1),
	.S(M_Signextend),
	.out(DM_Write_Data)
	);


	assign sign_ex2 = {{16{DM_Read_Data[15]}},DM_Read_Data[15:0]};

	Mux2to1 signex(
	.I0(DM_Read_Data),
	.I1(sign_ex2),
	.S(M_SignextendLoad),
	.out(DoubleEnd)
	);

	//M_WB


	M_WB M_WB1 ( 
	.clk(clk),
    	.rst(rst),
	.M_MemtoReg(M_MemtoReg),
	.M_RegWrite(M_RegWrite),
	.M_DM_Read_Data(DoubleEnd),
	.M_WD_out(M_WD_out),
	.M_WR_out(M_WR_out),
	.WB_MemtoReg(WB_MemtoReg),
	.WB_RegWrite(WB_RegWrite),
	.WB_DM_Read_Data(WB_DM_Read_Data),
	.WB_WD_out(WB_WD_out),
    	.WB_WR_out(WB_WR_out)
	);

	Mux2to1 DM_RD_Select (
	.I0(WB_WD_out),
	.I1(WB_DM_Read_Data),
	.S(WB_MemtoReg),
	.out(WB_Final_WD_out)
	);

endmodule



























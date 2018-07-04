// ALU

module ALU ( ALUOp,
			 src1,
			 src2,
			 shamt,
			 ALU_result,
			 Zero);
	
	parameter bit_size = 32;
	
	input [3:0] ALUOp;
	input [bit_size-1:0] src1;
	input [bit_size-1:0] src2;
	input [4:0] shamt;
	
	output [bit_size-1:0] ALU_result;
	output Zero;
	reg [bit_size-1:0] ALU_result;
	reg Zero;
			
	// write your code in here
	always@(*)
		begin
		ALU_result = 0;
		Zero = 0;
		case(ALUOp)
			4'd1 : ALU_result = src1+src2;//add
			4'd2 : ALU_result = src1-src2;//sub
			4'd3 : ALU_result = src1&src2;//and
			4'd4 : ALU_result = src1|src2;//or
		 	4'd5 : ALU_result = src1^src2;//xor
		  	4'd6 : ALU_result = ~(src1|src2);//nor
			4'd7 : ALU_result = (src1<src2) ? 1 : 0;//slt
			4'd8 : ALU_result = src2<<shamt;//sll
			4'd9 : ALU_result = src2>>shamt;//srl
			4'd10 : Zero = (src1==src2) ? 1 : 0;//beq
			4'd11 : Zero = (src1==src2) ? 0 : 1;//bne
			default:;
		endcase
		end
endmodule







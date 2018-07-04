// Controller

module Controller ( opcode,
					funct,
					ALUOp,
					RegWrite,
					Branch,
					Jr,
					Jump,
					Jal,
					MemWrite,
					MemToReg,
					RegDst,
					Signextend,
					SignextendLoad
					);

	input  [5:0] opcode;
	input  [5:0] funct;
	output [3:0] ALUOp;
	output RegWrite;
	output MemWrite;
	output MemToReg;
	output Branch;
	output Jr;
	output Jump;
	output Jal;
	output RegDst;
	output Signextend;
	output SignextendLoad;
	reg [3:0] ALUOp;
	reg RegWrite;
	reg MemToReg;
	reg MemWrite;
	reg Branch;
	reg Jr;
	reg Jump;
	reg Jal;
	reg RegDst;
	reg Signextend;
	reg SignextendLoad;
	always @(*)	
		begin
		RegWrite = 0;
		MemToReg = 0;
		MemWrite = 0;
		Branch = 0;
		Jr = 0;
		Jump = 0;
		Jal = 0;
		RegDst = 0;
		Signextend = 0;
		SignextendLoad = 0;
		ALUOp	 = 0;
		case(opcode)
			6'b000000:
				begin
				case(funct)
					6'b100000:
					begin
						ALUOp = 4'd1;//add
						RegWrite = 1;
					end
					6'b100010:
					begin
						ALUOp = 4'd2;//sub
						RegWrite = 1;
					end
					6'b100100:
					begin
						ALUOp= 4'd3;//and
						RegWrite = 1;
					end
					6'b100101:
					begin
						ALUOp = 4'd4;//or
						RegWrite = 1;
					end
					6'b100110:
					begin
						ALUOp = 4'd5;//xor
						RegWrite = 1;
					end
					6'b100111:
					begin
						ALUOp = 4'd6;//nor
						RegWrite = 1;
					end
					6'b101010:
					begin
						//Branch = 1;
						ALUOp = 4'd7;//less
						RegWrite = 1;
					end
					6'b000000:
					begin
						ALUOp = 4'd8;//left shift
						RegWrite = 1;
					end
					6'b000010:
					begin
						ALUOp = 4'd9;//right shift
						RegWrite = 1;
					end
					6'b001000://JR
					begin
						Jr = 1;
					end
					6'b001001://Jalr
					begin
						Jal = 1;
						Jr = 1;
						RegWrite = 1;
					end
					//6'b001000:ALUOp = 4'b1001;//beq
					//6'b100000:ALUOp = 4'b1010;//bne
				endcase
				end
			6'b001000:
			begin
				ALUOp = 4'd1;//addi
				RegWrite = 1;
				RegDst = 1;
			end
			6'b001100:
			begin
				ALUOp = 4'd3;//andi
				RegWrite = 1;
				RegDst = 1;
			end
			6'b001010:
			begin
				ALUOp = 4'd7;//slti
				RegWrite = 1;
				RegDst = 1;
			end
			6'b001101:
			begin
				ALUOp = 4'd4;//ori
				RegWrite = 1;
				RegDst = 1;
			end
			6'b000100:
			begin
				ALUOp = 4'd10;//equal
				Branch = 1;
			end
			6'b000101:
			begin
				ALUOp = 4'd11;//bne
				Branch = 1;
			end
			6'b100011:
			begin
				ALUOp = 4'd1;//lw->add
				RegWrite = 1;
				MemToReg = 1;
				RegDst = 1;
			end
			6'b101011:
			begin
				ALUOp = 4'd1;//sw->add
				MemWrite = 1;
				RegDst = 1;
			end
			6'b100001:
			begin
				ALUOp = 4'd1;//lh->add
				SignextendLoad = 1;
				RegWrite = 1;
				MemToReg = 1;
				RegDst = 1;
			end
			6'b101001:
			begin
				ALUOp = 4'd1;//sh->add
				Signextend = 1;
				MemWrite = 1;
				RegDst = 1;
			end
			6'b000010://jump
			begin
				Jump = 1;
			end
			6'b000011://jal
			begin
				Jump = 1;
				Jal = 1;
				RegWrite = 1;
			end
		endcase
		end
	
endmodule






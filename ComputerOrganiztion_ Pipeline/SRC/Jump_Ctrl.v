// Jump_Ctrl

module Jump_Ctrl( Zero,
                  JumpOP,
			Branch,
			Jump,
			Jr
				  );

    input Zero;
	input Branch;
	input Jump;
	input Jr;
	
	output [1:0] JumpOP;
	reg [1:0] JumpOP;
	
	always@ (*) begin
		JumpOP = (Branch&&Zero) ? 1 :Jr	? 2 :Jump? 3 : 0;
	end
endmodule







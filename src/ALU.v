`define ALU_AND               4'b0000
`define ALU_OR                4'b0001
`define ALU_ADD               4'b0010
`define ALU_SUB               4'b0011
`define ALU_SET_IF_LESS_THAN  4'b0100
`define ALU_NOR               4'b0101
`define ALU_SLL               4'b1000 //ALU_INPUT[0] identifies the shift opration 
`define ALU_SRL               4'b1001

module ALU_module (control_signal, in_world_a, in_world_b, out_world);
	input [3:0] control_signal;
	input [31:0] in_world_a;
	input [31:0] in_world_b;
	output reg [31:0] out_world;
	
	always @(*)
		
		case (control_signal)
			`ALU_AND:	out_world = in_world_a & in_world_b;
			`ALU_OR:		out_world = in_world_a | in_world_b;
			`ALU_ADD:	out_world = in_world_a + in_world_b;
			`ALU_SUB:	out_world = in_world_a - in_world_b;
			`ALU_SET_IF_LESS_THAN: out_world = (in_world_a < in_world_b) ? 32'd1 : 32'd0;
			`ALU_NOR:	out_world =  ~(in_world_a | in_world_b);
			`ALU_SLL:	out_world =  (in_world_a << in_world_b);
			`ALU_SRL:	out_world =  (in_world_a >> in_world_b);
			default: out_world = 32'd0;
		endcase	
endmodule
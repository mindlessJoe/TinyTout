
module ALU_module (clk, control_signal, in_world_a, in_world_b, out_world);
	input clk;
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
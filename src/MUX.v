	
module mux_32b_2channel (
    input  [31:0] world_a,
    input  [31:0] world_b,
    input        control,
    output [31:0] out_world
);
    assign out_world = control ? world_b : world_a;
endmodule
	   	


module mux_5b_2channel (
    input  [4:0] world_a,
    input  [4:0] world_b,
    input        control,
    output [4:0] out_world
);
    assign out_world = control ? world_b : world_a;
endmodule
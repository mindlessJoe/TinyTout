
module MIPS_processor_debug( 
	input clk,
	input rst,
	input [31:0] instruction,
	input [31:0] memory_word,
	output [31:0] address_out,
	output [31:0] register_data,
	output [31:0] jump_address,
	output branch_success,
	output jump,
	output mem_write,
	output mem_read,
	
	// === DEBUG OUTPUTS ===
	output [31:0] debug_ALU_source,
	output [31:0] debug_input_ALU_source_mux,
	output [31:0] debug_extender_output,
	output [31:0] debug_ALU_target,
	output [3:0]  debug_ALU_control,
	output [11:0] debug_control_signals,
	output [3:0]  debug_output_i_op,
	output [4:0]  debug_mux_address,
	output [31:0] debug_mux_data_to_store,
	output [31:0] debug_ALU_output,
	output [31:0] debug_out_LUI_mux
	);
	
	// === Segnali intermedi ===
	wire [31:0] input_ALU_source_mux;
	wire [11:0] output_signal;
	wire [3:0]  output_i_op;
	wire [3:0]  ALU_control_bus;
	
	wire [4:0]  out_mux_address_source;
	wire [31:0] out_mux_data_to_store;
	wire [31:0] out_LUI_mux;
	wire [31:0] out_I_or_R_source;
	wire [31:0] out_mux_ALU_target;
	wire [31:0] ALU_source;
	wire [31:0] ALU_output;
	wire [31:0] extender_output;
	wire [31:0] out_mux_jump_address;
	
	// === CONTROL UNIT ===
	control_unit_module control_unit (
		.clk(clk),
		.rst(rst),
		.control_signal(instruction[31:26]),
		.output_signal(output_signal),
		.output_i_op(output_i_op)
		);
	
	// === ALU CONTROLLER ===
	ALU_controller_module ALU_controller(
		.clk(clk),
		.ALU_OP({output_signal[7], output_signal[6]}),
		.ALU_I_OP(output_i_op),
		.func_field(instruction[5:0]),
		.ALU_input(ALU_control_bus)
		);
	
	// === REGISTER FILE ===
	register_port_module register_port(
		.clk(clk),
		.rst(rst),
		.write_enable(output_signal[9]),
		.read_address_0(instruction[25:21]),
		.read_address_1(instruction[20:16]),
		.write_address(out_mux_address_source),
		.data_to_write(out_LUI_mux),
		.data_read_0(ALU_source),
		.data_read_1(input_ALU_source_mux)
		);
	
	// === ALU ===
	ALU_module ALU(
		.clk(clk),
		.control_signal(ALU_control_bus),
		.in_world_a(ALU_source),
		.in_world_b(out_mux_ALU_target),
		.out_world(ALU_output)
		);
	
	// === MUX per write address ===
	mux_5b_2channel register_source_mux(
		.world_a(instruction[20:16]),
		.world_b(instruction[15:11]),
		.control(output_signal[0]),        // REG_DEST
		.out_world(out_mux_address_source)
		);
	
	// === MUX per ALU source B ===
	mux_32b_2channel ALU_source_mux(
		.world_a(input_ALU_source_mux),
		.world_b(extender_output),
		.control(output_signal[10]),       // ALU_SRC
		.out_world(out_I_or_R_source)
		);
	
	//=== MUX per il campo SHAMT ===
	mux_32b_2channel ALU_shamt_mux(
		.world_a(out_I_or_R_source),
		.world_b({27'b0, instruction[10:6]}),
		.control(ALU_control_bus[0]),       // ALU_SRC
		.out_world(out_mux_ALU_target)
		);	
	
	// === MUX per data to store ===
	mux_32b_2channel data_to_store_mux(
		.world_a(ALU_output),
		.world_b(memory_word),
		.control(output_signal[8]),        // MEM_TO_REG
		.out_world(out_mux_data_to_store)
		);
	
	// === MUX per jump address ===
	mux_32b_2channel jump_address_mux(
		.world_a({6'b0, instruction[25:0]}),
		.world_b(extender_output),
		.control(output_signal[2] | output_signal[3]), // BEQ o BNE
		.out_world(out_mux_jump_address)
		);
	// === MUX per LUI===
	mux_32b_2channel LUI_mux(
		.world_a(out_mux_data_to_store),
		.world_b({instruction[15:0],16'b0}),
		.control(output_signal[11]), // LUI
		.out_world(out_LUI_mux)
		);
	
	// === EXTENDER ===
	extender_module extender(
		.immediate(instruction[15:0]),
		.world(extender_output)
		);
	
	// === OUTPUTS ===
	assign address_out     = ALU_output;
	assign register_data   = input_ALU_source_mux;
	assign jump_address    = out_mux_jump_address;
	assign mem_write       = output_signal[4];   // MEM_WRITE
	assign mem_read        = output_signal[5];   // MEM_READ
	assign branch_success  = (output_signal[2] & (ALU_output == 0)) |
		(output_signal[3] & (ALU_output != 0));
	assign jump = output_signal[1];
	
	// === DEBUG OUTPUTS ===
	assign debug_ALU_source           = ALU_source;
	assign debug_input_ALU_source_mux = input_ALU_source_mux;
	assign debug_extender_output      = extender_output;
	assign debug_ALU_target           = out_mux_ALU_target;
	assign debug_ALU_control          = ALU_control_bus;
	assign debug_control_signals      = output_signal;
	assign debug_output_i_op          = output_i_op;
	assign debug_mux_address          = out_mux_address_source;
	assign debug_mux_data_to_store    = out_mux_data_to_store;
	assign debug_ALU_output           = ALU_output;
	assign debug_out_LUI_mux = out_LUI_mux;
	
endmodule


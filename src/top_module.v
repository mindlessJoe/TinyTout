module top_module (	
	
	input clk,              // TinyTapeOut clk
	input rst,              // TinyTapeOut rst
	input [7:0] data_in,    // TinyTapeOut Input
	output [7:0] data_out,  // TinyTapeOut Output
	output [7:0] address_out, // TinyTapeOut InOut
	
	// ===== IO_controller Debug Outputs =====
	output [31:0] instruction_debug,
	output [31:0] memory_out_debug,
	
	// ===== MIPS_PROCESSOR Debug Outputs =====
	output jump,
	output mem_write,
	output mem_read,
	
	output [31:0] debug_ALU_source,
	output [31:0] debug_input_ALU_source,
	output [31:0] debug_ALU_target,
	output [31:0] debug_ALU_control,
	output [31:0] debug_ALU_output,
	output [31:0] debug_LUI_MUX,
	output [11:0] debug_control_signals
);

	// ========================
	// Segnali interni
	// ========================
	wire [31:0] instruction;
	wire [31:0] memory_out;
	wire [31:0] mips_address_out;
	wire [31:0] register_data;
	wire [31:0] jump_address;
	wire cpu_clk;
	wire branch_success;
	
	// ========================
	// ISTANZA PROCESSORE MIPS
	// ========================
	MIPS_processor_debug mips_core (
		.clk(cpu_clk),
		.rst(rst),
		.instruction(instruction),
		.memory_word(memory_out),
		.address_out(mips_address_out),
		.register_data(register_data),
		.jump_address(jump_address),
		.branch_success(branch_success),
		.jump(jump),
		.mem_write(mem_write),
		.mem_read(mem_read),

		// Debug
		.debug_ALU_source(debug_ALU_source),
		.debug_input_ALU_source_mux(debug_input_ALU_source),
		.debug_ALU_target(debug_ALU_target),
		.debug_ALU_control(debug_ALU_control),
		.debug_ALU_output(debug_ALU_output),
		.debug_out_LUI_mux(debug_LUI_MUX),
		.debug_control_signals(debug_control_signals)
	);
	
	// ========================
	// ISTANZA IO CONTROLLER
	// ========================
	IO_controller_module IO_controller (
		.clk(clk),
		.rst(rst),
		.data_input(data_in),
		.address_out(address_out),
		.data_output(data_out),

		.mem_w(mem_write),
		.mem_r(mem_read),
		.branch_success(branch_success),
		.jump(jump),

		.memory_address(mips_address_out),
		.data_from_register(register_data),
		.jump_address(jump_address),

		.cpu_clk(cpu_clk),

		.instruction(instruction),
		.memory_out(memory_out),

		// debug IO controller
		.instruction_counter_en(),
		.register_data_counter_en(),
		.memory_data_counter_en(),
		.instruction_counter_reset(),
		.register_data_reset(),
		.memory_data_reset()
	);

	// Collegamento debug
	assign instruction_debug = instruction;
	assign memory_out_debug = memory_out;

endmodule

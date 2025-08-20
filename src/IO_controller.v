module counter_4 (
	input clk,
	input rst,
	input count_enable,
	output reg [2:0] counter
	);
	always @(posedge clk) begin
			if (!rst)
				counter <= 3'd0;
			else if (count_enable)
				counter <= counter + 1'b1;
		end
endmodule



module IO_controller_module(
	// TinyTapeOut IO
	input clk,
	input rst,
	input [7:0] data_input,
	output reg [7:0] address_out,
	output reg [7:0] data_output,
	
	// MIPS to IO communication
	input mem_w,
	input mem_r,
	input branch_success,
	input jump,
	
	input [31:0] memory_address,     // address to read/write
	input [31:0] data_from_register, // data from register (SW)
	input [31:0] jump_address,       // jump target address
	
	output reg cpu_clk,
	
	output reg [31:0] instruction,   // instruction fetched
	output reg [31:0] memory_out,    // memory data fetched
	
	// Counter controls
	output reg instruction_counter_en,
	output reg register_data_counter_en,
	output reg memory_data_counter_en,
	
	output reg instruction_counter_reset,
	output reg register_data_reset,
	output reg memory_data_reset
	);
	
	// === Stati della FSM ===
	typedef enum logic [2:0] {
	PREPARE_INST  = 3'b000,
	FETCH_INST    = 3'b001,
	EXECUTE       = 3'b010,
	GET_WORD      = 3'b011,
	WRITE_WORD    = 3'b100,
	STALL         = 3'b101
	} state_t;
	
	state_t state, next_state;
	
	wire [2:0] instruction_counter_output;
	wire [2:0] register_data_output;
	wire [2:0] memory_data_output;
	
	// === Contatori ===
	counter_4 instruction_counter_inst (
		.clk(clk),
		.rst(instruction_counter_reset),
		.count_enable(instruction_counter_en),
		.counter(instruction_counter_output)
		);
	
	counter_4 register_data_counter_inst (
		.clk(clk),
		.rst(register_data_reset),
		.count_enable(register_data_counter_en),
		.counter(register_data_output)
		);
	
	counter_4 memory_counter_inst (
		.clk(clk),
		.rst(memory_data_reset),
		.count_enable(memory_data_counter_en),
		.counter(memory_data_output)
		);
	reg [31:0] memory_out_reg = 32'b0;
	reg [31:0] next_memory_out_reg = 32'b0;
	reg [31:0] instruction_reg = 32'b0;
	reg[31:0] next_istruction_reg = 32'b0;
	reg[7:0] address_out_reg =8'b0;
	reg[7:0] data_output_reg = 8'b0;
	
	
	// =======================
	// 1) Registro di stato
	// =======================
	always @(posedge clk or negedge rst) begin
			if (!rst)
				state <= PREPARE_INST;
			else
				state <= next_state;
		end
	
	// =======================
	// 2) Logica combinatoria delle uscite
	// =======================
	always @(*) begin
			// Default
			cpu_clk = 1'b0;
			
			instruction_counter_en = 1'b0;
			register_data_counter_en = 1'b0;
			memory_data_counter_en = 1'b0;
			
			instruction_counter_reset = 1'b1;
			register_data_reset = 1'b1;
			memory_data_reset = 1'b1;
			
			case (state)
				PREPARE_INST: begin
						$display ( "PREPARE_INSTRUCTION");
						instruction_counter_reset = 1'b0;
						register_data_reset = 1'b0;
						memory_data_reset = 1'b0;
						
						next_istruction_reg = 32'b0;
						next_memory_out_reg = 32'b0;
						address_out_reg = 8'h0;
						data_output_reg = 8'b0;
					end	
				
				FETCH_INST: begin
						instruction_counter_en = 1'b1;
						next_istruction_reg[8*instruction_counter_output +: 8] = data_input;
						
						// Debug display
						$display("|clk = %0b| FETCH_INST | count=%0d | byte_in=%b | instruction=%b",
							clk,
							instruction_counter_output,
							data_input,
							next_istruction_reg);
						
					end
				
				EXECUTE: begin
						cpu_clk = 1'b1;
						instruction_counter_reset = 1'b0;
						$display("executing, count=%0d", instruction_counter_output); 
					end
				
				GET_WORD: begin
						cpu_clk = 1'b1;
						$display("|clk = %0b | GET_WORD | count= %0d | word = %h | in_address = %h | data_out =%h| address_out=%h",
							clk,
							register_data_output,
							data_from_register,
							memory_address,
							data_output_reg,
							address_out_reg);
						
						register_data_counter_en = 1'b1;
						data_output_reg = data_from_register[8*register_data_output +: 8];
						address_out_reg = memory_address[8*register_data_output +: 8];
					end
				
				STALL: begin
						cpu_clk = 1'b1;
						$display ("STALL");
						register_data_reset = 1'b0;
						address_out_reg = 8'hFF; 
					end
				
				WRITE_WORD: begin
						$display("|clk = %0b | WRITE_WORD | count=%0d | byte_in=%h | memory_out=%h",
							clk,

							memory_data_output,
							data_input,
							next_memory_out_reg);
						
							cpu_clk = 1'b1;
						memory_data_counter_en = 1'b1;
						next_memory_out_reg[8*memory_data_output +: 8] = data_input;
					end
			endcase
		end
	
	// =======================
	// 3) Funzione per prossimo stato
	// =======================
	function state_t next_state_func;
		
		input state_t curr_state;
		input mem_r, mem_w, jump, branch_success;
		input [2:0] instr_cnt;
		input [2:0] reg_cnt;
		input [2:0] mem_cnt;
		begin
			case (curr_state)
				PREPARE_INST:  next_state_func = FETCH_INST;
				FETCH_INST:    next_state_func = (instr_cnt == 3'd4) ? EXECUTE : FETCH_INST;
				EXECUTE:       next_state_func = (mem_w==0 && mem_r==0 && branch_success==0 && jump==0) ? PREPARE_INST : GET_WORD;
				GET_WORD: begin
						if(reg_cnt == 3'd3 && mem_r == 0) next_state_func =  PREPARE_INST;
						else if(reg_cnt == 3'd3 && mem_r == 1)	next_state_func =  STALL;
						else next_state_func =  GET_WORD;
					end 
				STALL:         next_state_func = WRITE_WORD;
				WRITE_WORD:    next_state_func = (mem_cnt == 3'd4) ? PREPARE_INST : WRITE_WORD;
				default:       next_state_func = PREPARE_INST;
			endcase
		end
	endfunction
	
	// =======================
	// 4) Aggancio della funzione
	// =======================
	always @(state or mem_r or mem_w or jump or branch_success or 
		instruction_counter_output or register_data_output or memory_data_output)
		
		begin
			
			next_state = next_state_func(state, mem_r, mem_w, jump, branch_success,
			instruction_counter_output,
			register_data_output,
			memory_data_output);
		end
	
	always @(negedge clk)
	
		begin

		instruction_reg <= next_istruction_reg;
		memory_out_reg <= next_memory_out_reg;
		
		end
	
	
	always @(*)	 begin
			instruction = instruction_reg;
			address_out = address_out_reg;
			data_output = data_output_reg;
			memory_out = memory_out_reg;
		end


	
endmodule
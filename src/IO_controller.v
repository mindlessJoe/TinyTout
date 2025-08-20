module counter_4 (
  input  logic       clk,
  input  logic       rst,             // active-low reset expected by your FSM
  input  logic       count_enable,
  output logic [2:0] counter
);
  always_ff @(posedge clk) begin
    if (!rst)
      counter <= 3'd0;
    else if (count_enable)
      counter <= counter + 3'd1;
  end
endmodule


module IO_controller_module(
  // TinyTapeOut IO
  input  logic        clk,
  input  logic        rst,                  // active-low reset (coerente con counter_4)
  input  logic [7:0]  data_input,
  output logic [7:0]  address_out,
  output logic [7:0]  data_output,

  // MIPS to IO communication
  input  logic        mem_w,
  input  logic        mem_r,
  input  logic        branch_success,
  input  logic        jump,

  input  logic [31:0] memory_address,       // address to read/write
  input  logic [31:0] data_from_register,   // data from register (SW)
  input  logic [31:0] jump_address,         // jump target address (unused qui, ma lasciato)

  output logic        cpu_clk,

  output logic [31:0] instruction,          // instruction fetched
  output logic [31:0] memory_out,           // memory data fetched

  // Counter controls
  output logic        instruction_counter_en,
  output logic        register_data_counter_en,
  output logic        memory_data_counter_en,

  output logic        instruction_counter_reset,  // active-low
  output logic        register_data_reset,        // active-low
  output logic        memory_data_reset           // active-low
);

  // === Stati della FSM ===
  typedef enum logic [2:0] {
    PREPARE_INST = 3'b000,
    FETCH_INST   = 3'b001,
    EXECUTE      = 3'b010,
    GET_WORD     = 3'b011,
    WRITE_WORD   = 3'b100,
    STALL        = 3'b101
  } state_t;

  state_t state, next_state;

  logic [2:0] instruction_counter_output;
  logic [2:0] register_data_output;
  logic [2:0] memory_data_output;

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

  // Registri "tenuti fino al reset"
  logic [31:0] instruction_reg,        next_instruction_reg;
  logic [31:0] memory_out_reg,         next_memory_out_reg;

  // Per evitare latch su queste uscite, le registro anch’esse
  logic [7:0]  address_out_reg,        next_address_out_reg;
  logic [7:0]  data_output_reg,        next_data_output_reg;

  // =======================
  // 1) Registro di stato  (reset SINCRONO, attivo basso)
  // =======================
  always_ff @(posedge clk) begin
    if (!rst)
      state <= PREPARE_INST;
    else
      state <= next_state;
  end

  // =======================
  // 2) Logica combinatoria di controllo + next_*
  //    (default HOLD, poi override per stato)
  // =======================
  always_comb begin
    // Default: HOLD / idle
    cpu_clk                   = 1'b0;

    instruction_counter_en    = 1'b0;
    register_data_counter_en  = 1'b0;
    memory_data_counter_en    = 1'b0;

    // reset dei contatori: deassert (1) per default, assert (0) in PREPARE
    instruction_counter_reset = 1'b1;
    register_data_reset       = 1'b1;
    memory_data_reset         = 1'b1;

    // HOLD dei registri (così instruction/memory_out restano invariati)
    next_instruction_reg      = instruction_reg;
    next_memory_out_reg       = memory_out_reg;
    next_address_out_reg      = address_out_reg;
    next_data_output_reg      = data_output_reg;

    unique case (state)
      PREPARE_INST: begin
        instruction_counter_reset = 1'b0; // reset contatori (active-low)
        register_data_reset       = 1'b0;
        memory_data_reset         = 1'b0;

        // opzionale: azzerare anche i registri interni al reset di sistema?
        // Non necessario per "tenere" i valori; li puliamo solo su rst sincrono.
        next_address_out_reg      = 8'h00;
        next_data_output_reg      = 8'h00;

        `ifndef SYNTHESIS
          $display("PREPARE_INSTRUCTION");
        `endif
      end

      FETCH_INST: begin
        instruction_counter_en = 1'b1;

        // Scrivi il byte nella fetta corretta, il resto rimane invariato (HOLD)
        next_instruction_reg[8*instruction_counter_output +: 8] = data_input;

        `ifndef SYNTHESIS
          $display("|clk=%0b| FETCH_INST | count=%0d | byte_in=%b | instruction(next)=%b",
                   clk, instruction_counter_output, data_input, next_instruction_reg);
        `endif
      end

      EXECUTE: begin
        cpu_clk = 1'b1;
        instruction_counter_reset = 1'b0; // tieni il contatore in reset durante EXECUTE?

        `ifndef SYNTHESIS
          $display("EXECUTE, count=%0d", instruction_counter_output);
        `endif
      end

      GET_WORD: begin
        cpu_clk = 1'b1;

        register_data_counter_en = 1'b1;
        next_data_output_reg = data_from_register[8*register_data_output +: 8];
        next_address_out_reg = memory_address      [8*register_data_output +: 8];

        `ifndef SYNTHESIS
          $display("|clk=%0b| GET_WORD | count=%0d | word=%h | addr_in=%h | data_out(next)=%h | address_out(next)=%h",
                   clk, register_data_output, data_from_register, memory_address,
                   next_data_output_reg, next_address_out_reg);
        `endif
      end

      STALL: begin
        cpu_clk = 1'b1;
        register_data_reset  = 1'b0;
        next_address_out_reg = 8'hFF;

        `ifndef SYNTHESIS
          $display("STALL");
        `endif
      end

      WRITE_WORD: begin
        cpu_clk = 1'b1;
        memory_data_counter_en = 1'b1;

        // Accumula il dato letto in un word (HOLD altrove)
        next_memory_out_reg[8*memory_data_output +: 8] = data_input;

        `ifndef SYNTHESIS
          $display("|clk=%0b| WRITE_WORD | count=%0d | byte_in=%h | memory_out(next)=%h",
                   clk, memory_data_output, data_input, next_memory_out_reg);
        `endif
      end

      default: /* nothing */;
    endcase
  end

  // =======================
  // 3) Funzione per prossimo stato
  // =======================
  function automatic state_t next_state_func(
      input state_t curr_state,
      input logic   mem_r, mem_w, jump, branch_success,
      input logic [2:0] instr_cnt,
      input logic [2:0] reg_cnt,
      input logic [2:0] mem_cnt
  );
    unique case (curr_state)
      PREPARE_INST:  next_state_func = FETCH_INST;
      FETCH_INST:    next_state_func = (instr_cnt == 3'd4) ? EXECUTE : FETCH_INST;
      EXECUTE:       next_state_func = (mem_w==0 && mem_r==0 && branch_success==0 && jump==0)
                                       ? PREPARE_INST : GET_WORD;
      GET_WORD: begin
        if      (reg_cnt == 3'd3 && mem_r == 0) next_state_func = PREPARE_INST;
        else if (reg_cnt == 3'd3 && mem_r == 1) next_state_func = STALL;
        else                                    next_state_func = GET_WORD;
      end
      STALL:         next_state_func = WRITE_WORD;
      WRITE_WORD:    next_state_func = (mem_cnt == 3'd4) ? PREPARE_INST : WRITE_WORD;
      default:       next_state_func = PREPARE_INST;
    endcase
  endfunction

  // =======================
  // 4) Aggancio della funzione (combinatorio)
  // =======================
  always_comb begin
    next_state = next_state_func(
      state, mem_r, mem_w, jump, branch_success,
      instruction_counter_output, register_data_output, memory_data_output
    );
  end

  // =======================
  // 5) Registri dati (reset SINCRONO; tengono il valore finché niente li modifica)
  // =======================
  always_ff @(posedge clk) begin
    if (!rst) begin
      instruction_reg   <= 32'd0;
      memory_out_reg    <= 32'd0;
      address_out_reg   <= 8'd0;
      data_output_reg   <= 8'd0;
    end else begin
      instruction_reg   <= next_instruction_reg;
      memory_out_reg    <= next_memory_out_reg;
      address_out_reg   <= next_address_out_reg;
      data_output_reg   <= next_data_output_reg;
    end
  end

  // =======================
  // 6) Uscite
  // =======================
  always_comb begin
    instruction = instruction_reg;
    memory_out  = memory_out_reg;
    address_out = address_out_reg;
    data_output = data_output_reg;
  end

endmodule

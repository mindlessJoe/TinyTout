`timescale 1ns/1ps

module tb_top_module;

  reg         clk;
  reg         rst;
  reg  [7:0]  data_in;

  wire [7:0]  data_out;
  wire [7:0]  address_out;

  // Debug signals dal top
  wire [31:0] instruction_debug;
  wire [31:0] memory_out_debug;

  wire        jump;
  wire        mem_write;
  wire        mem_read;

  wire [31:0] debug_ALU_source;
  wire [31:0] debug_input_ALU_source;
  wire [31:0] debug_ALU_target;
  wire [31:0] debug_ALU_control;
  wire [31:0] debug_ALU_output;
  wire [31:0] debug_LUI_MUX;

  wire [11:0] debug_control_signals;

  // DUT
  top_module dut (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .data_out(data_out),
    .address_out(address_out),
    .instruction_debug(instruction_debug),
    .memory_out_debug(memory_out_debug),
    .jump(jump),
    .mem_write(mem_write),
    .mem_read(mem_read),
    .debug_ALU_source(debug_ALU_source),
    .debug_input_ALU_source(debug_input_ALU_source),
    .debug_ALU_target(debug_ALU_target),
    .debug_ALU_control(debug_ALU_control),
    .debug_ALU_output(debug_ALU_output),
    .debug_LUI_MUX(debug_LUI_MUX),
    .debug_control_signals(debug_control_signals)
  ); 
  

  // Clock 100 MHz
  initial clk = 0;
  always #5 clk = ~clk;

  // Stimoli
  initial begin
    $dumpfile("tb_top_module.vcd");
    $dumpvars(0, tb_top_module);

    // Reset + valore iniziale
    rst     = 0;
    data_in = 8'b00000100;
    @(negedge clk);
    rst = 1;

    // ===== Invia LW $t0, 4($t1) = 0x8D080004 =====
    // 0x04, 0x00, 0x08, 0x8D
    //send_byte(8'b00000100); // imm[7:0]
    send_byte(8'b00000000); // imm[15:8]
    send_byte(8'b00001000); // rt|rs (rt=$t0=01000, rs=$t1=01001 -> 00001000 � rt, rs sta nei bit alti del byte MSB)
    send_byte(8'b10001101); // opcode (LW)

    @(posedge clk);
    wait (address_out == 8'hFF);
    $display("[%0t] STALL visto: address_out=0xFF. In attesa dell'avvio scrittura (addr=0x01)...", $time);

//    // ===== Avvia la scrittura quando address_out diventa 0x01 =====
//    // appena il controller passa allo stato WRITE_WORD e presenta il primo indirizzo di byte
//    @(posedge clk);
//    while (address_out != 8'h01) @(posedge clk);
//    $display("[%0t] Avvio scrittura parola: address_out=0x01", $time);

// Scrivi 0xDEADBEEF LSB-first: EF, BE, AD, DE
	//send_byte(8'h00); // byte 0 (LSB)
    send_byte(8'hEF); // byte 0 (LSB)
    send_byte(8'hBE); // byte 1
    send_byte(8'hAD); // byte 2
    send_byte(8'hDE); // byte 3 (MSB)

    // lascia correre un attimo e stop
	#10
    $finish;
  end

  // Task: invia un byte al negedge del clock (come il tuo flusso)
  task send_byte(input [7:0] b);
    begin
      @(negedge clk);
      data_in = b;
    end
  endtask

  // Monitor
  initial begin
    $monitor("monitor : instr=%h | addr_out=%02h | mem_out=%h | mem_r=%b | mem_w=%b | ALU_out=%h",
             instruction_debug, address_out, memory_out_debug, mem_read, mem_write, debug_ALU_output);
  end

endmodule


/**
* I-TYPE INSTRUCTIONS
*/
`define GENERIC_R 6'd0
`define BEQ       6'd4
`define BNE       6'd5
`define ADDI      6'd8
`define ADDIU     6'd9
`define SLTI      6'd10
`define SLTIU     6'd11
`define ANDI      6'd12
`define ORI       6'd13
`define LUI       6'd15
`define LW        6'd35
`define SW        6'd43

/**
* JUMP-TYPE INSTRUCTIONS
*/
`define JUMP      6'd2
`define JAL       6'd3

/**
* ALIAS OUTPUT SIGNALS (11-bit bus)
*/
`define REG_DEST     output_signal[0]
`define JUMP_SIGNAL  output_signal[1]
`define BEQ_SIGNAL   output_signal[2]
`define BNE_SIGNAL   output_signal[3]
`define MEM_WRITE    output_signal[4]
`define MEM_READ     output_signal[5]
`define ALU_OP_0     output_signal[6]
`define ALU_OP_1     output_signal[7]
`define MEM_TO_REG   output_signal[8]
`define WRITE_REG    output_signal[9]
`define ALU_SRC    output_signal[10]
`define LUI_CALLED    output_signal[11]

module control_unit_module (
	input clk,
	input rst,
	input [5:0] control_signal,
	output reg [11:0] output_signal,
	output reg [3:0] output_i_op
	);
	
	always @(posedge clk) begin
		
		if(!rst) begin
			output_signal <= 12'd0;
			output_i_op <= 4'd0;
		end
			
		
			case (control_signal)
			
				`GENERIC_R: begin
					$display("--an R type has been called --");
						`REG_DEST     <= 1'b1;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b0;
						`ALU_OP_0     <= 1'b0;
						`ALU_OP_1     <= 1'b1;
						`MEM_TO_REG   <= 1'b0;
						`WRITE_REG    <= 1'b1;
						`ALU_SRC	<= 1'b0; 
						`LUI_CALLED <= 1'b0;
						output_i_op <= 4'd0;
					end
				
				`LW: begin
					$display("--LW has been called --");
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b1;
						`ALU_OP_0     <= 1'b0;
						`ALU_OP_1     <= 1'b0;
						`MEM_TO_REG   <= 1'b1;
						`WRITE_REG    <= 1'b1;
						`ALU_SRC	<= 1'b1;
						`LUI_CALLED <= 1'b0;
						output_i_op <= 4'd0;
					end
				
				`SW: begin
					$display("--SW has been called --");
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b1;
						`MEM_READ     <= 1'b0;
						`ALU_OP_0     <= 1'b0;
						`ALU_OP_1     <= 1'b0;
						`MEM_TO_REG   <= 1'b0;
						`WRITE_REG    <= 1'b0;
						`ALU_SRC	<= 1'b1;
						`LUI_CALLED <= 1'b0;
						output_i_op <= 4'd0;
					end
				
				`BEQ: begin
					$display("--BEQ has been called --");
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b1;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b0;
						`ALU_OP_0     <= 1'b0;
						`ALU_OP_1     <= 1'b1;
						`MEM_TO_REG   <= 1'b0;
						`WRITE_REG    <= 1'b0;
						`LUI_CALLED <= 1'b0;
						output_i_op <= 4'd0;
					end
				
				`BNE: begin
					$display("--BNE has been called --");
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b1;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b0;
						`ALU_OP_0     <= 1'b0;
						`ALU_OP_1     <= 1'b1;
						`MEM_TO_REG   <= 1'b0;
						`WRITE_REG    <= 1'b0;
						output_i_op <= 4'd0;
						`LUI_CALLED <= 1'b0;
						`ALU_SRC	<= 1'b1;
					end
				
				`ADDI,`ADDIU: begin
					$display("--ADDI has been called --");
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b0;
						`ALU_OP_0     <= 1'b1;
						`ALU_OP_1     <= 1'b1;
						`MEM_TO_REG   <= 1'b0;
						`WRITE_REG    <= 1'b1;
						output_i_op <= `ALU_ADD;
						`ALU_SRC	<= 1'b1;
					end
				
				`SLTI, `SLTIU: begin
					$display("--SLTI has been called --");
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b0;
						`ALU_OP_0     <= 1'b1;
						`ALU_OP_1     <= 1'b1;
						`MEM_TO_REG   <= 1'b0;
						`WRITE_REG    <= 1'b1;
						`LUI_CALLED <= 1'b0;
						output_i_op <= `ALU_SET_IF_LESS_THAN;
						`ALU_SRC	<= 1'b1;
					end
				
				`ANDI: begin
					$display("--ANDI has been called --");
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b0;
						`ALU_OP_0     <= 1'b1;
						`ALU_OP_1     <= 1'b1;
						`MEM_TO_REG   <= 1'b0;
						`WRITE_REG    <= 1'b1;
						output_i_op <= `ALU_AND;
						`ALU_SRC	<= 1'b1;
						`LUI_CALLED <= 1'b0;
					end
				`ORI: begin
					$display("--ORI has been called --");
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b0;
						`ALU_OP_0     <= 1'b1;
						`ALU_OP_1     <= 1'b1;
						`MEM_TO_REG   <= 1'b0;
						`WRITE_REG    <= 1'b1;
						output_i_op <= `ALU_OR;
						`LUI_CALLED <= 1'b0;
					end		
				`LUI: begin
					$display("--LUI has been called --");
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b0;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b1;
						`ALU_OP_0     <= 1'b0;
						`ALU_OP_1     <= 1'b0;
						`MEM_TO_REG   <= 1'b1;
						`WRITE_REG    <= 1'b1;
						`ALU_SRC	<= 1'b1;
						`LUI_CALLED <= 1'b1;
						output_i_op <= 4'd0;
					end	
					`JUMP, `JAL: begin
						`REG_DEST     <= 1'b0;
						`JUMP_SIGNAL  <= 1'b1;
						`BEQ_SIGNAL   <= 1'b0;
						`BNE_SIGNAL   <= 1'b0;
						`MEM_WRITE    <= 1'b0;
						`MEM_READ     <= 1'b0;
						`ALU_OP_0     <= 1'b0;
						`ALU_OP_1     <= 1'b0;
						`MEM_TO_REG   <= 1'b0;
						`WRITE_REG    <= 1'b0;
						output_i_op <= 4'd0;
						`ALU_SRC	<= 1'b0;
						`LUI_CALLED <= 1'b0;
					end
				default: begin
						output_signal <= 11'b0; // disattiva tutto per sicurezza
					end
			endcase
		end
	
endmodule




`define ALU_AND               4'b0000
`define ALU_OR                4'b0001
`define ALU_ADD               4'b0010
`define ALU_SUB               4'b0011
`define ALU_SET_IF_LESS_THAN  4'b0100
`define ALU_NOR               4'b0101
`define ALU_SLL               4'b1000 //ALU_INPUT[0] identifies the shift opration 
`define ALU_SRL               4'b1001

module ALU_controller_module (
    input clk,
    input [1:0] ALU_OP,
	input [3:0] ALU_I_OP,
    input [5:0] func_field,
    output reg [3:0] ALU_input
);

always @(*) begin
		$display("--ALU_OP_CALLED:	%d", ALU_OP); 
        case (ALU_OP)
            2'b00: ALU_input = `ALU_ADD;  // lw, sw
            2'b01: ALU_input = `ALU_SUB;  // beq, bne 
			2'b11: ALU_input = ALU_I_OP; 
            2'b10: begin // R-type instructions
                case (func_field)
                    6'b100000: ALU_input = `ALU_ADD; // add
                    6'b100010: ALU_input = `ALU_SUB; // sub
                    6'b100100: ALU_input = `ALU_AND; // and
                    6'b100101: ALU_input = `ALU_OR;  // or
                    6'b101010: ALU_input = `ALU_SET_IF_LESS_THAN; // slt
                    6'b100111: ALU_input = `ALU_NOR; // nor
					6'b000000: ALU_input = `ALU_SLL; //SLL
					6'b000001: ALU_input = `ALU_SRL; //SRL
                    default:   ALU_input = 4'b0000; // NOP o undefined
                endcase
            end
            default: ALU_input = 4'b0000; // default safe value
        endcase
    end

endmodule
				
			
	
	
	

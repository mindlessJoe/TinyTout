module register_port_module (
	input clk,
	input rst,
	input write_enable,
	input [4:0] read_address_0,
	input [4:0] read_address_1,
	input [4:0] write_address,
	input [31:0] data_to_write,
	output reg [31:0] data_read_0,
	output reg [31:0] data_read_1
	);
	
	reg [31:0] register_file [0:31]; // 32 registri da 32 bit
	integer j;
	
	always @(negedge clk) begin
			if (!rst) begin
					for (j = 0; j < 32; j = j + 1) begin
							register_file[j] <= 32'b0;
						end
				end
			else begin
					if (write_enable && (write_address != 0))begin

						`ifndef SYNTHESIS
							$display("A wirting is request: adderss: %d 	word: %h", write_address, data_to_write);
						`endif 
							register_file[write_address] <= data_to_write;
						end
				end	
			//        data_read_0 = register_file[read_address_0];
			//        data_read_1 = register_file[read_address_1];
		end
	
	always @(*) begin
			data_read_0 = register_file[read_address_0];
			data_read_1 = register_file[read_address_1];
		end
	
endmodule

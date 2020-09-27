module DUAL_PORT_RAM #(
	parameter DATA_RAM_WIDTH = 8, // DATA WIDTH
	parameter ADDR_WIDTH = 8  // ADRESS WIDTH
) (
	input        [ADDR_WIDTH-1:0] 		address_0, 		// ADDRESS PORT 0
	input								chip_enable_0,  // CHIP ENABLE PORT 0
	input 				 				write_read_0, 	// WRITE OR READ PORT 0
	input  logic [DATA_RAM_WIDTH-1:0] 	data_0,  		// DATA PORT 0
	input 	     [ADDR_WIDTH-1:0]  		address_1, 		// ADDRESS PORT 1
	input								chip_enable_1,  // CHIP ENABLE PORT 1
	input 				 				write_read_1,   // WRITE OR READ PORT 1
	output logic [DATA_RAM_WIDTH-1:0] 	data_1,          // DATA PORT 1
	input full
);

	localparam RAM_DEPTH = 1 << ADDR_WIDTH; 				 // RAM depth = 2^addr_width
	logic      [DATA_RAM_WIDTH-1:0] 	memory[RAM_DEPTH-1:0];
	logic 	   [DATA_RAM_WIDTH-1:0] 	data_1_out;
	logic parallel;
	logic mutex_lock ;

//  ███╗   ███╗███████╗███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗    ██╗    ██╗██████╗ ██╗████████╗███████╗
//  ████╗ ████║██╔════╝████╗ ████║██╔═══██╗██╔══██╗╚██╗ ██╔╝    ██║    ██║██╔══██╗██║╚══██╔══╝██╔════╝
//  ██╔████╔██║█████╗  ██╔████╔██║██║   ██║██████╔╝ ╚████╔╝     ██║ █╗ ██║██████╔╝██║   ██║   █████╗
//  ██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║██║   ██║██╔══██╗  ╚██╔╝      ██║███╗██║██╔══██╗██║   ██║   ██╔══╝
//  ██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║╚██████╔╝██║  ██║   ██║       ╚███╔███╔╝██║  ██║██║   ██║   ███████╗
//  ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝        ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝   ╚═╝   ╚══════╝

	assign parallel = chip_enable_0 && chip_enable_1;
	always
		begin
			if (!parallel) begin
				if (chip_enable_0 && write_read_0) begin
					memory[address_0] = data_0;
				end
			end
			else begin
				if ((mutex_lock && !full) || (full && !mutex_lock) ) begin
					if (chip_enable_0 && write_read_0) begin
						memory[address_0] = data_0;
						mutex_lock = ~mutex_lock;
					end
				end
			end


		end


//  ███╗   ███╗███████╗███╗   ███╗ ██████╗ ██████╗ ██╗   ██╗    ██████╗ ███████╗ █████╗ ██████╗
//  ████╗ ████║██╔════╝████╗ ████║██╔═══██╗██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝██╔══██╗██╔══██╗
//  ██╔████╔██║█████╗  ██╔████╔██║██║   ██║██████╔╝ ╚████╔╝     ██████╔╝█████╗  ███████║██║  ██║
//  ██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║██║   ██║██╔══██╗  ╚██╔╝      ██╔══██╗██╔══╝  ██╔══██║██║  ██║
//  ██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║╚██████╔╝██║  ██║   ██║       ██║  ██║███████╗██║  ██║██████╔╝
//  ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝


	always @(address_1,chip_enable_1,write_read_1,address_0)
		begin
			if (!parallel) begin
				if (chip_enable_1 && !write_read_1) begin
					data_1_out = memory[address_1];
				end
			end
			else begin
				if ((!mutex_lock && !full) || (full && mutex_lock)) begin
					if (chip_enable_1 && !write_read_1) begin
						data_1_out = memory[address_1];
						mutex_lock = ~mutex_lock;
					end
				end
			end

		end


	always_comb
		begin
			data_1 = data_1_out;
		end



endmodule : DUAL_PORT_RAM

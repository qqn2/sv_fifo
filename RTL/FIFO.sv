module FIFO #(
	parameter DATA_WIDTH = 32, // Self explanatory parameters
	parameter FIFO_DEPTH = 4
) (
	input 									clk,
	input									rst_n,
	input 		 [DATA_WIDTH:0] 			push_data_i, 			    // Data input
	input 									push_valid_i,			    // High if stimuli wants to send data
	output logic							push_grant_o,			    // Indicates that fifo can accept data
	input 									pop_grant_i, 			    // Indicats that receiver wants data
	output logic [DATA_WIDTH:0] 			pop_data_o, 			    // Data output
	output logic							pop_valid_o				    // High if fifo has data to send
);

	logic 		[$clog2(FIFO_DEPTH)-1:0] 	count_write;					// Pointer write updated at posedge for FIFO
	logic 		[$clog2(FIFO_DEPTH)-1:0] 	next_count_write;				// Pointer write for FIFO
	logic 		[$clog2(FIFO_DEPTH)-1:0] 	count_read;						// Pointer read updated at posedge for FIFO
	logic 		[$clog2(FIFO_DEPTH)-1:0] 	next_count_read;				// Pointer read for FIFO
	logic 		[$clog2(FIFO_DEPTH):0] 		count_fifo;					    // Count of elements updated at posedge for FIFO
	logic 		[$clog2(FIFO_DEPTH):0] 		next_count_fifo;		        // Count of elements for FIFO

	wire 		[DATA_WIDTH:0]	 			data_ram;    	  		    	// Output data from RAM module
	logic 					 				pop_request;			    	// High when we have a pop request

//  ██████╗ ██████╗     ██████╗  █████╗ ███╗   ███╗
//  ██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗████╗ ████║
//  ██║  ██║██████╔╝    ██████╔╝███████║██╔████╔██║
//  ██║  ██║██╔═══╝     ██╔══██╗██╔══██║██║╚██╔╝██║
//  ██████╔╝██║         ██║  ██║██║  ██║██║ ╚═╝ ██║
//  ╚═════╝ ╚═╝         ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝

	DUAL_PORT_RAM
		#(
			.DATA_RAM_WIDTH(DATA_WIDTH+1),
			.ADDR_WIDTH($clog2(FIFO_DEPTH))
		)
		my_ram
			(
				.address_0(count_write),
				.chip_enable_0(push_request),
				.write_read_0(1'b1), 									// I will always write from the push side
				.data_0(push_data_i),
				.address_1(count_read),
				.chip_enable_1(pop_request),
				.write_read_1(1'b0),									// I will always read from the pop side
				.data_1(data_ram)

			);


	assign push_grant_o = !(count_fifo == FIFO_DEPTH);								// 1 : FIFO IS READY TO PUSH
	assign pop_valid_o  = !(count_fifo == 0 ) || push_valid_i;						// 1 : FIFO IS READY TO POP
	assign pop_request  = pop_valid_o  && pop_grant_i;  							// 1 : RECEIVER IS READY & FIFO IS READY
	assign push_request = push_valid_i && push_grant_o;								// 1 : SENDER IS READY   & FIFO IS READY







//  ██████╗  ██████╗ ██████╗
//  ██╔══██╗██╔═══██╗██╔══██╗
//  ██████╔╝██║   ██║██████╔╝
//  ██╔═══╝ ██║   ██║██╔═══╝
//  ██║     ╚██████╔╝██║
//  ╚═╝      ╚═════╝ ╚═╝


	always_comb
		if(~rst_n)
			for (int i = 0; i < FIFO_DEPTH; i++) begin
				my_ram.memory[i]=0;
			end


	always_comb
		begin
			pop_data_o = data_ram;
		end

//  ██████╗  ██████╗ ██╗███╗   ██╗████████╗███████╗██████╗
//  ██╔══██╗██╔═══██╗██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
//  ██████╔╝██║   ██║██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
//  ██╔═══╝ ██║   ██║██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
//  ██║     ╚██████╔╝██║██║ ╚████║   ██║   ███████╗██║  ██║
//  ╚═╝      ╚═════╝ ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝


	always_ff @(posedge clk or negedge rst_n) begin : proc_clk
		if(~rst_n || (push_request &&  (count_write == FIFO_DEPTH - 1 )) ) begin
			count_write <= 0;
		end else if  (push_request && !(count_write == FIFO_DEPTH - 1 )  ) begin
			count_write <= count_write + 1 ;
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_clk_rd
		if(~rst_n || (pop_request && (count_read == FIFO_DEPTH - 1)) ) begin
			count_read <= 0;
		end else if  (pop_request && !(count_read == FIFO_DEPTH - 1) ) begin
			count_read <= count_read + 1 ;
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_clk_fifo
		if(~rst_n) begin
			count_fifo <= 0;
		end else if (push_request && pop_request)
			count_fifo = count_fifo;
		else if (push_request && !pop_request) begin
			count_fifo = count_fifo + 1;
		end
		else if (pop_request && !push_request)
			count_fifo = count_fifo - 1;
	end










endmodule : FIFO










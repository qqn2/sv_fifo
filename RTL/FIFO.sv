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

	logic 		[$clog2(FIFO_DEPTH)-1:0] 	ptr_write;					// Pointer write updated at posedge for FIFO
	logic 		[$clog2(FIFO_DEPTH)-1:0] 	ptr_read;					// Pointer read updated at posedge for FIFO

	wire 		[DATA_WIDTH:0]	 			data_ram;    	  		    // Output data from RAM module
	logic 					 				pop_request;			    // High when we have a pop request
	logic 									push_request;
	logic 									flag;
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
				.address_0(ptr_write),
				.chip_enable_0(push_request),
				.write_read_0(1'b1), 									// I will always write from the push side
				.data_0(push_data_i),
				.address_1(ptr_read),
				.chip_enable_1(pop_valid_o),
				.write_read_1(1'b0),									// I will always read from the pop side
				.data_1(data_ram),
				.rst_n(rst_n),
				.clk(clk),
				.full(!push_grant_o)
			);


	assign push_grant_o = !( flag &&  (ptr_read == ptr_write) );					// 1 : FIFO IS READY TO PUSH
	assign pop_valid_o  = !( !flag && (ptr_write == ptr_read) );					// 1 : FIFO IS READY TO POP
	assign pop_request  = pop_valid_o  && pop_grant_i;  							// 1 : RECEIVER IS READY & FIFO IS READY
	assign push_request = push_valid_i && push_grant_o;								// 1 : SENDER IS READY   & FIFO IS READY







//  ██████╗  ██████╗ ██████╗
//  ██╔══██╗██╔═══██╗██╔══██╗
//  ██████╔╝██║   ██║██████╔╝
//  ██╔═══╝ ██║   ██║██╔═══╝
//  ██║     ╚██████╔╝██║
//  ╚═╝      ╚═════╝ ╚═╝


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
		if(~rst_n || (push_request &&  (ptr_write == FIFO_DEPTH - 1 )) ) begin
			ptr_write <= 0;
		end else if  (push_request && !(ptr_write == FIFO_DEPTH - 1 )  ) begin
			ptr_write <= ptr_write + 1 ;
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_clk_rd
		if(~rst_n || (pop_request && (ptr_read == FIFO_DEPTH - 1)) ) begin
			ptr_read <= 0;
		end else if  (pop_request && !(ptr_read == FIFO_DEPTH - 1) ) begin
			ptr_read <= ptr_read + 1 ;
		end
	end

	always_ff @(posedge clk or negedge rst_n) begin : proc_flag
		if(~rst_n) begin
			flag <= 0;
		end else if ((push_request &&  (ptr_write == FIFO_DEPTH - 1 ))) begin
			flag <= 1;
		end else if (pop_request && !(ptr_read == FIFO_DEPTH - 1)) begin 
			flag <= 0;
		end
	end








endmodule : FIFO










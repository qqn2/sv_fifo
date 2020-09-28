module parity_encoder #(
	parameter EVEN_ODD= 0 , // EVEN(0) or ODD(1)
	parameter SELECT_PARITY_BIT= 0, // MSB(1) or LSB(0)
	parameter DATA_WIDTH = 8
) (
	input [DATA_WIDTH:0]			data_in,
	input 							pop_valid_fifo,
	input 							pop_grant_receiver,
	output 		logic				pop_valid_receiver,
	output 		logic				pop_grant_fifo
);


	logic 							parity_bit=0; 				// Parity_bit
	logic							Valid_result;

	always_comb begin : Get_parity_and_get_result

		if (SELECT_PARITY_BIT)
			parity_bit = data_in[DATA_WIDTH];
		else
			parity_bit = data_in[0];

		Valid_result = (parity_bit == EVEN_ODD); 				// Valid if 1, otherwise 0
	end


	always_comb begin
			pop_valid_receiver = (Valid_result) ? pop_valid_fifo : 0;
			pop_grant_fifo     = (Valid_result) ? pop_grant_receiver : 1;
		end









endmodule : parity_encoder
`timescale 1ns / 1ps


module tb #(
	parameter DATA_WIDTH = 32, // Self explanatory parameters
	parameter FIFO_DEPTH = 4,
	parameter EVEN_ODD   = 0,
	parameter PARITY_BIT = 1
);

	localparam integer 					HALF_T_CLK=5;
	logic 								clk_test;
	logic								rst_n_test;
	logic 		 [DATA_WIDTH:0] 		push_data_i_test; 	// Data input
	logic 								push_valid_i_test;	// High if stimuli has data to send
	wire 								push_grant_o_test;	// Indicates that fifo can accept data
	logic 								pop_grant_i_test; 	// Indicats that fifo can send data
	wire		 [DATA_WIDTH:0] 		pop_data_o_test; 	// Data output
	wire 								pop_valid_o_test;	// High if fifo has data to send
	logic[DATA_WIDTH:0] temp_memory[(100*FIFO_DEPTH):0];	// Temporary array with enough elements for the test
	logic random_trigger_pgi = 0;							// random value to implement random duty cycle  for pop_gi
	logic random_trigger_pvi = 0;							// random value to implement random duty cycle for push_vi
	int i = 0;												// Numbers of elements that we pushed successfully
	int j = 0;												// Numbers of elements that we popped successfully
	logic[DATA_WIDTH:0]  value_ = 0;
	top
		#(
			.DATA_WIDTH(DATA_WIDTH),
			.FIFO_DEPTH(FIFO_DEPTH),
			.EVEN_ODD(EVEN_ODD),
			.PARITY_BIT(PARITY_BIT)
		)
		DUT
			(

				.clk(clk_test),
				.rst_n(rst_n_test),
				.push_data_i(push_data_i_test),
				.push_valid_i(push_valid_i_test),
				.push_grant_o(push_grant_o_test),
				.pop_grant_i(pop_grant_i_test),
				.pop_data_o(pop_data_o_test),
				.pop_valid_o(pop_valid_o_test)
			);



	function Check_if_fifo_is_reset();
		begin
			if (DUT.fifo_i.count_read || DUT.fifo_i.count_write || DUT.fifo_i.count_fifo)
				return 0;
			else
				return 1;
		end
	endfunction



	task ASYNC_CLEAR (input integer delay);
		begin
			rst_n_test = 0;
			#delay
			CHECK_RESET : assert (Check_if_fifo_is_reset())
				begin
					$display ("Clear is working at time %d", $time);
				end else begin
					$display("Clear not working found at %d,",$time);
				end
			rst_n_test = 1;
		end
	endtask 


	task push_value(input logic[DATA_WIDTH:0] val, input integer N); // Todo : la tache implique un delay d'un clk cycle a chaque fois peut etre  a modifié
		logic[DATA_WIDTH:0] value_to_be_pushed;
		@(negedge clk_test)
		$display("PUSH_VALUE_CALLED %d",$time);
		begin
			repeat (N)
				begin
					if (val == 0) 
						value_to_be_pushed = $urandom();
					else 		 
					    value_to_be_pushed = val;
					push_valid_i_test = 1;
					push_data_i_test = value_to_be_pushed;
					if (push_grant_o_test)
						begin
							temp_memory[i] = value_to_be_pushed;
							$display("Push successfully temp_memory[%d] == %d", i, temp_memory[i]);
							i++;
						end
					else
						begin	
							assert(!check_if_overflow())
								$display("Good : No overflow occured %d",$time);
							else
								$display("Error underflow at time %d: ", $time);
						end
					#(2*HALF_T_CLK);
					push_valid_i_test = 0;
				end
		end
	endtask



	task  pop_value(input integer N);
		begin
			//count_pop++;
			$display("POP_VALUE_CALLED  %d",$time);
			#(HALF_T_CLK/5) pop_grant_i_test = 1;
			begin
				@(posedge clk_test)
					begin
						repeat(N)
							begin
								if(pop_valid_o_test == 1) begin
									assert(temp_memory[j] == pop_data_o_test)
										$display("Good at time %d: temp_memory[%d] == %d whereas pop_data_o == %d", $time, j, temp_memory[j], pop_data_o_test);
									else
										$display("Error at time %d: temp_memory[%d] == %d whereas pop_data_o == %d", $time, j, temp_memory[j], pop_data_o_test);
									j++;
								end
								else begin
									assert(!check_if_underflow())
										$display("Good : No underflow occured %d",$time);
									else
										$display("Error at time %d : underflow", $time);
									#(2*HALF_T_CLK)  $display("");
								end
							end
					end
				pop_grant_i_test = 0;
			end
		end
	endtask


	function check_if_overflow();
		begin
			return ((i - j) > FIFO_DEPTH); //elements_in_fifo = i - j;
		end
	endfunction : check_if_overflow

	function check_if_underflow();
		begin
			return (j > i);
		end
	endfunction : check_if_underflow




	initial begin
		clk_test = 1;
		push_valid_i_test=0;
		pop_grant_i_test=0;
		//TEST 1 : ASYNC_CLEAR
		ASYNC_CLEAR(HALF_T_CLK);
		/*
		`ifdef RECREATE_WAVEFORM_FROM_PDF
		#(HALF_T_CLK)
		#(HALF_T_CLK/5)
		push_valid_i_test = 1;
		push_value(8);
		push_value(10); 			//Cycle 3
		push_value(12); 			//Cycle 4
		push_value(14); 			//Cycle 5
		pop_grant_i_test = 1;
		push_value(16); 			//Cycle 6
		#(2*HALF_T_CLK)
		push_data_i_test = 'hX; 	//Cycle 7
		push_valid_i_test = 0;
		pop_grant_i_test = 0;
		#(2*HALF_T_CLK)
		pop_grant_i_test = 1;
		`endif

		// TEST 2 : OVERFLOW
		$display("Starting test 2");
		push_value(0,6);
		pop_value(4);
		// TEST 3 : UNDERFLOW
		$display("Starting test 3");
		pop_value(4);
		*/
		// TEST 4 : RANDOM NUMBERS OF POPS, RANDOM NUMBER OF PUSH

		$display("Starting test 4");
		repeat(30)
			begin
				value_ = value_+ 2 ;
				random_trigger_pgi = $urandom_range(0,1);
				//if(random_trigger_pgi)
				push_value(value_,1);
				pop_value(1);
			end




	end


	always #HALF_T_CLK clk_test = ~clk_test;
	//always @(posedge clk_test) #(HALF_T_CLK/5) push_data_i_test = $urandom();
	//always @(posedge clk_test) @(DUT.fifo_i.count == FIFO_DEPTH - 1) pop_grant_i_test = 1;







endmodule : tb


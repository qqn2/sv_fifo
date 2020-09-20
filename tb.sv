`timescale 1ns / 1ps


module tb #(
	parameter DATA_WIDTH = 32, // Self explanatory parameters
	parameter FIFO_DEPTH = 4,
	parameter EVEN_ODD   = 0,
	parameter PARITY_BIT = 0
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
	logic[DATA_WIDTH:0]  value_ = 0;						// Variable I might use to input data
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


//  ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
//  ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
//  █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
//  ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
//  ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
//  ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝



/*
	Returns if parity checker changed pop_valid_o
	1 : Operation successful
	0 : Operation unsuccesful
*/
function Check_if_parity_check();
	begin
		return ( pop_valid_o_test == 0 && DUT.fifo_i.pop_grant_i == 1);
	end
endfunction

/*
/*
	Returns if fifo is reset or not 
	1 : Reset successful
	0 : Reset unsuccesful
*/
function Check_if_fifo_is_reset();
	begin
		return !(DUT.fifo_i.count_read || DUT.fifo_i.count_write || DUT.fifo_i.count_fifo);		
	end
endfunction

/*
	Returns if fifo was OVERFLOWN by comparing the numbers of successful pushs and pops by the tasks push_value and pop_value
	NB : Pushing & popping values outside of the tasks will render this function useless
	1 : Overflow happened
	0 : Overflow did not happen
*/
function check_if_overflow();
	begin
		return ((i - j) > FIFO_DEPTH); //elements_in_fifo = i - j;
	end
endfunction : check_if_overflow

/*
	Returns if fifo was UNDERFLOWN by comparing the numbers of successful pushs and pops by the tasks push_value and pop_value
	NB : Pushing & popping values outside of the tasks will render this function useless
	1 : Underflow happened
	0 : Underflow did not happen
*/
function check_if_underflow();
	begin
		return (j > i);
	end
endfunction : check_if_underflow


//  ████████╗ █████╗ ███████╗██╗  ██╗███████╗
//  ╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝██╔════╝
//     ██║   ███████║███████╗█████╔╝ ███████╗
//     ██║   ██╔══██║╚════██║██╔═██╗ ╚════██║
//     ██║   ██║  ██║███████║██║  ██╗███████║
//     ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝




/*	Resets the fifo
	input delay : time of the pulse for rst_n

*/

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


/*	Pushes value inside the fifo
	input val : value to be pushed, choose 0 to insert a 32b random value.
	input N : numbers of repetitions, can range from 1 to max integer value.
	input bandwith : duty cycle of the push_valid_i signal, can range from 0 to 100

*/

task automatic push_value(input logic[DATA_WIDTH:0] val, input integer N,input integer bandwidth); 
	begin
		logic [DATA_WIDTH:0] value_to_be_pushed;
		repeat(N)
		begin 
			@(negedge clk_test)
			begin
				$display("PUSH_VALUE_CALLED %d",$time);
				if (val == 0) 
					value_to_be_pushed = $urandom();
				else 		 
					value_to_be_pushed = val;
				push_valid_i_test = 1;
				push_data_i_test = value_to_be_pushed;
		/*		#
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
		*/		#(HALF_T_CLK+(bandwidth*HALF_T_CLK/100)) push_valid_i_test = 0;
			end
		end
	end
endtask

/*	Pops value outside the fifo
	input N : numbers of repetitions, can range from 1 to max integer value.
	input bandwith : duty cycle of the pop_valid_i signal, can range from 1 to 100

*/


task pop_value(input integer N,input integer bandwidth);
	begin
		repeat(N)
			begin 
				@(negedge clk_test)
				#(HALF_T_CLK/5) $display("POP_VALUE_CALLED  %d",$time);
				pop_grant_i_test = 1;
				#HALF_T_CLK
		/*			if(pop_valid_o_test == 1) begin
						assert(temp_memory[j] == pop_data_o_test)
							$display("Pop successful %d: temp_memory[%d] == %d ", $time, j, temp_memory[j]);
						else begin
							$display("Error at time %d: temp_memory[%d] == %d whereas pop_data_o == %d", $time, j, temp_memory[j], pop_data_o_test);
							end
							j++;
					end
					else if (pop_valid_o_test == ~DUT.fifo_i.pop_valid_o) begin
						assert(Check_if_parity_check())
							$display("Good : Corrupt data thrown away %d",$time);
						else
							$display("Error : Corrupt data not handled %d", $time);
						j++;
					end
					else begin
						assert(!check_if_underflow())
							$display("Good : No underflow occured %d",$time);
						else
							$display("Error at time %d : underflow", $time);
					end
		*/		#(bandwidth*HALF_T_CLK/100) pop_grant_i_test = 0;
			end
	end
endtask




//  ████████╗███████╗███████╗████████╗███████╗
//  ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██╔════╝
//     ██║   █████╗  ███████╗   ██║   ███████╗
//     ██║   ██╔══╝  ╚════██║   ██║   ╚════██║
//     ██║   ███████╗███████║   ██║   ███████║
//     ╚═╝   ╚══════╝╚══════╝   ╚═╝   ╚══════╝


	initial begin		
		clk_test = 1;
		push_valid_i_test=0;
		pop_grant_i_test=0;
		push_data_i_test=0;

		// Async Clear
		ASYNC_CLEAR(HALF_T_CLK/2);
		// TEST 1 : OVERFLOW
		$display("Starting test 1");
		push_value(0,FIFO_DEPTH+2,50);
		// TEST 2 : UNDERFLOW
		$display("Starting test 2");
		pop_value(FIFO_DEPTH+2,50);
	
		$display("Starting test 3"); 
		// TEST 3 : PARALLEL PUSH POP = Duty cycle of pop & push50
		repeat(30)
			begin
				value_ = value_ + 3;
				fork
					begin
				push_value(value_,1,25);
					end
					begin
				pop_value(1,25);
					end
				join
			end
		// TEST 4 :FULL PUSH HALF POP 
		$display("Starting test 4");
		repeat(30)
			begin					
			fork
				begin 
					push_value(0,1,100);
				end
				begin 
					pop_value(1,1);
				end
			join_any
			end
		// TEST 5 : 2 PUSH 1 POP
		repeat(30)
			begin					
			fork
				begin 
					push_value(0,1,100);
				end
				begin 
					pop_value(1,1);
				end
			join_any
			end
	end


	always 
	begin
		#HALF_T_CLK clk_test = ~clk_test;
	end
	// PUSH VERIFICATION
	always
	begin
		@(posedge push_valid_i_test)
			@(posedge clk_test)
				if (push_grant_o_test)
					begin
						temp_memory[i] = push_data_i_test;
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
	end
 	// POP VERIFICATION
 	always
	begin
		@(posedge pop_grant_i_test)
		/*	for (int i = 0; i < FIFO_DEPTH; i++) begin
				$display("Helping you with debug process memory[%d]=%d ", i ,DUT.fifo_i.my_ram.memory[i] );
			end
		*/	@(posedge clk_test)
				wait(i > j )
				if(pop_valid_o_test == 1) begin
						assert(temp_memory[j] == pop_data_o_test)
							$display("Pop successful %d: temp_memory[%d] == %d ", $time, j, temp_memory[j]);
						else begin
							$display("Error at time %d: temp_memory[%d] == %d whereas pop_data_o == %d", $time, j, temp_memory[j], pop_data_o_test);
							end
							j++;
					end
					else if (pop_valid_o_test == ~DUT.fifo_i.pop_valid_o) begin
						assert(Check_if_parity_check())
							$display("Good : Corrupt data thrown away %d",$time);
						else
							$display("Error : Corrupt data not handled %d", $time);
						j++;
					end
					else begin
						assert(!check_if_underflow())
							$display("Good : No underflow occured %d",$time);
						else
							$display("Error at time %d : underflow", $time);
					end
	end






endmodule : tb


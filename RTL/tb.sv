`timescale 1ns / 1ps


module tb #(
    parameter DATA_WIDTH = 32, // Self explanatory parameters
    parameter FIFO_DEPTH = 4,
    parameter EVEN_ODD   = 0,
    parameter PARITY_BIT = 0
);

    localparam integer                  HALF_T_CLK=5;
    logic                               clk_test;
    logic                               rst_n_test;
    logic        [DATA_WIDTH:0]         data_i_test;        // Data input
    logic                               valid_i_test;       // High if stimuli has data to send
    wire                                grant_o_test;       // Indicates that fifo can accept data
    logic                               grant_i_test;       // Indicats that fifo can send data
    wire         [DATA_WIDTH:0]         data_o_test;        // Data output
    wire                                valid_o_test;       // High if fifo has data to send
    logic[DATA_WIDTH:0] temp_memory[$];                     // Queue array for the test
    int c = 0;                                              // Numbers of elements that we pushed successfully
    int j = 0;                                              // Numbers of elements that we popped successfully
    logic[DATA_WIDTH:0]  value_ = 0;                        // Variable I might use to input data
    logic done_pushing;                                     // Event I might use when doing parallel forks

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
                .data_i(data_i_test),
                .valid_i(valid_i_test),
                .grant_o(grant_o_test),
                .grant_i(grant_i_test),
                .data_o(data_o_test),
                .valid_o(valid_o_test)
            );


// CLOCKING

    always 
    begin
        #HALF_T_CLK clk_test = ~clk_test;
    end

    default clocking cb @(posedge clk_test);
    endclocking 

    clocking cb_n @(negedge clk_test);
    endclocking 



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
        return ( valid_o_test == 0 && DUT.fifo_i.pop_grant_i == 1);
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
        return !(DUT.fifo_i.ptr_read || DUT.fifo_i.ptr_write || DUT.fifo_i.flag);     
    end
endfunction

/*
    Returns if fifo was OVERFLOWN by comparing the numbers of successful pushs and pops by the transmitter and receiver tasks
    NB : Pushing & popping values outside of the tasks will render this function useless
    1 : Overflow happened
    0 : Overflow did not happen
*/
function check_if_overflow();
    begin
        return ((c - j) > FIFO_DEPTH); //elements_in_fifo = c - j;
    end
endfunction : check_if_overflow

/*
    Returns if fifo was UNDERFLOWN by comparing the numbers of successful pushs and pops by the transmitter and receiver tasks
    NB : Pushing & popping values outside of the tasks will render this function useless
    1 : Underflow happened
    0 : Underflow did not happen
*/
function check_if_underflow();
    begin
        return (j > c);
    end
endfunction : check_if_underflow


//  ████████╗ █████╗ ███████╗██╗  ██╗███████╗
//  ╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝██╔════╝
//     ██║   ███████║███████╗█████╔╝ ███████╗
//     ██║   ██╔══██║╚════██║██╔═██╗ ╚════██║
//     ██║   ██║  ██║███████║██║  ██╗███████║
//     ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝


/*  Resets the fifo
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




/*  Pushes value inside the fifo if FIFO READY
    input val : value to be pushed, choose 0 to insert a 32b random value.
    input N : numbers of repetitions, can range from 1 to max integer value.
    input bandwith : duty cycle of the push_valid_i signal, can range from 0 to 100
    input corrupt : Corrupts RANDOM value if high, 

*/

task automatic good_transmitter(input logic[DATA_WIDTH:0] val, input integer N,input integer bandwidth, input logic corrupt); 
    begin
        logic [DATA_WIDTH:0] value_to_be_pushed;
        repeat(N)
        begin 
            @(negedge clk_test)
            begin
                $display("good_transmitter_CALLED %d",$time);
                if (grant_o_test) begin
                        valid_i_test = 1;
                        if (val == 0) begin 
                            value_to_be_pushed = $urandom();
                            if ( ( (value_to_be_pushed % 2 == 1) && !corrupt )     ||  ( !(value_to_be_pushed % 2 == 1) && corrupt )    )
                                value_to_be_pushed--;
                                    end
                        else         
                            value_to_be_pushed = val;
                        for (int i = 0; i < FIFO_DEPTH; i++) begin
                        $display("Helping you with debug process memory[%d]=%d ", i ,DUT.fifo_i.my_ram.memory[i] );
                        end
                        data_i_test = value_to_be_pushed;
                        #(HALF_T_CLK+(bandwidth*HALF_T_CLK/100)) valid_i_test = 0;
                        for (int i = 0; i < FIFO_DEPTH; i++) begin
                        $display("Helping you with debug process memory[%d]=%d ", i ,DUT.fifo_i.my_ram.memory[i] );
                        end
                end else 
                        $display("FIFO NOT READY TO RECEIVE, NO DATA SENT");
            end
        end
    end
endtask

/*  Pops value outside the fifo  if FIFO READY
    input N : numbers of repetitions, can range from 1 to max integer value.
    input bandwith : duty cycle of the pop_valid_i signal, can range from 1 to 100

*/


task good_receiver(input integer N,input integer bandwidth);
    begin
        repeat(N)
            begin 
                @(cb_n)
                $display("good_receiver_CALLED  %d",$time);
                if (valid_o_test) begin
                    grant_i_test = 1;
                    #(HALF_T_CLK+(bandwidth*HALF_T_CLK/100)) grant_i_test = 0;
                end else
                 $display("FIFO NOT READY, NO REQUEST SENT %d",$time);
            end
    end
endtask






/*  Pushes value inside the fifo without checking if FIFO READY
    input val : value to be pushed, choose 0 to insert a 32b random value.
    input N : numbers of repetitions, can range from 1 to max integer value.
    input bandwith : duty cycle of the push_valid_i signal, can range from 0 to 100
    input corrupt : Corrupts RANDOM value if high, 

*/

task automatic bad_transmitter(input logic[DATA_WIDTH:0] val, input integer N,input integer bandwidth, input logic corrupt); 
    begin
        logic [DATA_WIDTH:0] value_to_be_pushed;
        repeat(N)
        begin 
            @(negedge clk_test)
            begin
                $display("bad_transmitter_CALLED %d",$time);
                if (val == 0) begin 
                    value_to_be_pushed = $urandom();
                    if ( ( (value_to_be_pushed % 2 == 1) && !corrupt )     ||  ( !(value_to_be_pushed % 2 == 1) && corrupt )    )
                        value_to_be_pushed--;
                end
                else         
                    value_to_be_pushed = val;
                for (int i = 0; i < FIFO_DEPTH; i++) begin
                $display("Helping you with debug process memory[%d]=%d ", i ,DUT.fifo_i.my_ram.memory[i] );
                end
                valid_i_test = 1;
                data_i_test = value_to_be_pushed;
                #(HALF_T_CLK+(bandwidth*HALF_T_CLK/100)) valid_i_test = 0;
                for (int i = 0; i < FIFO_DEPTH; i++) begin
                $display("Helping you with debug process memory[%d]=%d ", i ,DUT.fifo_i.my_ram.memory[i] );
                end
            end
        end
    end
endtask

/*  Pops value outside the fifo without checking if FIFO READY
    input N : numbers of repetitions, can range from 1 to max integer value.
    input bandwith : duty cycle of the pop_valid_i signal, can range from 1 to 100

*/


task bad_receiver(input integer N,input integer bandwidth);
    begin
        repeat(N)
            begin 
                @(negedge clk_test)
                $display("bad_receiver_CALLED  %d",$time);
                grant_i_test = 1;
                #(HALF_T_CLK+(bandwidth*HALF_T_CLK/100)) grant_i_test = 0;
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
        valid_i_test=0;
        grant_i_test=0;
        data_i_test=0;

        // Async Clear
        ASYNC_CLEAR(2*HALF_T_CLK);
        // TEST 0 : GOOD TRANSMITTER & RECEIVER OVERFLOW/UNDERFLOW
        $display("Starting test 0");
        good_transmitter(0,FIFO_DEPTH+2,20, 0);
        good_receiver(FIFO_DEPTH+2,20);
        // TEST 1 : OVERFLOW
        $display("Starting test 1");
        bad_transmitter(0,FIFO_DEPTH+2,20, 0);
        // TEST 2 : UNDERFLOW
        $display("Starting test 2");
        bad_receiver(FIFO_DEPTH+2,20);
    
        $display("Starting test 3"); 
        // TEST 3 : PARALLEL PUSH POP with corrupt data 50% of the time , Duty cycle of pop & push ==50
        repeat(30)
            begin
                value_ = value_ + 3;
                
                fork
                    begin
                good_transmitter(value_,1,20,0);
                    end
                    begin
                good_receiver(1,20);
                    end
                join
            end
        // TEST 4 :FULL PUSH HALF POP 
        $display("Starting test 4");

        repeat(30)
            begin                   
            fork
                begin 
                    good_transmitter(0,1,100,0);
                end
                begin 
                    good_receiver(1,20);
                end
            join
            end 
        // TEST 5 : 2 PUSH 1 POP
        $display("Starting test 5");
        repeat(30)
            begin   
            value_ = value_ + 2;                
            fork
                begin 
                    bad_transmitter(value_,2,20,0);
                end
                begin 
                    bad_receiver(1,20);
                end
            join
            end
        // TEST 6 : 1 PUSH 2 POP
        $display("Starting test 6");
        repeat(30)
            begin   
            value_ = value_ + 2;                
            fork
                begin 
                    bad_transmitter(value_,1,20,0);
                end
                begin 
                    bad_receiver(2,20);
                end
            join
            end
    end

    // PUSH VERIFICATION
    always
    begin
        @(posedge valid_i_test)
            @(posedge clk_test)
                if (grant_o_test)
                    if (data_i_test % 2 == 0) begin
                        temp_memory[c] = data_i_test;
                        $display("Push successfully %d: temp_memory[%d] == %d", $time , c, temp_memory[c]);
                        c++;
                    end else 
                     $display("Pushed corrupted value, Value is [%d]", data_i_test);
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
        @(posedge grant_i_test)
            @(posedge clk_test)
                if(DUT.fifo_i.pop_valid_o == 1) begin
                    @(cb)
                    assert(temp_memory[j] == data_o_test)
                            $display("Pop successful %d: temp_memory[%d] == %d ", $time, j, temp_memory[j]);
                        else begin
                            $display("Error at time %d: temp_memory[%d] == %d whereas pop_data_o == %d", $time, j, temp_memory[j], data_o_test);
                            end
                            j++;
                    end
                    else if (valid_o_test == ~DUT.fifo_i.pop_valid_o) begin
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


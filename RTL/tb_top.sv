`include "interface.sv"
`include "top.sv"
`include "parity_encoder.sv"
`include "FIFO.sv"
`include "ram.sv"
`include "test.sv" 

module tb_top #(
    parameter DATA_WIDTH = 8, // Self explanatory parameters
    parameter FIFO_DEPTH = 4,
    parameter EVEN_ODD   = 0,
    parameter PARITY_BIT = 0
);
bit rst_n;
bit clk;
localparam integer                  HALF_T_CLK=5;

// CLOCKING

    always 
    begin
        #HALF_T_CLK clk = ~clk;
    end

    default clocking cb @(posedge clk);
    endclocking 



initial begin
	rst_n = 1;
	#5 rst_n = 0;
end


fifo_intf intf(clk,rst_n);

test tb1(intf);


    top
        #(
            .DATA_WIDTH(DATA_WIDTH),
            .FIFO_DEPTH(FIFO_DEPTH),
            .EVEN_ODD(EVEN_ODD),
            .PARITY_BIT(PARITY_BIT)
        )
        DUT
            (

                .clk(intf.clk),
                .rst_n(intf.rst_n),
                .push_data_i(intf.push_data_i),
                .push_valid_i(intf.push_valid_i),
                .push_grant_o(intf.push_grant_o),
                .pop_grant_i(intf.pop_grant_i),
                .pop_data_o(intf.pop_data_o),
                .pop_valid_o(intf.pop_valid_o)
            );





  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end











endmodule : tb_top